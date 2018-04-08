classdef cVesselDisplacement < cMySQL & cModelID & cVesselDisplacementConversion
    %CVESSELDISPLACEMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
%         Name = '';
%         Description = '';
        Displacement = [];
        Draft_Mean = [];
        Trim = [];
        TPC = [];
        LCF = [];
    end
    
    properties(Hidden, Constant)
        
        ModelTable = 'DisplacementModel';
        ValueTable = {'DisplacementModelvalue'};
        ModelField = 'Displacement_Model_Id';
    end
    
    methods
       
       function obj = cVesselDisplacement(varargin)
           
           obj = obj@cModelID(varargin{:});
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
       
       function obj = displacementInMass(obj)
       % displacementInMass Covert displacement units to those of mass
           
           obj = displacementInMass@cVesselDisplacementConversion(obj, 'Displacement');
%            newDisp_c = num2cell(newDisp_v);
%            [obj.Displacement] = deal(newDisp_c{:});
       end
       
       function obj = displacementInVolume(obj)
       % displacementInMass Covert displacement units to those of mass
           
           obj = displacementInVolume@cVesselDisplacementConversion(obj, 'Displacement');
%            newDisp_c = num2cell(newDisp_v);
%            [obj.Displacement] = deal(newDisp_c{:});
       end
       
%        function insertIntoTable(obj)
%        % insertIntoTable Insert into tables SpeedPower and SpeedPowerCoeffs
%            
%            insertIntoTable@cModelID(obj);
%            
%            % ModelID subclass needs to write model name, description 
%            % because cModelID cannot have those properties
%            for oi = 1:numel(obj)
%                
%                currObj = obj(oi);
%                insertIntoTable@cMySQL(currObj, currObj.ModelTable, [], ...
%                    currObj.ModelField, currObj.Model_ID);
%            end
%        end
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