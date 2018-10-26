function [relSpeed, relDir] = relWindFromTrue(trueSpeed, trueDir, sog, head)
%relWindFromTrue Relative wind from true wind
%   Detailed explanation goes here

% Wind Directions are assumed to be "direction from" so negate
trueDir = -(trueDir - 180);

% Wrap angles to [-180, 180]
normalizeDeg=@(x)(-mod(-x+180,360)+180);
head = normalizeDeg(head);
trueDir = normalizeDeg(trueDir);

% Get pointing angle from both angles
diffDeg=@(a,b) ((normalizeDeg(a)-normalizeDeg(b)));
alpha = -diffDeg(head, trueDir);
sign = 1;
if alpha < 0 
    sign = -1;
end

% Speed and dir
relSpeed = sqrt(trueSpeed.^2 + sog.^2 + 2.*trueSpeed.*sog.*cosd(alpha));
relDir = sign*acosd( (trueSpeed.*cosd(alpha) + sog) ./ relSpeed);
relDir = wrap2360(relDir);

    function ang = wrap2360(ang)
        
        ang_l = ang < 0;
        ang(ang_l) = ang(ang_l) + 360;
    end
end