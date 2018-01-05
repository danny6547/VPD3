classdef cVesselDisplacement < cMySQL & cModelName & cVesselDisplacementConversion
    %CVESSELDISPLACEMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        Draft_Mean = [];
        Trim = [];
        TPC = [];
        LCF = [];
        Displacement = [];
    end
    
    properties(Hidden, Constant)
        
        DBTable = {'Displacement'}; 
%         FieldName = 'Models_id'; 
        Type = 'Displacement'; 
    end
    
    methods
       
       function obj = cVesselDisplacement()
           
       end
       
       function obj = assignFromTable(obj, tbl)
           
           
       end
       
       function empty = isempty(obj)
           
        empty = false(size(obj));
        for oi = 1:numel(obj)

          if (isempty(obj(oi).Draft_Mean) && ...
                  isempty(obj(oi).Trim) && ...
                  isempty(obj(oi).Displacement)) || ...
                  (isempty(obj(oi).Draft_Mean) && ...
                  isempty(obj(oi).TPC) && ...
                  isempty(obj(oi).LCF) && ...
                  isempty(obj(oi).Displacement))

              empty(oi) = true;
          end
        end
       
        empty = all(empty);
        
       end
       
       function obj = copyFromSpeedPower(obj, sp)
       % copyFromSpeedPower Copy displacement, trim data from speed, power
       
        draft = nan(1, numel(sp));
        trim = nan(1, numel(sp));
        disp = nan(1, numel(sp));
        rho = nan(1, numel(sp));
        
        for ii = 1:numel(sp)
            
            draft(ii) = mean([sp(ii).Draft_Fore, sp(ii).Draft_Aft]);
            trim(ii) = sp(ii).Draft_Fore - sp(ii).Draft_Aft;
            disp(ii) = sp(ii).Displacement;
            rho(ii) = sp(ii).FluidDensity;
        end
        
        obj.Draft_Mean = draft;
        obj.Trim = trim;
        obj.Displacement = disp;
        obj.TPC = [];
        obj.LCF = [];
        if numel(unique(rho)) == 1
            rho = unique(rho);
        end
        obj.FluidDensity = rho;
        
       end
    end
    
    methods(Static)
       
       function [upperDisp, lowerDisp] = validLimits(spDisp, varargin)
       % validLimits Displacement range limits around speed, power value
       
       % Inputs
       validateattributes(spDisp, {'numeric'}, {'positive', ...
           'integer', 'real'}, 'cVesselDisplacement.validLimits', 'spDisp',...
           1);
       
       upperThresh = 1.05;
       if nargin > 1
           
           upperThresh = varargin{1};
           validateattributes(upperThresh, {'numeric'}, {'scalar', ...
               'positive', 'integer', 'real'}, 'spDisp', 1);
       end
       
       lowerThresh = 0.95;
       if nargin > 2
           
           lowerThresh = varargin{2};
           validateattributes(lowerThresh, {'numeric'}, {'scalar', ...
               'positive', 'integer', 'real'}, 'spDisp', 1);
       end
       
       % Standard requires that speed, power displacements are within 5% of
       % the measured displacement
       upperDisp = spDisp.*upperThresh;
       lowerDisp = spDisp.*lowerThresh;
       
       end
    end
    
    methods
       
       function obj = set.Draft_Mean(obj, draft)
       % Ensure vector is of equal length to other properties
           
           validateattributes(draft, {'numeric'}, {'vector', 'positive', 'real'},...
               'cVesselDisplacement.set.Draft_Mean', 'Draft_Mean');
           obj.Draft_Mean = draft;
       end 
    end
end