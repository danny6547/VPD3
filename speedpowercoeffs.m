function speedpowercoeffs(speed, power, varargin)
%speedpowercoeffs Print speed, power coefficients from vectors
%   speedpowercoeffs(speed, power) will print the coefficients, maximum and
%   minimum power and R-Squared value of the linear fit of the logarithm of
%   speed to that of power. The units of speed must be metres per second
%   and those of power, kW. SPEED and POWER are numeric vectors of the same
%   length.
%   speedpowercoeffs(speed, power, trim) will do as above but will also
%   print the trim, given by input numeric scalar TRIM, in m.
%   speedpowercoeffs(speed, power, trim, disp) will do as above and print
%   the displacement, given by input numeric scalar DISP in tonnes. The 
%   output will be in m^3.

% Create object and assig
obj = cVesselSpeedPower();
obj.Speed = speed;
obj.Power = power;
if nargin > 2
    
    trim = varargin{1};
    obj.Trim = trim;
end

if nargin > 3
    
    disp = varargin{2};
    obj.Displacement = disp;
end

% Fit
obj.fit;

% Print
obj.print;

end