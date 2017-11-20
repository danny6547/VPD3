function speedpowercoeffs(speed, power, varargin)
%speedpowercoeffs Print speed, power coefficients from vectors
%   speedpowercoeffs(speed, power) will print 

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