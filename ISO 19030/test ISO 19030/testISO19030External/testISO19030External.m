classdef testISO19030External < matlab.unittest.TestCase
%TESTISO19030EXTERNAL
%   Detailed explanation goes here

properties(Constant)
    
    TestDir char = fileparts(mfilename('fullpath'));
    TestDirValidated char = fullfile(fileparts(mfilename('fullpath')), '2');
    TestDirFiltered char = fullfile(fileparts(mfilename('fullpath')), '1');
    TestDirPower char = fullfile(fileparts(mfilename('fullpath')), '3');
    TestDirPV char = fullfile(fileparts(mfilename('fullpath')), '4');
    
    RawFile char = 'validateISO19030Test.csv';
    OutFilePrefix char = 'validateISOOut_';
    
    DataLengthPerCriteriaPV = 30;
    g = 9.80665;
    TimeStep = 1;
    PowerWindFile char = fullfile(testISO19030External.TestDirPower,...
        'validateISO19030TestWind.csv');
    WindFilePV = fullfile(testISO19030External.TestDirPV, ...
            'validateISO19030TestWind.csv');
    DiagnosticFilePV = fullfile(testISO19030External.TestDirPV, ...
            'validateISO19030Diagnostic.csv');
end

properties
    
    RawFileValidated = fullfile(testISO19030External.TestDirValidated, testISO19030External.RawFile);
    RawFileFiltered = fullfile(testISO19030External.TestDirFiltered, testISO19030External.RawFile);
    RawFilePower = fullfile(testISO19030External.TestDirPower, testISO19030External.RawFile);
    RawFilePV = fullfile(testISO19030External.TestDirPV, testISO19030External.RawFile);
    DBISOTableValidated = table();
    DBISOTableFiltered = table();
    DBISOTablePower = table();
    OutInputTable = table();
    OutInputTableValidated = table();
    OutInputTableFiltered = table();
    OutWindTablePower = table();
    OutPVTablePV = table();
    InputTableFiltered = table();
    InputTableValidated = table();
    InputTablePower = table();
    InputTablePV = table();
    ValidTableValidated = table();
    FilteredTableFiltered = table();
end

properties
    
        DBTab = 'tempRawISO';
        DBVars = {'DateTime_UTC'
                    'IMO_Vessel_Number'
                    'Relative_Wind_Speed'
                    'Relative_Wind_Direction'
                    'Speed_Over_Ground'
                    'Ship_Heading'
                    'Shaft_Revolutions'
                    'Static_Draught_Fore'
                    'Static_Draught_Aft'
                    'Water_Depth'
                    'Rudder_Angle'
                    'Seawater_Temperature'
                    'Air_Temperature'
                    'Air_Pressure'
                    'Air_Density'
                    'Speed_Through_Water'
                    'Delivered_Power'
                    'Shaft_Power'
                    'Brake_Power'
                    'Shaft_Torque'
                    'Wind_Resistance_Relative'
                    'Air_Resistance_No_Wind'
                    'Expected_Speed_Through_Water'
                    'Displacement'
                    'Speed_Loss'
                    'Transverse_Projected_Area_Current'
                    'Wind_Resistance_Correction'
                    'Corrected_Power'
                    'Filter_SpeedPower_Disp_Trim'
                    'Filter_SpeedPower_Trim'
                    'Filter_SpeedPower_Disp'
                    'Filter_SpeedPower_Below'
                    'NearestDisplacement'
                    'NearestTrim'
                    'Trim'
                    'Chauvenet_Criteria'
                    'Validated'
                    'Filter_All'
                    'Filter_SFOC_Out_Range'
                    'Filter_Reference_Seawater_Temp'
                    'Filter_Reference_Wind_Speed'
                    'Filter_Reference_Water_Depth'
                    'Filter_Reference_Rudder_Angle'
                    'True_Wind_Direction'
                    'True_Wind_Direction_Reference'
                    'True_Wind_Speed'
                    'True_Wind_Speed_Reference'    
                    'Relative_Wind_Speed_Reference'
                    };
        InputFileVars = {'Time', 'STW', 'Delivered_Power', 'Shaft_Revolutions',...
            'Relative_Wind_Speed', 'Relative_Wind_Direction', 'Air_Temperature',...
            'Speed_Over_Ground', 'Heading', 'Rudder_Angle', 'Water_Depth',...
            'Draft_Fore', 'Draft_Aft', 'Displacement', 'Water_Temperature'};
    
end

methods(Static)
    
    function spfiles = spFilesPower()
        
        vess = testISO19030External.testVesselPower;
        file1 = [num2str(vess.SpeedPower(1).Displacement), ' ', num2str(vess.SpeedPower(1).Trim)]; %, '_mps'];
        file2 = [num2str(vess.SpeedPower(2).Displacement), ' ', num2str(vess.SpeedPower(2).Trim)]; %, '_mps'];
        spfiles = cellfun(@(x) fullfile(testISO19030External.TestDirPower, [x, '.csv']), {file1, file2}, 'Uni', 0);
    end
    
    function spfiles = spFilesPV()
        
        vess = testISO19030External.testVesselPV;
        file1 = [num2str(vess.SpeedPower(1).Displacement), ' ', num2str(vess.SpeedPower(1).Trim)]; %, '_mps'];
        file2 = [num2str(vess.SpeedPower(2).Displacement), ' ', num2str(vess.SpeedPower(2).Trim)]; %, '_mps'];
        spfiles = cellfun(@(x) fullfile(testISO19030External.TestDirPV, [x, '.csv']), {file1, file2}, 'Uni', 0);
    end
    
    function testvessel = testVesselValidated()
        
    % Create speed, power curves
    objSP = cVesselSpeedPower();
    objSP.Displacement = 5e5;
    objSP.Trim = 0;
    objSP.Speed = 5:5:25;
    objSP.Power = 1e4:1e4:5e4;
    objSP.Propulsive_Efficiency = 0.7;
    
    objSP(2).Displacement = 1e6;
    objSP(2).Trim = -5;
    objSP(2).Speed = linspace(5, 20, 5);
    objSP(2).Power = linspace(1e4, 9e4, 5);
    objSP(2).Propulsive_Efficiency = 0.7;
    
    % Create wind coefficients (model ID 1 in database)
    wind = cVesselWindCoefficient();
    wind.Name = 'test';
    wind.Direction = [0,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180];
    wind.Coefficient = [1.2640,1.3450,1.4090,1.3890,1.3150,1.1430,0.9230,0.6840,0.5100,0.3200,0.0780,-0.2070,-0.5560,-0.9420,-1.2350,-1.4660,-1.5740,-1.4630,-1.2570];
    wind.Wind_Reference_Height_Design = 10;
    wind = wind.mirrorAlong180();
    
    % Create vessel
    testvessel = cVessel();
    testvessel.Database = 'test14';
    testvessel.IMO_Vessel_Number = 1234567;
    testvessel.Name = 'Test Vessel';
    testvessel.Draft_Design = 10;
    testvessel.Breadth_Moulded = 50;
    testvessel.Transverse_Projected_Area_Design = 2000;
    testvessel.LBP = 400;
    testvessel.SpeedPower = objSP;
    testvessel.WindCoefficient = wind;
    testvessel.DryDockDates = cVesselDryDockDates;
    testvessel.Anemometer_Height = 30;
    
    end
    
    function testvessel = testVesselFiltered()
        
        % Create speed, power curves
        objSP = cVesselSpeedPower();
        objSP.Displacement = 5e5;
        objSP.Trim = 0;
        objSP.Speed = 5:5:25;
        objSP.Power = 1e4:1e4:5e4;
        objSP.Propulsive_Efficiency = 0.7;

        objSP(2).Displacement = 1e6;
        objSP(2).Trim = -5;
        objSP(2).Speed = linspace(5, 20, 5);
        objSP(2).Power = linspace(1e4, 9e4, 5);
        objSP(2).Propulsive_Efficiency = 0.7;

        % Create wind coefficients (model ID 1 in database)
        wind = cVesselWindCoefficient();
        wind.Name = 'test';
        wind.Direction = [0,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180];
        wind.Coefficient = [1.2640,1.3450,1.4090,1.3890,1.3150,1.1430,0.9230,0.6840,0.5100,0.3200,0.0780,-0.2070,-0.5560,-0.9420,-1.2350,-1.4660,-1.5740,-1.4630,-1.2570];
        wind.Wind_Reference_Height_Design = 10;
        wind = wind.mirrorAlong180();

        % Create vessel
        testvessel = cVessel();
        testvessel.Database = 'test14';
        testvessel.IMO_Vessel_Number = 1234567;
        testvessel.Name = 'Test Vessel';
        testvessel.Draft_Design = 10;
        testvessel.Breadth_Moulded = 50;
        testvessel.Transverse_Projected_Area_Design = 2000;
        testvessel.LBP = 400;
        testvessel.SpeedPower = objSP;
        testvessel.WindCoefficient = wind;
        testvessel.DryDockDates = cVesselDryDockDates;
        testvessel.Anemometer_Height = 30;

    end
    
    function testvessel = testVesselPower()
       
        % Create speed, power curves
        objSP = cVesselSpeedPower();
        objSP.Displacement = 5e5 * 1.025;
        objSP.Trim = 0;
        objSP.Speed = 5:5:25;
        objSP.Power = 1e4:1e4:5e4;
        objSP.Propulsive_Efficiency = 0.7;

        objSP(2).Displacement = 1e6 * 1.025;
        objSP(2).Trim = -5;
        objSP(2).Speed = linspace(5, 20, 5);
        objSP(2).Power = linspace(1e4, 9e4, 5);
        objSP(2).Propulsive_Efficiency = 0.7;

        % Create wind coefficients (model ID 1 in database)
        windFile = testISO19030External.PowerWindFile;
        wintTbl = readtable(windFile);
        dirs = wintTbl.Var1;
        coeffs = wintTbl.Var2;
        dirsAbove180 = dirs > 180;
        dirs(dirsAbove180) = [];
        coeffs(dirsAbove180) = [];
        wind = cVesselWindCoefficient();
        wind.Name = 'test';
        wind.Direction = dirs;
        wind.Coefficient = coeffs;
        wind.Wind_Reference_Height_Design = 10;
        wind = wind.mirrorAlong180();

        % Create vessel
        testvessel = cVessel();
        testvessel.Database = 'test14';
        testvessel.IMO_Vessel_Number = 1234567;
        testvessel.Name = 'Test Vessel';
        testvessel.Draft_Design = 10;
        testvessel.Breadth_Moulded = 50;
        testvessel.Transverse_Projected_Area_Design = 1000;
        testvessel.LBP = 400;
        testvessel.SpeedPower = objSP;
        testvessel.WindCoefficient = wind;
        testvessel.DryDockDates = cVesselDryDockDates;
        testvessel.Anemometer_Height = 30;

    end
    
    function testvessel = testVesselPV()
       
        % Create speed, power curves
        objSP = cVesselSpeedPower();
        objSP.Displacement = 5e5;
        objSP.Trim = 0;
        objSP.Speed = [14.000000, 15.000000, 16.000000, 17.000000, 18.000000, 19.000000, 20.000000, 21.000000, 22.000000, 23.000000, 24.000000, 25.000000 ];
        objSP.Power = [10858.000000, 13273.000000, 15978.000000, 18951.000000, 22295.000000, 26348.000000, 30964.000000, 36257.000000, 43050.000000, 51246.000000, 60295.000000, 70034.000000]; 
        objSP.Propulsive_Efficiency = 0.7;

        objSP(2).Displacement = 1e6;
        objSP(2).Trim = -5;
        objSP(2).Speed = (5:5:25)*0.5; %5:5:25;
        objSP(2).Power = (1e4:1e4:5e4)*1.9; %linspace(1e4, 9e4, 5); %linspace(1e4, 9e4, 5);
        objSP(2).Propulsive_Efficiency = 0.7;

        % Create wind coefficients (model ID 1 in database)
        wind = cVesselWindCoefficient();
        wind.Name = 'test';
        wind.Direction = [0,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180];
        wind.Coefficient = [1.2640,1.3450,1.4090,1.3890,1.3150,1.1430,0.9230,0.6840,0.5100,0.3200,0.0780,-0.2070,-0.5560,-0.9420,-1.2350,-1.4660,-1.5740,-1.4630,-1.2570];
        wind.Wind_Reference_Height_Design = 10;
        wind = wind.mirrorAlong180();

        % Create vessel
        testvessel = cVessel();
        testvessel.Database = 'test14';
        testvessel.IMO_Vessel_Number = 1234567;
        testvessel.Name = 'Test Vessel';
        testvessel.Draft_Design = 10;
        testvessel.Breadth_Moulded = 50;
        testvessel.Transverse_Projected_Area_Design = 1000;
        testvessel.LBP = 400;
        testvessel.SpeedPower = objSP;
        testvessel.WindCoefficient = wind;
        testvessel.DryDockDates = cVesselDryDockDates;
        testvessel.Anemometer_Height = 30;
    end
    
    function varnames = varNames()
    % varNames
        
        varnames = {'Time', 'STW', 'Delivered_Power', 'Shaft_Revolutions',...
            'Relative_Wind_Speed', 'Relative_Wind_Direction', 'Air_Temperature',...
            'Speed_Over_Ground', 'Heading', 'Rudder_Angle', 'Water_Depth',...
            'Draft_Fore', 'Draft_Aft', 'Displacement', 'Water_Temperature'};
    end
    
    function diagFile = diagnosticFilePV()
        
        diagFile = fullfile(testISO19030Validate.TestDirPV, ...
            'validateISO19030Diagnostic.csv');
    end
    
    function diag = appendDiagnostic(diag, log, msgtrue, msgfalse)
    % appendDiagnostic Append to diagnostic based on criteria
    
    % Inputs
    if ~isempty(diag)
        validateattributes(diag, {'cell'}, {'vector', 'row'}, ...
            'testISO19030Validate.appendDiagnostic', 'diag', 1);
    end
    validateattributes(log, {'logical'}, {'vector'}, ...
        'testISO19030Validate.appendDiagnostic', 'log', 2);
    validateattributes(msgtrue, {'char'}, {'vector'}, ...
        'testISO19030Validate.appendDiagnostic', 'msgtrue', 3);
    validateattributes(msgfalse, {'char'}, {'vector'}, ...
        'testISO19030Validate.appendDiagnostic', 'msgfalse', 4);
    
    % Assign messages to corresponding values
    cm_c = cell(size(log));
    cm_c(~log) = {msgfalse};
    cm_c(log) = {msgtrue};
    
    % Append to existing diagnostic
    diag = [diag, cm_c];
    
    end
    
    function durations = splitInto(totalDuration, numDurations)
    % splitInto Return vector of durations covering total, with remainder
    
    validateattributes(totalDuration, {'numeric'}, ...
        {'scalar', 'integer', 'real'}, 'testISO19030Validate.splitInto',...
        'totalDuration', 1);
    validateattributes(numDurations, {'numeric'}, ...
        {'scalar', 'integer', 'real'}, 'testISO19030Validate.splitInto',...
        'numDurations', 2);
    
    x = totalDuration;
    y = numDurations;
    durations = repmat(floor(x/y), [1, y]);
    residual = round((x/y - floor(x/y))*y);
    if residual ~= 0
        durations = [durations, residual];
    end
    end
end

methods
    
    function [obj, inTable, varargout] = readInputTable(obj, fldr, varargin)
    % readInputTable Read table of input raw data
        
    % Input
    readSI_l = false;
    if nargin > 2
        
        readSI_l = varargin{1};
        validateattributes(readSI_l, {'logical'}, {'scalar'});
    end
    
    % Create full file path
    rawFile = fullfile(fldr, obj.RawFile);

    % Append string indicating that SI units are to be read
    if readSI_l

        [direct_ch, filename_ch, ext_ch] = fileparts(rawFile);
        filename_ch = [filename_ch, '_mps'];
        rawFile = fullfile(direct_ch, [filename_ch, ext_ch]);
        varargout{1} = rawFile;
    end

    % Read table
    varnames_c = obj.varNames;
    inTable = readtable(rawFile, 'ReadVariableNames', false);
    inTable.Properties.VariableNames = varnames_c;
    inTable.Time = datenum(inTable.Time, 'yyyy-mm-dd HH:MM:SS');
    end
    
    function [obj, outTable] = readOutputTable(obj, fldr, vars, fileSuffix)
    % readOutputTable Assign contents of files output by software to object
    
    % Get filename
    filename = fullfile(fldr, [obj.OutFilePrefix, fileSuffix]);
    
    % Read table from file
    stringTable = readtable(filename, 'ReadVariableNames', false, 'HeaderLines', 1);
    if isempty(stringTable)
       
        errid = 'testISO:OutputEmpty';
        errmsg = 'Output table cannot be created because output file is empty';
        warning(errid, errmsg);
    end
    
    numTable = varfun(@str2double, stringTable(:, 2:end));
    outTable = [stringTable(:, 1), numTable];
    outTable.Properties.VariableNames = vars;
    
    % Convert time to MATLAB datenum
    outTable.Time = datenum(outTable.Time, 'yyyy-mm-dd HH:MM:SS');
    
    end
    
    function [obj, outTable] = readOutInputTable(obj, fldr)
        
        pvVars = {
                    'Time'
                    'SpeedWater'
                    'DeliveredPower'
                    'ShaftRevolution'
                    'RelativeWindSpeed'
                    'RelativeWindDirection'
                    'AirTemp'
                    'SpeedGround'
                    'Heading'
                    'RudderAngle'
                    'WaterDepth'
                    'DraughtFore'
                    'DraughtAft'
                    'Displacements'
                    'WaterTemp'};
        outFileSuffix = '01_Input.csv';
        [obj, outTable] = readOutputTable(obj, fldr, pvVars, outFileSuffix);
    end
    
    function [obj, outTable] = readOutWindTable(obj, fldr)
        
            windVars = {'Time'
                    'SpeedWater'
                    'DeliveredPower'
                    'CorrectedPower'
                    'ShaftRevolution'
                    'RelativeWindSpeed'
                    'RelativeWindDirection'
                    'AirTemp'
                    'SpeedGround'
                    'Heading'
                    'RudderAngle'
                    'WaterDepth'
                    'DraughtFore'
                    'DraughtAft'
                    'Displacements'
                    'A'
                    'WaterTemp'
                    'TrueWindSpeed'};
        outFileSuffix = '04_Corrected.csv';
        [obj, outTable] = readOutputTable(obj, fldr, windVars, outFileSuffix);
    end
    
    function [obj, outTable] = readValidTable(obj, fldr)
    % readValidTable Read table of validated results
    
        pvVars = {
                'Time'
                'SpeedWater'
                'DeliveredPower'
                'ShaftRevolution'
                'RelativeWindSpeed'
                'RelativeWindDirection'
                'AirTemp'
                'SpeedGround'
                'Heading'
                'RudderAngle'
                'WaterDepth'
                'DraughtFore'
                'DraughtAft'
                'Disp'
                'WaterTemp'};
        outFileSuffix = '03_Validated.csv';
        [obj, outTable] = readOutputTable(obj, fldr, pvVars, outFileSuffix);
    end
    
    function [obj, outTable] = readFilteredTable(obj, fldr)
    % readValidTable Read table of validated results
    
        pvVars = {
                    'Time'
                    'SpeedWater'
                    'DeliveredPower'
                    'ShaftRevolution'
                    'RelativeWindSpeed'
                    'RelativeWindDirection'
                    'AirTemp'
                    'SpeedGround'
                    'Heading'
                    'RudderAngle'
                    'WaterDepth'
                    'DraughtFore'
                    'DraughtAft'
                    'Disp'
                    'WaterTemp'};
        outFileSuffix = '02_Filtered.csv';
        [obj, outTable] = readOutputTable(obj, fldr, pvVars, outFileSuffix);
    end
    
    function [obj, tbl] = readOutInputTableValidated(obj)
        
        fldr = obj.TestDirValidated;
        [obj, tbl] = readOutInputTable(obj, fldr);
        obj.OutInputTableValidated = tbl;
    end
    
    function [obj, tbl] = readValidTableValidated(obj)
        
        fldr = obj.TestDirValidated;
        [obj, tbl] = readValidTable(obj, fldr);
        obj.ValidTableValidated = tbl;
    end
       
    function [obj, tbl] = readDBISOTableValidated(obj)
    % readDBISOTable Read from database table where ISO values calculated
        
        dbTab = obj.DBTab;
        dbVars = obj.DBVars;
        [~, tbl] = obj.testVesselValidated.select(dbTab, dbVars);
        tbl.datetime_utc = datenum(tbl.datetime_utc, 'dd-mm-yyyy');
        obj.DBISOTableValidated = tbl;
    end
    
    function [obj, tbl] = readDBISOTableFiltered(obj)
    % readDBISOTableFiltered 
        
        dbTab = obj.DBTab;
        dbVars = obj.DBVars;
        [~, tbl] = obj.testVesselFiltered.select(dbTab, dbVars);
        tbl.datetime_utc = datenum(tbl.datetime_utc, 'dd-mm-yyyy');
        obj.DBISOTableFiltered = tbl;
    end
    
    function [obj, tbl] = readDBISOTablePower(obj)
    % readDBISOTablePower 
        
        dbTab = obj.DBTab;
        dbVars = obj.DBVars;
        [~, tbl] = obj.testVesselPower.select(dbTab, dbVars);
        tbl.datetime_utc = datenum(tbl.datetime_utc, 'dd-mm-yyyy');
        obj.DBISOTablePower = tbl;
    end
    
    function [obj, tbl] = readInputTableValidated(obj)
        
        fldr = obj.TestDirValidated;
        [obj, tbl] = readInputTable(obj, fldr);
        obj.InputTableValidated = tbl;
    end
    
    function [obj, tbl, varargout] = readInputTablePower(obj)
        
        fldr = obj.TestDirPower;
        readSI_l = true;
        [obj, tbl, filename] = readInputTable(obj, fldr, readSI_l);
        obj.InputTablePower = tbl;
        varargout{1} = filename;
    end
    
    function [obj, tbl, varargout] = readInputTablePV(obj)
        
        fldr = obj.TestDirPV;
        readSI_l = true;
        [obj, tbl, filename] = readInputTable(obj, fldr, readSI_l);
        obj.InputTablePV = tbl;
        varargout{1} = filename;
    end
    
    function obj = runISOOnInputValidated(obj)
        
        % Load input file
        obj = obj.readInputTableValidated;
        
        % Get vessel
        vessel = obj.testVesselValidated;
        
        % Insert data into test database, writing raw data file for software
        vessel.insert;
        rawFile = obj.RawFileValidated;
        tab = 'RawData';
        cols_c = {'DateTime_UTC',...
                    'Speed_Through_Water',...
                    'Delivered_Power',... Delivered Power
                    'Shaft_Revolutions',... Shaft Revs
                    'Relative_Wind_Speed',... Wind Speed knts
                    'Relative_Wind_Direction',... Wind dir sector 1 to 7
                    'Air_Temperature',... Air Temp
                    'Speed_Over_Ground',... SOG
                    'Ship_Heading',... Heading
                    'Rudder_Angle',... Rudder Angle
                    'Water_Depth',... Water depth
                    'Static_Draught_Fore',... Draft
                    'Static_Draught_Aft',... Draft
                    'Displacement',... Disp
                    'Seawater_Temperature'... Water temp
                    };
        delim_ch = ',';
        ignore_ch = 0;
        set = ['SET IMO_Vessel_Number = ', num2str(vessel.IMO_Vessel_Number)];

        delete_sql = ['DELETE FROM ', tab, ' WHERE IMO_Vessel_Number = ',...
            num2str(vessel.IMO_Vessel_Number), ';'];
        vessel.execute(delete_sql);
        vessel = vessel.loadInFile(rawFile, tab, cols_c, delim_ch, ignore_ch, set);
        
        % Delete test vessel data already in database
        vessel.execute(['SELECT * FROM PerformanceData WHERE IMO_Vessel_Number = ',...
            num2str(vessel.IMO_Vessel_Number), ';']);
        
        % Run in database
%         vessel.ISO19030(false, false, false);
        obj.refreshTestTable;
        vessel.call('updateValidated');
    end
    
    function obj = runISOOnInputFiltered(obj)
        
        % Load input file
        obj = obj.readInputTableFiltered;
        
        % Get vessel
        vessel = obj.testVesselFiltered;
        
        % Insert data into test database, writing raw data file for software
        vessel.insert;
        rawFile = obj.RawFileFiltered;
        tab = 'RawData';
        cols_c = {'DateTime_UTC',...
                    'Speed_Through_Water',...
                    'Delivered_Power',... Delivered Power
                    'Shaft_Revolutions',... Shaft Revs
                    'Relative_Wind_Speed',... Wind Speed knts
                    'Relative_Wind_Direction',... Wind dir sector 1 to 7
                    'Air_Temperature',... Air Temp
                    'Speed_Over_Ground',... SOG
                    'Ship_Heading',... Heading
                    'Rudder_Angle',... Rudder Angle
                    'Water_Depth',... Water depth
                    'Static_Draught_Fore',... Draft
                    'Static_Draught_Aft',... Draft
                    'Displacement',... Disp
                    'Seawater_Temperature'... Water temp
                    };
        delim_ch = ',';
        ignore_ch = 0;
        set = ['SET IMO_Vessel_Number = ', num2str(vessel.IMO_Vessel_Number)];

        delete_sql = ['DELETE FROM ', tab, ' WHERE IMO_Vessel_Number = ',...
            num2str(vessel.IMO_Vessel_Number), ';'];
        vessel.execute(delete_sql);
        vessel = vessel.loadInFile(rawFile, tab, cols_c, delim_ch, ignore_ch, set);
        
        % Delete test vessel data already in database
        vessel.execute(['SELECT * FROM PerformanceData WHERE IMO_Vessel_Number = ',...
            num2str(vessel.IMO_Vessel_Number), ';']);
        
        % Run in database
%         vessel.ISO19030(false, false, false);
        obj.refreshTestTable;
        vessel.call('updateChauvenetCriteria');
    end
    
    function obj = runISOOnInputPower(obj)
        
        % Load input file with SI units
        [obj, ~, rawPower] = obj.readInputTablePower;
        
        % Get vessel
        vessel = obj.testVesselPower;
        
        % Insert data into test database, writing raw data file for software
        vessel.insert;
        rawFile = rawPower; %obj.RawFilePower;
        tab = 'RawData';
        cols_c = {'DateTime_UTC',...
                    'Speed_Through_Water',...
                    'Delivered_Power',... Delivered Power
                    'Shaft_Revolutions',... Shaft Revs
                    'Relative_Wind_Speed',... Wind Speed knts
                    'Relative_Wind_Direction',... Wind dir sector 1 to 7
                    'Air_Temperature',... Air Temp
                    'Speed_Over_Ground',... SOG
                    'Ship_Heading',... Heading
                    'Rudder_Angle',... Rudder Angle
                    'Water_Depth',... Water depth
                    'Static_Draught_Fore',... Draft
                    'Static_Draught_Aft',... Draft
                    'Displacement',... Disp
                    'Seawater_Temperature'... Water temp
                    };
        delim_ch = ',';
        ignore_ch = 0;
        set = ['SET IMO_Vessel_Number = ', num2str(vessel.IMO_Vessel_Number)];
        
        delete_sql = ['DELETE FROM ', tab, ' WHERE IMO_Vessel_Number = ',...
            num2str(vessel.IMO_Vessel_Number), ';'];
        vessel.execute(delete_sql);
        vessel = vessel.loadInFile(rawFile, tab, cols_c, delim_ch, ignore_ch, set);
        obj.refreshTestTable;
        
        % Delete test vessel data already in database
        vessel.execute(['SELECT * FROM PerformanceData WHERE IMO_Vessel_Number = ',...
            num2str(vessel.IMO_Vessel_Number), ';']);
        
        % Run in database
%         vessel.ISO19030(false, false, false);
        vessel.ISO19030();
%         vessel.call('ISO19030', num2str(vessel.IMO_Vessel_Number));
    end
    
    function obj = runISOOnInputPV(obj)
        
        % Load input file
        [obj, ~, rawPV] = obj.readInputTablePV;
        
        % Get vessel
        vessel = obj.testVesselPV;
        
        % Insert data into test database, writing raw data file for software
        vessel.insert;
        rawFile = rawPV;
        tab = 'RawData';
        cols_c = {'DateTime_UTC',...
                    'Speed_Through_Water',...
                    'Delivered_Power',... Delivered Power
                    'Shaft_Revolutions',... Shaft Revs
                    'Relative_Wind_Speed',... Wind Speed knts
                    'Relative_Wind_Direction',... Wind dir sector 1 to 7
                    'Air_Temperature',... Air Temp
                    'Speed_Over_Ground',... SOG
                    'Ship_Heading',... Heading
                    'Rudder_Angle',... Rudder Angle
                    'Water_Depth',... Water depth
                    'Static_Draught_Fore',... Draft
                    'Static_Draught_Aft',... Draft
                    'Displacement',... Disp
                    'Seawater_Temperature'... Water temp
                    };
        delim_ch = ',';
        ignore_ch = 0;
        set = ['SET IMO_Vessel_Number = ', num2str(vessel.IMO_Vessel_Number)];

        delete_sql = ['DELETE FROM ', tab, ' WHERE IMO_Vessel_Number = ',...
            num2str(vessel.IMO_Vessel_Number), ';'];
        vessel.execute(delete_sql);
        vessel = vessel.loadInFile(rawFile, tab, cols_c, delim_ch, ignore_ch, set);
        
        % Run ISO
        vessel = vessel.ISO19030();
%         vessel.call('ISO19030', num2str(vessel.IMO_Vessel_Number));
        
        % Insert "input" to procedures: corrected power read from software
        [obj, pv_tbl] = obj.readOutPVTablePV;
%         pv_tbl = obj.OutPVTablePV;
        corr = pv_tbl.CorrectedPower;
        datetime_c = cellstr(datestr(pv_tbl.Time, 'yyyy-mm-dd HH:MM:SS'));
        vessel.insertValuesDuplicate('tempRawISO', ...
            {'DateTime_UTC', 'IMO_Vessel_Number', 'Corrected_Power'},...
            [datetime_c, num2cell(repmat(vessel.IMO_Vessel_Number, size(corr))) ,num2cell(corr)]);
        
        % Execute Relevant Procedures
        vessel.call('updateExpectedSpeed', num2str(vessel.IMO_Vessel_Number));
        vessel.call('updateSpeedLoss');
    end
    
    function refreshTestTable(obj)
    % refreshTestTable Reset test table to initial conditions
        
        vess = obj.testVesselValidated;
        vess = vess.call('createTempRawISO', num2str(vess.IMO_Vessel_Number));
        vess.call('sortOnDateTime');
    end
    
    function [obj, tbl] = readOutInputTableFiltered(obj)
        
        fldr = obj.TestDirFiltered;
        [obj, tbl] = readOutInputTable(obj, fldr);
        obj.OutInputTableFiltered = tbl;
    end
    
    function [obj, tbl] = readFilteredTableFiltered(obj)
        
        fldr = obj.TestDirFiltered;
        [obj, tbl] = readFilteredTable(obj, fldr);
        obj.FilteredTableFiltered = tbl;
    end
    
    function [obj, tbl] = readInputTableFiltered(obj)
        
        fldr = obj.TestDirFiltered;
        [obj, tbl] = readInputTable(obj, fldr);
        obj.InputTableFiltered = tbl;
    end
    
    function [obj, tbl] = readOutWindTablePower(obj)
        
        fldr = obj.TestDirPower;
        [obj, tbl] = readOutWindTable(obj, fldr);
        obj.OutWindTablePower = tbl;
    end
    
    function obj = convertUnitsPower(obj)
    % convertUnits Rewrite input files, make data units software-compatible 
    
        % Conversion factors
        mps2Knots = 1.94384449;
        
%         % Raw file
%         [newFilePath_ch, newFile_ch, newFileExt_ch] = fileparts(obj.RawFilePower);
%         newFile_ch = strcat(newFile_ch, '_mps');
%         copyfile(obj.RawFilePower, fullfile(newFilePath_ch, [newFile_ch, newFileExt_ch]));
%         obj = obj.readInputTablePower;
%         input_tbl = obj.InputTablePower;
%         input_tbl.STW = input_tbl.STW * mps2Knots;
%         input_tbl.Relative_Wind_Speed = input_tbl.Relative_Wind_Speed * mps2Knots;
%         input_tbl.Speed_Over_Ground = input_tbl.Speed_Over_Ground * mps2Knots;
%         input_tbl.Time = cellstr(datestr(input_tbl.Time, 'yyyy-mm-dd HH:MM:SS'));
%         writetable(input_tbl, obj.RawFilePower, 'WriteVariableNames', false);
        
        % Get Files
        sp = obj.spFilesPower;
        
        % Read files
        sp1_tbl = readtable(sp{1});
        sp2_tbl = readtable(sp{2});
        
        % Change values
        sp1_tbl.Var1 = sp1_tbl.Var1 * mps2Knots;
        sp2_tbl.Var1 = sp2_tbl.Var1 * mps2Knots;
        
        % Remove mps
        sp = strrep(sp, '_mps.csv', '.csv');
        
        % Write files
        writetable(sp1_tbl, sp{1}, 'WriteVariableNames', false);
        writetable(sp2_tbl, sp{2}, 'WriteVariableNames', false);
    end
    
    function [obj, tbl] = readOutPVTablePV(obj)
    % readOutPVTablePV 
        
        fldr = obj.TestDirPV;
        [obj, tbl] = readOutPVTable(obj, fldr);
        obj.OutPVTablePV = tbl;
    end
    
    function [obj, outTable] = readOutPVTable(obj, fldr)
        
        pvVars = {'Time'
                'SpeedWater'
                'DeliveredPower'
                'CorrectedPower'
                'TrueWindSpeed'
                'SpeedGround'
                'RudderAngle'
                'WaterDepth'
                'MeanDraught'
                'Displacements'
                'WaterTemp'
                'PV'};
        outFileSuffix = '05_PV.csv';
        [obj, outTable] = readOutputTable(obj, fldr, pvVars, outFileSuffix);
    end
    
    function tbl = appendRawPV(obj, rawtbl, len, vessel, varargin)
    % appendRaw Append to table input data and random data to pass filters 
    
    % Inputs
    validateattributes(rawtbl, {'table'}, {}, ...
        'testISO19030Validate.appendRaw', 'rawtbl', 1);
    validateattributes(len, {'numeric'}, {'scalar', 'integer', 'positive'}, ...
        'testISO19030Validate.appendRaw', 'len', 2);
    validateattributes(vessel, {'cVessel'}, {'scalar'}, ...
        'testISO19030Validate.appendRaw', 'vessel', 3);
    
    cellfun(@(x) validateattributes(x, {'char'}, {'vector'},...
        'testISO19030Validate.appendRaw', 'variableName', 4), varargin(1:2:end));
    cellfun(@(x) validateattributes(x, {'numeric'}, {'vector'},...
        'testISO19030Validate.appendRaw', 'variableValues', 5), varargin(2:2:end));
    
    % Get variables needed
    inputNames_c = varargin(1:2:end);
    allVars = [obj.InputFileVars, {'Trim'}];
    varData = cell(numel(allVars), 2);
    neededVars_c = setdiff(allVars, inputNames_c);
    
    % Assign data input
    varData(:, 1) = allVars;
    [~, inputData_i] = ismember(inputNames_c, varData(:, 1));
    inputData_c = varargin(2:2:end);
    varData(inputData_i, 2) = inputData_c;
    
    % Create data for testing displacement data within speed, power range
    uniDisps_v = [vessel.SpeedPower(:).Displacement];
    numDisplacements = numel(uniDisps_v);
    lengths_v = testISO19030External.splitInto(len, numDisplacements);
    temp_c = cell(1, numDisplacements + 1);
    spIndex_v = [1:numDisplacements, 1];
    currVar = 'Displacement';
    if ismember(currVar, neededVars_c)
        for di = spIndex_v

            currDisp = uniDisps_v(di);
            currLength = lengths_v(di);
            temp_c{di} = testISO19030.randInThreshold([1, currLength], ...
                @gt, (1/1.05)*currDisp, @lt, (1/0.95)*currDisp);
        end
        disp_v = [temp_c{:}];
        varData(ismember(allVars, currVar), 2) = {disp_v};
    end
    
    % Create data for testing trim within speed, power range
    uniTrims_v = [vessel.SpeedPower(:).Trim];
    temp_c = cell(1, numDisplacements);
    lbp = vessel.LBP;
    currVar = 'Trim';
    for ti = spIndex_v

        currTrim = uniTrims_v(ti);
        currLength = lengths_v(ti);
        temp_c{ti} = testISO19030.randInThreshold([1, currLength], ...
            @gt, currTrim - 1/(0.002*lbp), @lt, currTrim + 1/(0.002*lbp));
    end
    trim_v = [temp_c{:}];
    if ismember(currVar, neededVars_c)
        varData(ismember(allVars, currVar), 2) = {trim_v};
    else
        trim_l = ismember(varData(:, 1), 'Trim');
        trim_v = varData{trim_l, 2};
    end
    
    % Create data for testing speed, power data within speed, power range
    tempPower_c = cell(1, numDisplacements);
    tempSpeed_c = cell(1, numDisplacements);
    for si = spIndex_v
        
        currLength = lengths_v(si);
        currMinPower = min(vessel.SpeedPower(si).Power);
        currMaxPower = max(vessel.SpeedPower(si).Power);
        currMinSpeed = min(vessel.SpeedPower(si).Speed);
        currMaxSpeed = max(vessel.SpeedPower(si).Speed);
        tempPower_c{si} = testISO19030.randInThreshold([1, currLength], ...
            @gt, currMinPower, @lt, currMaxPower);
        tempSpeed_c{si} = testISO19030.randInThreshold([1, currLength], ...
            @gt, currMinSpeed, @lt, currMaxSpeed);
    end
    currVar = 'Delivered_Power';
    if ismember(currVar, neededVars_c)
        power_v = [tempPower_c{:}];
        varData(ismember(allVars, currVar), 2) = {power_v};
    end
    currVar = 'STW';
    if ismember(currVar, neededVars_c)
        stw_v = [tempSpeed_c{:}];
        varData(ismember(allVars, currVar), 2) = {stw_v};
    else
        stw_v = varData{ismember(allVars, currVar), 2};
    end
    
    % Create data for testing water temp within threshold
    currVar = 'Water_Temperature';
    if ismember(currVar, neededVars_c)
        waterTemp_v = testISO19030.randInThreshold([1, len], @gt, 2, @lt, 25);
        varData(ismember(allVars, currVar), 2) = {waterTemp_v};
    end
    
    % Create data for testing wind speed within threshold
    currVar = 'Relative_Wind_Speed';
    if ismember(currVar, neededVars_c)
        windSpeed_v = testISO19030.randInThreshold([1, len], @gt, 0, @lt, 7.9);
        varData(ismember(allVars, currVar), 2) = {windSpeed_v};
    end
    
    % Create data for testing water depth within threshold
    meanDraft_v = testISO19030.randInThreshold([1, len], @gt, 3, @lt, 10);
    draftAft_v = meanDraft_v - 0.5*trim_v;
    draftFore_v = trim_v + draftAft_v;

    minDepth1 = 3.*sqrt(vessel.Breadth_Moulded.*meanDraft_v);
    minDepth2 = 2.75.*sqrt(stw_v.^2./obj.g);
    depth_v = nan(1, len);
    for di = 1:len

        minDepth = max([minDepth1(di), minDepth2(di)]);
        depth_v(di) = testISO19030.randInThreshold(1, @gt, minDepth, ...
            @lt, minDepth + 1e3);
    end
    
    currVar = 'Water_Depth';
    if ismember(currVar, neededVars_c)
        varData(ismember(allVars, currVar), 2) = {depth_v};
    end
    currVar = 'Draft_Aft';
    if ismember(currVar, neededVars_c)
        varData(ismember(allVars, currVar), 2) = {draftAft_v};
    end
    currVar = 'Draft_Fore';
    if ismember(currVar, neededVars_c)
        varData(ismember(allVars, currVar), 2) = {draftFore_v};
    end
    
    % Create data for testing rudder angle within threshold
    currVar = 'Rudder_Angle';
    if ismember(currVar, neededVars_c)
        rudderAngle_v = testISO19030.randInThreshold([1, len], @gt, -5, @lt, 5);
        varData(ismember(allVars, currVar), 2) = {rudderAngle_v};
    end
    
    % Create time vector to represent noon-data
    currVar = 'Time';
    if ismember(currVar, neededVars_c)
        if isempty(rawtbl)
            prevTime = datenum('01-01-2000');
        else
            prevTime = rawtbl.Time(end);
        end
        tStep = obj.TimeStepPV;
%         dateTime_v = prevTime + 1 :prevTime+len;
        dateTime_v = prevTime + tStep: tStep: prevTime+len*tStep;
        varData(ismember(allVars, currVar), 2) = {dateTime_v};
    end
    
    % Create others
    currVar = 'Shaft_Revolutions';
    if ismember(currVar, neededVars_c)
        shaftRevs_v = testISO19030.randInThreshold([1, len], @gt, 0, @lt, 120);
        varData(ismember(allVars, currVar), 2) = {shaftRevs_v};
    end
    currVar = 'Relative_Wind_Direction';
    if ismember(currVar, neededVars_c)
        windDir_v = testISO19030.randInThreshold([1, len], @ge, 0, @lt, 360);
        varData(ismember(allVars, currVar), 2) = {windDir_v};
    end
    currVar = 'Air_Temperature';
    if ismember(currVar, neededVars_c)
        airTemp_v = testISO19030.randInThreshold([1, len], @gt, 0, @lt, 40);
        varData(ismember(allVars, currVar), 2) = {airTemp_v};
    end
    currVar = 'Speed_Over_Ground';
    if ismember(currVar, neededVars_c)
        sog_v = testISO19030.randInThreshold([1, len], @gt, 0, @lt, 40);
        varData(ismember(allVars, currVar), 2) = {sog_v};
    end
    currVar = 'Heading';
    if ismember(currVar, neededVars_c)
        head_v = testISO19030.randInThreshold([1, len], @gt, 0, @lt, 360);
        varData(ismember(allVars, currVar), 2) = {head_v};
    end
    
    % Make data compatible with table
    varData(:, 2) = cellfun(@(x) x(:), varData(:, 2), 'Uni', 0);
%     varData(end, :) = [];
    
    % Append all input data
    tbl = [rawtbl; table(varData{:, 2}, 'VariableNames', varData(:, 1))];
    
    end
    
    function obj = createTestFilesPV(obj)
    % createTestFiles Create files required for tests
    % obj = createTestFiles(obj) will return in the properties of obj the
    % paths to files, which are created in the test directory, containing
    % data which will fully test each of the outputs available from the
    % software.
    
    % Global test values
    len = obj.DataLengthPerCriteriaPV;
    testSize = [1, len];
    vessel = obj.testVesselPV;
    
    % Create raw data table
    varNames_c = [obj.InputFileVars, {'Trim'}];
    empty_c = cell(1, numel(varNames_c));
    rawTbl = table(empty_c{:}, 'VariableNames', varNames_c);
    diag_c = {};
    
    % Create speed, power data around extents of reference data
    for si = 1:numel(vessel.SpeedPower)
        
        minSpeed = min(vessel.SpeedPower(si).Speed);
        maxSpeed = max(vessel.SpeedPower(si).Speed);
        minPower = min(vessel.SpeedPower(si).Power);
        maxPower = max(vessel.SpeedPower(si).Power);
        minDisp = 1/1.05 * vessel.SpeedPower(si).Displacement;
        maxDisp = 1/0.95 * vessel.SpeedPower(si).Displacement;
%         minTrim = vessel.SpeedPower(si).Trim + (vessel.LBP - (1/0.998 * vessel.LBP)); % vessel.SpeedPower(si).Trim - 1/(0.002 * vessel.LBP);
%         maxTrim = vessel.SpeedPower(si).Trim + (vessel.LBP - (1/1.002 * vessel.LBP)); % vessel.SpeedPower(si).Trim + 1/(0.998 * vessel.LBP); %vessel.SpeedPower(si).Trim;
        minTrim = vessel.SpeedPower(si).Trim*0.999999;
        maxTrim = vessel.SpeedPower(si).Trim*1.000001;
        
        spd = testISO19030.randInThreshold(testSize, @gt, minSpeed, @lt, maxSpeed);
        pwr = testISO19030.randInThreshold(testSize, @gt, minPower, @lt, maxPower);
        disp = testISO19030.randInThreshold(testSize, @gt, minDisp, @lt, maxDisp);
        trim = testISO19030.randInThreshold(testSize, @gt, minTrim, @lt, maxTrim);
        
        [ospd, stwi] = testISO19030.randOutThreshold(testSize, @lt, minSpeed);
        diag_c = obj.appendDiagnostic(diag_c, stwi, 'Speed below minimum',...
            'Speed within range');
        rawTbl = obj.appendRawPV(rawTbl, len, vessel, 'STW', ospd, ...
            'Delivered_Power', pwr, 'Displacement', disp, 'Trim', trim...
            );
        [ospd, stwi] = testISO19030.randOutThreshold(testSize, @gt, maxSpeed);
        diag_c = obj.appendDiagnostic(diag_c, stwi, 'Speed above maximum',...
            'Speed within range');
        rawTbl = obj.appendRawPV(rawTbl, len, vessel, 'STW', ospd,...
            'Delivered_Power', pwr, 'Displacement', disp, 'Trim', trim...
            );
        [opwr, pwri] = testISO19030.randOutThreshold(testSize, @lt, minPower);
        diag_c = obj.appendDiagnostic(diag_c, pwri, 'Power below minimum',...
            'Power within range');
        rawTbl = obj.appendRawPV(rawTbl, len, vessel, 'Delivered_Power', opwr,...
            'STW', spd, 'Displacement', disp, 'Trim', trim);
        [opwr, pwri] = testISO19030.randOutThreshold(testSize, @gt, maxPower);
        diag_c = obj.appendDiagnostic(diag_c, pwri, 'Power above maximum',...
            'Power within range');
        rawTbl = obj.appendRawPV(rawTbl, len, vessel, 'Delivered_Power', opwr,...
            'STW', spd, 'Displacement', disp, 'Trim', trim);
        
        % Create displacement, trim around threshold for exclusion
        [odisp, dispi] = testISO19030.randOutThreshold(testSize, @lt, minDisp);
%         rawTbl = obj.appendRawPV(rawTbl, len, vessel, 'Displacement', disp);
%         minTrim = (1 - 0.002) * vessel.LBP; %vessel.SpeedPower(si).Trim;
        [otrim, trimi] = testISO19030.randOutThreshold(testSize, @lt, minTrim);
        diag_c = obj.appendDiagnostic(diag_c, dispi, 'Displacement, Trim below minimum',...
            'Displacement, Trim within range');
        rawTbl = obj.appendRawPV(rawTbl, len, vessel, 'Trim', otrim, ...
            'Displacement', odisp, 'Delivered_Power', pwr, 'STW', spd);
        
        [odisp, dispi] = testISO19030.randOutThreshold(testSize, @gt, maxDisp);
%         rawTbl = obj.appendRawPV(rawTbl, len, vessel, 'Displacement', disp);
%         maxTrim = (1 + 0.002) * vessel.LBP; % vessel.SpeedPower(si).Trim;
        [otrim, trimi] = testISO19030.randOutThreshold(testSize, @gt, maxTrim);
        diag_c = obj.appendDiagnostic(diag_c, dispi, 'Displacement, Trim above maximum',...
            'Displacement, Trim within range');
        rawTbl = obj.appendRawPV(rawTbl, len, vessel, 'Trim', otrim, ...
            'Displacement', odisp, 'Delivered_Power', pwr, 'STW', spd);
    end
    
    % Create depth around threshold
    mean_Draft = testISO19030.randInThreshold(testSize, @gt, 5, @lt, 15);
    validTrim_v = rawTbl.Trim(1:len);
    draft_Aft = mean_Draft(:)' - 0.5.*validTrim_v(:)';
    draft_Fore = validTrim_v(:)' + draft_Aft;
    stw_v = testISO19030.randInThreshold(testSize, @gt, 1, @lt, 20);
    minDepth1 = 3 .* sqrt(obj.testVesselPV.Breadth_Moulded .* mean_Draft);
    minDepth2 = 2.75.* (stw_v.^2 / obj.g) ;
    minDepth = max([minDepth1, minDepth2]);
    [depth_v, depth_l] = testISO19030.randOutThreshold(testSize, @gt, minDepth);
    diag_c = obj.appendDiagnostic(diag_c, depth_l, 'Depth below minimum',...
        'Depth within range');
    rawTbl = obj.appendRawPV(rawTbl, len, vessel,...
                                            'Draft_Fore', draft_Fore,...
                                            'Draft_Aft', draft_Aft,...
                                            'STW', stw_v,...
                                            'Water_Depth', depth_v);
    
    % Create wind, water temp, rudder angle around thresholds for exclusion
    [temp_v, temp_l] = testISO19030.randOutThreshold(testSize, @gt, 2);
    diag_c = obj.appendDiagnostic(diag_c, temp_l, 'Temp below minimum',...
        'Temp within range');
    rawTbl = obj.appendRawPV(rawTbl, len, vessel, 'Water_Temperature', temp_v);
    
    [wind_v, wind_l] = testISO19030.randOutThreshold(testSize, @gt, 7.9);
    diag_c = obj.appendDiagnostic(diag_c, wind_l, 'Wind above maximum',...
        'Wind within range');
    rawTbl = obj.appendRawPV(rawTbl, len, vessel, 'Relative_Wind_Speed', wind_v);
    
    [rudder_v, rudder_l] = testISO19030.randOutThreshold(testSize, @lt, 5);
    diag_c = obj.appendDiagnostic(diag_c, rudder_l, 'Rudder above maximum',...
        'Rudder within range');
    rawTbl = obj.appendRawPV(rawTbl, len, vessel, 'Rudder_Angle', rudder_v);
    
    % Create time strings from dates, remove trim
    rawTbl.Time = datestr(rawTbl.Time, 'yyyy-mm-dd HH:MM:SS');
    rawTbl.Trim = [];
    
%     % Concat comment table to raw table
%     numRowsDiff = size(rawTbl, 1) - size(cm_tbl, 1);
%     cm_tbl = [cm_tbl; repmat({''}, [numRowsDiff, 1])];
%     rawTbl = [rawTbl, cm_tbl];
    
    % Insert data into test database, writing raw data file for software
    vessel.insert;
    rawFile = obj.RawFilePV;
    tab = 'RawData';
    cols_c = {'DateTime_UTC',...
                'Speed_Through_Water',...
                'Delivered_Power',... Delivered Power
                'Shaft_Revolutions',... Shaft Revs
                'Relative_Wind_Speed',... Wind Speed knts
                'Relative_Wind_Direction',... Wind dir sector 1 to 7
                'Air_Temperature',... Air Temp
                'Speed_Over_Ground',... SOG
                'Ship_Heading',... Heading
                'Rudder_Angle',... Rudder Angle
                'Water_Depth',... Water depth
                'Static_Draught_Fore',... Draft
                'Static_Draught_Aft',... Draft
                'Displacement',... Disp
                'Seawater_Temperature'... Water temp
                };
    delim_ch = ',';
    writetable(rawTbl, rawFile, 'FileType', 'text', ...
        'WriteVariableNames', false);
    ignore_ch = 0;
    set = ['SET IMO_Vessel_Number = ', num2str(vessel.IMO_Vessel_Number),','];
    
    delete_sql = ['DELETE FROM ', tab, ' WHERE IMO_Vessel_Number = ',...
        num2str(vessel.IMO_Vessel_Number), ';'];
    vessel.execute(delete_sql);
    vessel = vessel.loadInFile(rawFile, tab, cols_c, delim_ch, ignore_ch, set);
    
    % Write diagnostic file
    obj = obj.writeDiagnosticFilePV(diag_c);
    
    % Write other input files for software, reading paths from properties
    spfile = obj.spFilesPV;
    windfile = obj.WindFilePV;
    vessel.validateISO19030({}, spfile, windfile, [], obj.TestDirPV);
    
    % Convert units
    obj = obj.convertUnitsPV;
    
    % Delete test vessel data already in database
%     vessel.execute(['SELECT * FROM PerformanceData WHERE IMO_Vessel_Number = ',...
%         num2str(vessel.IMO_Vessel_Number), ';']);
    
    % Run in database
    vessel.ISO19030(false, false, false);
    
    end
    
    function obj = convertUnitsPV(obj)
    % convertUnits Rewrite input files, make data units software-compatible 
    
        % Conversion factors
        mps2Knots = 1.94384449;
        
        % Raw file
        [newFilePath_ch, newFile_ch, newFileExt_ch] = fileparts(obj.RawFilePV);
        newFile_ch = strcat(newFile_ch, '_mps');
        copyfile(obj.RawFilePV, fullfile(newFilePath_ch, [newFile_ch, newFileExt_ch]));
        obj = obj.readInputTablePV;
        input_tbl = obj.InputTablePV;
        input_tbl.STW = input_tbl.STW * mps2Knots;
        input_tbl.Relative_Wind_Speed = input_tbl.Relative_Wind_Speed * mps2Knots;
        input_tbl.Speed_Over_Ground = input_tbl.Speed_Over_Ground * mps2Knots;
        input_tbl.Time = cellstr(datestr(input_tbl.Time, 'yyyy-mm-dd HH:MM:SS'));
        writetable(input_tbl, obj.RawFilePV, 'WriteVariableNames', false);
        
        % Get Files
        sp = obj.spFilesPV;
        
        % Read files
        sp1_tbl = readtable(sp{1});
        sp2_tbl = readtable(sp{2});
        
        % Change values
        sp1_tbl.Var1 = sp1_tbl.Var1 * mps2Knots;
        sp2_tbl.Var1 = sp2_tbl.Var1 * mps2Knots;
        
        % Remove mps
        sp = strrep(sp, '_mps.csv', '.csv');
        
        % Write files
        writetable(sp1_tbl, sp{1}, 'WriteVariableNames', false);
        writetable(sp2_tbl, sp{2}, 'WriteVariableNames', false);
    end
    
    function obj = writeDiagnosticFilePV(obj, diagnostic)
    % writeDiagnosticFile Write file giving information on each row's data
    
    % Input
    validateCellStr(diagnostic, 'writeDiagnosticFile', 'diagnostic', 2);
    
    % Write file
    filename = obj.DiagnosticFilePV;
    tbl = cell2table(diagnostic(:), 'VariableNames', {'Diagnostic'});
    writetable(tbl, filename, 'WriteVariableNames', true);
        
    end
end

methods(Test)
    
    function testValidated(testcase)
    % testValidated Test that validation matches that described in Annex J
    % 1. Test that the validation procedure has been carried out according
    % to Annex J by comparing the column 'Validated' in the test table with
    % the rows of the table in the output file with suffix "_Validated".
    % This test assumes that validation is being executed and that
    % filtering is not.
    
    % 1
    % Run ISO Input
    testcase = testcase.runISOOnInputValidated;
    
    % Input
    [~, db_tbl] = testcase.readDBISOTableValidated;
    db_filt = logical(db_tbl.validated);
    
    testcase = testcase.readOutInputTableValidated;
    testcase = testcase.readValidTableValidated;
    
    inputDates_v = testcase.OutInputTableValidated.Time;
    validDates_v = testcase.ValidTableValidated.Time;
    
    file_filt = ismember(inputDates_v, validDates_v);
    
    % Verify
    filt_msg = ['Validation procedure expected to be calculated based on '...
        'formula I7.'];
    testcase.verifyEqual(db_filt, file_filt, filt_msg);
    
    end
    
    function testFiltered(testcase)
    % testFiltering Test that filtering is carried out according to Annex I
    % 1: Test that rows in the output file with suffix "_Validated" match 
    % only FALSE values in column 'Chauvenet_Criteria' of the test table.
    
    % 1
    % Run ISO Input
    testcase = testcase.runISOOnInputFiltered;
    
    % Input
    [~, db_tbl] = testcase.readDBISOTableFiltered;
    db_filt = logical(db_tbl.chauvenet_criteria);
    
    testcase = testcase.readOutInputTableFiltered;
    testcase = testcase.readFilteredTableFiltered;
    
    inputDates_v = testcase.OutInputTableFiltered.Time;
    validDates_v = testcase.FilteredTableFiltered.Time;
    
    file_filt = ~ismember(inputDates_v, validDates_v);
    
    % Verify
    chauv_msg = ['Chauvenet criterion expected to be calculated based on '...
        'formula I7.'];
    testcase.verifyEqual(db_filt, file_filt, chauv_msg);
    
    end
    
    function testCorrectedDeliveredPower(testcase)
    % testCorrectedDeliveredPower Test corrected, delivered power
    
    % 1
    % Run ISO Input
    testcase = testcase.runISOOnInputPower;
    
    outVars = {'Time', 'CorrectedPower', 'DeliveredPower'};
    dbVars = lower({'DateTime_UTC', 'Corrected_Power', 'Delivered_Power'});
    
    % Read vars from DB
    [~, db_tbl] = testcase.readDBISOTablePower;
    dataDB = db_tbl(:, dbVars);
%     dataDB = testcase.DBISOTablePower(:, dbVars);
    
    % Read vars from software
    [testcase, dataOut] = testcase.readOutWindTablePower;
    dataOut = dataOut(:, outVars);
%     dataOut = testcase.OutWindTable(:, outVars);
    
    % Take only the intersection in Time
    [~, commonFromDB, commonFromOut] = intersect(...
        dataDB.(dbVars{1}), dataOut.(outVars{1}));
    dataDB = dataDB(commonFromDB, :);
    dataOut = dataOut(commonFromOut, :);
    
    % Compare
    msg_Corr = ['Values for Corrected, Delivered Power are expected to match'...
        ' those output by the software'];
    act_Corr = dataDB.(dbVars{2});
    exp_Corr = dataOut.(outVars{2});
    
    testcase.assertNotEmpty(act_Corr);
    testcase.assertNotEmpty(exp_Corr);
    testcase.verifyEqual(act_Corr, exp_Corr, 'RelTol', 1e-4, msg_Corr);
    
    end
    
    function testCalculationOfPerformanceValues(testcase)
    % testCalculationOfPerformanceValues PV from CorrectedPower
    
    % 1
    % Run ISO Input
    testcase = testcase.runISOOnInputPV;
    
    % Inputs
    [testcase, pv_tbl] = testcase.readOutPVTablePV;
    exp_sl = pv_tbl.PV;
    
    % Assert
    [testcase, act_tbl] = testcase.readDBISOTablePower;
    act_sl = act_tbl.speed_loss;
    len_msg = ['PV values returned by DB must be same size as those of the'...
        ' software'];
%     testcase.assertNumElements(act_sl, numel(exp_sl), len_msg);
    
    % Take only the intersection in Time
    actDates = act_tbl.datetime_utc;
    expDates = pv_tbl.Time;
    [~, commonFromDB, commonFromOut] = intersect(actDates, expDates);
    act_tbl = act_tbl(commonFromDB, :);
    exp_sl = exp_sl(commonFromOut, :);
    act_sl = act_tbl.speed_loss .* 1e2;
    exp_sl = pv_tbl.PV;
    
    % Verify
    msg_sl = ['Performance Values calculated by Hempel are expected to '...
        'match those of the software.'];
    testcase.verifyEqual(act_sl, exp_sl, 'AbsTol', 5, msg_sl);
%     testcase.verifyEqual(act_sl, exp_sl, 'RelTol', 0.1, msg_sl);
    
%     % Plot
%     act_date = act_tbl.datetime_utc;
%     figure;
%     scatter(act_date, act_sl, 'b*');
%     exp_date = pv_tbl.Time;
%     hold on;
%     scatter(exp_date, exp_sl, 'ro');
%     hold off;
%     legend({'Hempel Speed Loss', 'Software Speed Loss'});
%     
%     figure;
%     plot(act_sl, exp_sl, 'b*');
%     p = polyfit(act_sl, exp_sl, 1);
%     slope = p(1);
%     annotation('textbox',[.2 .5 .3 .3],...
%                     'String',['Slope = ', num2str(slope)],...
%                     'FitBoxToText','on');
    end
end
end