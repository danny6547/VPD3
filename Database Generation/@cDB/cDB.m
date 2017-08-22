classdef cDB < cMySQL
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
        
        CreateSchema = true;
        LoadRaw = true;
        LoadPerformance = true;
        RunISO = true;
        InsertStatic = {...
            ['L:\Project\MWB-Fuel efficiency\Hull and propeller performance'...
            '\Vessels\AMCL\Data\Scripts\Insert_Static_AMCL.m']...
            ['L:\Project\MWB-Fuel efficiency\Hull and propeller performance'...
            '\Vessels\CMA CGM\Data\Raw\DNVGL\Scripts\Insert_Static_CMA_CGM.m']...
            ['L:\Project\MWB-Fuel efficiency\Hull and propeller performance'...
            '\Vessels\UASC data\Scripts\Insert_Static_UASC.m']...
            ['L:\Project\MWB-Fuel efficiency\Hull and propeller performance'...
            '\Vessels\UASC data\Scripts\Insert_Static_Al_Farahidi.m']...
            };
        ISO19030Parameters = {9288095, 'Only one speed, power curve from Sea Trial and that is of sister vessel New Century. Estimates made for Ta and Anemometer Height. Shaft torsiometer data utilised. Wind coefficients taken from ISO15016 for tanker with conventional bow. No displacement data available prior to 2016.', {};...                    % New Spirit
                              9445631, 'No speed, power curves available so that of New Century, another vessel of the same owner applied. Estimates made for Ta and Anemometer Height. Shaft torsiometer data utilised. Wind coefficients taken from ISO15016 for tanker with conventional bow. No displacement data available prior to 2016.', {}; ...     % New Vanguard
                              9434632, 'No speed, power curves available so that of New Century, another vessel of the same owner applied. Estimates made for Ta and Anemometer Height. Shaft torsiometer data utilised. Wind coefficients taken from ISO15016 for tanker with conventional bow. No displacement data available prior to 2016.', {}, ...     % New Success
                              9525924, '', {},...
                                9525936, '', {},...
                                9525895, '', {},...
                                9525871, '', {},...
                                9525869, '', {},...
                                9525883, '', {},...
                                9525900, '', {},...
                                9525857, '', {},...
                                9349552, '', {},...
                                9349502, '', {},...
                                9349538, '', {},...
                                9349564, '', {},...
                                9349497, '', {},...
                                9349540, '', {},...
                                9349514, '', {}...
                              };
    end
    
    methods
    
       function obj = cDB()
       % cDB Constructor method for class cDB.
    
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
       
       scripts_c = obj.InsertStatic;
       
       % Input
       validateattributes(name, {'char'}, {'vector'}, 'create', 'name', 2);
       
       topleveldir = ['C:\Users\damcl\OneDrive - Hempel Group\Documents\'...
           'SQL\tests\EcoInsight Test Scripts'];
       if nargin > 2
           topleveldir = varargin{1};
           validateattributes(topleveldir, {'char'}, {'vector'}, 'create', ...
               'topleveldir', 3);
       end
       
       % Change to desired database
       obj.Database = name;
       
       % Get file paths to create tables
       if obj.CreateSchema
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
                                'insertFromDNVGLRawIntoRaw.sql'
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
                                };
           createFiles1_c = cellfun(@(x) fullfile(topleveldir, ISODir, x), ...
               ISO19030Create_c, 'Uni', 0);

           createFiles2Dir_ch = 'Create Tables';
           createFiles2_c = {...
                        'createDDDtable.sql'
                        'createDNVGLPerformanceData.sql'
                        'createDNVGLRawTable.sql'
                        'createDNVGLRawTempTable.sql'
                        'createRawData.sql'
                        'createVesselCoating.sql'
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

           createFiles4_c = {['C:\Users\damcl\OneDrive - Hempel Group\'...
               'Documents\SQL\tests\EcoInsight Test Scripts\Accessing Database'...
               '\performanceData.sql']};

           createFiles5_c = {...
               'createTempMarorkaRaw.sql'
               'insertFromMarorkaRawIntoRaw.sql'
               };
           marorkaDir_ch = ['Marorka'];
           createFiles5_c = cellfun(@(x) fullfile(topleveldir, marorkaDir_ch, x), ...
               createFiles5_c, 'Uni', 0);

           createFiles_c = [createFiles1_c; createFiles2_c; createFiles3_c;...
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
                           'createDNVGLRawTempTable'
                           'createDNVGLRaw'
                           'createDNVGLPerformanceData'
                           'createDryDockDates'
                           'createTempChauvenetFilter'
                           'createvesselspeedpowermodel'
                           };

           % Check there are as many proc as files
           cellfun(@(x) obj.call(x), createProc_c, 'Uni', 0);

       end
       
       if obj.LoadPerformance
           
           % Insert performance data
           run(['C:\Users\damcl\OneDrive - Hempel Group\Documents\SQL\tests\'...
               'EcoInsight Test Scripts\Vessel Data\Load_All_DNVGL_Performance.m']);
       end
       
       % Insert raw data, bunker delivery note
       if obj.LoadRaw
           rawFiles_c = {...
                        'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\Yang Ming\Data\DNVGL\Raw\1 Operational reporting 2017-02-08 11-17.csv'
                        'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\TMS\DNVGL\Raw\LX7, ZX7\1 Operational reporting 2017-02-08 10-51.csv'
                        'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\TMS\DNVGL\Raw\CX7, ASPC, BINT, CINT\1 Operational reporting 2017-02-08 11-46.csv'
                        'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\Teekay\Data\DNVGL\Raw\1 Operational reporting 2016-10-07 11_59_All.csv'
                        'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\Teekay\Data\DNVGL\Raw\1 Operational reporting 2017-02-08 09-36.csv'
                        'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\SETAF-SAGET\Data\DNVGL\Raw\1 Operational reporting 2017-02-08 10-49.csv'
                        'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\Euronav\Data\DNVGL\Raw\Sandra, Sara\1 Operational reporting 2017-02-08 10-38.csv'
                        'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\Euronav\Data\DNVGL\Raw\Hakone, Hirado\1 Operational reporting 2017-02-08 10-28.csv'
                        'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\Euronav\Data\DNVGL\Raw\Devon, Hakata\1 Operational reporting 2017-02-08 10-19.csv'
                        'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\DFDS Seaways\DNVGL\Raw\1 Operational reporting 2017-02-08 10-44.csv'
                        'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\CMA CGM\Data\Raw\DNVGL\Jules, Litani, Marco\1 Operational reporting 2017-01-03 14_04.csv'
                        'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\CMA CGM\Data\Raw\DNVGL\Alexander Chopin, Danube, Dalila, Gemini\1 Operational reporting 2017-01-03 13_35.csv'
                        'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\CMA CGM\Data\Raw\DNVGL\Almaviva, Cassiopeia, Gemini\1 Operational reporting 2017-01-03 12_41.csv'
                        'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\Anglo-Eastern Ship management\Data\DNVGL\Raw\1 Operational reporting 2017-02-08 11-11.csv'
                        'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\AMCL\Data\DNVGL\Raw\1 Operational reporting 2017-02-08 11-15.csv'
    %                     'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\Berge Kibo\DNVGL\Raw\1 Operational reporting 2017-03-10 13_58.csv'
                        };
           bunkerFiles_c = {...
               'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\Yang Ming\Data\DNVGL\Raw\2 Bunker reporting 2017-04-24 08_09.csv'...
               'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\TMS\DNVGL\Raw\2 Bunker reporting 2017-04-24 08_12.csv'...
               'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\Teekay\Data\DNVGL\Raw\2 Bunker reporting 2017-04-24 08_14.csv'...
               'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\CMA CGM\Data\Raw\DNVGL\2 Bunker reporting 2017-04-24 08_18.csv'...
               'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\SETAF-SAGET\Data\DNVGL\Raw\2 Bunker reporting 2017-04-24 08_21.csv'...
               'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\Euronav\Data\DNVGL\Raw\2 Bunker reporting 2017-04-24 08_21.csv'...
               'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\AMCL\Data\DNVGL\Raw\2 Bunker reporting 2017-04-24 08_22.csv'
               };
           obj_ves = cVessel();
           obj_ves.Database = name;
           obj_ves = obj_ves.insertBunkerDeliveryNoteDNVGL(bunkerFiles_c);
           obj_ves.loadDNVGLRaw(rawFiles_c);

            % Insert time-series data
            vess = cVessel();
            AMCLNoonFiles = 'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\AMCL\New Spirit\New Spirit - ????_before 2016.xls';
            vess(1) = vess(1).loadAMCLRaw(AMCLNoonFiles, {'IMO_Vessel_Number = 9288095', 'Displacement = 299825000'});

            q = rdir('L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\AMCL\New Spirit\**.xlsx');
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

            q = rdir('L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\AMCL\New Vanguard\**.xlsx');
            NewVanguardFiles_c = [{q.name}'; 'L:\Project\MWB-Fuel efficiency\Hull and propeller performance\Vessels\AMCL\New Vanguard\M.T. NEW VANGUARD -JUN 2016 Hempel''s Data Collection Form_Hull Performan....xlsx'];
            vess(1) = vess(1).loadDNVGLReportingFormat(NewVanguardFiles_c, 9445631, 'firstRowIdx', 16);

            % Take Speed over ground as that through water because data missing
            vess(1).update('RawData', 'Speed_Through_Water', 'Speed_Over_Ground WHERE IMO_Vessel_Number = 9445631');
            clear vess;
            
            

       end
       
       
       % Load Dry Docking Dates from Files
       ddFiles = ['L:\Project\MWB-Fuel efficiency\Hull and propeller '...
           'performance\Vessels\CMA CGM\Cart reports 2\Cart reports '...
           'CMA CGM.xlsx'];
       objddd = cVesselDryDockDates();
       objddd.readFile(ddFiles, 'dd-mm-yy');
       
       % Recreate file later
       objddd = cVesselDryDockDates();
       ddFileEuronav = ['L:\Project\MWB-Fuel efficiency\'...
           'Hull and propeller performance\Vessels\Euronav\Data\Scripts\'...
           'DryDockDates.xlsx'];
       objddd.readFile(ddFileEuronav, 'dd-mm-yyyy');
       
       % Load standard wind coefficients
       windFile = ['L:\Project\MWB-Fuel efficiency\Hull and propeller '...
           'performance\Other Vessel Data\Wind\ISO15016\'...
           'Insert_ISO15016_Wind_Data.m'];
       run(windFile);
       
       % Run Additional Scripts
       executedFully_l = false(size(scripts_c));
       insertedVessels = [];
       for si = 1:numel(scripts_c)
           
           % Run script, temporarily adding directory to path if necessary
           vess = cVessel();
           [vess.Database] = deal(name);
           currScript = scripts_c{si};
           
           try run(currScript);
               
               executedFully_l(si) = true;
           catch ee
               
               if strcmp(ee.identifier, 'MATLAB:UndefinedFunction');
                   
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
       
       obj = obj.test;
       obj.create(obj.Database);
           
       end
       
       function createHullPer(obj)
       % createTest Create the Hull Performance database
       
       obj = obj.hullPer;
       obj.create(obj.Database);
           
       end
    end
end