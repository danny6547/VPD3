classdef cVesselSpeedPower
    %CVESSELSPEEDPOWER Vessel speed and power data
    %   Detailed explanation goes here
    
    properties
        
        Speed double;
        Power double;
        Trim double;
        Displacement double;
        Speed_Power_Source char = '';
        SpeedPowerCoefficients double = [];
        SpeedPowerRSquared double = [];
        
    end
    
    methods
    
       function obj = cVesselSpeedPower()
    
       end
    
    end
    
end
