function [obj, currIter, vesselI] = iterVessel(obj)
%iterVessel Iterate over each vessel for each in object array
%   Detailed explanation goes here

currIter = obj(1).CurrIter;

szIn = size(obj);
nDDi = szIn(1);
vesselI = currIter:currIter + nDDi - 1;
nextIter = currIter + nDDi;

[obj.CurrIter] = deal(nextIter);

% obj = obj.checkFinishIter(nextIter);
obj = obj.checkFinishIter(currIter);