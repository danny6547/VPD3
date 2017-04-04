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
           
           
           
       end
       
       function [LowestFOCph, LowestPower, HighestPower] = limitsOfData(obj)
       % limitsOfData 
       
           LowestFOCph = [];
           LowestPower = [];
           HighestPower = [];
           
       end
    end
end