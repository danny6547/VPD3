classdef cDateConvert < handle
    %CDATECONVERT Convert dates
    %   Detailed explanation goes here
    
    properties(Abstract, Constant, Hidden)
        
        StartDateProp;
        EndDateProp;
    end
    
%     properties(Dependent)
%         
%         StartDate char = '';
%         EndDate char = '';
%     end
    
    properties
        
        DateStrFormat char = 'yyyy-mm-dd';
    end
    
    properties(Hidden)
        
        StartDateNum = [];
        EndDateNum = [];
    end
    
    methods
    
       function obj = cDateConvert()
    
       end
    
       function obj = assignDates(obj, startdate, enddate, varargin)
           
           for oi = 1:numel(obj)
                
                dateform = obj(oi).DateStrFormat;
                if nargin > 3
                    dateform = varargin{1};
                end

                startProp = obj.StartDateProp;
                endProp = obj.EndDateProp;
                
                % Validate abstracted properties implemented correctly
%                 validateattributes(startProp, 
                
                obj(oi).StartDateNum = obj(oi).setDate(startdate, dateform);
                obj(oi).EndDateNum = obj(oi).setDate(enddate, dateform);
                
                obj(oi).(startProp) = datestr(obj(oi).StartDateNum, obj.DateStrFormat);
                obj(oi).(endProp) = datestr(obj(oi).EndDateNum, obj.DateStrFormat);
           end
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
        
        function set.DateStrFormat(obj, str)
            
            startProp = obj.StartDateProp;
            endProp = obj.EndDateProp;
            
            obj.DateStrFormat = str;
            obj.(startProp) = datestr(obj.StartDateNum, obj.DateStrFormat);
            obj.(endProp) = datestr(obj.EndDateNum, obj.DateStrFormat);
        end
        
%         function obj = get.DateStrFormat(obj)
%             
% %              str = obj.DateStrFormat;
%         end
    end
end