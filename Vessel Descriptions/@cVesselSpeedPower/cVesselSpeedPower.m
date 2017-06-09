classdef cVesselSpeedPower < cMySQL
    %CVESSELSPEEDPOWER Vessel speed and power data
    %   Detailed explanation goes here
    
    properties
        
        ModelID double = []; % ModelID of SpeedPower table %
        
        IMO_Vessel_Number double;
        Speed double;
        Power double;
        Trim double;
        Displacement double;
        Speed_Power_Source char = '';
        Propulsive_Efficiency double = [];
        Coefficients double = [];
        R_Squared double = [];
    end
    
    properties(Dependent, Hidden)
        
       SpeedPowerDraftTrim double = [];
    end
    
    properties(Hidden)
       
       Model = 'polynomial2';
    end
    
    methods
    
       function obj = cVesselSpeedPower(varargin)
           
           if nargin > 0
              
%                size_c = num2cell(size(varargin{1}));
%                obj(size_c{:}) = cVesselSpeedPower();
%                propValue_c = 
%                set(obj, varargin{:});
           end
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
                    
                    fo = polyfit(log(power), speed, 1);
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
            obj(oi).Coefficients = fo;
%             obj(oi).Exponent_B = fo(2);
%             
%             if numel(fo) > 2
%                 
%                 obj(oi).Exponent_C = fo(3);
%             end
            obj(oi).R_Squared = r2;
            
%             coeffs = nan(numObj, numel(fo));
            coeffs(oi, 1:numel(fo)) = fo;
            R2(oi) = r2;
       end
       end
       
       function insertIntoTable(obj)
       % insertIntoTable Insert into tables SpeedPower and SpeedPowerCoeffs
       
       % Generate struct containing coefficients in same structure as table
       coeffNames_c = {'Coefficient_A', 'Coefficient_B', 'Coefficient_C'};
       coeff_c = nan(1, 3);
       for oi = 1:numel(obj)
           
           % Fit
           if isempty(obj(oi).Coefficients)
               obj(oi) = obj(oi).fit;
           end
       
           % Create matrix of coefficients
           if numel(obj(oi).Coefficients) > 0
            coeff_c(oi, 1) = obj(oi).Coefficients(1);
           end
           if numel(obj(oi).Coefficients) > 1
            coeff_c(oi, 2) = obj(oi).Coefficients(2);
           end
           if numel(obj(oi).Coefficients) > 2
            coeff_c(oi, 3) = obj(oi).Coefficients(3);
           end
       end
       coeff_c = mat2cell(coeff_c, numel(obj), [1, 1, 1]);
       coeffInput_c = cell(1, 6);
       coeffInput_c(1:2:5) = coeffNames_c;
       coeffInput_c(2:2:6) = coeff_c;
       
       % Insert
       insertIntoTable@cMySQL(obj, 'SpeedPower');
       insertIntoTable@cMySQL(obj, 'SpeedPowerCoefficients', [], ...
           coeffInput_c{:});
       
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
                
                if ~isempty(obj(oi).Coefficients)
                    
                    y = linspace(min(obj(oi).Power), max(obj(oi).Power), 1e3);
                    x = polyval(obj(oi).Coefficients, y);
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
       
       function obj = incrementModelID(obj)
       % Lowest value of ModelID not yet in DB table.
       
       % Build SQL
       maxPlusOne_sql = ['SELECT MAX(ModelID) + 1 FROM '...
           'speedpowercoefficients'];
       
       % Get empty ModelIDs of object array
       emptyModels_l = arrayfun(@(x) isempty(x.ModelID), obj);
       
       % Get new highest value
       [~, out_c] = obj(1).execute(maxPlusOne_sql);
       firstModelID = str2double([out_c{:}]);
       
       % Account for case where table was empty or column was all null
       if isnan(firstModelID)
           firstModelID = 1;
       end
       
       % Increment all empty ModelIDs
       newModelID_c = num2cell( firstModelID:firstModelID + ...
           numel(find(emptyModels_l)) - 1 );
       
       % Assign
       [obj(emptyModels_l).ModelID] = deal( newModelID_c{:} );
       
       end
    end
    
    methods(Hidden)
       
       function spdt = speedPowerDraftTrim(obj)
          
           % Repeat all to the same size
           allLengths_c = arrayfun(@(x) length(x.Speed), obj, 'Uni', 0);
           numRows = sum([allLengths_c{:}]);
           
           out_c = cell(1, 5);
           currOut_m = nan(numRows, 5);
           currRow = 1;
            
            for oi = 1:numel(obj)
                [out_c{:}] = cVessel.repeatInputs({obj(oi).Speed, obj(oi).Power,...
                    obj(oi).Displacement, obj(oi).Trim, obj(oi).Propulsive_Efficiency});
                out_c = cellfun(@(x) x(:), out_c, 'Uni', 0);
%                 currOut_m = [currOut_m; cell2mat(out_c)];'
%                 currMat = cell2mat(out_c);
                currMat = [out_c{:}];
                currNumRows = size(currMat, 1);
                currOut_m(currRow : currRow + currNumRows - 1, :) = currMat;
                currRow = currRow + currNumRows;
            end
            spdt = currOut_m;
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
            validateattributes(speed, {'numeric'}, {'real', 'vector',...
                'nonnan'});
        end
        
        power = obj.Power;
        if ~isempty(power) && (~isempty(speed) && ~isempty(power))...
                && ~isequal(size(power), size(speed))
            
            errID = 'cSP:SPSizeMismatch';
            errMsg = 'Speed vector length must match that of Power';
            error(errID, errMsg);
        end
        
        if ~isempty(speed)
            obj = obj.incrementModelID;
        end
        
        obj.Speed = speed;
        end
        
        function obj = set.Power(obj, power)
        % 
        
        if ~isempty(power)
            validateattributes(power, {'numeric'}, {'real', 'vector',...
                'nonnan'});
        end
        
        speed = obj.Speed;
        if ~isempty(power) && (~isempty(speed) && ~isempty(power))...
                && ~isequal(size(power), size(speed))
            
            errID = 'cSP:SPSizeMismatch';
            errMsg = 'Power vector length must match that of Speed';
            error(errID, errMsg);
        end
        
        if ~isempty(power)
            obj = obj.incrementModelID;
        end
        obj.Power = power;
            
        end
        
        function obj = set.Trim(obj, trim)
        % 
        
        if ~isempty(trim)
            validateattributes(trim, {'numeric'}, {'real', 'scalar',...
                'nonnan'});
        end
%         obj.Trim = trim;
            
        if ~isempty(trim)
            obj = obj.incrementModelID;
        end
        obj.Trim = trim;
        
        end
        
        function obj = set.Displacement(obj, displacement)
        % 
        
        if ~isempty(displacement)
            validateattributes(displacement, {'numeric'}, {'real', 'scalar',...
                'nonnan'});
        end
        
        if ~isempty(displacement)
            obj = obj.incrementModelID;
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
        
        function obj = set.ModelID(obj, modelID)
        % set.ModelID Update values with those from DB
        
        % Check integer scalar
        validateattributes(modelID, {'numeric'}, ...
            {'scalar', 'integer', 'real'}, ...
            'cVesselSpeedPower.set.ModelID', 'modelID', 1);
        
        % If ModelID already in DB, read data out
        tab1 = 'speedpowercoefficients';
        cols1 = {'Coefficient_A', 'Coefficient_B', 'Coefficient_C', ...
            'Dispalcement', 'Trim', 'R_Sqaured'};
        
        tab2 = 'speedpower';
        cols2 = {'Speed', 'Power', 'Propulsive_Efficiency'};
        [~, temp] = obj.execute(['SELECT MAX(ModelID) FROM ' tab1]);
        highestExistingModel = temp{1};
        
        % Assign
        obj.ModelID = modelID;
        
        if modelID <= highestExistingModel
            
            obj = obj.readFromTable(tab1, 'ModelID', cols1);
            obj = obj.readFromTable(tab2, 'ModelID', cols2);
        else
            
            obj.Speed = [];
            obj.Power = [];
            obj.Trim = [];
            obj.Displacement = [];
            obj.Speed_Power_Source = '';
            obj.Propulsive_Efficiency = [];
            obj.Coefficients = [];
            obj.R_Squared = [];
        end
        end
        
        function obj = set.Speed_Power_Source(obj, sps)
            
            if ~isempty(sps)
                obj = obj.incrementModelID;
            end
            
            obj.Speed_Power_Source = sps;

        end
        
        function obj = set.Propulsive_Efficiency(obj, propEff)
            
            if ~isempty(propEff)
                obj = obj.incrementModelID;
            end
            
            obj.Propulsive_Efficiency = propEff;
        end
        
        function obj = set.Coefficients(obj, coeff)
            
            
            if strcmp(obj.Model, 'polynomial2')
                
                nVals = 3;
                
            elseif strcmp(obj.Model, 'exponential')
                
                nVals = 2;
            end
            
            if ~isempty(coeff)
                validateattributes(coeff, {'numeric'}, ...
                    {'vector', 'real', 'numel', nVals});
                obj = obj.incrementModelID;
            end
            
            obj.Coefficients = coeff;
        end
        
        function obj = set.R_Squared(obj, r2)
            
            if ~isempty(r2)
                obj = obj.incrementModelID;
            end

            obj.R_Squared = r2;
        end
    end
end