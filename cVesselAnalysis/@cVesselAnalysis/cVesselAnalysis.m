classdef cVesselAnalysis
    %CVESSELANALYSIS Analyse performance data of vessels
    %   Detailed explanation goes here
    
    properties
        
        Variable = 'Speed_Index';
        DateFormStr = 'dd-mm-yyyy';
        
        Performance_Index
        Speed_Index
        DateTime_UTC
        
        RandomValue = 1;
        TimeStep = 1;
        
        MovingAverages
        Regression
        ServiceInterval
        GuaranteeDurations
        PerformanceMark
        DryDockingPerformance
        AnnualSavingsDD
        
        IMO_Vessel_Number
    end
    
    methods
    
       function obj = cVesselAnalysis( varargin )
       % cShipAnalysis Constructor for class cShipAnalysis
       
       % Detect whether input is struct, or IMO data for retreiving struct
       if nargin > 0
          
           structInput_l = nargin == 1 && isstruct(varargin{1});
           imoDDInput_l = nargin == 2 && ...
               isnumeric(varargin{1}) && isnumeric(varargin{2});
           
           if structInput_l
               
               shipData = varargin{1};
               validateattributes(shipData, {'struct'}, {});
            
           elseif imoDDInput_l
               
               shipData = cVesselAnalysis.performanceData(varargin{:});
               
           else
               
               % Error when inputs not recognised
           end
           
            szIn = size(shipData);

            numOuts = prod(szIn);
            obj(numOuts) = cVesselAnalysis;

            validFields = {'DateTime_UTC', ...
                            'Performance_Index',...
                            'Speed_Index',...
                            'IMO_Vessel_Number'};
            inputFields = fieldnames(shipData);
            fields2read = intersect(validFields, inputFields);
            
            for ii = 1:numel(obj)
                for fi = 1:numel(fields2read)
                    
                    currField = fields2read{fi};
                    obj(ii).(currField) = shipData(ii).(currField);
                end
            end
            obj = reshape(obj, szIn);
        
       end
       end
       
       function obj = randomMethod(obj)
           
           for ii = 1:numel(obj)
           
                obj(ii).RandomValue = randn([1, 1]);
           end
       end
       
       function skip = isPerDataEmpty(obj)
       % isPerDataEmpty True if performance data variable empty.
       
       
       vars = {obj.Variable};
       skip = arrayfun(@(x, y) all(isnan(isempty(x.(y{:})))), obj, vars);
           
       end
       
       function written = reportTable(obj, filename)
       % reportTable Write tables for report into xlsx file
       % written = reportTable(obj, filename) will write into partial or
       % full file path string FILENAME the tables for the hull performance
       % report and return in the fields of struct WRITTEN logical values
       % indicating which tables were generated. Tables whose values are
       % fully given in OBJ are generated.
       
       % Output
       written = struct('Service', false,...
                        'Coating', false,...
                        'DDPerformance', false, ...
                        'Savings', false);
       
       % Input
       validateattributes(filename, {'char'}, {'vector'}, 'reportTable',...
           'filename', 2);
       if exist(filename, 'file') == 2
           
          errid = 'ShipAnalysis:FileInvalid';
          errmsg = 'Input FILENAME must not exist.';
          error(errid, errmsg);
       end
       
       % Write table 1
       
       
       end
       
       function [obj, activity] = activityFromSeaWeb(obj, filename)
       % activityFromSeaWeb Parse activity data from SeaWeb download
       
       % Input
       [validFile, errMsg] = obj.validateFileExists(filename);
       if ~validFile
           errid = 'ShipAnalysis:SeawebFileMissing';
           error(errid, errMsg);
       end
       
       % Parse File
       
       
       % Calculate Idle time as difference of arrival and departures
       
       % Activity defined as ratio between total idle time and total time
       
       % 
       
       end
    end
    
    methods(Static)
        
        function [valid, errmsg] = validateFileExists(filename, varargin)
        % validateFile Check whether file exists or not.
        
        % Output
        valid = false;
        
        % Input
        validateattributes(filename, {'char'}, {'vector'}, 'validateFile',...
            'filename', 1);
        
        existCriteria = true;
        if nargin > 1
            
            existCriteria = varargin{1};
            validateattributes(existCriteria, {'logical'}, {'scalar'},...
                'validateFile', 'existCriteria', 2);
        end
        
        % Create error message in case either criteria fail
        if existCriteria
            errmsg = 'Input FILENAME must exist.';
        else
            errmsg = 'Input FILENAME must not exist.';
        end
        
        % Check if file exists
        fileExists = (exist(filename, 'file') == 2);
        
        % Assign output based on criteria matching file state
        if existCriteria == fileExists
           valid = true;
        end
        
        end
        
        [ out ] = performanceData(imo, varargin)
        
    end
    
    methods
       
       function obj = set.DateTime_UTC(obj, dates)
        % Set property method for DateTime_UTC
        
            dateFormStr = obj.DateFormStr;
            errid = 'ShipAnalysis:InvalidDateType';
            errmsg = ['Values representing dates must either be numeric '...
                'MATLAB serial date values, strings representing those '...
                'values or a cell array of strings representing those '...
                'values.'];
            
            if iscell(dates)
                
                
                try dates = char(dates);
                    
                catch e
                    
                    try allNan_l = all(cellfun(@isnan, dates));

                        if allNan_l
                            dates = [dates{:}];
                        end

                    catch ee
                        
                        error(errid, errmsg);
                    end
                end
            end
            
            if ischar(dates)
                date_v = datenum(char(dates), dateFormStr);
            elseif isnumeric(dates)
                date_v = dates;
            else
                error(errid, errmsg);
            end
            obj.DateTime_UTC = date_v;
        
       end
       
       function obj = set.Variable(obj, variable)
       % Set property method for Variable
        
       obj.checkVarname( variable );
       obj.Variable = variable;
           
       end
       
    end
end
