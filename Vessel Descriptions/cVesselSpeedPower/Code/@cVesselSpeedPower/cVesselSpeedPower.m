classdef cVesselSpeedPower < cMySQL & cModelID & matlab.mixin.Copyable & cVesselDisplacementConversion
    %CVESSELSPEEDPOWER Vessel speed and power data
    %   Detailed explanation goes here
    
    properties
        
        Speed double;
        Power double;
        Trim double;
        Displacement double;
%         FluidDensity double;
        Speed_Power_Source char = '';
        Propulsive_Efficiency double = [];
        Coefficient_A double = [];
        Coefficient_B double = [];
        Coefficient_Q double = [];
        R_Squared double = [];
        Maximum_Power = [];
        Minimum_Power = [];
    end
    
    properties(Dependent, Hidden)
        
        SpeedPowerDraftTrim double = [];
    end
    
    properties(Hidden)
        
        Model = 'exponential';
        Draft_Fore = [];
        Draft_Aft = [];
    end
    
    properties(Hidden, Constant)
       
        ModelTable = 'SpeedPowerCoefficientModel';
        ValueTable = {'SpeedPowerCoefficientModelValue', 'speedpower'};
        ModelField = 'Speed_Power_Coefficient_Model_Id';
    end
    
    methods
    
       function obj = cVesselSpeedPower(varargin)
           
           obj = obj@cModelID(varargin{:});
       end
       
       function [obj, coeffs, R2] = fit(obj, varargin)
       % fit Fit data to exponential curve
       
       % Iterate over objects
       numObj = numel(obj);
       R2 = nan(numObj, 1);
       for oi = 1:numObj

            % Inputs
            speed = obj(oi).Speed;
            if nargin > 1

               speed = varargin{1};
               validateattributes(speed, {'numeric'}, {'vector'}, ...
                   'cVesselSpeedPower.fit', 'speed', 2);
            end

            power = obj(oi).Power;
            if nargin > 2

               power = varargin{2};
               validateattributes(power, {'numeric'}, {'vector'}, ...
                   'cVesselSpeedPower.fit', 'power', 3);
            end

            if isempty(speed) || isempty(power)

                errid = 'cVSP:SpeedPowerRequired';
                errmsg = ['Speed and Power must both be given, either through'...
                  ' inputs or in object properties'];
                error(errid, errmsg);
            end
            
            % Fit
            switch obj(oi).Model
                
                case 'exponential'
                    
                    fo = polyfit(log(speed), log(power), 1);
                    residuals = speed - (fo(2) + fo(1).*log(power));
                case 'polynomial2'
                    
                    fo = polyfit(power, speed, 2);
                    residuals = speed - (fo(1)*power.^2 + fo(2)*power + fo(3));  % polyval(fo, power);
            end
            
            % Get statistics of fit
            r2 = 1 - (sum(residuals.^2) / sum((speed - mean(speed)).^2));
            
            % Assign into obj, outputs
            obj(oi).Speed = speed;
            obj(oi).Power = power;
            
            if numel(fo) > 2
                
                obj(oi).Coefficient_A = fo(1);
                obj(oi).Coefficient_B = fo(2);
                obj(oi).Coefficient_Q = fo(3);
            else
                
                obj(oi).Coefficient_A = fo(1);
                obj(oi).Coefficient_B = fo(2);
            end
            obj(oi).R_Squared = 0;
            
            coeffs(oi, 1:numel(fo)) = fo;
            R2(oi) = r2;
       end
       end
       
       function insertModel(obj)
       % insertIntoTable Insert into tables SpeedPower and SpeedPowerCoeffs
       
           obj = obj.fit;
           obj = obj.powerExtents;
           
%            obj.insertModel;
           insertModel@cModelID(obj);
           
%            insertIntoTable@cModelID(obj);
%            
%            % ModelID subclass needs to write model name, description 
%            % because cModelID cannot have those properties
%            for oi = 1:numel(obj)
%                
%                currObj = obj(oi);
%                insertIntoTable@cMySQL(currObj, currObj.ModelTable, [], ...
%                    currObj.ModelField, currObj.Model_ID);
%            end
       end
       
       function [obj, h] = plot(obj)
       % plot
       
       for oi = 1:numel(obj)
           if ~isempty(obj(oi).Speed) && ~isempty(obj(oi).Power)

                figure;
                axes;

                h(1) = plot(obj(oi).Speed, obj(oi).Power, 'b*');
                xlabel('Speed (knots)')
                ylabel('Power (kW)');
                title('Speed against Power data and fit');
                
                if ~isempty(obj(oi).Coefficient_A) && ~isempty(obj(oi).Coefficient_B)
                    
                    y = linspace(min(obj(oi).Power), max(obj(oi).Power), 1e3);
                    coeffs = [obj(oi).Coefficient_A, obj(oi).Coefficient_B];
%                     x = polyval(obj(oi).Coefficients, y);

                    switch obj(oi).Model
                        
                        case 'exponential'
                            
                            x = (y / exp(coeffs(2))).^(1/coeffs(1));
                        otherwise
                        
                    end
                    
                    hold on;
                    plot(x, y, 'r--');
                    legend({'Speed, power data', 'Second-order polynomial fit'});
                    text(0.1, 0.9, ['Displacement = ', ...
                        num2str(obj(oi).Displacement), ', Trim = ', ...
                        num2str(obj(oi).Trim)], 'Units', 'Normalized');
                end
           end
       end
       end
       
       function [obj, indb] = isInDB(obj)
       % isInDB True if speed, power data is in DB
       
       indb = false(size(obj));
       
       for oi = 1:numel(obj)

            % Get vessels speed, power models
            currObj = obj(oi);
            currIMO = currObj.IMO_Vessel_Number;
            tab_ch = 'speedpower';
            cols_c = {'ModelID', 'Speed', 'Power', 'Displacement', 'Trim'};
            where_ch = ['ModelID IN (SELECT Speed_Power_Model FROM '...
                'vesselspeedpowermodel WHERE IMO_Vessel_Number = '...
                num2str(currIMO) ')'];
            [~, tbl] = obj(1).select(tab_ch, cols_c, where_ch);
            
            % Case of no data in table, return false
            if isempty(tbl)
                return
            end
            
            % Compare object to data read from db
            models_v = unique(tbl.modelid);
            numModels = numel(models_v);
            for mi = 1:numModels
                
                % Index into table of models to this model
                currModel = models_v(mi);
                currRows_l = tbl.modelid == currModel;
                currData = table2array(tbl(currRows_l, 2:end));
                indbi = currObj.isequal(currData);
                
                % When a model is found for this object, go to next object
                if indbi
                    
                    indb(oi) = true;
                    break
                end
            end
       end
       end
       
       function log = isequal(obj, spdt)
       % isequal True if object data and array are numerically equal.
       
       log = true;
       
       eqf = @(x, y, tol) (numel(x) == numel(y)) && all(abs(x(:) - y(:)) < tol);
       tolerance = 1e-15;
       
       if ~eqf(obj.Speed, spdt(:, 1), tolerance)
           log = false;
       end
       if ~eqf(obj.Power, spdt(:, 2), tolerance)
           log = false;
       end
       if ~eqf(obj.Displacement, unique(spdt(:, 3)), tolerance)
           log = false;
       end
       if ~eqf(obj.Trim, unique(spdt(:, 4)), tolerance)
           log = false;
       end
       
       end

       function empty = isempty(obj)
           
           
          empty = isempty(obj.speedPowerDraftTrim); 
       end
       
       function obj = print(obj)
       % print Print data into formatted columns
       
       % Fit
       obj.fit();
       
       % Coeffs
       a = arrayfun(@(x) x.Coefficient_A, obj)';
       b = arrayfun(@(x) x.Coefficient_B, obj)';
       
       % Max, min power
       minP = arrayfun(@(x) min(x.Power), obj)';
       maxP = arrayfun(@(x) max(x.Power), obj)';
       
       % Numeric vectors of optional values, with nan where empty
%        r2 = [obj.R_Squared]';
       r2 = arrayfun(@(x) mean(x.R_Squared), obj)';
%        tr = [obj.Trim]';
       tr = arrayfun(@(x) mean(x.Trim), obj)';
       obj = obj.displacementInVolume('Displacement'); 
       diM3 = arrayfun(@(x) mean(x.Displacement), obj)';
       obj = obj.displacementInMass('Displacement'); 
       
       % Concat
       mat = [a, b, r2, minP, maxP, tr, diM3];
       
       % Output
       fprintf(1, '%c\n', '');
       fprintf(1, '%s\t%s\t%s\t  %s\t  %s\t      %s\t%s\n',...
           'Coefficient A', 'Coefficient B', 'R Squared', 'MinPower',...
           'MaxPower', 'Trim', 'Displacement (m^3)');
       fprintf(1, '%11.10f\t%11.10f\t%9f\t%10.3f\t%10.3f\t%10f\t%10.3f\n', mat');
       
       end
    end
    
    methods(Hidden)
       
       function spdt = speedPowerDraftTrim(obj)
          
           % Repeat all to the same size
%            allLengths_c = arrayfun(@(x) length(x.Speed), obj, 'Uni', 0);
%            numRows = sum([allLengths_c{:}]);
           
           empties_c = arrayfun(@(x) [isempty(x.Speed), ...
                        isempty(x.Power),...
                        isempty(x.Displacement),...
                        isempty(x.Trim), ...
                        isempty(x.Propulsive_Efficiency)]', obj, 'Uni', 0);
           
           numCols = sum(any(~[empties_c{:}]'));
           out_c = cell(1, numCols);
           
           currRow = 1;
           for oi = 1:numel(obj)
                
                
%                 currOut_m = nan(numRows, numNonEmptyProps);
                [out_c{:}] = cVessel.repeatInputs({obj(oi).Speed, obj(oi).Power,...
                    obj(oi).Displacement, obj(oi).Trim, obj(oi).Propulsive_Efficiency});
                out_c = cellfun(@(x) x(:), out_c, 'Uni', 0);
%                 currOut_m = [currOut_m; cell2mat(out_c)];'
%                 currMat = cell2mat(out_c);

                % Error can occur when some props not assigned to. Fix with
                % replacing missing values in matrix with nan columns

                currMat = [out_c{:}];
                currNumRows = size(currMat, 1);
                currOut_m(currRow : currRow + currNumRows - 1, :) = currMat;
                currRow = currRow + currNumRows;
            end
            spdt = currOut_m;
       end
       
       function obj = powerExtents(obj)
       % powerExtents Return extents of power values
       
       for oi = 1:numel(obj)
           
           obj(oi).Maximum_Power = max(obj(oi).Power);
           obj(oi).Minimum_Power = min(obj(oi).Power);
       end
       end
    end
    
    methods
        
        function spdt = get.SpeedPowerDraftTrim(obj)
        % 
            
            % Repeat all to the same size, make into matrix
            [speed, power, draft, trim] = cVessel.repeatInputs({obj.Speed,...
                obj.Power, obj.Trim, obj.Displacement});
            spdt = [speed(:), power(:), draft(:), trim(:)];
            
        end
        
        function obj = set.Speed(obj, speed)
        % 
        
        if ~isempty(speed)
            validateattributes(speed, {'numeric'}, {'real', 'vector'});
        end
        
        speed(isnan(speed)) = [];
        if isempty(speed)
           
            errid = 'cVSP:PropertyValueInvalid';
            errmsg = 'Property Speed must have some non-nan values';
            error(errid, errmsg);
        end
        
        power = obj.Power;
        speed = speed(:)';
        power = power(:)';
        if ~isempty(power) && (~isempty(speed) && ~isempty(power))...
                && ~isequal(size(power), size(speed))
            
            errID = 'cSP:SPSizeMismatch';
            errMsg = 'Speed vector length must match that of Power';
            error(errID, errMsg);
        end
        
        if ~isempty(speed)
%             obj = obj.incrementModelID;
        end
        
        obj.Speed = speed;
        end
        
        function obj = set.Power(obj, power)
        % 
        
        if ~isempty(power)
            validateattributes(power, {'numeric'}, {'real', 'vector'});
        end
        
        power(isnan(power)) = [];
        if isempty(power)
           
            errid = 'cVSP:PropertyValueInvalid';
            errmsg = 'Property Power must have some non-nan values';
            error(errid, errmsg);
        end
        
        speed = obj.Speed;
        speed = speed(:)';
        power = power(:)';
        if ~isempty(power) && (~isempty(speed) && ~isempty(power))...
                && ~isequal(size(power), size(speed))
            
            errID = 'cSP:SPSizeMismatch';
            errMsg = 'Power vector length must match that of Speed';
            error(errID, errMsg);
        end
        
        obj.Power = power;
            
        end
        
        function obj = set.Trim(obj, trim)
        % 
        
        if ~isempty(trim)
            validateattributes(trim, {'numeric'}, {'real', 'scalar',...
                'nonnan'});
        end
        
        obj.Trim = trim;
        
        end
        
        function obj = set.Displacement(obj, displacement)
        % 
        
        if ~isempty(displacement)
            validateattributes(displacement, {'numeric'}, {'real', 'scalar',...
                'nonnan'});
        end
        
        obj.Displacement = displacement;
        
        end
        
        function obj = set.Model(obj, model)
        %  
            
            validateattributes(model, {'char'}, {'vector'})
            model = lower(model);
            validModels = {'polynomial2', 'exponential'};
            if ~ismember(model, validModels)
                errid = 'cVSP:InvalidModel';
                errmsg = ['Model ', model, ' is invalid.'];
                error(errid, errmsg);
            end
            
            obj.Model = model;
        end

        function obj = set.Speed_Power_Source(obj, sps)
            
%             if ~isempty(sps)
%                 obj = obj.incrementModelID;
%             end
            
            obj.Speed_Power_Source = sps;
        end
        
        function obj = set.Propulsive_Efficiency(obj, propEff)
            
%             if ~isempty(propEff)
%                 obj = obj.incrementModelID;
%             end
            
            obj.Propulsive_Efficiency = propEff;
        end
        
        function obj = set.Coefficient_A(obj, coeff)
            
            if ~isempty(coeff)
                validateattributes(coeff, {'numeric'}, {'scalar', 'real'});
            end
            
            obj.Coefficient_A = coeff;
        end
        
        function obj = set.Coefficient_B(obj, coeff)
            
            if ~isempty(coeff)
                validateattributes(coeff, {'numeric'}, {'scalar', 'real'});
            end
            
            obj.Coefficient_B = coeff;
        end
        
        function obj = set.Coefficient_Q(obj, coeff)
            
            if ~isempty(coeff)
                validateattributes(coeff, {'numeric'}, {'scalar', 'real'});
            end
            
            obj.Coefficient_Q = coeff;
        end
        
        function obj = set.R_Squared(obj, r2)
            
            obj.R_Squared = r2;
        end
        
        function obj = set.Draft_Fore(obj, d)
            
            if isempty(d)
                
               obj.Draft_Fore = [];
               return
            end
            
            validateattributes(d, {'numeric'}, ...
                {'real', 'scalar', 'positive', 'nonnan'});
            obj.Draft_Fore = d;
        end
        
        function obj = set.Draft_Aft(obj, d)
            
            if isempty(d)
                
               obj.Draft_Aft = [];
               return
            end
            validateattributes(d, {'numeric'}, ...
                {'real', 'scalar', 'positive', 'nonnan'});
            obj.Draft_Aft = d;
        end
    end
end