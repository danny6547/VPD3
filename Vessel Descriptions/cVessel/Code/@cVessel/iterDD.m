function [obj, currIter, firstDDi, secondDDi, DDi] = iterDD(obj)
%iter Iterate over each dry-docking interval in object array
%   Detailed explanation goes here

currentIteration = obj(1).CurrIter;

allI = 1:numel(obj);
szIn = size(obj);
allDDI_m = reshape(allI, szIn);
validDDI_m = allDDI_m(2:end, :);
allDDLinearIndex = validDDI_m(:);
currIter = allDDLinearIndex(currentIteration);
firstDDi = currIter;
secondDDi = currIter - 1;

currentIteration = currentIteration + 1;
[obj.CurrIter] = deal(currentIteration);

obj = obj.checkFinishIter(currIter);

% Get index for DD struct
objsz = size(obj);
objsz(1) = objsz(1) - 1;
DDsz = objsz;

DDdim_c = cell(1, ndims(obj));
[DDdim_c{:}] = ind2sub(size(obj), currIter);
DDdim_c{1} = DDdim_c{1} - 1;

DDi = sub2ind(DDsz, DDdim_c{:});