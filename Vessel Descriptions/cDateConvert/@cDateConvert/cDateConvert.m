classdef cDateConvert < handle
    %CDATECONVERT Convert dates
    %   Detailed explanation goes here
    
    properties
        
        Valid_From;
        Valid_To;
    end
    
%     properties(Dependent)
%         
%         StartDate char = '';
%         EndDate char = '';
%     end
    
    properties(Hidden, Constant)
        
        DateStrFormat char = 'yyyy-mm-dd';
    end
    
    properties(Hidden)
        
        StartDateNum = [];
        EndDateNum = [];
    end
    
    methods
    
       function obj = cDateConvert()
    
       end
    
    end
    
    methods(Hidden, Static)
        
        function newdate = setDate(olddate, stringformat)
            
            % Trim excess whitespace sometimes read from DB
            olddate(olddate == 0) = [];
            newdatenum = datenum(olddate, 'yyyy-mm-dd');
            
            if newdatenum < datenum('1900-01-01', 'yyyy-mm-dd')
                
                newdatenum = datenum(olddate, 'dd-mm-yyyy');
            end

            newdate = datestr(newdatenum, stringformat);
        end
    end
    
    methods
        
        function set.Valid_From(obj, olddate)
            
            stringformat = obj.DateStrFormat;
            newdate = obj.setDate(olddate, stringformat);
            obj.Valid_From = newdate;
        end
        
        function set.Valid_To(obj, olddate)
            
            stringformat = obj.DateStrFormat;
            newdate = obj.setDate(olddate, stringformat);
            obj.Valid_To = newdate;
        end
    end
end