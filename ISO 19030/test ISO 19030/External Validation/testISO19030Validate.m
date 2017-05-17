classdef testISO19030Validate < matlab.unittest.TestCase % & testISO19030
%testISO19030Validate Test suite for external validation of ISO19030
%   testISO19030Validate will test database procedures against external
%   results from program "ISO 19030 Test Software".
%   This test suite will compare data from the files returned by the
%   program "ISO 19030 Test Software" (the software) with those returned by
%   the test database for the same input data. First, the data in the file
%   "_Input" will be inserted along with those containing the ship data.
%   Then procedures will be called in each of the test methods as
%   appropriate to replicate the behaviour of the corresponding output
%   files. Therefore, a prerequisite of this suite is that data
%   describing the vessels speed, power relationship and wind coefficients, 
%   used by the software, exist in the test directory where they can be
%   accessed by the test suite.

properties(Constant)
    
    TestDir char = fullfile(testISO19030Validate.HomeDirectory, '\ISO 19030\test ISO 19030\External Validation');
    SPFile cell = {}; %testISO19030Validate.spFiles;
    WindFile char = testISO19030Validate.windFile;
    RawFile char = testISO19030Validate.rawFile;
    OutFilePrefix char = 'validateISOOut_';
    TestVessel = testISO19030Validate.testVessel;
    VarNames = testISO19030Validate.varNames();
    Anemometre_Height = 40;
    Reference_Height = 10;
    g = 9.80665;
end

properties(Constant, Hidden)
    
    HomeDirectory char = 'C:\Users\damcl\OneDrive - Hempel Group\Documents\SQL\tests\EcoInsight Test Scripts';
    VesselName = 'testVessel';
end

properties
    
    OutPVTable = table();
    OutWindTable = table();
    DBPVTable = table();
    DBISOTable = table();
end

methods(Static)
    
    function spfiles = spFiles()
        
        spfiles = arrayfun(@(x) fullfile(testISO19030Validate.TestDir, ...
            ['spFile', num2str(x), '.csv']), 1:2, 'Uni', 0);
    end
    
    function testvessel = testVessel()
        
    % Create speed, power curves
    objSP = cVesselSpeedPower();
    objSP.Displacement = 5e5;
    objSP.Trim = 0;
    objSP.Speed = 5:5:25;
    objSP.Power = 1e4:1e4:5e4;
    
    objSP(2).Displacement = 1e6;
    objSP(2).Trim = -5;
    objSP(2).Speed = linspace(5, 20, 5);
    objSP(2).Power = linspace(1e4, 9e4, 5);
    
    % Create wind coefficients (model ID 1 in database)
    wind = cVesselWindCoefficient();
    wind.Direction = [0,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180];
    wind.Coefficient = [1.2640,1.3450,1.4090,1.3890,1.3150,1.1430,0.9230,0.6840,0.5100,0.3200,0.0780,-0.2070,-0.5560,-0.9420,-1.2350,-1.4660,-1.5740,-1.4630,-1.2570];
    wind = wind.mirrorAlong180();
    
    % Create vessel
    testvessel = cVessel();
    testvessel.IMO_Vessel_Number = 1234567;
    testvessel.Name = 'Test Vessel';
    testvessel.Draft_Design = 10;
    testvessel.Breadth_Moulded = 50;
    testvessel.Transverse_Projected_Area_Design = 2000;
    testvessel.LBP = 400;
    testvessel.SpeedPower = objSP;
    testvessel.WindCoefficient = wind;
    testvessel.Database = 'test';
    testvessel.DryDockDates = cVesselDryDockDates;
    
    end
    
    function windfile = windFile()
        
        windfile = fullfile(testISO19030Validate.TestDir, ...
            'validateISO19030TestWind.csv');
    end
    
    function rawfile = rawFile()
        
        rawfile = fullfile(testISO19030Validate.TestDir, ...
            'validateISO19030Test.csv');
        
    end
    
    function varnames = varNames()
    % varNames
        
        varnames = {'Time', 'STW', 'Delivered_Power', 'Shaft_Revolutions',...
            'Relative_Wind_Speed', 'Relative_Wind_Direction', 'Air_Temperature',...
            'Speed_Over_Ground', 'Heading', 'Rudder_Angle', 'Water_Depth',...
            'Draft_Fore', 'Draft_Aft', 'Displacement', 'Water_Temperature'};
        
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
   
    function obj = findFilesInDir(obj)
    % findFilesInDir Find files required for testing in test directory
        
    end
    
    function tbl = appendRaw(obj, rawtbl, len, vessel, varargin)
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
    allVars = [obj.VarNames, {'Trim'}];
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
    lengths_v = testISO19030Validate.splitInto(len, numDisplacements);
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
        dateTime_v = prevTime + 1:prevTime+len;
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
    
    function obj = createTestFiles(obj)
    % createTestFiles Create files required for tests
    % obj = createTestFiles(obj) will return in the properties of obj the
    % paths to files, which are created in the test directory, containing
    % data which will fully test each of the outputs available from the
    % software.
    
    % Global test values
    len = 2;
    testSize = [1, len];
    vessel = obj.TestVessel;
    
    % Create raw data table
    varNames_c = [obj.VarNames, {'Trim'}];
    empty_c = cell(1, numel(varNames_c));
    rawTbl = table(empty_c{:}, 'VariableNames', varNames_c);
    
    % Create speed, power data around extents of reference data
    for si = 1:numel(vessel.SpeedPower)
        
        minSpeed = min(vessel.SpeedPower(si).Speed);
        stw = testISO19030.randOutThreshold(testSize, @lt, minSpeed);
        rawTbl = obj.appendRaw(rawTbl, len, vessel, 'STW', stw);
        maxSpeed = max(vessel.SpeedPower(si).Speed);
        stw = testISO19030.randOutThreshold(testSize, @gt, maxSpeed);
        rawTbl = obj.appendRaw(rawTbl, len, vessel, 'STW', stw);
        
        minPower = min(vessel.SpeedPower(si).Power);
        pwr = testISO19030.randOutThreshold(testSize, @lt, minPower);
        rawTbl = obj.appendRaw(rawTbl, len, vessel, 'Delivered_Power', pwr);
        maxPower = max(vessel.SpeedPower(si).Power);
        pwr = testISO19030.randOutThreshold(testSize, @gt, maxPower);
        rawTbl = obj.appendRaw(rawTbl, len, vessel, 'Delivered_Power', pwr);
        
        % Create displacement, trim around threshold for exclusion
        minDisp = 1/1.05 * vessel.SpeedPower(si).Displacement;
        disp = testISO19030.randOutThreshold(testSize, @lt, minDisp);
%         rawTbl = obj.appendRaw(rawTbl, len, vessel, 'Displacement', disp);
        minTrim = (1 - 0.002) * vessel.LBP; %vessel.SpeedPower(si).Trim;
        trim = testISO19030.randOutThreshold(testSize, @lt, minTrim);
        rawTbl = obj.appendRaw(rawTbl, len, vessel, 'Trim', trim, 'Displacement', disp);
        
        maxDisp = 1/0.95 * vessel.SpeedPower(si).Displacement;
        disp = testISO19030.randOutThreshold(testSize, @gt, maxDisp);
%         rawTbl = obj.appendRaw(rawTbl, len, vessel, 'Displacement', disp);
        maxTrim = (1 + 0.002) * vessel.LBP; % vessel.SpeedPower(si).Trim;
        trim = testISO19030.randOutThreshold(testSize, @gt, maxTrim);
        rawTbl = obj.appendRaw(rawTbl, len, vessel, 'Trim', trim, 'Displacement', disp);
    end
    
    % Create depth around threshold
    mean_Draft = testISO19030.randInThreshold(testSize, @gt, 5, @lt, 15);
    validTrim_v = rawTbl.Trim(1:len);
    draft_Aft = mean_Draft(:)' - 0.5.*validTrim_v(:)';
    draft_Fore = validTrim_v(:)' + draft_Aft;
    stw_v = testISO19030.randInThreshold(testSize, @gt, 1, @lt, 20);
    minDepth1 = 3 .* sqrt(obj.TestVessel.Breadth_Moulded .* mean_Draft);
    minDepth2 = 2.75.* (stw_v.^2 / obj.g) ;
    minDepth = max([minDepth1, minDepth2]);
    depth_v = testISO19030.randOutThreshold(testSize, @gt, minDepth);
    rawTbl = obj.appendRaw(rawTbl, len, vessel,...
                                            'Draft_Fore', draft_Fore,...
                                            'Draft_Aft', draft_Aft,...
                                            'STW', stw_v,...
                                            'Water_Depth', depth_v);
    
    % Create wind, water temp, rudder angle around thresholds for exclusion
    temp_v = testISO19030.randOutThreshold(testSize, @gt, 2);
    rawTbl = obj.appendRaw(rawTbl, len, vessel, 'Water_Temperature', temp_v);
    
    wind_v = testISO19030.randOutThreshold(testSize, @gt, 7.9);
    rawTbl = obj.appendRaw(rawTbl, len, vessel, 'Relative_Wind_Speed', wind_v);
    
    rudder_v = testISO19030.randOutThreshold(testSize, @lt, 5);
    rawTbl = obj.appendRaw(rawTbl, len, vessel, 'Rudder_Angle', rudder_v);
    
    % Create time strings from dates, remove trim
    rawTbl.Time = datestr(rawTbl.Time, 'yyyy-mm-dd HH:MM:SS');
    rawTbl.Trim = [];
    
    % Insert data into test database, writing raw data file for software
    vessel.insert;
    rawFile = obj.RawFile;
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
    
    % Write other input files for software, reading paths from properties
    spfile = obj.SPFile;
    windfile = obj.WindFile;
    vessel.validateISO19030({}, spfile, windfile, [], obj.TestDir);
    
    % Run in database
    vessel.ISO19030(false, false, false);
    
    end
    
    function [obj, outTable] = readOutputTable(obj, vars, fileSuffix)
    % readOutputTable Assign contents of files output by software to object
    
    % Get filename
    filename = fullfile(obj.TestDir, [obj.OutFilePrefix, fileSuffix]);
    
    % Read table from file
    stringTable = readtable(filename, 'ReadVariableNames', false, 'HeaderLines', 1);
    numTable = varfun(@str2double, stringTable(:, 2:end));
    outTable = [stringTable(:, 1), numTable];
    outTable.Properties.VariableNames = vars;
    
    % Convert time to MATLAB datenum
    outTable.Time = datenum(outTable.Time, 'yyyy-mm-dd HH:MM:SS');
    
    
    end
end

methods(TestClassSetup)
    
    function obj = readPVTable(obj)
        
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
        [obj, outTable] = readOutputTable(obj, pvVars, outFileSuffix);
        
        % Assign
        obj.OutPVTable = outTable;
    end
    
    function obj = readWindTable(obj)
        
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
        [obj, outTable] = readOutputTable(obj, windVars, outFileSuffix);
        
        % Assign
        obj.OutWindTable = outTable;
    end

    function obj = readDBPVTable(obj)
    % readDBPVTable Read from database table containing processed results
        
        dbTab = 'PerformanceData';
        dbVars = {'DateTime_UTC', 'Speed_Index'};
        [~, dataDB] = obj.TestVessel.select(dbTab, dbVars);
        dataDB.datetime_utc = datenum(dataDB.datetime_utc, 'dd-mm-yyyy');
        obj.DBPVTable = dataDB;
    end
    
    function obj = readDBISOTable(obj)
    % readDBISOTable Read from database table where ISO values calculated
    
        dbTab = 'tempRawISO';
        dbVars = {'DateTime_UTC'
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
                    'Displacement_Correction_Needed'
                    'Filter_All'
                    'Filter_SFOC_Out_Range'
                    'Filter_Reference_Seawater_Temp'
                    'Filter_Reference_Wind_Speed'
                    'Filter_Reference_Water_Depth'
                    'Filter_Reference_Rudder_Angle'};
        [~, dataDB] = obj.TestVessel.select(dbTab, dbVars);
        dataDB.datetime_utc = datenum(dataDB.datetime_utc, 'dd-mm-yyyy');
        obj.DBISOTable = dataDB;
    end
end

methods(Test)
    
    function testFiltering(testcase)
    % testFiltering Test that filtering is carried out according to Annex I
    % 1:
    
    % 1
    % Call DB procedure: insert values, call proc, read data to MATLAB
    testcase.dropTable
    testcase.createTable
    N = 5E2;
    nBlock = 5;
    k = 20;
    
    in_SpeedOverGround = abs(randn([1, N])*10);
    in_RelWindSpeed = abs(randn([1, N])*10);
    in_RudderAngle = abs(randn([1, N])*k);
    tstep = 1 / (24*(60/2));
    in_DateTimeUTC = linspace(now, now+(tstep*(N-1)), N);
    
    [startrow, count] = testcase.insert([cellstr(datestr(...
        in_DateTimeUTC, 'yyyy-mm-dd HH:MM:SS.FFF')), ...
        num2cell(in_SpeedOverGround)',...
        num2cell(in_RelWindSpeed)', ...
        num2cell(in_RudderAngle)'], ...
        {'DateTime_UTC', 'Speed_Over_Ground', 'Relative_Wind_Speed',...
        'Rudder_Angle'});
    
    testcase.call('updateChauvenetCriteria');
    
    % Read external files
    
    
    % Verify
    chauv_msg = ['Chauvenet criterion expected to be calculated based on '...
        'formula I7.'];
    testcase.verifyEqual(int_Chauv, ext_Chauv, 'RelTol', 1.5E-7, chauv_msg);
        
    end

    function testWindCorrection(testcase)
    % Test the results for wind resistance correction against the software
        
    outVars = {'Time', 'TrueWindSpeed'};
    dbVars = lower({'DateTime_UTC', 'True_Wind_Speed'});
    
    % Read vars from DB
    dataDB = testcase.DBISOTable;
    
    % Read vars from software
    dataOut = testcase.OutWindTable(:, outVars);
    
    % Take only the intersection in Time
    [~, commonFromDB, commonFromOut] = intersect(...
        dataDB.(dbVars{1}), dataOut.(outVars{1}));
    dataDB = dataDB(commonFromDB, :);
    dataOut = dataOut(commonFromOut, :);
    
    % Compare
    dataMsg = ['Values for the Speed Loss are expected to match those '...
        'output by the software'];
    actPV = dataDB.speed_index;
    exp_PV = dataOut.PV;
    testcase.verifyEqual(actPV, exp_PV, dataMsg);
        
    end
    
    function testPV(testcase)
    % Compare performance values between software and DB
        
    outVars = {'Time', 'PV'};
    dbVars = lower({'DateTime_UTC', 'Speed_Loss'});
    
    % Read vars from DB
    dataDB = testcase.DBPVTable;
    
    % Read vars from software
    dataOut = testcase.OutPVTable(:, outVars);
    
    % Take only the intersection in Time
    [~, commonFromDB, commonFromOut] = intersect(...
        dataDB.(dbVars{1}), dataOut.(outVars{1}));
    dataDB = dataDB(commonFromDB, :);
    dataOut = dataOut(commonFromOut, :);
    
    % Compare
    dataMsg = ['Values for the Speed Loss are expected to match those '...
        'output by the software'];
    actPV = dataDB.speed_index;
    exp_PV = dataOut.PV;
    testcase.verifyEqual(actPV, exp_PV, dataMsg);
    
    end
end

end