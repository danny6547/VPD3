classdef cVesselInService < cTableObject
    %CVESSELINSERVICE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        Limit = 20000;
        Data = timetable();
        Variable;
        Timestep = 1;
    end
    
    properties(Hidden, Constant)
        
        DataProperty = {'Data'};
        TableIdentifier = '';
        EmptyIgnore = '';
    end
    
    properties(Hidden, Dependent)
        
        DateFormStr;
    end
    
    properties(Hidden)
        
        Vessel_Id;
        IMO;
    end
    
    methods
           
       function obj = cVesselInService(varargin)
           
           obj = obj@cTableObject(varargin{:});
       end
       
       function obj = insert(obj)
           
           % Check if raw data has been read
           if ~obj.canWriteImportFile()

%                % Check if raw data can be read
%                obj = obj.selectRaw();
%                if ~obj.canWriteImportFile()
%                    
                   return
%                end
           end
           
           % Input
           
           % Create flat file
           filename = fullfile(userpath, 'tempImportFile.csv');
           obj.printImportFile2(filename, true);
           
           % Insert file
           cols = obj.importFileVars;
           cols = [{'Timestamp'}, cols, {'Vessel_Id'}];
           tempTab = 'tempRaw';
           permTab = 'RawData';
           delim = ',';
           ignore = 1;
           sql = obj.SQL;
           sql.loadInFileDuplicate(filename, cols, tempTab, permTab, delim, ignore);
           
           % Delete file
           delete(filename);
       end
    end
    
    methods(Static)
        
        [params, tabFound] = tableParameters(dbname)
        vars = importFileVars()
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
        
        function str = get.DateFormStr(obj)
            
            % Get params for this database
            switch class(obj.SQL)
                
                case 'cMySQL'
                    
                    str = 'dd-MM-yyyy HH:mm:ss';
                    
                case 'cTSQL'
                    
                    str = 'yyyy-MM-dd HH:mm:ss.s';
                otherwise
            end
        end
        
        function obj = set.DateFormStr(obj, ~)
            
            
        end
    end
end