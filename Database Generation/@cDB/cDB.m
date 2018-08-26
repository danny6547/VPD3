classdef cDB
    %cDB Generate Hull Performance database structure and insert data
    %   cDB will generate the tables and procedures of existing schema, and
    %   load data into them, to create the Hempel Hull Performance
    %   database. The prerequisites are therefore the schema named 'test'
    %   and 'hull_performance' and the files containing DNVGL raw and
    %   processed data.
    %
    % cDB Methods:
    %    create - Create database with given name, optionally specifying 
    %    top level directory for location of database code repository. 
    %    createTest - Create the database named 'test', used for running
    %    MATLAB unit tests of the MySQL procedures related to the ISO19030
    %    standard.
    %    createHullPer - Create the database named 'hull_performance', the
    %    Hempel Hull Performance database, which will store and process
    %    vessel sensor and performance data.
    
    properties
        
        VesselDirectory = '\\hempelgroup.sharepoint.com@SSL\DavWWWRoot\sites\HullPerformanceManagementTeam\Vessel Library';
        SQL;
        BuildSchema = true;
        LoadRaw = true;
        LoadPerformance = true;
        RunISO = true;
        InsertStatic = true;
        InsertStaticDir = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'Insert_Static');
        InsertStaticScript = {...
            ['L:\Project\MWB-Fuel efficiency\Hull and propeller performance'...
            '\Vessels\AMCL\Data\Scripts\Insert_Static_AMCL.m']...
            ['L:\Project\MWB-Fuel efficiency\Hull and propeller performance'...
            '\Vessels\CMA CGM\Data\Raw\DNVGL\Scripts\Insert_Static_CMA_CGM.m']...
            ['L:\Project\MWB-Fuel efficiency\Hull and propeller performance'...
            '\Vessels\UASC data\Scripts\Insert_Static_UASC.m']...
%             ['L:\Project\MWB-Fuel efficiency\Hull and propeller performance'...
%             '\Vessels\UASC data\Scripts\Insert_Static_Al_Farahidi.m']...
            };
        InsertInServiceScript = {};
        ForceDir = ['C:\Users\damcl\OneDrive - Hempel Group\Documents'...
               '\L DRIVE BACKUP\ARCHIVE\External Vessel Data\Force'];
        DNVGLDir = ['C:\Users\damcl\OneDrive - Hempel Group\Documents\'...
            'L DRIVE BACKUP\ARCHIVE\External Vessel Data\DNV-GL'];
        ISO19030Parameters = {9288095, 'Only one speed, power curve from Sea Trial and that is of sister vessel New Century. Estimates made for Ta and Anemometer Height. Shaft torsiometer data utilised. Wind coefficients taken from ISO15016 for tanker with conventional bow. No displacement data available prior to 2016.', {};...                    % New Spirit
                              9445631, 'No speed, power curves available so that of New Century, another vessel of the same owner applied. Estimates made for Ta and Anemometer Height. Shaft torsiometer data utilised. Wind coefficients taken from ISO15016 for tanker with conventional bow. No displacement data available prior to 2016.', {}; ...     % New Vanguard
                              9434632, 'No speed, power curves available so that of New Century, another vessel of the same owner applied. Estimates made for Ta and Anemometer Height. Shaft torsiometer data utilised. Wind coefficients taken from ISO15016 for tanker with conventional bow. No displacement data available prior to 2016.', {}; ...     % New Success
                              9525924, '', {};...
                                9525936, '', {};...
                                9525895, '', {};...
                                9525871, '', {};...
                                9525869, '', {};...
                                9525883, '', {};...
                                9525900, '', {};...
                                9525857, '', {};...
                                9349552, '', {};...
                                9349502, '', {};...
                                9349538, '', {};...
                                9349564, '', {};...
                                9349497, '', {};...
                                9349540, '', {};...
                                9349514, '', {}...
                              };
    end
    
    properties(Hidden)
        
       TopLevelDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
        
    end
    
    methods
    % Methods to delete
       
       function obj = cDB(varargin)
       % cDB Constructor method for class cDB.
       
           obj.SQL = cMySQL(varargin{:});
       end
       
       function create(obj, name, varargin)
       % create Create a new database with given name.
       % create(obj, name) will create the Hull Performance database in an
       % existing MySQL schema with input string NAME. The procedures and
       % tables of the database will be created in schema NAME and then
       % data will be loaded from files downloaded from the DNVGL
       % ECOInsight webpage "manage data" function, followed by the
       % performance data.
       % create(obj, name, topleveldir) will, in addition to the above, 
       % take string TOPLEVELDIR as the path to the top-level directory of
       % the Vessel Performance Database repository working directory.
       
       scripts_c = obj.InsertStaticScripts;
       
       % Input
       validateattributes(name, {'char'}, {'vector'}, 'create', 'name', 2);
       
       topleveldir = obj.TopLevelDir;
       if nargin > 2
           topleveldir = varargin{1};
           validateattributes(topleveldir, {'char'}, {'vector'}, 'create', ...
               'topleveldir', 3);
       end
       
       % Change to desired database
       obj.Database = name;
       
       % Get file paths to create tables
       if obj.BuildSchema
           
           ISODir = 'ISO 19030';
           ISO19030Create_c = {...
                                'createAnalysis.sql'
                                'createBunkerDeliveryNote.sql'
                                'createChauvenetFilter.sql'
                                'createDisplacementTable.sql'
                                'createGlobalConstants.sql'
                                'createModels.sql'
                                'createPerformanceData.sql'
                                'createSFOCCoefficients.sql'
                                'createSensorRecalibration.sql'
                                'createSpeedPower.sql'
                                'createSpeedPowerCoefficients.sql'
                                'createTempRaw.sql'
                                'createTempRawISO.sql'
                                'createVessels.sql'
                                'createWindCoefficients.sql'      
                                'IMOStartEnd.sql'
                                'ISO19030.sql'
                                'ISO19030A.sql'
                                'ISO19030B.sql'
                                'ISO19030C.sql'
                                'ProcessISO19030.sql'
                                'createBunkerDeliveryNote.sql'
                                'createChauvenetFilter.sql'
                                'createDisplacementTable.sql'
                                'createGlobalConstants.sql'
                                'createPerformanceData.sql'
                                'createSFOCCoefficients.sql'
                                'createSensorRecalibration.sql'
                                'createSpeedPower.sql'
                                'createSpeedPowerCoefficients.sql'
                                'createTempRaw.sql'
                                'createTempRawISO.sql'
                                'createVessels.sql'
                                'createWindCoefficients.sql'
                                'filterPowerBelowMinimum.sql'
                                'filterReferenceConditions.sql'
                                'filterSFOCOutOfRange.sql'
                                'filterSpeedPowerLookup.sql'
                                %'insertFromDNVGLRawIntoRaw.sql'
                                'insertIntoPerformanceData.sql'
                                'isBrakePowerAvailable.sql'
                                'isShaftPowerAvailable.sql'
                                'normaliseHigherFreq.sql'
                                'normaliseLowerFreq.sql'
                                'removeFOCBelowMinimum.sql'
                                'removeInvalidRecords.sql'
                                'removeNullRows_prc.sql'
                                'sortOnDateTime.sql'
                                'updateAirDensity.sql'
                                'updateAirResistanceNoWind.sql'
                                'updateBrakePower.sql'
                                'updateChauvenetCriteria.sql'
                                'updateCorrectedPower.sql'
                                'updateDeliveredPower.sql'
                                'updateDisplacement.sql'
                                'updateExpectedSpeed.sql'
                                'updateFromBunkerNote.sql'
                                'updateMassFuelOilConsumed.sql'
                                'updateShaftPower.sql'
                                'updateSpeedLoss.sql'
                                'updateTransProjArea.sql'
                                'updateTrim.sql'
                                'updateValidated.sql'
                                'updateWindResistanceCorrection.sql'
                                'updateWindResistanceRelative.sql'
                                'validateFrequencies.sql'
                                'createvesselspeedpowermodel.sql'
                                'updateDefaultValues.sql'
                                'updateWindReference.sql'
                                'knots2mps.sql'
                                'updateNearestTrim.sql'
                                'applyFilters.sql'
                                'bar2Pa.sql'
                                };
           createFiles1_c = cellfun(@(x) fullfile(topleveldir, ISODir, x), ...
               ISO19030Create_c, 'Uni', 0);

           createFiles2Dir_ch = 'Create Tables';
           createFiles2_c = {...
                        'createDDDtable.sql'
                        %'createDNVGLPerformanceData.sql'
                        %'createDNVGLRawTable.sql'
                        %'createDNVGLRawTempTable.sql'
                        'createRawData.sql'
                        'createVesselCoating.sql'
                    };
           createFiles2_c = cellfun(@(x) fullfile(topleveldir, createFiles2Dir_ch, x), ...
               createFiles2_c, 'Uni', 0);

%            dnvglrawDir_ch = '\DNVGL Raw';
% 
%            createFiles3_c = {...
%                'convertDNVGLRawToRawData.sql'
%                'createTempBunkerDeliveryNote.sql'
%                };
%            createFiles3_c = cellfun(@(x) fullfile(topleveldir, dnvglrawDir_ch, x), ...
%                createFiles3_c, 'Uni', 0);

           createFiles4_c = {['C:\Users\damcl\OneDrive - Hempel Group\'...
               'Documents\SQL\tests\EcoInsight Test Scripts\Accessing Database'...
               '\performanceData.sql']};

           createFiles5_c = {...
               'createTempMarorkaRaw.sql'
               'insertFromMarorkaRawIntoRaw.sql'
               };
           marorkaDir_ch = 'Marorka';
           createFiles5_c = cellfun(@(x) fullfile(topleveldir, marorkaDir_ch, x), ...
               createFiles5_c, 'Uni', 0);

           createFiles_c = [createFiles1_c; createFiles2_c;...
               createFiles4_c; createFiles5_c];

           % Create procedures for creating tables
           obj.source(createFiles_c);

           % Create tables
           createProc_c = {...
                           'createAnalysis'
                           'createModels'
                           'createwindcoefficientdirection'
                           'createVessels'
                           'createspeedPowerCoefficients'
                           'createSpeedPower'
                           'createSFOCCoefficients'
                           'createsensorRecalibration'
                           'createPerformanceData'
                           'createglobalConstants'
                           'createDisplacement'
                           'createBunkerDeliveryNote'
                           'createvesselCoating'
                           'createrawdata'
%                            'createDNVGLRawTempTable'
%                            'createDNVGLRaw'
%                            'createDNVGLPerformanceData'
                           'createDryDockDates'
                           'createTempChauvenetFilter'
                           'createvesselspeedpowermodel'
                           };

           % Check there are as many proc as files
           cellfun(@(x) obj.call(x), createProc_c, 'Uni', 0);

       end
       
%        if obj.LoadPerformance
%            
%            % Insert performance data
%            allPerformanceFile_ch = ['L:\Project\MWB-Fuel efficiency\Hull '...
%                'and propeller performance\External Vessel Data\DNV-GL\'...
%                'Performance\Download.xlsx'];
%            obj_ves = cVessel();
%            obj_ves.loadDNVGLPerformance(allPerformanceFile_ch);
% %            run(['C:\Users\damcl\OneDrive - Hempel Group\Documents\SQL\tests\'...
% %                'EcoInsight Test Scripts\Vessel Data\Load_All_DNVGL_Performance.m']);
%        end
       
       % Insert raw data, bunker delivery note
       if obj.LoadRaw
           
%            rawDirect = 'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\External Vessel Data\DNV-GL\Raw';
%            rawFiles_st = rdir([rawDirect, '\**\*.csv']);
%            rawFiles_c = {rawFiles_st.name};
%            bunkerFile_ch = 'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\External Vessel Data\DNV-GL\Bunker Reporting\2 Bunker reporting 2017-10-31 09_39.csv';
%            
%            obj_ves = cVessel();
%            obj_ves.Database = name;
%            obj_ves = obj_ves.insertBunkerDeliveryNoteDNVGL(bunkerFile_ch);
%            obj_ves.loadDNVGLRaw(rawFiles_c);

            % Insert time-series data
            vess = cVessel();
            AMCLNoonFiles = 'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\AMCL\New Spirit\New Spirit - ????_before 2016.xls';
            vess(1) = vess(1).loadAMCLRaw(AMCLNoonFiles, {'IMO_Vessel_Number = 9288095', 'Displacement = 299825000'});

            q = rdir('L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\AMCL\New Spirit\**\*.xlsx');
            NewSpiritDNVGLFiles_c = {q.name}'; 
            vess(1) = vess(1).loadDNVGLReportingFormat(NewSpiritDNVGLFiles_c, 9288095);

            filename = 'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\AMCL\New Success\New Success - 2015_01 to 2016_01.xls';
            vess(1) = vess(1).loadAMCLRaw(filename, {'IMO_Vessel_Number = 9434632'});

            NewSuccessFiles_c = {...
            'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\AMCL\New Success\Hempel''s Data Collection Form (Feb-2017).xlsx',...
            'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\AMCL\New Success\Hempel''s Data Collection Form OF (MAR-2017).xlsx',...
            'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\AMCL\New Success\New Success Hempel''s Data Collection Form (Dec-2016).xlsx',...
            'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\AMCL\New Success\New Success Hempel''s Data Collection Form (Oct-2016).xlsx',...
            'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\AMCL\New Success\New Success Hempel''s Data Collection Form-SEP-2016.xlsx',...
            'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\AMCL\New Success\New Success Hempel''s Data Collection OF NOV-2016.xlsx'};
            vess(1) = vess(1).loadDNVGLReportingFormat(NewSuccessFiles_c, 9434632);

            q = rdir('L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\AMCL\New Vanguard\**\*.xlsx');
            NewVanguardFiles_c = [{q.name}'; 'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\AMCL\New Vanguard\M.T. NEW VANGUARD -JUN 2016 Hempel''s Data Collection Form_Hull Performan....xlsx'];
            vess(1) = vess(1).loadDNVGLReportingFormat(NewVanguardFiles_c, 9445631, 'firstRowIdx', 16);

            % Take Speed over ground as that through water because data missing
            vess(1).update('RawData', 'Speed_Through_Water', 'Speed_Over_Ground WHERE IMO_Vessel_Number = 9445631');
            clear vess;
       end
       
%        % Load Dry Docking Dates from Files
%        % CMA CGM
%        ddFiles = 'Metadata\Cart reports CMA CGM.xlsx';
%        objddd = cVesselDryDockDates();
%        objddd = objddd.readFile(ddFiles, 'dd-mm-yy');
%        objddd.insertIntoTable;
%        
%        % Euronav
%        objddd = cVesselDryDockDates();
%        ddFileEuronav = ['L:\Project\MWB-Fuel efficiency\'...
%            'Hull and propeller performance\Vessels\Euronav\Data\Scripts\'...
%            'DryDockDates.xlsx'];
%        objddd = objddd.readFile(ddFileEuronav, 'dd-mm-yyyy');
%        objddd.insertIntoTable;
%        
%        % UASC
%        objddd = cVesselDryDockDates();
%        ddFileUASC = ['https://hempelgroup.sharepoint.com/sites/'...
%            'HullPerformanceManagementTeam/Vessel Library/UASC/Scripts'];
%        objddd = objddd.readFile(ddFileUASC, 'yyyy-mm-dd');
%        objddd.insertIntoTable;
%        
%        % Load standard wind coefficients
%        windFile = ['L:\Project\MWB-Fuel efficiency\Hull and propeller '...
%            'performance\Other Vessel Data\Wind\ISO15016\'...
%            'Insert_ISO15016_Wind_Data.m'];
%        run(windFile);
       
       % Run Additional Scripts
       executedFully_l = false(size(scripts_c));
       insertedVessels = [];
       if obj.InsertStatic
           
           for si = 1:numel(scripts_c)

               % Run script, temporarily adding directory to path if necessary
               vess = cVessel();
               [vess.Database] = deal(name);
               currScript = scripts_c{si};

               try run(currScript);

                   executedFully_l(si) = true;
               catch ee

                   if strcmp(ee.identifier, 'MATLAB:UndefinedFunction')

                       scriptDir = fileparts(currScript);
                       addpath(scriptDir);

                       try run(currScript);

                       catch ee

                           rmpath(scriptDir);
                           throw(ee);
                       end

                   else

                       throw(ee);
                   end
               end

               % Change database of vessel returned by script and insert data
               vess.insert;
               insertedVessels = [insertedVessels, vess];

               % Clear up handles with ModelID properties
    %            vess.delete;
    %            sp = [vess.SpeedPower];
    %            sp.delete;
           end
       end
       
       if obj.RunISO
       
           % Run ISO Procedure on vessels inserted
           insertedIMO_v = [insertedVessels.IMO_Vessel_Number];
           ISOParams = obj.ISO19030Parameters;
           rowsInTable_l = ismember([ISOParams{:, 1}], insertedIMO_v);
           additionalInputs_c = ISOParams(rowsInTable_l, 3);
           comment_c = ISOParams(rowsInTable_l, 2);
           vessels2run_l = ismember(insertedIMO_v, [ISOParams{:, 1}]);
           vess = insertedVessels(vessels2run_l);
           vess.ISO19030Analysis(comment_c, additionalInputs_c);
       end
       
       end
       
       function createTest(obj)
       % createTest Create the test database
       
%        obj = obj.test;
       obj.create(obj.Database);
           
       end
       
       function createHullPer(obj)
       % createTest Create the Hull Performance database
       
       obj = obj.hullPer;
       obj.create(obj.Database);
           
       end
       
       function createHempel(obj)
       % Create database for Hempel performance analysis
       
       % Create Database
       dbname = 'Static';
       obj = obj.drop('DATABASE', dbname, true);
       obj = obj.createDatabase(dbname, true);
       obj.Database = dbname;
       
       % Build Schema
       topleveldir = obj.TopLevelDir;
       ISODir = 'ISO 19030';
       
       % Build Schema
       createTable_c = {
        'createAnalysis.sql             '
        'createGlobalConstants.sql              '
        'createPerformanceData.sql         '
        'createRawData.sql                        '
        'createSensorRecalibration.sql                    '
        'createTempRawISO.sql     '
        };
       createStaticFullpath_c = cellfun(@(x) fullfile(topleveldir, ISODir, x), ...
           createTable_c, 'Uni', 0);
       obj = obj.source(createStaticFullpath_c);
       static_c = strrep(createStatic_c, '.sql', '');
       cellfun(@(x) obj.call(x), static_c);
       
       createProc_c = {
        'del10Min.sql'
        'erfc10Mins.sql                     	'
        'filterPowerBelowMinimum.sql            '
        'filterReferenceConditions.sql                    '
        'filterSFOCOutOfRange.sql                     '
        'filterSpeedPowerLookup.sql                    '
        'isBrakePowerAvailable.sql'
        'ISO19030A.sql'
        'ISO19030B.sql'
        'ISO19030C.sql'
        'isShaftPowerAvailable.sql'
        'isBrakePowerAvailable.sql'
        'normaliseHigherFreq.sql'
        'normaliseLowerFreq.sql'
        'ProcessISO19030.sql'
        'removeFOCBelowMinimum.sql'
        'removeInvalidRecords.sql'
        'removeNullRows_prc.sql'
        'sem10Mins.sql'
        'sortOnDateTime.sql'
        'updateAirDensity.sql'
        'updateAirResistanceNoWind.sql'
        'updateBrakePower.sql'
        'updateChauvenetCriteria.sql'
        'updateCorrectedPower.sql'
        'updateDefaultValues.sql'
        'updateDeliveredPower.sql'
        'updateDisplacement.sql'
        'updateDisplacementFromDraftTrim.sql'
        'updateDisplacementWithTrimCorrection.sql'
        'updateExpectedSpeed.sql'
        'updateFromBunkerNote.sql'
        'updateMassFuelOilConsumed.sql'
        'updateNearestTrim.sql'
        'updateShaftPower.sql'
        'updateSpeedLoss.sql'
        'updateTransProjArea.sql'
        'updateTrim.sql'
        'updateValidated.sql'
        'updateWindReference.sql'
        'updateWindResistanceCoefficient.sql'
        'updateWindResistanceCorrection.sql'
        'updateWindResistanceRelative.sql'
        'validateFrequencies.sql'
        
        'insertFromDNVGLRawIntoRaw.sql            '
        'insertIntoPerformanceData.sql           '
        'createWindCoefficientModelValue.sql  	'
        
        'knots2mps.sql'
        'mu10Min.sql'
        'knots2mps.sql'
        'rad2deg.sql'
        
        };
       createProcFullpath_c = cellfun(@(x) fullfile(topleveldir, ISODir, x), ...
           createProc_c, 'Uni', 0);
       proc_c = strrep(createProcFullpath_c, '.sql', '');
       cellfun(@(x) obj.call(x), proc_c);
       
       end
       
       function loadHempel(obj)
          
           obj.loadHempelModel;
           obj.loadHempelTime;
       end
       
       function runHempel(obj)
       % Run analyses in Hempel database
       
       % Insert static and time data if requested
       if obj.InsertStatic
           
           obj = obj.loadHempel;
       end
       
       % Run Analyses
       if obj.RunISO
       
           % Get IMO of vessels in Static DB
           static_cm = cMySQL();
           static_cm.Database = 'Static';
           [~, vess_tbl] = static_cm.select('Vessel', ...
               'DISTINCT(IMO) AS ''IMO''');
           insertedIMO_v = vess_tbl.IMO;
%            insertedIMO_v = [insertedVessels.IMO_Vessel_Number];
           
           % Run Analyses for requested vessels which have static data
           ISOParams = obj.ISO19030Parameters;
           rowsInTable_l = ismember([ISOParams{:, 1}], insertedIMO_v);
           additionalInputs_c = ISOParams(rowsInTable_l, 3);
           comment_c = ISOParams(rowsInTable_l, 2);
           vessels2run_l = ismember(insertedIMO_v, [ISOParams{:, 1}]);
           vess = insertedVessels(vessels2run_l);
           vess.ISO19030Analysis(comment_c, additionalInputs_c);
       end
       
       end
       
    end
    
    methods
    % Methods to keep
    
       function [obj, file] = insertScript(obj, type, varargin)
        % insertStaticScripts Return all insert static scripts under top dir

        % Input
        topdir = obj.VesselDirectory;
        if nargin > 2

            topdir = varargin{1};
            validateattributes(topdir, {'char'}, {'vector'},...
                'cDB.insertStaticScripts', 'topdir', 3);
        end

        % Concatenate search string to dir path
        switch type
            case 'Static'
                
                search_ch = '\**\Insert_Static_*.m';
                prop = 'InsertStaticScript';
            case 'InService'
                
                search_ch = '\**\Insert_InService_*.m';
                prop = 'InsertInServiceScript';
            otherwise
                
                errid = 'cDB:ScriptTypeUnknown';
                errmsg = 'Input TYPE must be either ''Static'' or ''InService''';
                error(errid, errmsg);
        end
        topdir = [topdir, search_ch];

        % Find recursively all .m files under directory
        tic;
        file_st = rdir(topdir);
        file = {file_st.name};
        toc;
        
        % Assign
        obj.(prop) = file;

       end
       
       function [obj, file] = insertStaticScript(obj, varargin)
           
           [obj, file] = obj.insertScript('Static', varargin{:});
       end
       
       function [obj, file] = insertInServiceScript(obj, varargin)
           
           [obj, file] = obj.insertScript('InService', varargin{:});
       end
       
       function createStatic(obj, varargin)
       % Create database for static vessel data.
       
       % Input
       dbname = 'static';
       if nargin > 1 && ~isempty(varargin{1})
           
           dbname = varargin{1};
           validateattributes(dbname, {'char'}, {'vector'}, ...
               'cDB.createStatic', 'dbname', 2);
       end
       
       % Create Database
       sql = obj.SQL;
       sql.drop('DATABASE', dbname, true);
       sql.Database = '';
       [~, connInput_c] = sql.connectionData;
       sql = cMySQL(connInput_c{:});
       sql.createDatabase(dbname, true);
       sql = cMySQL('SavedConnection', dbname);
       obj.SQL = sql;
       
       % Build Schema
       topleveldir = obj.TopLevelDir;
       ISODir = 'ISO 19030';
       createStatic_c = {
        'createRawData.sql             '
        'createBunkerDeliveryNote.sql             '
        'createDisplacementModel.sql              '
        'createDisplacementModelValue.sql         '
        'createDryDock.sql                        '
        'createEngineModel.sql                    '
        'createSpeedPowerCoefficientModel.sql     '
        'createSpeedPowerCoefficientModelValue.sql'
        'createVessel.sql                     	'
        'createVesselConfiguration.sql            '
        'createVesselGroup.sql                    '
        'createVesselInfo.sql                     '
        'createVesselOwner.sql                    '
        'createVesselToVesselOwner.sql            '
        'createWindCoefficientModel.sql           '
        'createWindCoefficientModelValue.sql  	'
        'createSpeedPower.sql'
        'createGlobalConstants.sql'
        'createCalculatedData.sql      '
        'createAnalysis.sql'};
    createProcedures_c = {
        'createTempChauvenetFilter.sql'
        'ISO19030.sql'
        'ProcessISO19030.sql'
        'createChauvenetFilter.sql'
        'filterPowerBelowMinimum.sql'
        'filterReferenceConditions.sql'
        'filterSFOCOutOfRange.sql'
        'filterSpeedPowerLookup.sql'
        'isBrakePowerAvailable.sql'
        'isShaftPowerAvailable.sql'
        'normaliseHigherFreq.sql'
        'normaliseLowerFreq.sql'
        'removeFOCBelowMinimum.sql'
        'removeInvalidRecords.sql'
        'removeNullRows_prc.sql'
        'sortOnDateTime.sql'
        'updateAirDensity.sql'
        'updateAirResistanceNoWind.sql'
        'updateBrakePower.sql'
        'updateChauvenetCriteria.sql'
        'updateCorrectedPower.sql'
        'updateDeliveredPower.sql'
        'updateDisplacement.sql'
        'updateExpectedSpeed.sql'
        'updateFromBunkerNote.sql'
        'updateMassFuelOilConsumed.sql'
        'updateShaftPower.sql'
        'updateSpeedLoss.sql'
        'updateTransProjArea.sql'
        'updateTrim.sql'
        'updateValidated.sql'
        'updateWindResistanceCorrection.sql'
        'updateWindResistanceRelative.sql'
        'validateFrequencies.sql'
        'updateDefaultValues.sql'
        'updateWindReference.sql'
        'knots2mps.sql'
        'updateNearestTrim.sql'
        'applyFilters.sql'
        'bar2Pa.sql'};
       createStaticFullpath_c = cellfun(@(x) fullfile(topleveldir, ISODir, x), ...
           createStatic_c, 'Uni', 0);
       sql.source(createStaticFullpath_c);
       static_c = strrep(createStatic_c, '.sql', '');
       cellfun(@(x) sql.call(x), static_c, 'Uni', 0);
       
       % Create procedures
       createStaticFullpath_c = cellfun(@(x) fullfile(topleveldir, ISODir, x), ...
           createProcedures_c, 'Uni', 0);
       sql.source(createStaticFullpath_c);
       
%        % Run all files in InsertStatic dir
%        if obj.InsertStatic
%            
%            findStaticFiles_ch = [obj.InsertStaticDir, '\*.m'];
%            allFiles_st = dir(findStaticFiles_ch);
%            allFilesNames = cellfun(@(x) fullfile(obj.InsertStaticDir, x), ...
%                {allFiles_st.name}, 'Uni', 0);
%            for fi = 1:numel(allFilesNames)
% 
%                run(allFilesNames{fi});
%            end
%        end
%        obj.createInService(dbname, false);

       end
       
       function createInService(obj, varargin)
       
       % Input
       dbname = 'InService';
       if nargin > 1 && ~isempty(varargin{1})

           dbname = varargin{1};
           dbname = obj.validateDBName(dbname);
       end
       obj.SQL = cMySQL('SavedConnection', dbname);
       
       refresh_l = true;
       if nargin > 2
           
           refresh_l = varargin{2};
           validateattributes(refresh_l, {'logical'}, {'scalar'},...
               'cDB.createInService', 'refresh', 3);
       end
           
       % Create Database
       sql = obj.SQL;
       if refresh_l
           
           sql.drop('DATABASE', dbname, true);
           sql.createDatabase(dbname, true);
       end
       
       % Build Schema
%        obj.Database = dbname;
       topleveldir = obj.TopLevelDir;
       ISODir = 'ISO 19030';
       createInService_c = {
                        'createRawData.sql             '
                        'createCalculatedData.sql      '
                        'createTempChauvenetFilter.sql'};
       createStaticFullpath_c = cellfun(@(x) fullfile(topleveldir, ISODir, x), ...
           createInService_c, 'Uni', 0);
       sql.source(createStaticFullpath_c);
       createInService_c = strrep(createInService_c, '.sql', '');
       cellfun(@(x) sql.call(x), createInService_c, 'Uni', 0);
       
       % Create ISO19030 Procedures
       iso19030_c = {'createAnalysis.sql'
                                'createBunkerDeliveryNote.sql'
                                'createChauvenetFilter.sql'
                                'createDisplacementTable.sql'
                                'createGlobalConstants.sql'
                                'createModels.sql'
                                'createPerformanceData.sql'
                                'createSFOCCoefficients.sql'
                                'createSensorRecalibration.sql'
                                'createSpeedPower.sql'
                                'createSpeedPowerCoefficients.sql'
                                'createTempRaw.sql'
                                'createTempRawISO.sql'
                                'createVessels.sql'
                                'createWindCoefficients.sql'      
                                'IMOStartEnd.sql'
                                'ISO19030.sql'
                                'ISO19030A.sql'
                                'ISO19030B.sql'
                                'ISO19030C.sql'
                                'ProcessISO19030.sql'
                                'createBunkerDeliveryNote.sql'
                                'createChauvenetFilter.sql'
                                'createDisplacementTable.sql'
                                'createGlobalConstants.sql'
                                'createPerformanceData.sql'
                                'createSFOCCoefficients.sql'
                                'createSensorRecalibration.sql'
                                'createSpeedPower.sql'
                                'createSpeedPowerCoefficients.sql'
                                'createTempRaw.sql'
                                'createTempRawISO.sql'
                                'createVessels.sql'
                                'createWindCoefficients.sql'
                                'filterPowerBelowMinimum.sql'
                                'filterReferenceConditions.sql'
                                'filterSFOCOutOfRange.sql'
                                'filterSpeedPowerLookup.sql'
                                %'insertFromDNVGLRawIntoRaw.sql'
                                'insertIntoPerformanceData.sql'
                                'isBrakePowerAvailable.sql'
                                'isShaftPowerAvailable.sql'
                                'normaliseHigherFreq.sql'
                                'normaliseLowerFreq.sql'
                                'removeFOCBelowMinimum.sql'
                                'removeInvalidRecords.sql'
                                'removeNullRows_prc.sql'
                                'sortOnDateTime.sql'
                                'updateAirDensity.sql'
                                'updateAirResistanceNoWind.sql'
                                'updateBrakePower.sql'
                                'updateChauvenetCriteria.sql'
                                'updateCorrectedPower.sql'
                                'updateDeliveredPower.sql'
                                'updateDisplacement.sql'
                                'updateExpectedSpeed.sql'
                                'updateFromBunkerNote.sql'
                                'updateMassFuelOilConsumed.sql'
                                'updateShaftPower.sql'
                                'updateSpeedLoss.sql'
                                'updateTransProjArea.sql'
                                'updateTrim.sql'
                                'updateValidated.sql'
                                'updateWindResistanceCorrection.sql'
                                'updateWindResistanceRelative.sql'
                                'validateFrequencies.sql'
                                'createvesselspeedpowermodel.sql'
                                'updateDefaultValues.sql'
                                'updateWindReference.sql'
                                'knots2mps.sql'
                                'updateNearestTrim.sql'
                                'applyFilters.sql'
                                'bar2Pa.sql'
                        };
       iso19030Fullpath_c = cellfun(@(x) fullfile(topleveldir, ISODir, x), ...
           iso19030_c, 'Uni', 0);
       sql.source(iso19030Fullpath_c);
       end
       
       function loadStatic(obj, varargin)
       % loadStatic Load static vessel data into DB
       
       if nargin > 1 && ~isempty(varargin{1})
           
           file = varargin{1};
           file = validateCellStr(file, 'cDB.loadStatic', 'file', 2);
       else
           
           % Find all insert static scripts in vessel library
           [~, file] = insertStaticScript(obj, varargin);
       end
       
       % Run all insert static scripts
       for fi = 1:numel(file)

           run(file{fi});
       end
       end
       
       function loadInService(obj, varargin)
       % loadStatic Load static vessel data into DB
       
       if nargin > 1 && ~isempty(varargin{1})
           
           file = varargin{1};
           file = validateCellStr(file, 'cDB.loadInService', 'file', 2);
       else
           
           % Find all insert static scripts in vessel library
           [~, file] = insertInServiceScript(obj, varargin);
       end
       
       % Run all insert static scripts
       for fi = 1:numel(file)

           run(file{fi});
       end
       end
       
       function createForce(obj)
       % Create database for hull performance data provided by Force Tech.
       
       % Assign DB?
       database = 'force';
       obj.Database = database;
       
       if obj.BuildSchema
           
           % Create tables
           topleveldir = obj.TopLevelDir;
           
           ISODir = 'ISO 19030';
           ISO19030Create_c = {'knots2mps'
                               'rad2deg'
                                };
           createFiles1_c = cellfun(@(x) fullfile(topleveldir, ISODir, x), ...
               ISO19030Create_c, 'Uni', 0);
           
           ForceDirect = 'Force Technologies';
           force_c = {'createForceRaw'
                      'createPerformanceData'
                               };
           createFiles2_c = cellfun(@(x) fullfile(topleveldir, ForceDirect, x), ...
               force_c, 'Uni', 0);
           
           createDir = 'Create Tables';
           create_c = {'createRawData'
                               };
           createFiles3_c = cellfun(@(x) fullfile(topleveldir, createDir, x), ...
               create_c, 'Uni', 0);
           
           % Create procedures to create tables and functions
           createProc_c = [createFiles3_c; createFiles2_c; createFiles1_c];
           createProc_c = strcat(createProc_c, '.sql');
           obj.source(createProc_c);
           
           % Call procedures to create tables and functions
           [~, procNames_c, ~] = cellfun(@fileparts, createProc_c, 'Uni', 0);
           cellfun(@(x) obj.call(x), procNames_c, 'Uni', 0);
       end
       
%        % Insert raw data
%        if obj.LoadRaw || obj.LoadPerformance
%            
%            % Load Raw
%            rawDirect = ['C:\Users\damcl\OneDrive - Hempel Group\Documents'...
%                '\L DRIVE BACKUP\ARCHIVE\External Vessel Data\Force'];
%            rawFiles_st = rdir([rawDirect, '\**\*.csv']);
%            rawFiles_c = {rawFiles_st.name};
%            
%            obj_ves = cVessel();
%            obj_ves.Database = database;
%            obj_ves.loadForceTech(rawFiles_c);
%            
% %            obj_ves.drop('table', 'tempforceraw');
%        end
       
%        % Insert Performance
%        if obj.LoadPerformance
%            
%            % Insert performance data
%            allPerformanceFile_ch = ['L:\Project\MWB-Fuel efficiency\Hull '...
%                'and propeller performance\External Vessel Data\DNV-GL\'...
%                'Performance\Download.xlsx'];
%            obj_ves = cVessel();
%            obj_ves.Database = database;
%            obj_ves.loadForcePerformance(allPerformanceFile_ch);
%        end
       end
       
       function createDNVGL(obj)
       % Create database for hull performance data provided by DNVGL
       
       % Assign DB?
       database = 'dnvgl';
       obj.Database = database;
       
       if obj.BuildSchema
           
           % Create tables
           topleveldir = obj.TopLevelDir;

           ISODir = 'ISO 19030';
           ISO19030Create_c = {'createPerformanceData.sql'
                                'createBunkerDeliveryNote.sql'
                                'createTempRaw.sql'
                                'insertFromDNVGLRawIntoRaw.sql'
                                'updateFromBunkerNote.sql'
                                'knots2mps.sql'
                                'bar2Pa.sql'};
           createFiles1_c = cellfun(@(x) fullfile(topleveldir, ISODir, x), ...
               ISO19030Create_c, 'Uni', 0);

           createFiles2Dir_ch = 'Create Tables';
           createFiles2_c = {...
                        'createDNVGLRawTable.sql'
                        'createDNVGLRawTempTable.sql'
                        'createRawData.sql'
                    };
           createFiles2_c = cellfun(@(x) fullfile(topleveldir, createFiles2Dir_ch, x), ...
               createFiles2_c, 'Uni', 0);

           dnvglrawDir_ch = '\DNVGL Raw';
           createFiles3_c = {...
               'convertDNVGLRawToRawData.sql'
               'createTempBunkerDeliveryNote.sql'
               };
           createFiles3_c = cellfun(@(x) fullfile(topleveldir, dnvglrawDir_ch, x), ...
               createFiles3_c, 'Uni', 0);

           % Create procedures for creating tables
           createFiles_c = [createFiles1_c; createFiles2_c; createFiles3_c];
           obj.source(createFiles_c);

           % Create tables
           createProc_c = {...
                           'createBunkerDeliveryNote'
                           'createDNVGLRawTempTable'
                           'createDNVGLRaw'
                           'createPerformanceData'
                           'createrawdata'
                           };

           % Check there are as many proc as files
           cellfun(@(x) obj.call(x), createProc_c, 'Uni', 0);
       end
%        
%        if obj.LoadPerformance
%            
%            % Insert performance data
%            allPerformanceFile_ch = ['L:\Project\MWB-Fuel efficiency\Hull '...
%                'and propeller performance\External Vessel Data\DNV-GL\'...
%                'Performance\Download.xlsx'];
%            obj_ves = cVessel();
%            obj_ves.Database = database;
%            obj_ves.loadDNVGLPerformance(allPerformanceFile_ch);
%        end
%        
%        if obj.LoadRaw
%            
%            % Load Raw
%            rawDirect = 'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\External Vessel Data\DNV-GL\Raw';
%            rawFiles_st = rdir([rawDirect, '\**\*.csv']);
%            rawFiles_c = {rawFiles_st.name};
%            bunkerFile_ch = 'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\External Vessel Data\DNV-GL\Bunker Reporting\2 Bunker reporting 2017-10-31 09_39.csv';
%            
%            obj_ves = cVessel();
%            obj_ves.Database = database;
%            obj_ves = obj_ves.insertBunkerDeliveryNoteDNVGL(bunkerFile_ch);
%            obj_ves.loadDNVGLRaw(rawFiles_c);
%            
%            obj_ves.drop('table', 'tempraw');
%            obj_ves.drop('table', 'tempbunkerdeliverynote');
%        end
%         
       end
       
       function loadForce(obj, varargin)
       % Load data into Force database
           
           % Input
           forceDir = obj.ForceDir;
           if nargin > 1 && ~isempty(varargin{1})

               forceDir = varargin{1};
               validateattributes(forceDir, {'char'}, {'vector'}, ...
                   'cDB.loadForce', 'forceDir', 2);
           end
           
           % Find Files
           rawFiles_st = rdir([forceDir, '\**\*.csv']);
           rawFiles_c = {rawFiles_st.name};
           
           % Load Files
           obj_ves = cVessel('Database', 'Force');
           obj_ves.loadForceTech(rawFiles_c);
       end
       
       function loadDNVGL(obj, varargin)
       % loadDNVGL Load data into DNVGL database

           % Load Performance
           file_st = rdir([obj.DNVGLDir, '\**\Download.xlsx']);
           allPerformanceFile_ch = file_st.name;
           obj_ves = cVessel('Database', 'DNVGL');
           obj_ves.loadDNVGLPerformance(allPerformanceFile_ch);

           % Load Raw
           rawFiles_st = rdir([obj.DNVGLDir, '\**\1 Operational reporting*.csv']);
           rawFiles_c = {rawFiles_st.name};
           obj_ves.loadDNVGLRaw(rawFiles_c);
           
           % Load Bunker
           bunkerFiles_st = rdir([obj.DNVGLDir, '\**\2 Bunker reporting*.csv']);
           bunkerFiles_c = {bunkerFiles_st.name};
           obj_ves = obj_ves.insertBunkerDeliveryNoteDNVGL(bunkerFiles_c);

           % Drop unneeded tables
           obj_ves.drop('table', 'tempraw');
           obj_ves.drop('table', 'tempbunkerdeliverynote');
       end
       
       function createTestStatic(obj)
       % createTestStatic Create Test Static DB
       
       dbname = 'TestStatic';
       obj.createStatic(dbname);
           
       end
       
       function createTestInService(obj)
           
           obj.createInService('TestInService');
       end
       
    end
    
    methods(Static)
       
       function Insert_ISO15016_Wind_Data()
          
           dbstatic = 'Static';
           windData_m = [...
            0	-0.019146806	-0.677665	-1.03173	-0.986038	-0.875632
            7.5	7.434988	-0.74222815	-1.07344	-0.978263	-0.825984
            15	14.888325	-0.7725274	-1.1342	-1.06567	-0.905776
            22.5	22.340067	-0.7342987	-1.13404	-1.05028	-0.878966
            30	29.664871	-0.6694229	-1.13008	-0.913072	-0.718913
            45	44.690327	-0.40641463	-0.966054	-0.809965	-0.69195
            60	59.971073	-0.25761423	-0.744929	-0.657366	-0.6193
            75	74.749214	-0.22303768	-0.466693	-0.466693	-0.466693
            90	89.78194	-0.27221212	-0.135159	-0.256981	-0.295057
            105	104.42978	-0.06631846	0.257283	0.11642	0.021245
            120	119.32546	0.3451643	0.74872	0.489834	0.40988
            135	134.2231	0.6728907	1.07264	0.897518	0.794721
            150	148.99716	0.88259417	1.15671	1.03108	0.966353
            165	164.28252	0.83342505	1.16464	1.05043	0.985707
            180	179.82368	0.6472055	0.925114	0.879426	0.86039];
            dir = windData_m(:, 1);

            obj_wnd = cVesselWindCoefficient();
            obj_wnd.Database = dbstatic;
            obj_wnd.Direction = dir;
            obj_wnd.Coefficient = windData_m(:, 3);
            obj_wnd = obj_wnd.mirrorAlong180;
            obj_wnd.Name = 'ISO15016 Container Vessel 1';
            obj_wnd.Description = 'Container Vessel 6800TEU, Laden with containers';
            obj_ves = cVessel();
            obj_ves.Database = dbstatic;
            obj_ves.WindCoefficient = obj_wnd;
            obj_ves.insertIntoWindCoefficients;

            obj_wnd = cVesselWindCoefficient();
            obj_wnd.Database = dbstatic;
            obj_wnd.Direction = dir;
            obj_wnd.Coefficient = windData_m(:, 4);
            obj_wnd = obj_wnd.mirrorAlong180;
            obj_wnd.Name = 'ISO15016 Container Vessel 2';
            obj_wnd.Description = 'Container Vessel 6800TEU, Laden without containers, with lashing bridges';
            obj_ves = cVessel();
            obj_ves.Database = dbstatic;
            obj_ves.WindCoefficient = obj_wnd;
            obj_ves.insertIntoWindCoefficients;

            obj_wnd = cVesselWindCoefficient();
            obj_wnd.Database = dbstatic;
            obj_wnd.Direction = dir;
            obj_wnd.Coefficient = windData_m(:, 5);
            obj_wnd = obj_wnd.mirrorAlong180;
            obj_wnd.Name = 'ISO15016 Container Vessel 3';
            obj_wnd.Description = 'Container Vessel 6800TEU, Laden without containers, with lashing bridges';
            obj_ves = cVessel();
            obj_ves.Database = dbstatic;
            obj_ves.WindCoefficient = obj_wnd;
            obj_ves.insertIntoWindCoefficients;

            obj_wnd = cVesselWindCoefficient();
            obj_wnd.Database = dbstatic;
            obj_wnd.Direction = dir;
            obj_wnd.Coefficient = windData_m(:, 6);
            obj_wnd = obj_wnd.mirrorAlong180;
            obj_wnd.Name = 'ISO15016 Container Vessel 4';
            obj_wnd.Description = 'Container Vessel 6800TEU, Ballast without containers, without lashing bridges';
            obj_ves = cVessel();
            obj_ves.Database = dbstatic;
            obj_ves.WindCoefficient = obj_wnd;
            obj_ves.insertIntoWindCoefficients;

            wind9200 = cVesselWindCoefficient();
            wind9200.Database = 'test16';
            dirCoeffs = ...
            [
            0	-0.9724771
            7.573311	-0.96330273
            14.917127	-1.0550458
            22.41394	-1.0389909
            29.98725	-0.9013761
            44.980877	-0.79816514
            59.821503	-0.6536697
            74.968124	-0.48165137
            89.885254	-0.2614679
            104.878876	0.116972476
            119.949	0.4885321
            134.94263	0.9036697
            149.85976	1.0298165
            165.08287	1.0665138
            179.92351	0.9105505
            ];
            directions = [0 7.5 15 22.5 30 45 60 75 90 105 120 135 150 165 180];
            wind9200.Direction = directions;
            wind9200.Coefficient = dirCoeffs(:, 2);
            wind9200 = wind9200.mirrorAlong180;
            wind9200.Name = 'ISO15016 Container Vessel 5';
            wind9200.Description = ['Container Vessel 6800TEU, Ballast '...
                'without containers, with lashing bridges'];
            obj_ves = cVessel();
            obj_ves.Database = dbstatic;
            obj_ves.WindCoefficient = obj_wnd;
            obj_ves.insertIntoWindCoefficients;

            tankersBallastConventional = [...
                0.0474177	-0.871362
            10.3859	-0.766187
            21.1052	-0.629526
            31.4848	-0.460979
            42.1904	-0.345442
            52.359	-0.224323
            62.1332	-0.155813
            72.8045	-0.0930859
            83.0745	-0.09353
            92.8487	-0.0250199
            102.796	0.0328277
            112.768	0.127642
            122.205	0.23332
            132.34	0.301629
            142.128	0.391263
            151.909	0.470335
            161.666	0.51244
            171.419	0.549264
            181.132	0.522717
            ];
            obj_wnd = cVesselWindCoefficient();
            obj_wnd.Database = dbstatic;
            obj_wnd.Direction = 0:10:180;
            obj_wnd.Coefficient = tankersBallastConventional(:, 2);
            obj_wnd = obj_wnd.mirrorAlong180;
            obj_wnd.Name = 'ISO15016 Tanker 1';
            obj_wnd.Description = 'Tankers in ballast with conventinoal bow';
            obj_ves = cVessel();
            obj_ves.Database = dbstatic;
            obj_ves.WindCoefficient = obj_wnd;
            obj_ves.insertIntoWindCoefficients;

            generalCargo = [....
                -0.60115	0
            -0.874312	10
            -0.997667	20
            -1.00194	30
            -0.875619	40
            -0.84532	50
            -0.657525	60
            -0.435164	70
            -0.285782	80
            -0.113352	90
            0.0667608	100
            0.461987	110
            0.822631	120
            1.34419	130
            1.44363	140
            1.2934	150
            0.885803	160
            0.770147	170
            ];
            obj_wnd = cVesselWindCoefficient();
            obj_wnd.Database = dbstatic;
            obj_wnd.Direction = [0:10:120, 140:10:180];
            obj_wnd.Coefficient = generalCargo(:, 1);
            obj_wnd = obj_wnd.mirrorAlong180;
            obj_wnd.Name = 'ISO15016 General Cargo Vessel 1';
            obj_wnd.Description = 'General Cargo Vessel';
            obj_ves = cVessel();
            obj_ves.Database = dbstatic;
            obj_ves.WindCoefficient = obj_wnd;
            obj_ves.insertIntoWindCoefficients;
       end
       
       function loadHempelModel
           
           insertModel_c = {...
               'https://hempelgroup.sharepoint.com/sites/'...
               'HullPerformanceManagementTeam/Vessel%20Library/AMCL/Scripts/'...
               'Insert_Model_AMCL.m'...
               };
           cellfun(@run, insertModel_c);
       end
       
       function loadHempelTime
           
           insertTime_c = {...
               'https://hempelgroup.sharepoint.com/sites/'...
               'HullPerformanceManagementTeam/Vessel%20Library/AMCL/Scripts/'...
               'Insert_Time_AMCL.m'...
               };
           cellfun(@run, insertTime_c);
       end
       
       function dbname = validateDBName(dbname)
           
           stack = dbstack;
           funcname = stack(1).name;
           validateattributes(dbname, {'char'}, {'vector'}, funcname,...
               'dbname', 1);
       end
    end
end