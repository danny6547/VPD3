classdef cVesselInService < cTableObject
    %CVESSELINSERVICE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        Limit = 20000;
        Data = timetable();
        DateFormStr;
        Variable;
    end
    
    properties(Hidden, Constant)
        
        DataProperty = {'Data'};
        TableIdentifier = '';
        EmptyIgnore = '';
    end
    
    methods
           
       function obj = cVesselInService(varargin)
           
           obj = obj@cTableObject(varargin{:});
       end
       
       function obj = insert(obj)
           
       end
    end
    
    methods(Static)
        
        params = tableParameters(dbname)
    end
    
    methods
        
        function obj = set.Data(obj, ins)
            
            if isempty(ins)
                
                ins = timetable();
                obj.Data = ins;
                return
            end
            
            if isa(ins, 'table')
                
                % Find time column
                varNames_c = ins.Properties.VariableNames';
                timeNames_c = {'datetime_utc', 'timestamp', 'start'};
                time_l = ismember(varNames_c, timeNames_c);
                
                % If all timestamps are midnight, times are omitted
                length_v = cellfun(@length, ins{:, time_l});
                dateformstr = obj.DateFormStr;
                if all(length_v == 10)
                    
                    dateformstr = obj.DateFormStr(1:10);
                end
                
                % Change name to timestamp
                ins.Properties.VariableNames{time_l} = 'timestamp';
                
                ins.timestamp = datetime(ins{:, time_l},'InputFormat',...
                    dateformstr);
                
%                 ins.timestamp = datetime(ins.timestamp, 'ConvertFrom', 'datenum');
                ins = table2timetable(ins, 'RowTimes', 'timestamp');
            end
            
            validateattributes(ins, {'timetable'}, {});
            ins = sortrows(ins);
            obj.Data = ins;
        end
    end
end