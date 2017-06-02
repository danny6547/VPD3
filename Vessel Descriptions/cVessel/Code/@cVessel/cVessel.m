classdef cVessel < cMySQL
    %CVESSEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        IMO_Vessel_Number double = [];
        Name char = '';
        Owner char = '';
        Class = [];
        LBP = [];
        Engine = cVesselEngine();
        Transverse_Projected_Area_Design = [];
        Block_Coefficient = [];
        Length_Overall = [];
        Breadth_Moulded = [];
        Draft_Design = [];
        Anemometer_Height = [];
        
        DryDockInterval double = [];
        SpeedPower cVesselSpeedPower = cVesselSpeedPower();
        DryDockDates = cVesselDryDockDates();
        WindCoefficient = cVesselWindCoefficient();
        
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
        Activity double = nan;
    end
    
    properties(Hidden)
        
        DateFormStr char = 'dd-mm-yyyy';
        CurrIter = 1;
        IterFinished = false;
        DryDockIndexDB = [];
    end
    
    properties(Dependent)
        
        Speed;
        Power;
        Displacement
        Trim;
        Propulsive_Efficiency;
        Engine_Model;
        Wind_Model_ID;
        Wind_Reference_Height_Design;
    end
    
    properties(Access = private)
        
        PerformanceTable = 'DNVGLPerformanceData';
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
               [shipData, ddd] = obj.performanceData(readInputs_c{:});
           end
           
           if imo_l
                
                % Read data out from DB
                validateattributes(imo, {'numeric'},...
                  {'positive', 'real', 'integer'}, 'cVessel constructor',...
                  'IMO', 1);
               [shipData, ddd] = obj.performanceData(readInputs_c{:});
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
                if isempty(name)
                    name = repmat({''}, size(imo));
                else
                    name = validateCellStr(name);
                end
           end

            szIn = size(shipData);

            numOuts = prod(szIn);
            obj(numOuts) = cVessel;

            validFields = {'DateTime_UTC', ...
                            'Performance_Index',...
                            'Speed_Index',...
                            'IMO_Vessel_Number'...
                            'DryDockInterval'};
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
            
            
            % Read Vessel static data from DB
            emptyObj_l = arrayfun(@(x) isempty(x.IMO_Vessel_Number), obj);
            obj(~emptyObj_l) = obj(~emptyObj_l).readFromTable('Vessels', 'IMO_Vessel_Number');
            
            nDocks = size(obj, 1);
            if size(ddd, 1) > size(obj, 1)
                
                ddd(end, :) = [];
            end
            
            emptyVessels_l = arrayfun(@(x) numel(find(~isnan(x.(x.Variable)))), obj) == 0;
            emptyDD_l = arrayfun(@isempty, ddd);
            rows2remove_l = all((emptyVessels_l | emptyDD_l)');
            ddd(rows2remove_l, :) = [];
            
            tempDD_c = num2cell(ddd);
            [obj(2:end, :).DryDockDates] = tempDD_c{:};
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
       
       function obj = insert(obj)
       % insert Insert all available vessel data into database
           
           % Vessels
           obj = obj.insertIntoVessels();
           
           % SpeedPower
           obj.SpeedPower.insertIntoTable();
%            obj = insertIntoSpeedPower(obj);
           
           % SpeedPower Coefficients
%            obj = insertIntoSpeedPowerCoefficients(obj);
           
           % Wind
           obj = insertIntoWindCoefficients(obj);
           
           % Dry Dock Dates
           obj = insertIntoDryDockDates(obj);
           
           % SFOC
           obj = insertIntoSFOCCoefficients(obj);
           
           % Bunker delivery notes
           obj = insertBunkerDeliveryNote(obj);
           
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
           dataObj(isempty(dataObj)) = [];
           if ~isempty(dataObj)
               tab = 'SFOCCoefficients';
               obj.insertIntoTable(tab, dataObj, 'Engine_Model', {dataObj.Name});
           end
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
           dataObj(isempty(dataObj)) = [];
           if ~isempty(dataObj)
               imo = [obj.IMO_Vessel_Number];
               [dataObj.IMO_Vessel_Number] = deal(imo(:));
               tab = 'DryDockDates';
               obj.insertIntoTable(tab, dataObj);
           end
       end
       
       function skip = isPerDataEmpty(obj)
       % isPerDataEmpty True if performance data variable empty or NAN.
       
       vars = {obj.Variable};
       skip = arrayfun(@(x, y) isempty(x.(y{:})) || all(isnan(x.(y{:}))), obj, vars);
           
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
        cols_c = {...
                    'IMO_Vessel_Number'
                    'Date_UTC'
                    'Time_UTC'
                    'Date_Local'
                    'Time_Local'
                    'Voyage_From'
                    'Voyage_To'
                    'Voyage_Number'
                    'Latitude_Degree'
                    'Latitude_Minutes'
                    'Latitude_North_South'
                    'Longitude_Degree'
                    'Longitude_Minutes'
                    'Longitude_East_West'
                    'Wind_Dir'
                    'Wind_Force_Kn'
                    'Wind_Force_Bft'
                    'Sea_state_Dir'
                    'Sea_state_Force_Douglas'
                    'Swell_Dir'
                    'Swell_Force'
                    'Current_Dir'
                    'Current_Speed'
                    'Temperature_Ambient'
                    'Temperature_Water'
                    'Draft_Actual_Fore'
                    'Draft_Actual_Aft'
                    'Draft_Recommended_Fore'
                    'Draft_Recommended_Aft'
                    'Draft_Ballast_Actual'
                    'Draft_Ballast_Optimum'
                    'Draft_Displacement_Actual'
                    'ME_Fuel_BDN'
%                     'ME_Fuel_BDN2'
%                     'ME_Fuel_BDN3'
%                     'ME_Fuel_BDN4'
                    'AE_Fuel_BDN'
%                     'AE_Fuel_BDN2'
%                     'AE_Fuel_BDN3'
%                     'AE_Fuel_BDN4'
                    'Event'
                    'Time_Since_Previous_Report'
                    'Time_Elapsed_Sailing'
                    'Time_Elapsed_Maneuvering'
                    'Time_Elapsed_Waiting'
                    'Time_Elapsed_Loading_Unloading'
                    'Distance'
                    'Nominal_Slip'
                    'Apparent_Slip'
                    'Cargo_Mt'
                    'Cargo_Total_TEU'
                    'Cargo_Total_Full_TEU'
                    'Cargo_Reefer_TEU'
                    'Cargo_CEU'
                    'Crew'
                    'Passengers'
                    'People'
                    'ME_Projected_Consumption'
                    'ME_Consumption'
%                     'ME_Consumption2'
%                     'ME_Consumption3'
%                     'ME_Consumption4'
                    'ME_Cylinder_Oil_Consumption'
                    'ME_System_Oil_Consumption'
                    'ME_1_Running_Hours'
                    'ME_1_Consumption'
                    'ME_1_Cylinder_Oil_Consumption'
                    'ME_1_System_Oil_Consumption'
                    'ME_1_Work'
%                     'ME_1_Shaft_Gen_Work'
%                     'ME_1_Shaft_Gen_Running_Hours'
                    'ME_2_Running_Hours'
                    'ME_2_Consumption'
                    'ME_2_Cylinder_Oil_Consumption'
                    'ME_2_System_Oil_Consumption'
                    'ME_2_Work'
%                     'ME_2_Shaft_Gen_Work'
%                     'ME_2_Shaft_Gen_Running_Hours'
                    'AE_Projected_Consumption'
                    'AE_Consumption'
%                     'AE_Consumption2'
%                     'AE_Consumption3'
%                     'AE_Consumption4'
                    'AE_1_Running_Hours'
                    'AE_1_Consumption'
                    'AE_1_Work'
                    'AE_2_Running_Hours'
                    'AE_2_Consumption'
                    'AE_2_Work'
                    'AE_3_Running_Hours'
                    'AE_3_Consumption'
                    'AE_3_Work'
                    'AE_4_Running_Hours'
                    'AE_4_Consumption'
                    'AE_4_Work'
                    'AE_5_Running_Hours'
                    'AE_5_Consumption'
                    'AE_5_Work'
                    'AE_6_Running_Hours'
                    'AE_6_Consumption'
                    'AE_6_Work'
                    'Boiler_Consumption'
%                     'Boiler_Consumption2'
%                     'Boiler_Consumption3'
%                     'Boiler_Consumption4'
                    'Boiler_1_Running_Hours'
                    'Boiler_1_Consumption'
                    'Boiler_2_Running_Hours'
                    'Boiler_2_Consumption'
                    'Air_Compr_1_Running_Time'
                    'Air_Compr_2_Running_Time'
                    'Thruster_1_Running_Time'
                    'Thruster_2_Running_Time'
                    'Thruster_3_Running_Time'
                    'Lube_Oil_System_Type_Of_Pump_In_Service'
                    'Cleaning_Event'
                    'Mode'
                    'Speed_GPS'
                    'Speed_Through_Water'
                    'Speed_Projected_From_Charter_Party'
                    'Water_Depth'
                    'ME_Barometric_Pressure'
                    'ME_Charge_Air_Coolant_Inlet_Temp'
                    'ME_Air_Intake_Temp'
                    'ME_1_Load'
                    'ME_1_Speed_RPM'
                    'Prop_1_Pitch'
                    'ME_1_Aux_Blower'
                    'ME_1_Shaft_Gen_Power'
                    'ME_1_Charge_Air_Inlet_Temp'
                    'ME_1_Scav_Air_Pressure'
                    'ME_1_Pressure_Drop_Over_Scav_Air_Cooler'
                    'ME_1_TC_Speed'
                    'ME_1_Exh_Temp_Before_TC'
                    'ME_1_Exh_Temp_After_TC'
                    'ME_1_Current_Consumption'
                    'ME_1_SFOC_ISO_Corrected'
                    'ME_1_SFOC'
                    'ME_1_Pmax'
                    'ME_1_Pcomp'
                    'ME_2_Load'
                    'ME_2_Speed_RPM'
                    'Prop_2_Pitch'
                    'ME_2_Aux_Blower'
                    'ME_2_Shaft_Gen_Power'
                    'ME_2_Charge_Air_Inlet_Temp'
                    'ME_2_Scav_Air_Pressure'
                    'ME_2_Pressure_Drop_Over_Scav_Air_Cooler'
                    'ME_2_TC_Speed'
                    'ME_2_Exh_Temp_Before_TC'
                    'ME_2_Exh_Temp_After_TC'
                    'ME_2_Current_Consumption'
                    'ME_2_SFOC_ISO_Corrected'
                    'ME_2_SFOC'
                    'ME_2_Pmax'
                    'ME_2_Pcomp'
                    'AE_Barometric_Pressure'
                    'AE_Charge_Air_Coolant_Inlet_Temp'
                    'AE_Air_Intake_Temp'
                    'AE_1_Load'
                    'AE_1_Charge_Air_Inlet_Temp'
                    'AE_1_Charge_Air_Pressure'
                    'AE_1_TC_Speed'
                    'AE_1_Exh_Gas_Temperature'
                    'AE_1_Current_Consumption'
                    'AE_1_SFOC_ISO_Corrected'
                    'AE_1_SFOC'
                    'AE_1_Pmax'
                    'AE_1_Pcomp'
                    'AE_2_Load'
                    'AE_2_Charge_Air_Inlet_Temp'
                    'AE_2_Charge_Air_Pressure'
                    'AE_2_TC_Speed'
                    'AE_2_Exh_Gas_Temperature'
                    'AE_2_Current_Consumption'
                    'AE_2_SFOC_ISO_Corrected'
                    'AE_2_SFOC'
                    'AE_2_Pmax'
                    'AE_2_Pcomp'
                    'AE_3_Load'
                    'AE_3_Charge_Air_Inlet_Temp'
                    'AE_3_Charge_Air_Pressure'
                    'AE_3_TC_Speed'
                    'AE_3_Exh_Gas_Temperature'
                    'AE_3_Current_Consumption'
                    'AE_3_SFOC_ISO_Corrected'
                    'AE_3_SFOC'
                    'AE_3_Pmax'
                    'AE_3_Pcomp'
                    'AE_4_Load'
                    'AE_4_Charge_Air_Inlet_Temp'
                    'AE_4_Charge_Air_Pressure'
                    'AE_4_TC_Speed'
                    'AE_4_Exh_Gas_Temperature'
                    'AE_4_Current_Consumption'
                    'AE_4_SFOC_ISO_Corrected'
                    'AE_4_SFOC'
                    'AE_4_Pmax'
                    'AE_4_Pcomp'
                    'AE_5_Load'
                    'AE_5_Charge_Air_Inlet_Temp'
                    'AE_5_Charge_Air_Pressure'
                    'AE_5_TC_Speed'
                    'AE_5_Exh_Gas_Temperature'
                    'AE_5_Current_Consumption'
                    'AE_5_SFOC_ISO_Corrected'
                    'AE_5_SFOC'
                    'AE_5_Pmax'
                    'AE_5_Pcomp'
                    'AE_6_Load'
                    'AE_6_Charge_Air_Inlet_Temp'
                    'AE_6_Charge_Air_Pressure'
                    'AE_6_TC_Speed'
                    'AE_6_Exh_Gas_Temperature'
                    'AE_6_Current_Consumption'
                    'AE_6_SFOC_ISO_Corrected'
                    'AE_6_SFOC'
                    'AE_6_Pmax'
                    'AE_6_Pcomp'
                    'Boiler_1_Operation_Mode'
                    'Boiler_1_Feed_Water_Flow'
                    'Boiler_1_Steam_Pressure'
                    'Boiler_2_Operation_Mode'
                    'Boiler_2_Feed_Water_Flow'
                    'Boiler_2_Steam_Pressure'
                    'Cooling_Water_System_SW_Pumps_In_Service'
                    'Cooling_Water_System_SW_Inlet_Temp'
                    'Cooling_Water_System_SW_Outlet_Temp'
                    'Cooling_Water_System_Pressure_Drop_Over_Heat_Exchanger'
                    'Cooling_Water_System_Pump_Pressure'
                    'ER_Ventilation_Fans_In_Service'
                    'ER_Ventilation_Waste_Air_Temp'
                    'Remarks'
                    'Entry_Made_By_1'
                    'Entry_Made_By_2'
            };
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
        finalCols = [cols; {col}];
        cols1 = finalCols;
        tab2 = permTab;
        cols2 = finalCols;
        obj = obj.insertSelectDuplicate(tab1, cols1, tab2, cols2);
        
        % Get IMO numbers added to DB
%         [obj, tbl] = obj.select(tempTab, 'DISTINCT(IMO_Vessel_Number)');
        
%         if nargout > 1
           
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
%         end
    
        % Insert into RawData table
        arrayfun(@(x) obj.call('insertFromDNVGLRawIntoRaw', num2str(x)), ...
            IMO, 'Uni', 0);
        
        % Drop temp
        obj = obj.drop('TABLE', tempTab);
        
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

        function obj = insertIntoSpeedPowerCoefficients(obj)
        % insertIntoSpeedPowerCoefficients Insert into table SPCoefficients
            
            % Vector all SP objects
            allSP = [obj.SpeedPower];
            
            % Fit data
            allSP = allSP.fit;
            
            % Insert into table, giving IMO
            tabName = 'speedpowercoefficients';
            
            imo_c = arrayfun(@(x) repmat(x.IMO_Vessel_Number, ...
                [1, numel(x.SpeedPower)]), obj, 'Uni', 0);
            imo_v = [imo_c{:}];
            obj.insertIntoTable(tabName, allSP, 'IMO_Vessel_Number', imo_v);
            
        end
        
        function obj = insertIntoWindCoefficients(obj)
        % insertIntoWindCoefficient Insert data into wind coefficient table
            
            windCoeffs_v = [obj.WindCoefficient];
%             imo_v = [obj.IMO_Vessel_Number];
            tabName = 'WindCoefficientDirection';
            obj.insertIntoTable(tabName, windCoeffs_v);
        end
        
        function obj = ISO19030(obj, varargin)
        % Process raw data for this vessel according to ISO19030 procedure 
        
        % Input
        all_l = true;
        if nargin > 1
            all_l = varargin{1};
            validateattributes(all_l, {'logical'}, {'scalar'}, ...
                'cVessel.ISO19030', 'all', 1);
        end
        
        sp_l = true;
        if nargin > 2
            sp_l = varargin{2};
            validateattributes(sp_l, {'logical'}, {'scalar'}, ...
                'cVessel.ISO19030', 'speedPower', 2);
        end
        
        sfoc_l = true;
        if nargin > 3
            sfoc_l = varargin{3};
            validateattributes(sfoc_l, {'logical'}, {'scalar'}, ...
                'cVessel.ISO19030', 'SFOC', 3);
        end
        
        % Call SQL procedure, with filter inputs
        for oi = 1:numel(obj)
            
            imo = obj(oi).IMO_Vessel_Number;
            inputArg_c = arrayfun(@num2str, [imo, all_l, sp_l, sfoc_l],...
                'Uni', 0);
            proc_sql = 'ProcessISO19030';
            obj(oi) = obj(oi).call(proc_sql, inputArg_c);
            
            % Refresh performance data
            cols = {'DateTime_UTC', 'Speed_Index'};
            [~, tempTbl] = obj(oi).select('PerformanceData', ...
                cols, ...
                ['IMO_Vessel_Number = ', num2str(obj(oi).IMO_Vessel_Number)]);
%             tempTbl = struct(tempTbl);
            if isempty(tempTbl)
                obj(oi).DateTime_UTC = [];
                obj(oi).Performance_Index = [];
                obj(oi).Speed_Index = [];
            else
                obj(oi) = assignPerformanceData(obj(oi), tempTbl, cols);
            end
%             obj(oi).Speed_Index = tempTbl.speed_index;
%             obj(oi).DateTime_UTC = tempTbl.datetime_utc;
        end
        
        end
        
        function obj = plotSpeedIndex(obj)
        % 
            
            figure();
            for oi = 1:numel(obj)
                
                scatter(obj(oi).DateTime_UTC, obj(oi).Speed_Index, '*');
            end
        end
        
        function obj = updatePerformanceTable(obj, newTable)
        % updatePerformanceTable Change value of PerformanceTable property
            
            % Error if input not member of accepted table names
            dataTables_c = {'DNVGLPerformanceData', 'PerformanceData', ...
               'ForcePerformanceData'};
            if ~ismember(newTable, dataTables_c)

              errid = 'cV:IncorrectPerformanceTable';
              errmsg = 'Performance table name must match one of those in DB';
              error(errid, errmsg);
            end

            % If name has changed, load performance data from new table
            oldTabl = obj.PerformanceTable;
            if ~isequal(oldTabl, newTable);
                
                % Assign table name
                [obj.PerformanceTable] = deal(newTable);
                
                % Get new dd, vessel data
                [imo, ddi] = currentIMODryDockIndex(obj);
                ddi_c = {ddi};
                newData = obj.performanceData(imo, ddi_c{:});

                % Resize array to fit new data
                obj = obj.fitToData(newData);

                % Assign data
                obj = obj.assignPerformanceData(newData);
            end
        end
        
        function [rawStruc, rawTable] = rawData(obj)
        % rawData Get raw data for this vessel at this dry-docking interval
        
            % Get raw table name, performanceData inputs
            rawTable = strrep(obj(1).PerformanceTable, 'PerformanceData',...
                'raw');
            [imo, ddi] = obj.currentIMODryDockIndex;
            [~, rawColumns] = obj(1).colNames(rawTable);
            excludedCols = {'id'};
            rawColumns = setdiff(rawColumns, excludedCols);
            inputs_c = {imo, ddi, rawColumns};
            
            % Get DDi, Vessel data from raw table using PerformanceTable
            % property
            perTable = obj(1).PerformanceTable;
            [obj.PerformanceTable] = deal(rawTable);
            rawStruc = obj(1).performanceData(inputs_c{:});
            [obj.PerformanceTable] = deal(perTable);
            
            % Convert raw datetime to datenum
            tempObj = obj;
            tempObj = tempObj.assignPerformanceData(rawStruc, 'DateTime_UTC');
            [rawStruc.DateTime_UTC] = deal(tempObj.DateTime_UTC);
            
            % Modify or Remove data affected not read directly from DB
            rawStruc = rmfield(rawStruc, 'DryDockInterval');
            dataField_c = setdiff(fieldnames(rawStruc), 'IMO_Vessel_Number');
            dataField1 = dataField_c{1};
            for ri = 1:numel(rawStruc)
                
                rawStruc(ri).IMO_Vessel_Number = ...
                    repmat(rawStruc(ri).IMO_Vessel_Number, 1, ...
                    length(rawStruc(ri).(dataField1)));
            end
            
            rawStruc = arrayfun(@(x) structfun(@(y) y(:), x, 'Uni', 0),...
                rawStruc);
            
            % Table output: create vector cell of tables, vertically
            % concatenate them, return as vector of tables
            rawTable = struct2table(rawStruc);
        end
        
        function obj = loadFile(obj)
            
            
            
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
        
%         [ out ] = performanceData(imo, varargin)
        
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
        
        function obj = dummy(obj, varargin)
           
            obj = obj.fitToData(varargin{:});
            
        end
        
    end
    
    methods(Access = private, Hidden)
        
        function obj = assignPerformanceData(obj, dataStruct, varargin)
        % assignPerformanceData Assign from struct or table to obj
        
        % Input
%         validateattributes(dataStruct, {'struct'}, {}, ...
%             'cVessel.assignPerformanceData', 'dataStruct', 2);
        
        propName = lower({'DateTime_UTC',...
                    'Speed_Index',...
                    'Performance_Index',...
                    'DryDockInterval'
                    });
%         fieldName = lower(propName);
        if nargin > 2
            
            propName = varargin{1};
            propName = validateCellStr(propName, ...
                'cVessel.assignPerformanceData', 'propName', 3);
        end
        
        % Iterate objects and assign to properties
        for oi = 1:numel(obj)
            for pi = 1:numel(propName)

                obj(oi).(propName{pi}) = dataStruct.(lower(propName{pi}));
            end
        end
        end
        
        function obj = fitToData(obj, struc)
        % fitToData Expand OBJ to fit structure based on dates in structure
        
        % Inputs
        validateattributes(struc, {'struct'}, {'2d'}, ...
            'cVessel.fitToData', 'struc', 2);
        
        % Number of new vessels / columns
        [oldIMO, oldIntervals] = currentIMODryDockIndex(obj);
        newIMO = [struc(1, :).IMO_Vessel_Number];
        [~, ~, oldColsI] = intersect(oldIMO, newIMO);
        
        newRows_c = arrayfun(@(x) x.DryDockInterval, struc, 'Uni', 0);
        newRows_cc = mat2cell(newRows_c, size(newRows_c, 1), ...
            ones(1, size(newRows_c, 2)));
        allIntervalRow_l = cellfun(@(x) ~any(isempty(x)), newRows_cc);
        newIntervals = [newRows_c{:, find(allIntervalRow_l, 1)}];
        
        [~, ~, oldRowsI] = intersect(oldIntervals, newIntervals);
        
        % Assign old objects to keep into new array
        newObj(size(struc, 1), size(struc, 2)) = cVessel();
        
        % Assign existing objects into new array if they should exist in
        % new array
        if ~isempty(oldIntervals) && ~isempty(oldRowsI) && ~isempty(oldColsI)
            
            newObj(oldRowsI, oldColsI) = obj(oldRowsI, oldColsI);
        end
        
        obj = newObj;
        
        end
        
        function [imo, ddi] = currentIMODryDockIndex(obj)
        % currentIMODryDockIndex IMO and dry-dock index vector
        
        % IMO vector is in first row of object array
        imo = [obj(1, :).IMO_Vessel_Number];
            
        % DDi is found in vessel with no empty Dry Dock intervals
        oldRows_c = arrayfun(@(x) x.DryDockInterval, obj, 'Uni', 0);
        allIntervalRow_l = all(cellfun(@(x) ~(isempty(x)), oldRows_c));
        ddi = [oldRows_c{:, find(allIntervalRow_l, 1)}];
        
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
           
%            if ~isempty(obj.DryDockDates)
%                
%                [obj.DryDockDates(:).IMO_Vessel_Number] = deal(IMO);
%            end
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
                date_v = dates(:)';
            else
                error(errid, errmsg);
            end
            obj.DateTime_UTC = date_v;
        
       end
       
       function obj = set.Performance_Index(obj, per)
           
           obj.Performance_Index = per(:)';
       end
       
       function obj = set.Speed_Index(obj, spe)
           
           obj.Speed_Index = spe(:)';
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
       
       function etaD = get.Propulsive_Efficiency(obj)
           
       % Get matrix of speed, power, draft, trim
       spdt = obj.SpeedPower.speedPowerDraftTrim;
       
       % Index appropriately
       etaD = spdt(:, 5);
       
%            sp = obj.SpeedPower;
%            if isempty(sp)
%                
%                etaD = [];
%            else
%                
%                etaD_c = {sp.Propulsive_Efficiency};
%                etaD_c(cellfun(@isempty, etaD_c)) = { nan };
%                etaD = [etaD_c{:}];
%            end
       end
       
       function id = get.Wind_Model_ID(obj)
           
           id = [];
           if ~isempty(obj.WindCoefficient)
               
               id = obj.WindCoefficient.ModelID;
           end
       end

       function model = get.Engine_Model(obj)
       % Get method for dependent property Engine_Model
          
          model = '';
          if ~isempty(obj.Engine)
              
              model = obj.Engine.Name;
          end
       end
       
       function windRefHeight = get.Wind_Reference_Height_Design(obj)
           
           windRefHeight = [];
           if ~isempty(obj.WindCoefficient)
               
               windRefHeight = obj.WindCoefficient.Wind_Reference_Height_Design;
           end
       end
       
       function obj = set.DryDockDates(obj, ddd)
       % 
       
       % Input
       validateattributes(ddd, {'cVesselDryDockDates'}, {'scalar'});
       
       % Assign IMO
       imo = obj.IMO_Vessel_Number;
       if ~isempty(imo)
           ddd.IMO_Vessel_Number = imo;
       end
       
       % Assign object
       obj.DryDockDates = ddd;
       
       end
       
       function obj = set.SpeedPower(obj, sp)
           
           % Input
           validateattributes(sp, {'cVesselSpeedPower'}, {'vector'});

           % Assign IMO
           imo = obj.IMO_Vessel_Number;
           if ~isempty(imo)
               [sp.IMO_Vessel_Number] = deal(imo);
           end
           
           % Copy connection details to object
           sp = sp.copyConnection(obj);
           
           % Assign object
           obj.SpeedPower = sp;
       end
    end
end