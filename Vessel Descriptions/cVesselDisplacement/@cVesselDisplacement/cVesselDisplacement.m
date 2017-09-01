classdef cVesselDisplacement < cMySQL & cModelID & cVesselDisplacementConversion
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
        FieldName = 'ModelID'; 
        Type = 'Displacement'; 
    end
    
    methods
       
       function obj = cVesselDisplacement()
           
       end
       
       function obj = assignFromTable(obj, tbl)
           
           
       end
       
       function empty = isempty(obj)
           
        empty = true(size(obj));
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