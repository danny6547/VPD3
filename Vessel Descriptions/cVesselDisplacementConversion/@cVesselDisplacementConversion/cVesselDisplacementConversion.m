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
       
       function disp = displacementInVolume(obj)
       % displacementInVolume Convert displacement from mass to volume
       
       dens = nan(size(obj));
       disp_c = {obj.Displacement};
       disp_c(cellfun(@isempty, disp_c)) = {nan};
       disp = [disp_c{:}];
       
       for oi = 1:numel(obj)
           if ~isempty(obj(oi).FluidDensity)
               
               dens(oi) = obj(oi).FluidDensity;
           else
               
               dens(oi) = obj(oi).DefaultDensity;
           end
       end
       
           disp = disp ./ (dens ./ 1e3);
       end
       
       function disp = displacementInMass(obj)
       
       dens = nan(size(obj));
       disp = [obj.Displacement];
       for oi = 1:numel(obj)
           if ~isempty(obj(oi).FluidDensity)
           
               dens(oi) = obj(oi).FluidDensity;
           else
               
               dens(oi) = obj(oi).DefaultDensity;
           end
       end
       
           disp = disp .* (dens ./ 1e3);
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
