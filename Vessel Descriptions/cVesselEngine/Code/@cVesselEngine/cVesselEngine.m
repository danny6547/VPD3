classdef cVesselEngine < cModelID
    %CVESSELENGINE Ship Engine details and SFOC curve.
    %   Detailed explanation goes here
    
    properties
        
        Engine_Model char = '';
        MCR double = [];
        Power double = [];
        SFOC double = [];
        X0 double = [];
        X1 double = [];
        X2 double = [];
        Minimum_FOC_ph double = [];
        Lowest_Given_Brake_Power double = [];
        Highest_Given_Brake_Power double = [];
        Fuel_Type char = '';
    end
    
    properties(Hidden, Constant)
        
        DBTable = 'EngineModel';
        ModelTable = 'EngineModel';
        ValueTable = {};
        ModelField = {'Engine_Model_Id'};
        DataProperty = {'Engine_Model',...
                        'MCR',...
                        'X0',...
                        'X1',...
                        'X2',...
                        'Minimum_FOC_ph',...
                        'Lowest_Given_Brake_Power',...
                        'Highest_Given_Brake_Power',...
                        'Fuel_Type',...
                        'Name',...
                        'Description',...
                        'Engine_Model_Id', ...
                        'Model_ID', ...
                        'Deleted'};
        ValueObject = {};
        OtherTable = {};
        OtherTableIdentifier = {};
        TableIdentifier = 'Engine_Model_Id';
        NameAlias = 'Engine_Model';
        EmptyIgnore = {'Deleted'};
    end
    
    properties(Hidden, Dependent)
        
        Engine_Model_Id;
    end
    
    methods
    
       function obj = cVesselEngine(varargin)
           
           obj = obj@cModelID(varargin{:});
       end
       
       function obj = fitData2Quadratic(obj, mcr, sfoc, powerPCT)
       % fitData2Quadratic Assign coefficients of quadratic fit of data
       
       for oi = 1:numel(obj)
            
            currObj = obj(oi);
            
            % Get FOC, Power 
            power = currObj.powerFromMCRPCT(powerPCT, mcr);
            FOC = currObj.FOCFromSFOC(sfoc./1e6, power);
            
            % Assign vectors
            currObj.MCR = mcr;
            currObj.Power = power;
            currObj.SFOC = sfoc;
            
            % Assign limits
            obj.limitsOfData;
            
            % Fit Data
            fit_v = polyfit(FOC, power, 2);
            
            % Assign coefficients
            currObj.X0 = fit_v(end);
            currObj.X1 = fit_v(end-1);
            currObj.X2 = fit_v(end-2);
            
       end
       end
       
       function [obj, LowestFOCph, LowestPower, HighestPower] = limitsOfData(obj)
       % limitsOfData Find limits of power, fuel consumption data
       
       numObj = numel(obj);
       LowestFOCph = nan(1, numObj);
       LowestPower = nan(1, numObj);
       HighestPower = nan(1, numObj);
       
       for oi = 1:numObj
           
           if ~isempty(obj(oi).Power)
               currPower = obj(oi).Power;
               LowestPower(oi) = min(currPower);
               HighestPower(oi) = max(currPower);
               obj(oi).Lowest_Given_Brake_Power = min(currPower);
               obj(oi).Highest_Given_Brake_Power = max(currPower);
               
               if ~isempty(obj(oi).SFOC)
                   currFOC = obj(oi).FOCFromSFOC(obj(oi).SFOC, currPower);
                   LowestFOCph(oi) = min(currFOC);
                   obj(oi).Minimum_FOC_ph = min(currFOC) / 1000;
               end
           end
       end
       end
    end
    
    methods(Static)
       
       function powerPCT = powerPercentageMCR(power, MCR)
           
           powerPCT = (power/MCR) .* 100;
       end
       
       function power = powerFromMCRPCT(powerPCT, MCR)
           
           power = powerPCT .* MCR / 100;
       end
       
       function FOC = FOCFromSFOC(SFOC, Power)
           
           FOC = SFOC .* Power;
       end
       
    end

    methods
        
        function eid = get.Engine_Model_Id(obj)

            eid = obj.Model_ID;
        end
        
        function obj = set.Engine_Model_Id(obj, ~)
            
        end
    end
end