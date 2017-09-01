classdef cVesselSpeedPower < cMySQL & cModelID & matlab.mixin.Copyable & cVesselDisplacementConversion
    %CVESSELSPEEDPOWER Vessel speed and power data
    %   Detailed explanation goes here
    
    properties
        
%         ModelID double = []; % ModelID of SpeedPower table %
        
%         IMO_Vessel_Number double;
        Speed double;
        Power double;
        Trim double;
        Displacement double;
%         FluidDensity double;
        Speed_Power_Source char = '';
        Propulsive_Efficiency double = [];
        Coefficients double = [];
        R_Squared double = [];
    end
    
    properties(Dependent, Hidden)
        
        SpeedPowerDraftTrim double = [];
    end
    
    properties(Hidden)
       
        Model = 'exponential';
    end
    
    properties(Hidden, Constant)
       
        DBTable = {'speedpowercoefficients', 'speedpower'};
        FieldName = 'ModelID';
        Type = 'Speed, Power';
    end
    
    methods
    
       function obj = cVesselSpeedPower(varargin)
           
           obj = obj@cModelID(varargin{:});
%            if nargin > 0
%                
%               
% %                size_c = num2cell(size(varargin{1}));
% %                obj(size_c{:}) = cVesselSpeedPower();
% %                propValue_c = 
% %                set(obj, varargin{:});
%            end
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
%                     fo = abs(fo);
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
            obj(oi).R_Squared = 0; %r2;
            
%             coeffs = nan(numObj, numel(fo));
            coeffs(oi, 1:numel(fo)) = fo;
            R2(oi) = r2;
       end
       end
       
       function insertIntoTable(obj)
       % insertIntoTable Insert into tables SpeedPower and SpeedPowerCoeffs
       
       % Check that at least one OBJ has data, which can then be fitted,
       % so that the matrix of coefficients can be initialised before loop
       
%        % Filter obj without IMO numbers
%        withIMO_l = ~cellfun(@isempty, {obj.IMO_Vessel_Number});
%        obj2insert = obj(withIMO_l);
%        if isempty(obj2insert)
%            
%            errid = 'cVSP:NoIMO';
%            errmsg = ['OBJ must have an associated IMO_Vessel_Number before '...
%                'inserting into the database.'];
%            error(errid, errmsg);
%        end
%        
%        % Filter obj already in DB
%        [obj, indb] = isInDB(obj);
%        obj = obj(~indb);
%        if isempty(obj)
%            
%            warnid = 'cVSP:AlreadyInDB';
%            warnmsg = 'All speed, power data already in database.';
%            warning(warnid, warnmsg);
%            return
%        end
       
       % Fit
       if isempty(obj(1).Coefficients)
           
           obj(1) = obj(1).fit;
       end
       
       % Generate struct containing coefficients in same structure as table
       numCoeffs = numel(obj(1).Coefficients);
       firstLetters_c = cellstr(char(97:97+numCoeffs-1)');
       coeffNames_c = strcat('Coefficient_', firstLetters_c);
       coeff_c = nan(1, numCoeffs);
       for oi = 1:numel(obj)
           
           % Fit
           if isempty(obj(oi).Coefficients)
               
               obj(oi) = obj(oi).fit;
           end
           
           % Create matrix of coefficients
           for ci = 1:numCoeffs
               
               coeff_c(oi, ci) = obj(oi).Coefficients(ci);
           end
       end
       
       coeff_c = mat2cell(coeff_c, numel(obj), ones(1, numCoeffs));
       nCols = numCoeffs*2;
       coeffInput_c = cell(1, nCols);
       coeffInput_c(1:2:nCols-1) = coeffNames_c;
       coeffInput_c(2:2:nCols) = coeff_c;
       
       % Release the model ID to get rid of any rows containing just the
       % modelID and NULL or default values
       obj.releaseModelID;
       
       % Convert
       obj = obj.displacementInVolume;
       
       % Insert
       insertIntoTable@cMySQL(obj, 'SpeedPower');
       insertIntoTable@cMySQL(obj, 'SpeedPowerCoefficients', [], ...
           coeffInput_c{:});
%        insertIntoTable@cMySQL(obj, ...
%            'vesselspeedpowermodel', [], ...
%            'Speed_Power_Model', [obj.ModelID]);
       obj.insertIntoModels();
       
       % Convert back
       obj = obj.displacementInMass;
       
       end
       
       function obj = readFromTable(obj, varargin)
       % readFromTable 
       
           % Inputs
           
           % Read from speed, power
           obj = readFromTable@cMySQL(obj, 'speedpower', 'ModelID',...
               {'Speed', 'Power'}, varargin{:});
           
           % Read from coefficients
           obj = readFromTable@cMySQL(obj, 'speedpowercoefficients', 'ModelID',...
               {'Displacement', 'Trim'}, varargin{:});
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
       
       function obj = incrementModelID(obj)
       % Lowest value of ModelID not yet in DB table.
       
       
%        % Build SQL
%        maxPlusOne_sql = ['SELECT MAX(ModelID) + 1 FROM '...
%            'speedpowercoefficients'];
%        
%        % Get empty ModelIDs of object array
%        emptyModels_l = arrayfun(@(x) isempty(x.ModelID), obj);
%        
%        % Get new highest value
%        [~, out_c] = obj(1).execute(maxPlusOne_sql);
%        firstModelID = str2double([out_c{:}]);
%        
%        % Account for case where table was empty or column was all null
%        if isnan(firstModelID)
%            firstModelID = 1;
%        end
%        
%        % Increment all empty ModelIDs
%        newModelID_c = num2cell( firstModelID:firstModelID + ...
%            numel(find(emptyModels_l)) - 1 );
%        
%        % Assign
%        [obj(emptyModels_l).ModelID] = deal( newModelID_c{:} );
%        
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
       
       function obj = displacementInVolume(obj)
       % displacementInVolume Convert displacement from mass to volume
       
       for oi = 1:numel(obj)
          
           if ~isempty(obj(oi).FluidDensity)
           
               dens = obj(oi).FluidDensity;
           else
               
               dens = obj(oi).DefaultDensity;
           end
           
           obj(oi).Displacement = obj(oi).Displacement * 1E3 / dens;
       end
       end
       
       function obj = displacementInMass(obj)
       
       for oi = 1:numel(obj)
          
           if ~isempty(obj(oi).FluidDensity)
           
               dens = obj(oi).FluidDensity;
           else
               
               dens = obj(oi).DefaultDensity;
           end
           
           obj(oi).Displacement = obj(oi).Displacement * 1E3 * dens;
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
            obj = obj.incrementModelID;
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
%         
%         function obj = set.ModelID(obj, modelID)
%         % set.ModelID Update values with those from DB
%         
%         % Check integer scalar
%         validateattributes(modelID, {'numeric'}, ...
%             {'scalar', 'integer', 'real'}, ...
%             'cVesselSpeedPower.set.ModelID', 'modelID', 1);
%         
%         % If ModelID already in DB, read data out
%         tab1 = 'speedpowercoefficients';
%         cols1 = {'Coefficient_A', 'Coefficient_B', 'Coefficient_C', ...
%             'Dispalcement', 'Trim', 'R_Sqaured'};
%         
%         tab2 = 'speedpower';
%         cols2 = {'Speed', 'Power', 'Propulsive_Efficiency'};
%         [~, temp] = obj.execute(['SELECT MAX(ModelID) FROM ' tab1]);
%         highestExistingModel = temp{1};
%         
%         % Assign
%         obj.ModelID = modelID;
%         
%         if modelID <= highestExistingModel
%             
%             obj = obj.readFromTable(tab1, 'ModelID', cols1);
%             obj = obj.readFromTable(tab2, 'ModelID', cols2);
%         else
%             
%             obj.Speed = [];
%             obj.Power = [];
%             obj.Trim = [];
%             obj.Displacement = [];
%             obj.Speed_Power_Source = '';
%             obj.Propulsive_Efficiency = [];
%             obj.Coefficients = [];
%             obj.R_Squared = [];
%         end
%         end
%         
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