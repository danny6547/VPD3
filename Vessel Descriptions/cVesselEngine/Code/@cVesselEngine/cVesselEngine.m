classdef cVesselEngine < handle
    %CVESSELENGINE Ship Engine details and SFOC curve.
    %   Detailed explanation goes here
    
    properties
        
        Name char = '';
        MCR double = [];
        Power double = [];
        SFOC double = [];
        X0 double = [];
        X1 double = [];
        X2 double = [];
        MinimumFOC_ph double = [];
        Lowest_Given_Brake_Power double = [];
        Highest_Given_Brake_Power double = [];
        
    end
    
    methods
    
       function obj = cVesselEngine()
           
           
           
       end
       
       function obj = fitData2Quadratic(obj, mcr, sfoc, perCentMcr)
       % 
           
           
       end
       
       function [LowestFOCph, LowestPower, HighestPower] = limitsOfData(obj)
       % limitsOfData Find limits of power, fuel consumption data
       
       numObj = numel(obj);
       LowestFOCph = nan(1, numObj);
       LowestPower = nan(1, numObj);
       HighestPower = nan(1, numObj);
       
       for oi = 1:numObj
           
           if ~isempty(obj(oi).Power) && ~isempty(obj(oi).MCR)
               currPower = (obj(oi).Power/100) .* obj(oi).MCR;
               LowestPower(oi) = min(currPower);
               HighestPower(oi) = max(currPower);
               
               if ~isempty(obj(oi).SFOC)
                   currFOC = obj(oi).SFOC .* currPower;
                   LowestFOCph(oi) = min(currFOC);
               end
           end
       end
       end
    end
end