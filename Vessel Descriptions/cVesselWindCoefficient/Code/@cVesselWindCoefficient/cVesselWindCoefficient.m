classdef cVesselWindCoefficient < cMySQL & cModelID
    %CVESSELWINDCOEFFICIENT Wind resistance coefficents for ships.
    %   Detailed explanation goes here
    
    properties
        
        Direction double = [];
        Coefficient double = [];
        Wind_Reference_Height_Design = [];
%         ModelID = [];
%         Name char = '';
    end
    
    properties(Hidden)
        
%         DBTable = '';
    end
    
    properties(Hidden, Constant)
        
        DBTable = {'windcoefficientdirection'};
        FieldName = 'ModelID';
        Type = 'Wind';
    end
    
    methods
    
       function obj = cVesselWindCoefficient(varargin)
           
           obj = obj@cModelID(varargin{:});
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
       
       function empty = isempty(obj)
       % isempty True for empty object data.
       
           empty = true(size(obj));
           for oi = 1:numel(obj)
               if ~isempty(obj(oi).Direction)
                   empty(oi) = false;
               end
               if ~isempty(obj(oi).Coefficient)
                   empty(oi) = false;
               end
               if ~isempty(obj(oi).Wind_Reference_Height_Design)
                   empty(oi) = false;
               end
               if ~isempty(obj(oi).Name)
                   empty(oi) = false;
               end
           end
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
        
%         function obj = set.ModelID(obj, modelID)
%         % set.ModelID Update values with those from DB
%         
%         % Check integer scalar
%         validateattributes(modelID, {'numeric'}, ...
%             {'scalar', 'integer', 'real'}, ...
%             'cVesselWindCoefficient.set.ModelID', 'modelID', 1);
%         
%         % If ModelID already in DB, read data out
%         tab = 'windcoefficientdirection';
%         cols = {'Direction', 'Coefficient', 'Name'};
%         [~, temp] = obj.execute(['SELECT MAX(ModelID) AS `A` FROM ' tab]);
%         highestExistingModel = temp{1};
%         
%         % Assign
%         obj.ModelID = modelID;
%         
%         if modelID <= highestExistingModel
%             
%             obj = obj.readFromTable(tab, 'ModelID', cols);
%         else
%             
%             obj.Direction = [];
%             obj.Coefficient = [];
%             obj.Name = [];
%         end
%         end
        
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
        
%         function obj = set.Name(obj, name)
%         % Set method for property 'Name'
%         
%         if iscellstr(name) && numel(unique(name)) == 1
%             name = name{1};
%         end
%         
%         % Input
%         validateattributes(name, {'char'}, {});
%         
%         % If string is white space, let's make it empty
%         if ~any(name)
%             name = '';
%         end
%         
%         obj.Name = name;
%             
%         end
    end
end