function [obj] = deleteData(obj, varargin)
%deleteData Delete object property data and, optionally, nested objects
%   Detailed explanation goes here

% Input
validateattributes(obj, {'cTableObject'}, {'scalar'},...
    'cTableObject.copyData', 'obj', 1);

% Generate cell of all OBJ
obj_c = num2cell(obj);
if nargin > 1 && ~isempty(varargin{1})
    
    obj_c = varargin{1};
    validateattributes(obj_c, {'cell'}, {'vector'}, ...
        'cTableObject.deleteData', 'otherObj', 2);
end

prop2skip = {};
if nargin > 2 && ~isempty(varargin{2})
    
    prop2skip = varargin{2};
    validateCellStr(prop2skip, 'cTableObject.deleteData', 'prop2skip', 3);
end

% % Generate cell of all OBJ
% obj_c = num2cell(obj);
% obj_c = [obj_c(:)', otherObj(:)'];

for oi = 1:numel(obj_c)
    
    currObj = obj_c{oi};
    prop_c = setdiff(currObj.DataProperty, prop2skip);
    
    mc = eval(['?', class(currObj)]);
    allProps_p = mc.PropertyList;
    allPropsName_c = {allProps_p.Name};
    [~, propLookup_i] = ismember(prop_c, allPropsName_c);
    
    for pi = 1:numel(prop_c)

        currProp = prop_c{pi};
        currVal = currObj.(currProp);
        currPropInfo_p = allProps_p(propLookup_i(pi));
        
        % Reset to default value
        if currPropInfo_p.HasDefault
            
            newVal = currPropInfo_p.DefaultValue;
        else
            
            newVal = [];
        end
        
        % Delete property data
        if ~isempty(currVal)
            currObj.(currProp) = newVal;
        end
    end
end