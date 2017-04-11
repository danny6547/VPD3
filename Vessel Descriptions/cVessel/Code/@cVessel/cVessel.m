classdef cVessel < cMySQL & cVesselWindCoefficient
    %CVESSEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        IMO_Vessel_Number double = [];
        Name char = '';
        Owner char = '';
        Class = [];
        LBP = [];
        Engine = [];
        Transverse_Projected_Area_Design = [];
        Block_Coefficient = [];
        Length_Overall = [];
        Breadth_Moulded = [];
        Draft_Design = [];
        
        DryDockInterval double = [];
        SpeedPower cVesselSpeedPower = cVesselSpeedPower();
        DryDockDates = cVesselDryDockDates();
        WindResistance = cVesselWindCoefficient();
        
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
        InServicePerformance
    end
    
    properties(Hidden)
        
        DateFormStr char = 'dd-mm-yyyy';
        CurrIter = 1;
        IterFinished = false;
    end
    
    properties(Dependent)
        
        Speed;
        Power;
        Displacement;
        Trim;
    end
    
    methods
    
       function obj = cVessel(varargin)
       % Class constructor. Construct new object, assign array of IMO.
       
       if nargin > 0
           
           % Inputs
           p = inputParser();
           p.addParameter('IMO', []);
           p.addParameter('FileName', '');
           p.addParameter('DDi', []);
           p.addParameter('ShipData', []);
           p.addParameter('Name', '');
           p.parse(varargin{:});
           res = p.Results;
           
           file = res.FileName;
           imo = res.IMO;
           DDi = res.DDi;
           shipDataInput = res.ShipData;
           vesselNames = res.Name;
           
           file_l = ~isempty(file);
           imo_l = ~isempty(imo);
           ddi_l = ~isempty(DDi);
           shipData_l = ~isempty(shipDataInput);
           vesselName_l = ~isempty(vesselNames);
           
           % Append DDi to list of inputs for reading from DB, if input
           readInputs_c = {imo};
           if ddi_l
               
               readInputs_c = [readInputs_c, {DDi}];
           end
           
           if shipData_l
               
               validateattributes(shipDataInput, {'struct'}, {});
           end
           
           if file_l
               
               % Load data from file into DB
               file = validateCellStr(file, 'cVessel constructor', 'IMO');
               [valid, errmsg] = cellfun(@(x) cVessel.validateFileExists(x), file,...
                   'Uni', 0);
               valid = [valid{:}];
               if any(~valid)
                  
                   errmsg = errmsg{find(~valid, 1)};
                   errid = 'cVA:FileNotFound';
                   error(errid, strrep(errmsg, '\', '/'));
               end
               
               firstFile_ch = file{1};
               
               dnvglProc_l = strcmp(xlsfinfo(firstFile_ch), ...
                   'Microsoft Excel Spreadsheet');
               fid = fopen(firstFile_ch);
                headerLine = textscan(fid, '%s', 1, 'delimiter', '\n');
               fclose(fid);
               
               validLengths = [235, 220];
               dnvglRaw_l = ismember(length(strsplit(headerLine{1}{:}, ',')),...
                   validLengths);
               
               if dnvglRaw_l
                   
                   [obj, imoFile] = loadDNVGLRaw(obj, file);
                   
                   if imo_l && ~isequal(sort(imoFile), sort(file))
                       
                       errid = 'cVA:IMOInputFileMismatch';
                       errmsg = ['IMO numbers contained in files input do '...
                           'not match those of input parameter IMO.'];
                       error(errid, errmsg);
                   end
                   
                   imo = unique(imoFile);
                   
               elseif dnvglProc_l
                   
                   if ~imo_l
                       
                       errid = 'cVA:FileRequiresIMO';
                       errmsg = ['When filenames input are paths to DNVGL '...
                           'processed data files, the IMO of the vessels '...
                           'must also be given.'];
                       error(errid, errmsg);
                   end
                   
                   obj = obj.loadDNVGLPerformance(file, imo);
               end
               
               readInputs_c = [{imo}, DDi];
               shipData = cVessel.performanceData(readInputs_c{:});
           end
           
           if imo_l
                
                % Read data out from DB
                validateattributes(imo, {'numeric'},...
                  {'positive', 'real', 'integer'}, 'cVessel constructor',...
                  'IMO', 1);
                shipData = cVessel.performanceData(readInputs_c{:});
           end
           
           if shipData_l && file_l
               
               % Concatenate time-series data
               allDates_c = arrayfun(@(x, y) cat(1, x.DateTime_UTC, ...
                   y.DateTime_UTC), shipDataInput, shipData, 'Uni', 0);
               allPI_c = arrayfun(@(x, y) cat(1, x.Performance_Index, ...
                   y.Performance_Index), shipDataInput, shipData, 'Uni', 0);
               allSI_c = arrayfun(@(x, y) cat(1, x.Speed_Index, ...
                   y.Speed_Index), shipDataInput, shipData, 'Uni', 0);
               [shipData.DateTime_UTC] = deal(allDates_c{:});
               [shipData.Performance_Index] = deal(allPI_c{:});
               [shipData.Speed_Index] = deal(allSI_c{:});
               
           end
           
           if shipData_l && ~any([file_l, imo_l])
               
               shipData = shipDataInput;
           end

           % Get IMO from struct
           imo = deal([shipData(:).IMO_Vessel_Number]);
           if vesselName_l
                name = validateCellStr(vesselNames, 'cVessel constructor',...
                    'name', 2);
                if isscalar(name)
                    name = repmat(name, size(imo));
                end
           else
                name = vesselName(imo);
                name = validateCellStr(name);
           end

            szIn = size(shipData);

            numOuts = prod(szIn);
            obj(numOuts) = cVessel;

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
                    obj(ii).IMO_Vessel_Number = imo(ii);
                    obj(ii).Name = name{ii};
                end
            end
            obj = reshape(obj, szIn);
            
            % Check that no duplicates were added when concatenating struct
            % data with that read from DB
            index_c = 'DateTime_UTC';
            prop_c = {'Performance_Index'...
                    'Speed_Index'};
            obj = obj.filterOnUniqueIndex(index_c, prop_c);
            
            
            % Error when inputs not recognised
            
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
%        [obj.Wind_Resist_Coeff_Dir] = vesselclass(:).Wind_Resist_Coeff_Dir;
       [obj.Transverse_Projected_Area_Design] = vesselclass(:).Transverse_Projected_Area_Design;
       [obj.Block_Coefficient] = vesselclass(:).Block_Coefficient;
       [obj.Length_Overall] = vesselclass(:).Length_Overall;
       [obj.Breadth_Moulded] = vesselclass(:).Breadth_Moulded;
       [obj.Draft_Design] = vesselclass(:).Draft_Design;
       [obj.Class] = vesselclass(:).WeightTEU;
       
       end
       
       function obj = insertIntoVessels(obj)
       % insertIntoVessels Insert vessel data into table 'Vessels'.
       
       
       obj.insertIntoTable('Vessels');
       
%        % Table of vessel data
%        numShips = numel(obj);
%        numColumns = 11;
%        data = cell(numShips, numColumns);
%        
%        for ii = 1:numel(obj)
%            
%            data{ii, 1} = obj(ii).IMO_Vessel_Number;
%            data{ii, 2} = obj(ii).Name;
%            data{ii, 3} = obj(ii).Owner;
%            data{ii, 4} = obj(ii).Engine;
%            data{ii, 5} = obj(ii).Wind_Resist_Coeff_Dir;
%            data{ii, 6} = obj(ii).Transverse_Projected_Area_Design;
%            data{ii, 7} = obj(ii).Block_Coefficient;
%            data{ii, 8} = obj(ii).Breadth_Moulded;
%            data{ii, 9} = obj(ii).Length_Overall;
%            data{ii, 10} = obj(ii).Draft_Design;
%            data{ii, 11} = obj(ii).LBP;
%        end
%        
%        
%        % Prepate inputs to insert data without duplicates
%        otherCols_c = {'Name', ...
%                         'Owner', ...
%                         'Engine_Model', ...
%                         'Wind_Resist_Coeff_Dir', ...
%                         'Transverse_Projected_Area_Design', ...
%                         'Block_Coefficient', ...
%                         'Breadth_Moulded', ...
%                         'Length_Overall', ...
%                         'Draft_Design', ...
%                         'LBP'};
% %        format_s = '%u, %s, %s, %s, %f, %f, %f, %f, %f, %f, %f';
%        
%        % Remove any columns with any empty values
%        cols_c = [{'IMO_Vessel_Number'}, otherCols_c];
%        emptyMat_l = cellfun(@isempty, data);
%        if isvector(emptyMat_l)
%            emptyVect_l = emptyMat_l;
%        else
%            emptyVect_l = any(emptyMat_l);
%        end
%        cols_c(emptyVect_l) = [];
%        data(emptyVect_l) = [];
%        
%        obj = obj.insertValuesDuplicate('Vessels', cols_c, data);
%        insertWithoutDuplicates(data, 'Vessels', 'id', 'IMO_Vessel_Number',...
%            otherCols_c, format_s);
       
       end
       
       function obj = insertIntoSFOCCoefficients(obj)
       % insertIntoSFOCCoefficients Insert engine data into table
       
%        for oi = 1:numel(obj)
%            
%            if isempty(obj(oi).Engine)
%                
%                 continue
% %               errid = 'VesselPer:EngineNeeded';
% %               errmsg = ['Vessel Engine needed before SFOC data can be inserted'...
% %                   ' into database.'];
% %               error(errid, errmsg);
%            end
           
           dataObj = [obj.Engine];
           tab = 'SFOCCoefficients';
           obj.insertIntoTable(tab, dataObj, 'Engine_Model', {dataObj.Name});
%        end
       
       % Iterate over engines, build matrix
%        [obj.Engine]
       
       % Keep only unique engines
       
       % Call SQL
%        obj = obj.insertValuesDuplicate();
       
       
       % 
       
       
       end
       
       function obj = insertIntoSpeedPower(obj) %, speed, power, displacement, trim)
       % insertIntoSpeedPower Insert speed, power, draft, trim data.
       
%        % Repeat scalar inputs to match uniform size (call SPCoeffs)
%        imo = repmat(obj.IMO_Vessel_Number, size(speed, 1));
%        
%        data_c = arrayfun(@(x) [repmat(x, size(speed, 1), 1), ...
%            speed, displacement, trim, power]', [obj.IMO_Vessel_Number],...
%            'Uni', 0);
%        data = [data_c{:}]';
%        
%        % Insert
% %        data = [imo, speed, displacement, trim, power];
% %        toTable = 'speedPower';
% %        key = 'id';
% %        uniqueColumns = {'IMO_Vessel_Number', 'Speed', 'Displacement', 'Trim', };
% %        otherColumns = {'Power'};
% %        format_s = '%u, %f, %f, %f, %f';
%        
%        table = 'speedPower';
%        columns_c = {'IMO_Vessel_Number', 'Speed', 'Displacement', 'Trim',...
%            'Power'};
%        obj = obj.insertValuesDuplicate(table, columns_c, data);
       
%        [speed, power, displacement, trim] = repeatInputs(speed, power, ...
%            displacement, trim);
%        obj.Speed = speed;
%        obj.Power = power;
%        obj.Displacement = displacement;
%        obj.Trim = trim;
%        obj = obj.insertIntoTable('speedPower');
%        insertWithoutDuplicates(data, toTable, key, uniqueColumns, ...
%            otherColumns, format_s);
        
%         % Pre-allocate
%         numObj = numel(obj);
%         imo_c = cell(1, numObj);
%         speed_c = cell(1, numObj);
%         power_c = cell(1, numObj);
%         trim_c = cell(1, numObj);
%         displacement_c = cell(1, numObj);
%         
%         % Generate matrix of all speed, power curves for all vessels
%         for oi = 1:numObj
%             
%             speed_c{oi} = obj(oi).Speed;
%             power_c{oi} = obj(oi).Power;
%             trim_c{oi} = obj(oi).Trim;
%             displacement_c{oi} = obj(oi).Displacement;
%             imo_c{oi} = obj.repeatInputs(obj.IMO_Vessel_Number, ...
%                 obj(oi).Speed);
%         end
%         
%         tableMat = cell2mat([imo_c, displacement_c, trim_c, speed_c, ...
%             power_c]);
        tableName = 'SpeedPower';
        obj.insertIntoTable(tableName);
       
       end
       
       function obj = insertBunkerDeliveryNote(obj)
       % insertBunkerDeliveryNote Insert data from 
           
           
       end
       
       function obj = insertIntoDryDockDates(obj)
       % insertIntoDryDocking Insert data into table "DryDockDates"

           dataObj = [obj.DryDockDates];
           tab = 'DryDockDates';
           obj.insertIntoTable(tab, dataObj);
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
            fclose(currTabid);
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

        function [obj, IMO] = loadDNVGLRaw(obj, filename)
        % loadDNVGLRaw Load raw data sourced from DNVGL

        % Drop if exists
        tempTab = 'tempDNVGLRaw';
        obj = obj.drop('TABLE', tempTab, true);
        
        % Create temp table
        permTab = 'DNVGLRaw';
        obj = obj.createLike(tempTab, permTab);
        
        % Drop unique constraint, allowing for duplicates in temporary
        % loading table which will not carry through to final table
        dropCons_sql = ['ALTER TABLE `' tempTab '` DROP INDEX ' ...
            '`UniqueIMODates`'];
        execute(obj, dropCons_sql);
        
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
        if ~isscalar(filename)
            cols = cols{1}(:)';
        end
        tab1 = tempTab;
        finalCols = [cols, {col}];
        cols1 = finalCols;
        tab2 = permTab;
        cols2 = finalCols;
        obj = obj.insertSelectDuplicate(tab1, cols1, tab2, cols2);
        
        % Drop temp
        obj = obj.drop('TABLE', tempTab);
        
        if nargout > 1
           
           % Get IMO contained in file
           filename = cellstr(filename);
           IMO = [];
           for fi = 1:numel(filename)
               
               filei = filename{fi};
               fid = fopen(filei);
               w = {};
               while fgetl(fid) ~= -1
                   
                   q = textscan(fid, '%[0123456789]', 'Headerlines', 1,...
                       'TreatAsEmpty', '');
                   w = [w, q{1}];
               end
               
               IMO = [IMO, str2double(unique(w))];
           end
        end
        
        end

        function obj = filterOnUniqueIndex(obj, index, prop)
        % filterOnUniqueIndex Filter data based on duplicate keys.
        
        % Input
        validateattributes(index, {'char'}, {'vector'}, ...
            'filterOnUniqueIndex', 'index', 2);
        prop = validateCellStr(prop, 'filterOnUniqueIndex', 'prop', 3);
        
        % Iterate and filter non-unique indices of index data
        while ~obj.iterFinished
            
            [obj, ii] = obj.iter;
            [uniIndex, uniIndexI] = unique(obj(ii).(index));
            
            for pi = 1:numel(prop)
                
                currData = obj(ii).(prop{pi});
                obj(ii).(prop{pi}) = currData(uniIndexI);
            end
            
            obj(ii).(index) = uniIndex;
        end
        obj = obj.iterReset;
        
        end
        
        function obj = readFromTable(obj, table, identifier)
        % readFromTable Assign object properties from table column values
        
        % Input
        validateattributes(table, {'char'}, {'vector'}, ...
            'cVessel.readFromTable', 'table', 2);
        validateattributes(identifier, {'char'}, {'vector'}, ...
            'cVessel.readFromTable', 'identifier', 3);
        
        % Get matching field names and object properties
        temp_st = obj(1).execute(['DESCRIBE ', table]);
        fields_c = temp_st.field;
        prop_c = properties(obj);
        matchField_c = intersect(fields_c, prop_c);
        
        % Error if identifier is not in both fields and properties
        if ~ismember(identifier, matchField_c)
            
            errid = 'readTable:IdentifierMissing';
            errmsg = ['Input IDENTIFIER must be both a property of OBJ '...
                'and a field of table TABLE.'];
            error(errid, errmsg);
        end
        
        % Select table where rows match identifier values in object
        objID_c = {obj.(identifier)};
        objID_cs = cellfun(@num2str, objID_c, 'Uni', 0);
        objIDvals_ch = obj(1).colList(objID_cs);
        [obj(1), sqlWhereIn_ch] = obj(1).combineSQL('WHERE', identifier, 'IN',...
            objIDvals_ch);
        [obj(1), ~, sqlSelect] = obj(1).select(table, '*');
        [obj(1), sqlSelect] = obj(1).determinateSQL(sqlSelect);
        [obj(1), sqlSelectWhereIn_ch] = obj(1).combineSQL(sqlSelect, sqlWhereIn_ch);
        table_st = obj(1).execute(sqlSelectWhereIn_ch);
        if isempty(table_st)
            
            errid = 'readTable:IdentifierDataMissing';
            errmsg = 'No data could be read for the values of IDENTIFIER.';
            error(errid, errmsg);
        end
        
        % Get indices to OBJ identified in table
        lowerId_ch = lower(identifier);
        tableID_c = table_st.(lowerId_ch);
        [obj_l, obj_i] = ismember([tableID_c{:}], [objID_c{:}]);
        nID = sum(obj_l);
        
        % Iterate over properties of matching obj and assign values
        for ii = 1:length(matchField_c)
            
            currField = matchField_c{ii};
            lowerField = lower(currField);
            currData = table_st.(lowerField);
            
            for oi = 1:nID
                
                currObji = obj_i(oi);
                obj(currObji).(currField) = currData{oi};
            end
        end
        
        end

        function obj = insertIntoSpeedPowerCoefficients(obj)
        % insertIntoSpeedPowerCoefficients Insert into table SPCoefficients
            
            % Vector all SP objects
            allSP = [obj.SpeedPower];
            
            % Insert into table, giving IMO
            tabName = 'speedpowercoefficients';
            
            imo_c = arrayfun(@(x) repmat(x.IMO_Vessel_Number, ...
                [1, numel(x.SpeedPower)]), obj, 'Uni', 0);
            imo_v = [imo_c{:}];
            obj.insertIntoTable(tabName, allSP, 'IMO_Vessel_Number', imo_v);
            
        end
        
        function obj = insertIntoWindCoefficients(obj)
        % insertIntoWindCoefficient Insert data into wind coefficient table
            
            windCoeffs_v = [obj.WindResistance];
            imo_v = [obj.IMO_Vessel_Number];
            tabName = 'WindCoefficientDirection';
            obj.insertIntoTable(tabName, windCoeffs_v, ...
                'IMO_Vessel_Number', imo_v);
            
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
        % [A, B, ...] = repeatInputs(inputs) will return in A, B... vectors
        % of size equal to the size of any non-scalar in INPUTS, i.e. any
        % scalars in INPUTS will be repeated to match the size of the
        % non-scalars and returned in A, B... There can be multiple scalars
        % and non-scalars but all non-scalars they must all be the same 
        % size. If any of INPUTS are strings, they will be treated as
        % scalars.
        
        % Check that all inputs are the same size or are scalar
        scalars_l = cellfun(@(x) isscalar(x) || ischar(x), inputs);
        empty_l = cellfun(@isempty, inputs);
        emptyOrScalar_l = scalars_l | empty_l;
        allSizes_c = cellfun(@size, inputs(~emptyOrScalar_l), 'Uni', 0);
        
        if ~isempty(allSizes_c)
        
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
        end
        
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
            errmsg = ['Input file ' filename ' must exist.'];
        else
            errmsg = ['Input file ' filename ' must not exist.'];
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
    
    methods(Hidden)
        
        function [finished, obj] = iterFinished(obj)
        % iterFinished Scalar indicating whether array iteration finished
            
            % Return value
            finished = obj(1).IterFinished;
            
        end
        
        function obj = iterReset(obj)
        % iterReset Reset counters for iteration
            
            finished = iterFinished(obj);
            
            % Value is reset if true
            if finished
                [obj.IterFinished] = deal(false);
                [obj.CurrIter] = deal(1);
            end
        end
        
    end
    
    methods
       
       function obj = set.IMO_Vessel_Number(obj, IMO)
           
           if ~isempty(IMO(~isnan(IMO)))
                validateattributes(IMO, {'numeric'}, ...
                    {'scalar', 'positive', 'real', 'nonnan', 'integer'});
           else
                validateattributes(IMO, {'numeric'}, ...
                    {'scalar'});
                IMO = [];
           end
           obj.IMO_Vessel_Number = IMO;
           
           if ~isempty(obj.DryDockDates)
               
               [obj.DryDockDates(:).IMO_Vessel_Number] = deal(IMO);
           end
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
       
       function speed = get.Speed(obj)
       % Get Speed from SpeedPower object
       
       % Get matrix of speed, power, draft, trim
       spdt = obj.SpeedPower.speedPowerDraftTrim;
       
       % Index appropriately
       speed = spdt(:, 1);
           
       end
       
       function power = get.Power(obj)
       % Get Speed from SpeedPower object
       
       % Get matrix of speed, power, draft, trim
       spdt = obj.SpeedPower.speedPowerDraftTrim;
       
       % Index appropriately
       power = spdt(:, 2);
           
       end
       
       function disp = get.Displacement(obj)
       % Get Speed from SpeedPower object
       
       % Get matrix of speed, power, draft, trim
       spdt = obj.SpeedPower.speedPowerDraftTrim;
       
       % Index appropriately
       disp = spdt(:, 3);
           
       end
       
       function trim = get.Trim(obj)
       % Get Speed from SpeedPower object
       
       % Get matrix of speed, power, draft, trim
       spdt = obj.SpeedPower.speedPowerDraftTrim;
       
       % Index appropriately
       trim = spdt(:, 4);
           
       end

    end
end