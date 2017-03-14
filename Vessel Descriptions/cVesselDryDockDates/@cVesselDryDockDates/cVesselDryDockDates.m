classdef cVesselDryDockDates
    %CVESSELDRYDOCKDATES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        IMO_Vessel_Number = [];
        DateStrFormat char = 'yyyy-mm-dd';
        
    end
    
    properties(Dependent)
        
        StartDate char = '';
        EndDate char = '';
        
    end
    
    properties(Hidden)
        
        StartDateNum = [];
        EndDateNum = [];
        
    end
    
    methods
    
       function obj = cVesselDryDockDates()
    
       end
       
        function obj = assignDates(obj, startdate, enddate, varargin)
           
            dateform = obj.DateStrFormat;
            if nargin > 3
                dateform = varargin{1};
            end
            
            obj.StartDateNum = obj.setDate(startdate, dateform);
            obj.EndDateNum = obj.setDate(enddate, dateform);
        end
    end
    
    methods(Hidden, Static)
    
        function datenumeric = setDate(date, stringformat)
            
            if isnumeric(date)
                
                datenumeric = date;
                
            elseif ischar(date) || iscellstr(date)
                
                datenumeric = datenum(date, stringformat);
            end
        end
    end
    
    methods
        
        function date = get.StartDate(obj)
            
            date = datestr(obj.StartDateNum, obj.DateStrFormat);
        end
        
        function date = get.EndDate(obj)
            
            date = datestr(obj.EndDateNum, obj.DateStrFormat);
        end
    end
end