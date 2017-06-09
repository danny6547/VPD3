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
        
        AdditionalScripts = {...
            ['C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data'...
            '\CMA CGM\Scripts\Insert_data.m']...
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
       
       scripts_c = obj.AdditionalScripts;
       
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
       ISODir = 'ISO 19030';
       ISO19030Create_c = {...
                            'createBunkerDeliveryNote.sql'
                            'createChauvenetFilter.sql'
                            'createDisplacementTable.sql'
                            'createGlobalConstants.sql'
                            'createPerformanceData.sql'
                            'createSFOCCoefficients.sql'
                            'createSensorRecalibration.sql'
                            'createSpeedPower.sql'
                            'createSpeedPowerCoefficients.sql'
                            'createStandardCompliance.sql'
                            'createTempRaw.sql'
                            'createTempRawISO.sql'
                            'createVessels.sql'
                            'createWindCoefficients.sql'      
                            'IMOStartEnd.sql'
                            'ISO19030.sql'
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
                            'createStandardCompliance.sql'
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
       
       createFiles_c = [createFiles1_c; createFiles2_c; createFiles3_c;...
           createFiles4_c];
       
       % Create procedures for creating tables
       obj.source(createFiles_c);
       
       % Create tables
       createProc_c = {...
                       'createwindcoefficientdirection'
                       'createVessels'
                       'createStandardCompliance'
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
                       
                       };
       
       % Check there are as many proc as files
       cellfun(@(x) obj.call(x), createProc_c, 'Uni', 0);
       
       % Insert performance data
       run(['C:\Users\damcl\OneDrive - Hempel Group\Documents\SQL\tests\'...
           'EcoInsight Test Scripts\Vessel Data\Load_All_DNVGL_Performance.m']);
       
       % Insert raw data, bunker delivery note
       rawFiles_c = {...
                    'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\Yang Ming\DNVGL Raw\1 Operational reporting 2017-02-08 11-17.csv'
                    'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\TMS\LX7, ZX7\1 Operational reporting 2017-02-08 10-51.csv'
                    'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\TMS\CX7, ASPC, BINT, CINT\1 Operational reporting 2017-02-08 11-46.csv'
                    'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\Teekay\Raw\1 Operational reporting 2016-10-07 11_59_All.csv'
                    'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\Teekay\Raw\1 Operational reporting 2017-02-08 09-36.csv'
                    'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\SETAF-SAGET\1 Operational reporting 2017-02-08 10-49.csv'
                    'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\Euronav\DNVGL Raw\Sandra, Sara\1 Operational reporting 2017-02-08 10-38.csv'
                    'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\Euronav\DNVGL Raw\Hakone, Hirado\1 Operational reporting 2017-02-08 10-28.csv'
                    'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\Euronav\DNVGL Raw\Devon, Hakata\1 Operational reporting 2017-02-08 10-19.csv'
                    'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\DFDS Seaways\1 Operational reporting 2017-02-08 10-44.csv'
                    'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\CMA CGM\Jules, Litani, Marco\1 Operational reporting 2017-01-03 14_04.csv'
                    'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\CMA CGM\Alexander Chopin, Danube, Dalila, Gemini\1 Operational reporting 2017-01-03 13_35.csv'
                    'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\CMA CGM\Almaviva, Cassiopeia, Gemini\1 Operational reporting 2017-01-03 12_41.csv'
                    'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\Anglo-Eastern Ship management\1 Operational reporting 2017-02-08 11-11.csv'
                    'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\AMCL\1 Operational reporting 2017-02-08 11-15.csv'
%                     'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\Berge Kibo\DNVGL\Raw\1 Operational reporting 2017-03-10 13_58.csv'
                    };
       bunkerFiles_c = {...
           'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\Yang Ming\DNVGL Raw\2 Bunker reporting 2017-04-24 08_09.csv'...
           'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\TMS\2 Bunker reporting 2017-04-24 08_12.csv'...
           'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\Teekay\Raw\2 Bunker reporting 2017-04-24 08_14.csv'...
           'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\CMA CGM\Raw\2 Bunker reporting 2017-04-24 08_18.csv'...
           'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\SETAF-SAGET\2 Bunker reporting 2017-04-24 08_21.csv'...
           'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\Euronav\DNVGL Raw\2 Bunker reporting 2017-04-24 08_21.csv'...
           'C:\Users\damcl\OneDrive - Hempel Group\Documents\Ship Data\AMCL\2 Bunker reporting 2017-04-24 08_22.csv'
           };
       obj_ves = cVessel();
       obj_ves.Database = name;
       obj_ves = obj_ves.insertBunkerDeliveryNoteDNVGL(bunkerFiles_c);
       obj_ves.loadDNVGLRaw(rawFiles_c);
       
%        % Load Dry Docking Dates from Files
%        ddFiles = {['L:\Project\MWB-Fuel efficiency\Hull and propeller '...
%            'performance\Vessels\CMA CGM\Cart reports 2\Cart reports '...
%            'CMA CGM.xlsx']};
%        objddd = cVesselDryDockDates();
%        objddd = objddd.readFile(ddFiles);
       
       % Run Additional Scripts
       for si = 1:numel(scripts_c)
           
           % Run script, temporarily adding directory to path if necessary
           currScript = scripts_c{si};
           try run(currScript);
               
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
%            [vess.Database] = deal(name);
%            vess = vess.insert;
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