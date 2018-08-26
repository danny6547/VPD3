classdef cVesselDisplacementConversion < handle
    %CVESSELDISPLACEMENTCONVERSION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        FluidDensity double;
    end
    
    properties(Hidden)
        
        DefaultDensity = 1025;
    end
    
    methods
    
       function obj = cVesselDisplacementConversion()
    
       end
    end
    
    methods(Hidden)
       
       function obj = displacementInVolume(obj, prop)
       % displacementInVolume Convert displacement from mass to volume
       
       prop = validateCellStr(prop);
       numProps = numel(prop);
        for oi = 1:numel(obj)
           for pi = 1:numProps

               currProp = prop{pi};
               disp = [obj(oi).(currProp)];
               
               if ~isempty(obj(oi).FluidDensity)

                   dens = obj(oi).FluidDensity;
               else

                   dens = obj(oi).DefaultDensity;
               end
               disp = disp ./ (dens ./ 1e3);
               obj(oi).(currProp) = disp;
           end
        end
       end
       
       function obj = displacementInMass(obj, prop)
       
       prop = validateCellStr(prop);
       numProps = numel(prop);
       
        for oi = 1:numel(obj)
           for pi = 1:numProps

               currProp = prop{pi};
               disp = [obj(oi).(currProp)];
               if ~isempty(obj(oi).FluidDensity)

                   dens = obj(oi).FluidDensity;
               else

                   dens = obj(oi).DefaultDensity;
               end
               disp = disp .* (dens ./ 1e3);
               obj(oi).(currProp) = disp;
           end
        end
       end
    end
    
    methods
       
       function set.FluidDensity(obj, dens)
           
           validateattributes(dens, {'numeric', 'real', 'positive'},...
               {'scalar'});
           obj.FluidDensity = dens;
       end
    end
end
