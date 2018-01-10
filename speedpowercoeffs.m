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

% Input
validateattributes(speed, {'numeric'}, {'positive', 'real', 'nonempty'});
validateattributes(power, {'numeric'}, {'positive', 'real', 'nonempty'});

if (~isvector(speed) || ~isvector(power)) && (~isequal(size(speed), size(power)))
    
    errid = 'sp:SpeedPowerSizeMismatch';
    errmsg = 'If speed and power are matrices, they must be the same size';
    error(errid, errmsg);
end

% Pre-allocate
nCurves = size(speed, 1);
obj = cVesselSpeedPower([1, nCurves]);

for ci = 1:nCurves

    % Create object and assig
    obj(ci).Speed = speed(ci, :);
    obj(ci).Power = power(ci, :);
    if nargin > 2

        trim = varargin{1};
        validateattributes(trim, {'numeric'}, {'real', 'vector', 'nonempty'});
        obj(ci).Trim = trim((ci));
    end

    if nargin > 3

        disp = varargin{2};
        validateattributes(disp, {'numeric'}, {'real', 'vector', 'nonempty'});
        obj(ci).Displacement = disp((ci));
    end

    % Fit
    obj(ci).fit;
end
% Print
obj.print;

end