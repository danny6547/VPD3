classdef cVessel < cMySQL
    %CVESSEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        IMO_Vessel_Number double, single, int = [];
        Name char = '';
        Owner char = '';
        Class = [];
        LBP = [];
        Engine = [];
        Wind_Resist_Coeff_Dir = [];
        Transverse_Projected_Area_Design = [];
        Block_Coefficient = [];
        Length_Overall = [];
        Breadth_Moulded = [];
        Draft_Design = [];
        Speed_Power_Source char = '';
        SpeedPowerCoefficients double = [];
        SpeedPowerRSquared double = [];
        
        Variable = 'Speed_Index';
        
        Performance_Index
        Speed_Index
        DateTime_UTC
        
        TimeStep double = 1;
        
        MovingAverages
        Regression
        ServiceInterval
        GuaranteeDurations
        PerformanceMark
        DryDockingPerformance
        AnnualSavingsDD
        
    end
    
    properties(Hidden)
        
        DateFormStr char = 'dd-mm-yyyy';
    end
    
    methods
    
       function obj = cVessel(varargin)
       % Class constructor. Construct new object, assign array of IMO.
       
       if nargin > 0
           
           szIn = [0, 1];
           
           % Inputs
           structInput_l = nargin == 1 && isstruct(varargin{1});
           imoDDInput_l = nargin == 2 && ...
               isnumeric(varargin{1}) && isnumeric(varargin{2});
           imoInput_l = nargin == 1 && isnumeric(varargin{1}) && ...
               isscalar(varargin{1});
           
           if nargin > 1
                name = varargin{2};
                name = validateCellStr(name, 'cShip constructor', 'name', 2);
           else
                name = repmat({''}, szIn);
           end
           
            if imoInput_l
                
                imo = varargin{1};
                validateattributes(imo, {'numeric'},...
                  {'positive', 'real', 'integer'}, 'cShip constructor', 'IMO',...
                  1);
                szIn = size(imo);
                
                numOuts = prod(szIn);
                obj(numOuts) = cShip;

                for ii = 1:numel(imo)
                    obj(ii).IMO_Vessel_Number = imo(ii);
                    obj(ii).Name = name{ii};
                end

                obj = reshape(obj, szIn);
                
            else
                
                if structInput_l
                
                   shipData = varargin{1};
                   validateattributes(shipData, {'struct'}, {});
            
                elseif imoDDInput_l
               
                   shipData = cVesselAnalysis.performanceData(varargin{:});
                   
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
                
                % Error when inputs not recognised
            end
       end
       
       end
       
       function obj = assignClass(obj, vesselclass)
       % assignClass Assign vessel to vessel class.
       
       % Inputs
       validateattributes(vesselclass, {'cVesselClass'}, {'scalar'}, ...
           'assignClass', 'vesselclass', 1);
       if isscalar(vesselclass)
           vesselclass = repmat(vesselclass, size(obj));
       end
       
       [obj.LBP] = vesselclass(:).LBP;
       [obj.Engine] = vesselclass(:).Engine;
       [obj.Wind_Resist_Coeff_Dir] = vesselclass(:).Wind_Resist_Coeff_Dir;
       [obj.Transverse_Projected_Area_Design] = vesselclass(:).Transverse_Projected_Area_Design;
       [obj.Block_Coefficient] = vesselclass(:).Block_Coefficient;
       [obj.Length_Overall] = vesselclass(:).Length_Overall;
       [obj.Breadth_Moulded] = vesselclass(:).Breadth_Moulded;
       [obj.Draft_Design] = vesselclass(:).Draft_Design;
       [obj.Class] = vesselclass(:).WeightTEU;
       
       end
       
       function obj = insertIntoVessels(obj)
       % insertIntoVessels Insert vessel data into table 'Vessels'.
       
       % Table of vessel data
       numShips = numel(obj);
       numColumns = 11;
       data = cell(numShips, numColumns);
       
       for ii = 1:numel(obj)
           
           data{ii, 1} = obj(ii).IMO_Vessel_Number;
           data{ii, 2} = obj(ii).Name;
           data{ii, 3} = obj(ii).Owner;
           data{ii, 4} = obj(ii).Engine;
           data{ii, 5} = obj(ii).Wind_Resist_Coeff_Dir;
           data{ii, 6} = obj(ii).Transverse_Projected_Area_Design;
           data{ii, 7} = obj(ii).Block_Coefficient;
           data{ii, 8} = obj(ii).Breadth_Moulded;
           data{ii, 9} = obj(ii).Length_Overall;
           data{ii, 10} = obj(ii).Draft_Design;
           data{ii, 11} = obj(ii).LBP;
       end
       
       
       % Prepate inputs to insert data without duplicates
       otherCols_c = {'Name', ...
                        'Owner', ...
                        'Engine_Model', ...
                        'Wind_Resist_Coeff_Dir', ...
                        'Transverse_Projected_Area_Design', ...
                        'Block_Coefficient', ...
                        'Breadth_Moulded', ...
                        'Length_Overall', ...
                        'Draft_Design', ...
                        'LBP'};
%        format_s = '%u, %s, %s, %s, %f, %f, %f, %f, %f, %f, %f';
       
       % Remove any columns with any empty values
       cols_c = [{'IMO_Vessel_Number'}, otherCols_c];
       emptyMat_l = cellfun(@isempty, data);
       if isvector(emptyMat_l)
           emptyVect_l = emptyMat_l;
       else
           emptyVect_l = any(emptyMat_l);
       end
       cols_c(emptyVect_l) = [];
       data(emptyVect_l) = [];
       
       obj = obj.insertValuesDuplicate('Vessels', cols_c, data);
       
%        insertWithoutDuplicates(data, 'Vessels', 'id', 'IMO_Vessel_Number',...
%            otherCols_c, format_s);
       
       end
       
       function obj = insertIntoSFOCCoefficients(obj)
       % insertIntoSFOCCoefficients Insert engine data into table
       
       
       if isempty(obj.Engine)
           
          errid = 'VesselPer:EngineNeeded';
          errmsg = ['Vessel Engine needed before SFOC data can be inserted'...
              ' into database.'];
          error(errid, errmsg);
       end
       
       % Iterate over engines, build matrix
       [obj.Engine]
       
       % Keep only unique engines
       
       % Call SQL
       obj = obj.insertValuesDuplicate();
       
       end
       
       function obj = insertIntoSpeedPower(obj, speed, power, displacement, trim)
       % insertIntoSpeedPower Insert speed, power, draft, trim data.
       
       % Repeat scalar inputs to match uniform size (call SPCoeffs)
       imo = repmat(obj.IMO_Vessel_Number, size(speed, 1));
       
       data_c = arrayfun(@(x) [repmat(x, size(speed, 1), 1), ...
           speed, displacement, trim, power]', [obj.IMO_Vessel_Number],...
           'Uni', 0);
       data = [data_c{:}]';
       
       % Insert
%        data = [imo, speed, displacement, trim, power];
%        toTable = 'speedPower';
%        key = 'id';
%        uniqueColumns = {'IMO_Vessel_Number', 'Speed', 'Displacement', 'Trim', };
%        otherColumns = {'Power'};
%        format_s = '%u, %f, %f, %f, %f';
       
       table = 'speedPower';
       columns_c = {'IMO_Vessel_Number', 'Speed', 'Displacement', 'Trim',...
           'Power'};
       obj = obj.insertValuesDuplicate(table, columns_c, data);
%        insertWithoutDuplicates(data, toTable, key, uniqueColumns, ...
%            otherColumns, format_s);
       
       end
       
       function obj = insertBunkerDeliveryNote(obj)
       % insertBunkerDeliveryNote Insert data from 
           
           
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

        function obj = loadDNVGLPerformance(obj, filename, imo, varargin)
        % loadDNVGLPerformance Load performance data sourced from DNVGL.

        % Input
        filename = validateCellStr(filename);
        validateattributes(imo, {'numeric'}, {'vector', 'integer', ...
            'positive'}, 'loadDNVGLPerformance', 'imo', 3);

        deleteTab_l = true;
        if nargin > 3

            deleteTab_l = varargin{1};
            validateattributes(deleteTab_l, {'logical'}, {'scalar'},...
                'loadDNVGLPerformance', 'deleteTab_l', 2);
        end

        % Convert xls files to tab, if necessary
        if ~isscalar(filename)

            [~, file, ext] = cellfun(@fileparts, filename, 'Uni', 0);
            ext = unique(ext);

            if numel(ext) > 1

                errid = 'VesselDB:MultiFileTypes';
                errmsg = ['If FILENAME is a non-scalar, file extensions '...
                    'must all be either ''tab'' or ''xlsx''.'];
                error(errid, errmsg);
            end

            file = file{1};
            ext = [ext{:}];

            if strcmpi(ext, '.tab')

                tabfile = filename;
            elseif strcmpi(ext, '.xlsx')

                outfilename = filename{1};
                tabfile = strrep(outfilename, file, ['temp', file]);
                tabfile = strrep(tabfile, ext, '.tab');
                if exist(tabfile, 'file') == 2
                    delete(tabfile);
                end
                [~, ~, ~, tabfile] = convertEcoInsightXLS2tab( filename, ...
                    tabfile, true, imo);
            else
                errid = 'VesselDB:FileTypeUnrecognised';
                errmsg = ['Extension of file given by input FILENAME must be '...
                    'either ''xlsx'' or ''tab''.'];
                error(errid, errmsg);
            end

        else

            filename = [filename{:}];
            [~, file, ext] = fileparts(filename);
            if strcmpi(ext, '.tab')

                tabfile = filename;
            elseif strcmpi(ext, '.xlsx') 

                tabfile = strrep(filename, file, ['temp', file]);
                tabfile = strrep(tabfile, ext, '.tab');
                if exist(tabfile, 'file') == 2
                    delete(tabfile);
                end
                [~, ~, ~, tabfile] = convertEcoInsightXLS2tab( filename, ...
                    tabfile, true, imo);
            else

                errid = 'VesselDB:FileTypeUnrecognised';
                errmsg = ['Extension of file given by input FILENAME must be '...
                    'either ''xlsx'' or ''tab''.'];
                error(errid, errmsg);
            end
        end

        %         tabfile = validateCellStr(tabfile);
        % Load performance, speed files
        tempTab = 'tempDNVPer';
        permTab = 'DNVGLPerformanceData';
        delimiter_ch = '\t';
        ignore_i = 1;

        %         if ~isempty(pTab)
        %             pCols = {'Performance_Index', 'DateTime_UTC', 'IMO_Vessel_Number'};
        %             obj = obj.loadInFileDuplicate(pTab, pCols, tempTab,...
        %                 permTab, ignore_i);
        %         end
        %         if ~isempty(sTab)
        %             sCols = {'Speed_Index', 'DateTime_UTC', 'IMO_Vessel_Number'};
        %             obj = obj.loadInFileDuplicate(sTab, sCols, tempTab,...
        %                 permTab, ignore_i);
        %         end

        % Load in tab file
        tabfile = validateCellStr(tabfile);
        for ti = 1:numel(tabfile)

        %             cols = {'Performance_Index', 'Speed_Index', ...
        %                 'DateTime_UTC', 'IMO_Vessel_Number'};
            currTab = tabfile{ti};
            currTabid = fopen(currTab);
            currCols_cc = textscan(currTabid, '%s', 3);
            currCols_c = [currCols_cc{:}];
            obj = obj.loadInFileDuplicate(currTab, currCols_c, tempTab,...
                permTab, delimiter_ch, ignore_i);
        end

        % Delete tab file, unless requested
        if deleteTab_l

           cellfun(@delete, tabfile);
        %            delete(pTab); 
        %            delete(sTab); 
        end
        end

        function obj = loadDNVGLRaw(obj, filename)
        % loadDNVGLRaw Load raw data sourced from DNVGL

        % Drop if exists
        tempTab = 'tempDNVGLRaw';
        obj = obj.drop('TABLE', tempTab, true);

        % Create temp table
        permTab = 'DNVGLRaw';
        obj = obj.createLike(tempTab, permTab);

        % Load into temp table
        cols_c = [];
        delimiter_s = ',';
        ignore_s = 1;
        set_s = ['SET Date_UTC = STR_TO_DATE(@Date_UTC, ''%d/%m/%Y''), ', ...
         'Time_UTC = STR_TO_DATE(@Time_UTC, '' %H:%i''), '];
        setnull_c = {'Date_UTC', 'Time_UTC'};
        [obj, cols] = obj.loadInFile(filename, tempTab, cols_c, ...
            delimiter_s, ignore_s, set_s, setnull_c);

        % Generate DateTime prior to using it for identification
        expr_sql = 'ADDTIME(Date_UTC, Time_UTC)';
        col = 'DateTime_UTC';
        obj = obj.update(tempTab, col, expr_sql);

        % Update insert into final table
        tab1 = tempTab;
        finalCols = [cols, {col}];
        cols1 = finalCols;
        tab2 = permTab;
        cols2 = finalCols;
        obj = obj.insertSelectDuplicate(tab1, cols1, tab2, cols2);

        % Drop temp
        obj = obj.drop('TABLE', tempTab);

        end

%        function obj = fitSpeedPower(obj, speed, power, varargin)
%        % fitSpeedPower Fit speed, power data to model
%        
%        % Input
%        validateattributes(speed, {'numeric'}, {'real', 'positive', 'vector',...
%            'nonnan'}, 'fitSpeedPower', 'speed', 2);
%        validateattributes(power, {'numeric'}, {'real', 'positive', 'vector',...
%            'nonnan'}, 'fitSpeedPower', 'power', 3);
%        
%        % Fit data
%        coeffs = polyfit();
%        
%            
%        end
    end
    
    methods(Static)
        
        function varargout = repeatInputs(inputs)
        % repeatInputs Repeat any scalar inputs to match others' size
        
        % Check that all inputs are the same size or are scalar
        scalars_l = cellfun(@isscalar, inputs);
        empty_l = cellfun(@isempty, inputs);
        emptyOrScalar_l = scalars_l | empty_l;
        allSizes_c = cellfun(@size, inputs(~emptyOrScalar_l), 'Uni', 0);
        szMat_c = allSizes_c(1);
        chkSize_c = repmat(szMat_c, size(allSizes_c));
        if ~isequal(allSizes_c, chkSize_c)
           errid = 'DBTab:SizesMustMatch';
           errmsg = 'All inputs must be the same size, or any can be scalar';
           error(errid, errmsg);
        end
        
        % Repeat scalars
        inputs(scalars_l) = cellfun(@(x) repmat(x, chkSize_c{1}),...
            inputs(scalars_l), 'Uni', 0);
        
        % Assign outputs
        varargout = inputs;
        
        end
        
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
       
       function obj = set.IMO_Vessel_Number(obj, IMO)
           
           validateattributes(IMO, {'numeric'}, ...
               {'positive', 'real', 'nonnan', 'integer'});
           obj.IMO_Vessel_Number = IMO;
           
       end
        
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