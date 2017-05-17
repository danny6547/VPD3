classdef cVesselWindCoefficient < cMySQL
    %CVESSELWINDCOEFFICIENT Wind resistance coefficents for ships.
    %   Detailed explanation goes here
    
    properties
        
        Direction double = [];
        Coefficient double = [];
        Wind_Reference_Height_Design = [];
        ModelID = [];
        Name char = '';
        
    end
    
    methods
    
       function obj = cVesselWindCoefficient()
           
           
       end
       
       function prop = properties(obj)
           
           prop = {
                    'Direction'
                    'Coefficient'
                    'ModelID'
                    'Name'
%                     'Server'
%                     'Database'
%                     'UserID'
%                     'Password'
%                     'Connection'
                                };
       end
       
       function out = disp(obj)
       % disp Display selected properties only
           
           props = properties(obj);
           numObj = numel(obj);
%            out = repmat(struct(), size(obj));
           for oi = 1:numObj
               
               currPropNameVal = cell(numel(props), 2);
               for pi = 1:numel(props)
                   
                   currPropName = props{pi};
                   currPropVal = obj(oi).(currPropName);
                   currPropNameVal{pi, 1} = currPropName;
                   currPropNameVal{pi, 2} = currPropVal;
               end
               
               currPropNameVal = currPropNameVal';
               out(oi) = struct(currPropNameVal{:});
           end
           
           disp(out);
       end
%        
%        function obj = binCentres(directions, coeffs, binWidths)
%        % binCentres Accept bin centres from bin edges
%        
%         validateattributes(directions, {'numeric'}, {'vector'},...
%            'binCentres', 'directions', 1);
%         validateattributes(coeffs, {'numeric'}, {'vector'},...
%            'binCentres', 'coeffs', 2);
%        validateattributes(binWidths, {'numeric'}, {'vector'},...
%            'binCentres', 'binWidths', 3);
%        
%        % Expand scalar binwidths to vector
%        if isscalar(binWidths
%         binWidths = repmat(binWidths, size(directions));
% 
%         % Sort Directions
%         [directions, di] = sort(directions, 'asc');
%         coeffs = coeffs(di);
% 
%         % Shift to between 0 and 360
%         shift360_f = @(x) x - 360;
%         shift0_f = @(x) 360 + x;
% 
%         directions(directions>360) = shift360_f(directions(directions>360));
%         directions(directions<0) = shift0_f(directions(directions<0));
% 
%         % Get binwidths
% %         binWidths = [diff(directions(1:end)), ...
% %            360 - directions(end) + directions(1)];
% 
%        % Error if vector and number of widths not number of centres
% 
%        % Error if overlapping bins
%        
%         
%         % Get start and finish directions
%         startDirections = directions - binWidths/2;
%         endDirections = directions + binWidths/2;
%         
%         % Shift to between 0 and 360
%         startDirections(startDirections>360) = shift360_f(startDirections(startDirections>360));
%         startDirections(startDirections<0) = shift0_f(startDirections(startDirections<0));
%         endDirections(endDirections>360) = shift360_f(endDirections(endDirections>360));
%         endDirections(endDirections<0) = shift0_f(endDirections(endDirections<0));
%         
%         % Split any bin crossing 360
%         
%         % Assign
%         
%         
%        end
%         
%     
%        end
%     
       function obj = mirrorAlong180(obj)


           % Error if empty, values above 180
           dir1 = obj.Direction;
           if any(dir1 > 180)
               
              errid = 'cVWC:ValuesExceed180';
              errmsg = 'Direction values cannot exceed 180 degrees';
              error(errid, errmsg);
           end

           % Ensure that data lies between 0 and 180
           dir1 = cVesselWindCoefficient.shiftBetween0And360(dir1);
           
           % Extend to other side of the symmetry plane by taking from 360
           dir2 = 360 - dir1;
           includes180 = ismember(180, dir1);
           includes0 = ismember(0, dir1);
           coeffs = obj.Coefficient;
           coeffs2 = coeffs;
           
           startIndex = length(dir2);
           if includes180
               startIndex = length(dir2) - 1;
           end
           
           finalIndex = 1;
           if includes0
               finalIndex = 2;
           end
           
           obj.Direction = [dir1, dir2(startIndex:-1:finalIndex)];
           obj.Coefficient = [coeffs, coeffs2(startIndex:-1:finalIndex)];
           
       end
       
       function [obj, plotHandles] = plot(obj)
          
           plotHandles = plot(obj.Direction, obj.Coefficient);
           
       end
       
       function obj = incrementModelID(obj)
       % Lowest value of ModelID not yet in DB table.
       
       % Build SQL
       maxPlusOne_sql = ['SELECT MAX(ModelID) + 1 FROM '...
           'windcoefficientdirection'];
       
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

    methods(Static)
        
        function angle = shiftBelow360(angle)
            
            angle = angle - 360;
        end
        
        function angle = shiftAbove0(angle)
            
            angle = 360 + angle;
        end
        
        function angle = shiftBetween0And360(angle)
            
            angle = cVesselWindCoefficient.shiftBelow360(angle);
            angle = cVesselWindCoefficient.shiftAbove0(angle);
        end
    end
    
    methods
        
        function obj = set.ModelID(obj, modelID)
        % set.ModelID Update values with those from DB
        
        % Check integer scalar
        validateattributes(modelID, {'numeric'}, ...
            {'scalar', 'integer', 'real'}, ...
            'cVesselWindCoefficient.set.ModelID', 'modelID', 1);
        
        % Read from database all Dirs, Coefficients for model
%         if isempty(obj.Direction) && isempty(obj.Coefficient)
%             msql = cMySQL();
            where_ch = ['ModelID = ' num2str(modelID)];
            tab = 'windcoefficientdirection';
            cols = {'Direction', 'Coefficient', 'Name'};
            [~, tabl] = obj.select(tab, cols, where_ch);
            
            % Error if model ID not found
            if isempty(tabl)
%                 && ~isempty(obj.Direction) && ...
%                     ~isempty(obj.Coefficient)
                if ~isempty(obj.Direction)
                    obj.Direction = [];
                end
                if ~isempty(obj.Coefficient)
                    obj.Coefficient = [];
                end
                if ~isempty(obj.Name)
                    obj.Name = '';
                end
%                errid = 'setWindCoeffModel:ModelMissing';
%                errmsg = ['Wind model identifier ', num2str(modelID)...
%                    ' not found in database'];
%                error(errid, errmsg);
                
            else
                obj.Direction = tabl.direction;
                obj.Coefficient = tabl.coefficient;
                obj.Name = tabl.name(1);
            end

%         end
        
        obj.ModelID = modelID;
            
        end
        
        function obj = set.Direction(obj, dir)
            
            if ~isempty(dir)
                obj = obj.incrementModelID;
            end
            obj.Direction = dir(:)';
            
        end
        
        function obj = set.Coefficient(obj, coeff)
            
            if ~isempty(coeff)
                obj = obj.incrementModelID;
            end
            obj.Coefficient = coeff(:)';
        end
        
    end
    
end
