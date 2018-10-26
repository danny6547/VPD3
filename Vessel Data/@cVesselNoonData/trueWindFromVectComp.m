function [true_wind_speed, true_wind_dir] = trueWindFromVectComp(windu, windv)
%trueWindFromVectComp True wind speed and direction from vector components
%   Detailed explanation goes here
    
    winddir = atan2d(windu, windv);
    winddir_l = winddir < 0;
    winddir(winddir_l) = winddir(winddir_l) + 360;
    true_wind_speed = sqrt(windu.^2 + windv.^2);
    true_wind_dir = winddir;
end