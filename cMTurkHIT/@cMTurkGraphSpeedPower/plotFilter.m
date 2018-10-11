function obj = plotFilter(obj)
%plotFilter Filter data with plot UI
%   Detailed explanation goes here

% Plot, get axis
ax = obj.plot([], true);

% Iterate curves
for ci = 1:obj.NCurve
    
    currObj = obj.CurveObj(ci);
    currObj = plotFilter@cMTurkHIT(currObj, ax);
    obj.CurveObj(ci) = currObj;
end