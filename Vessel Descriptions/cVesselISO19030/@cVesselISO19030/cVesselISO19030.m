classdef cVesselISO19030 < cVesselAnalysis & cConnectSQLDB
    %CVESSELISO19030 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        VesselConfiguration;
        Procedure;
    end
    
    properties(Hidden)
        
        SQL;
    end
    
    methods
    
       function obj = cVesselISO19030(varargin)
           
           obj = obj@cConnectSQLDB(varargin{:});
           
           proc = procedureDefault(obj);
           proc = obj.wrapSQLCall(proc);
           obj.Procedure = proc;
       end
    end
    
    methods(Hidden)
       
       proc = wrapSQLCall(obj, proc);
       proc = procedureDefault(obj);
    end
    
    methods 
        
        function obj = set.Procedure(obj, proc)
            
           proc = obj.wrapSQLCall(proc);
           obj.Procedure = proc;
        end
        
        function obj = set.VesselConfiguration(obj, vc)
            
           % Input
           
           % Assign
%            obj.Vessel_Configuration_Id = num2str(vcid);
           obj.VesselConfiguration = vc;
           
           % Update procedure calls with new config id
           if isempty(obj.Procedure)
               
               proc = obj.procedureDefault();
               obj.Procedure = proc;
           end
        end
    end
end