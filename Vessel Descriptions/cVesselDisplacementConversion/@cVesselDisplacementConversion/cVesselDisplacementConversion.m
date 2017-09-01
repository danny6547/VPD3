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
       
       function obj = displacementInVolume(obj)
       % displacementInVolume Convert displacement from mass to volume
       
       for oi = 1:numel(obj)
          
           if ~isempty(obj(oi).FluidDensity)
           
               dens = obj(oi).FluidDensity;
           else
               
               dens = obj(oi).DefaultDensity;
           end
           
           obj(oi).Displacement = obj(oi).Displacement * 1E3 / dens;
       end
       end
       
       function obj = displacementInMass(obj)
       
       for oi = 1:numel(obj)
          
           if ~isempty(obj(oi).FluidDensity)
           
               dens = obj(oi).FluidDensity;
           else
               
               dens = obj(oi).DefaultDensity;
           end
           
           obj(oi).Displacement = obj(oi).Displacement * 1E3 * dens;
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
