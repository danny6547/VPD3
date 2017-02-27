function [ obj ] = checkFinishIter( obj, currIter )
%finishIter Finish iteration
%   Detailed explanation goes here

if currIter >= numel(obj)
    [obj.IterFinished] = deal(true);
end

end

