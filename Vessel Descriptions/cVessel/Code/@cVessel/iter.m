function [obj, currIter] = iter(obj)
%iter Iterate over each element in object array
%   Detailed explanation goes here

currIter = obj(1).CurrIter;
obj = obj.checkFinishIter(currIter);

nextIter = currIter + 1;
[obj.CurrIter] = deal(nextIter);