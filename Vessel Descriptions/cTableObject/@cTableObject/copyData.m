function [obj2] = copyData(obj, obj2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Input
validateattributes(obj, {'cTableObject'}, {'scalar'},...
    'cTableObject.copyData', 'obj', 1);

prop_c = obj(1).DataProperty;
    for pi = 1:numel(prop_c)
        
        currProp = prop_c{pi};
        currVal = obj(1).(currProp);
        if ~isempty(currVal)
            obj2.(currProp) = currVal;
        end
    end
end