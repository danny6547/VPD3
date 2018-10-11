function speed = linspaceSpeedOrdinate(obj, ax)
%linspaceSpeedOrdinate Linearly spaced vector of speed in units of pixels
%   Detailed explanation goes here

speedLim = xlim(ax);
nLines = obj.NumRows;
speed = ceil(linspace(speedLim(1), speedLim(2), nLines));
speed(speed>speedLim(2)) = floor(speedLim(2));
end