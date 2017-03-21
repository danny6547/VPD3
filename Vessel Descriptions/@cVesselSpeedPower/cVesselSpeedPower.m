classdef cVesselSpeedPower < handle
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
    
    properties(Dependent, Hidden)
        
       SpeedPowerDraftTrim double = []; 
        
    end
    
    methods
    
       function obj = cVesselSpeedPower()
            
       end
       
    end
    
    methods
        
        function spdt = get.SpeedPowerDraftTrim(obj)
        % 
            
            % Repeat all to the same size
            out_c = cell(1, 4);
            currOut_m = nan(1, 4);
            
            for oi = 1:numel(obj)
                [out_c{:}] = cVessel.repeatInputs({obj(oi).Speed, obj(oi).Power,...
                    obj(oi).Trim, obj(oi).Displacement});
                out_c = cellfun(@(x) x(:), out_c, 'Uni', 0);
                currOut_m = [currOut_m; cell2mat(out_c)];
            end
            spdt = currOut_m;
            
        end
        
        function set.Speed(obj, speed)
        % 
        
        if ~isempty(speed)
            validateattributes(speed, {'numeric'}, {'real', 'vector',...
                'nonnan'});
        end
        obj.Speed = speed;
            
        end
        
        function set.Power(obj, power)
        % 
        
        if ~isempty(power)
            validateattributes(power, {'numeric'}, {'real', 'vector',...
                'nonnan'});
        end
        obj.Power = power;
            
        end
        
        function set.Trim(obj, trim)
        % 
        
        if ~isempty(trim)
            validateattributes(trim, {'numeric'}, {'real', 'scalar',...
                'nonnan'});
        end
        obj.Trim = trim;
            
        end
        
        function set.Displacement(obj, displacement)
        % 
        
        if ~isempty(displacement)
            validateattributes(displacement, {'numeric'}, {'real', 'scalar',...
                'nonnan'});
        end
        obj.Displacement = displacement;
            
        end
        
    end
end
