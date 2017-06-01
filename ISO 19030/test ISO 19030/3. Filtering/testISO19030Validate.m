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
%   The procedure for running the tests in this suite is as follows. First,
%   a set of input files will be created to be loaded into the software and
%   this is done by calling method createTestFiles:
%   obj = testISO19030Validate();
%   obj = obj.createTestFiles();
%   Note that the XML file containing the static data for the test vessel
%   already exists, so the user now needs to open the software, load this
%   XML file, and then load the raw data file created by createTestFiles.
%   This method also inserts equivalent data into the test database and
%   runs the ISO19030 procedure on that data. Now one can expect that, for
%   the test vessel, performance values in the database will match those in
%   the output files. Therefore, the user can now call the test methods:
%   res = run(obj, 'testMethod');

properties(Constant)
    
    TestDir char = fileparts(mfilename('fullpath')); % fullfile(testISO19030Validate.HomeDirectory, '\ISO 19030\test ISO 19030\External Validation');
    SPFile cell = {};
    WindFile char = testISO19030Validate.windFile;
    RawFile char = testISO19030Validate.rawFile;
    DiagnosticFile char = testISO19030Validate.diagnosticFile;
    OutFilePrefix char = 'validateISOOut_';
    TestVessel = testISO19030Validate.testVessel;
    VarNames = testISO19030Validate.varNames();
    Anemometre_Height = 40;
    Reference_Height = 10;
    g = 9.80665;
    DataLengthPerCriteria = 30;
    TimeStep = 1 / (24*60*4); % 0.25;
end

properties(Constant, Hidden)
    
%     HomeDirectory char = 'C:\Users\damcl\OneDrive - Hempel Group\Documents\SQL\tests\EcoInsight Test Scripts';
    VesselName = 'testVessel';
end

properties
    
    OutPVTable = table();
    OutWindTable = table();
    OutValidTable = table();
    OutFilteredTable = table();
    OutInputTable = table();
    DBPVTable = table();
    DBISOTable = table();
    DiagnosticTable = table();
    InputTable = table();
end

properties(Hidden)
    
    WindTable = table();
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
    objSP.Propulsive_Efficiency = 0.7;
    
    objSP(2).Displacement = 1e6;
    objSP(2).Trim = -5;
    objSP(2).Speed = linspace(5, 20, 5);
    objSP(2).Power = linspace(1e4, 9e4, 5);
    objSP(2).Propulsive_Efficiency = 0.7;
    
    % Create wind coefficients (model ID 1 in database)
    wind = cVesselWindCoefficient();
    wind.Direction = [0,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180];
    wind.Coefficient = [1.2640,1.3450,1.4090,1.3890,1.3150,1.1430,0.9230,0.6840,0.5100,0.3200,0.0780,-0.2070,-0.5560,-0.9420,-1.2350,-1.4660,-1.5740,-1.4630,-1.2570];
    wind.Wind_Reference_Height_Design = 10;
    wind = wind.mirrorAlong180();
    
    % Create vessel
    testvessel = cVessel();
    testvessel.Database = 'test';
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
    
    function diagFile = diagnosticFile()
        
        diagFile = fullfile(testISO19030Validate.TestDir, ...
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
        tStep = obj.TimeStep;
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
    
    function obj = createTestFiles(obj)
    % createTestFiles Create files required for tests
    % obj = createTestFiles(obj) will return in the properties of obj the
    % paths to files, which are created in the test directory, containing
    % data which will fully test each of the outputs available from the
    % software.
    
    % Global test values
    len = obj.DataLengthPerCriteria;
    testSize = [1, len];
    vessel = obj.TestVessel;
    
    % Create raw data table
    varNames_c = [obj.VarNames, {'Trim'}];
    empty_c = cell(1, numel(varNames_c));
    rawTbl = table(empty_c{:}, 'VariableNames', varNames_c);
    diag_c = {};
    
    % Get corrected, delivered power as bounds of speed, power relationship
    obj = obj.updateCorrectedDeliveredPower;
    
    % Create speed, power data around extents of reference data
    for si = 1:numel(vessel.SpeedPower)
        
        minSpeed = min(vessel.SpeedPower(si).Speed);
        [stw, stwi] = testISO19030.randOutThreshold(testSize, @lt, minSpeed);
        diag_c = obj.appendDiagnostic(diag_c, stwi, 'Speed below minimum',...
            'Speed within range');
        rawTbl = obj.appendRaw(rawTbl, len, vessel, 'STW', stw);
        maxSpeed = max(vessel.SpeedPower(si).Speed);
        [stw, stwi] = testISO19030.randOutThreshold(testSize, @gt, maxSpeed);
        diag_c = obj.appendDiagnostic(diag_c, stwi, 'Speed above maximum',...
            'Speed within range');
        rawTbl = obj.appendRaw(rawTbl, len, vessel, 'STW', stw);
        
        minPower = min(vessel.SpeedPower(si).Power);
        [pwr, pwri] = testISO19030.randOutThreshold(testSize, @lt, minPower);
        diag_c = obj.appendDiagnostic(diag_c, pwri, 'Power below minimum',...
            'Power within range');
        rawTbl = obj.appendRaw(rawTbl, len, vessel, 'Delivered_Power', pwr);
        maxPower = max(vessel.SpeedPower(si).Power);
        [pwr, pwri] = testISO19030.randOutThreshold(testSize, @gt, maxPower);
        diag_c = obj.appendDiagnostic(diag_c, pwri, 'Power above maximum',...
            'Power within range');
        rawTbl = obj.appendRaw(rawTbl, len, vessel, 'Delivered_Power', pwr);
        
        % Create displacement, trim around threshold for exclusion
        minDisp = 1/1.05 * vessel.SpeedPower(si).Displacement;
        [disp, dispi] = testISO19030.randOutThreshold(testSize, @lt, minDisp);
%         rawTbl = obj.appendRaw(rawTbl, len, vessel, 'Displacement', disp);
        minTrim = (1 - 0.002) * vessel.LBP; %vessel.SpeedPower(si).Trim;
        [trim, trimi] = testISO19030.randOutThreshold(testSize, @lt, minTrim);
        diag_c = obj.appendDiagnostic(diag_c, dispi, 'Displacement, Trim below minimum',...
            'Displacement, Trim within range');
        rawTbl = obj.appendRaw(rawTbl, len, vessel, 'Trim', trim, 'Displacement', disp);
        
        maxDisp = 1/0.95 * vessel.SpeedPower(si).Displacement;
        [disp, dispi] = testISO19030.randOutThreshold(testSize, @gt, maxDisp);
%         rawTbl = obj.appendRaw(rawTbl, len, vessel, 'Displacement', disp);
        maxTrim = (1 + 0.002) * vessel.LBP; % vessel.SpeedPower(si).Trim;
        [trim, trimi] = testISO19030.randOutThreshold(testSize, @gt, maxTrim);
        diag_c = obj.appendDiagnostic(diag_c, dispi, 'Displacement, Trim above maximum',...
            'Displacement, Trim within range');
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
    [depth_v, depth_l] = testISO19030.randOutThreshold(testSize, @gt, minDepth);
    diag_c = obj.appendDiagnostic(diag_c, depth_l, 'Depth below minimum',...
        'Depth within range');
    rawTbl = obj.appendRaw(rawTbl, len, vessel,...
                                            'Draft_Fore', draft_Fore,...
                                            'Draft_Aft', draft_Aft,...
                                            'STW', stw_v,...
                                            'Water_Depth', depth_v);
    
    % Create wind, water temp, rudder angle around thresholds for exclusion
    [temp_v, temp_l] = testISO19030.randOutThreshold(testSize, @gt, 2);
    diag_c = obj.appendDiagnostic(diag_c, temp_l, 'Temp below minimum',...
        'Temp within range');
    rawTbl = obj.appendRaw(rawTbl, len, vessel, 'Water_Temperature', temp_v);
    
    [wind_v, wind_l] = testISO19030.randOutThreshold(testSize, @gt, 7.9);
    diag_c = obj.appendDiagnostic(diag_c, wind_l, 'Wind above maximum',...
        'Wind within range');
    rawTbl = obj.appendRaw(rawTbl, len, vessel, 'Relative_Wind_Speed', wind_v);
    
    [rudder_v, rudder_l] = testISO19030.randOutThreshold(testSize, @lt, 5);
    diag_c = obj.appendDiagnostic(diag_c, rudder_l, 'Rudder above maximum',...
        'Rudder within range');
    rawTbl = obj.appendRaw(rawTbl, len, vessel, 'Rudder_Angle', rudder_v);
    
    % Create time strings from dates, remove trim
    rawTbl.Time = datestr(rawTbl.Time, 'yyyy-mm-dd HH:MM:SS');
    rawTbl.Trim = [];
    
%     % Concat comment table to raw table
%     numRowsDiff = size(rawTbl, 1) - size(cm_tbl, 1);
%     cm_tbl = [cm_tbl; repmat({''}, [numRowsDiff, 1])];
%     rawTbl = [rawTbl, cm_tbl];
    
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
    
    % Write diagnostic file
    obj = obj.writeDiagnosticFile(diag_c);
    
    % Write other input files for software, reading paths from properties
    spfile = obj.SPFile;
    windfile = obj.WindFile;
    vessel.validateISO19030({}, spfile, windfile, [], obj.TestDir);
    
    % Delete test vessel data already in database
    vessel.execute(['SELECT * FROM PerformanceData WHERE IMO_Vessel_Number = ',...
        num2str(vessel.IMO_Vessel_Number), ';']);
    
    % Run in database
    vessel.ISO19030(false, false, false);
    
    end
    
    function [obj, outTable] = readOutputTable(obj, vars, fileSuffix)
    % readOutputTable Assign contents of files output by software to object
    
    % Get filename
    filename = fullfile(obj.TestDir, [obj.OutFilePrefix, fileSuffix]);
    
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
    
    function obj = writeDiagnosticFile(obj, diagnostic)
    % writeDiagnosticFile Write file giving information on each row's data
    
    % Input
    validateCellStr(diagnostic, 'writeDiagnosticFile', 'diagnostic', 2);
    
    % Write file
    filename = obj.DiagnosticFile;
    tbl = cell2table(diagnostic(:), 'VariableNames', {'Diagnostic'});
    writetable(tbl, filename, 'WriteVariableNames', true);
        
    end
    
    function [obj, outTable, dbTable] = compareOutputs(obj)
    % compareOutputs Compare results of DB and software calculations
    
    % Read from DB all
    obj = obj.readDBISOTable;
    db_tbl = obj.DBISOTable;
    
    % Get Diagnostic and append
    obj = readDiagnosticTable(obj);
    diag_tbl = obj.DiagnosticTable;
    if isequal(size(db_tbl, 1), size(diag_tbl, 1))
        db_tbl = [db_tbl, diag_tbl];
    end
    
    % Read from Output file all
    obj = readPVTable(obj);
    out_tbl = obj.OutPVTable;
    
    % Find significantly different columns
    
    % Plot with diagnostic
    figure;
    plot(db_tbl.datetime_utc, db_tbl.speed_loss, 'b*');
    hold on;
    plot(out_tbl.Time, out_tbl.PV, 'ro');
    text(db_tbl.datetime_utc, db_tbl.speed_loss, db_tbl.Diagnostic);
    hold off;
    
    title(['Comparison of Speed Index calculated by Hempel DB and ISO '...
        'Verification Tool'], 'fontsize', 12);
    xlabel('Time')
    ylabel('Speed Index')
    legend({'Hempel DB', 'ISO Verification'});
    
    % Assign
    outTable = out_tbl;
    dbTable = db_tbl;
    
    end

    function [obj, data, outi] = outlierDetection(obj, outlier, varargin)
    % outlierDetection Random data within thresholds, including outliers
    
    % While size of data requested has not been met
    
    % Pass additional inputs to randInThreshold
    
    % Run SQL procedure
    
    % Assign any outliers / non-outliers to outputs
    
    
    end
    
    function [obj, data, validi] = validData(obj, dateutc, varargin)
    % validData Generate random data within thresholds which are valid
    % Assumptions: 
    % tempRawISO is empty prior
    % 
    
    % Input
    narginchk(4, inf);
    
    valid_l = varargin{1};
    validateattributes(valid_l, {'logical'}, {'scalar'}, ...
        'testISO19030Validate.validData', 'valid', 2);
%     col_ch = varargin{2};
%     validateattributes(col_ch, {'char'}, {'vector'}, ...
%         'testISO19030Validate.validData', 'column', 3);
    
    % Remaining inputs are those to randInThreshold / randOutThreshold
    randInputs_c = varargin(2:end);
    cols = {'Shaft_Revolutions', 'Speed_Through_Water', 'Speed_Over_Ground',...
        'Rudder_Angle'};
    threholds_v = [3, 0.5, 0.5, 1];
    thresh = threholds_v(ismember(cols, col_ch));
    timecols = {'DateTime_UTC', [cols{:}]};
    if valid_l
        
        data = testISO19030.randInThreshold(randInputs_c{:});
        timedata = [dateutc(:), data(:)];
        
        vessel = obj.testVessel;
        vessel = vessel.insert('tempRawISO', timecols, timedata);
        vessel.call('updateValidated');
        [~, valid_tbl] = vessel.select('tempRawISO', 'validated');
        vessel.execute('DELETE FROM tempRawISO');
        
        % Check whether data is all valid
        valid_l = valid_tbl.validated;
        finished = all(valid_l);
        
        while ~finished
            
            % Take indices to invalid data
            invalid_i = find(~valid_l);
            
            % Repeat call to random data function
            
            % Assign any new valid data to output
            data(valid_l)
            
        end
    else
        
        [data, validi] = testISO19030.randOutThreshold(randInputs_c{:});
    end
    
    % Drop tempRawISO
    
    
    end
    
    function [obj, expSpeed] = expectedSpeed(obj, model, corr, ndisp, ntrim)
    % expectedSpeed Calculate expected speed for model from corrected power
    
    % Input
    validateattributes(model, {'char'}, {'vector'}, ...
        'testISO19030Validate.expectedSpeed', 'model', 2);
    validateattributes(corr, {'numeric'}, {'vector', 'positive'}, ...
        'testISO19030Validate.expectedSpeed', 'corr', 3);
    validateattributes(ndisp, {'numeric'}, {'vector', 'positive'}, ...
        'testISO19030Validate.expectedSpeed', 'ndisp', 4);
    validateattributes(ntrim, {'numeric'}, {'vector'}, ...
        'testISO19030Validate.expectedSpeed', 'ntrim', 5);
    
    vess = obj.TestVessel;
    sp = vess.SpeedPower;
    sp = sp.fit;
    
    nearCoeffs = arrayfun(@(d, t) ...
        sp([sp.Displacement]==d & [sp.Trim]==t).Coefficients, ndisp, ntrim, 'Uni', 0);
    nearCoeffs = cell2mat(nearCoeffs);
    
    switch model
        
        case 'exp'

            % Exponential model
            expSpeed = arrayfun(@(x, a, b) a*log(x) + b, corr, nearCoeffs(:, 1), nearCoeffs(:, 2));

        case 'poly'

            % Polynomial
            expSpeed = arrayfun(@(x, a, b, c) polyval([a, b, c], x), ...
                corr, nearCoeffs(:, 1), nearCoeffs(:, 2), nearCoeffs(:, 3));
    end
    end

    function [obj, pv] = performanceValues(obj, eSpeed, mSpeed)
    % performanceValues Calculate speed loss as described in 5.3.6.1
        
        pv = 100.* (mSpeed - eSpeed) ./ eSpeed;
        
    end
    
    function obj = rewriteForValidation(obj)
    % rewriteForValidation Rewrite input data file for validation test
    
    
    % Load file into table
    obj = obj.readInputTable();
    input_tbl = obj.InputTable;
    
    % Generate table of four parameters with ~50% passing validation
    valid_m = nan(size(input_tbl, 1), 4);
    
    % Create vector of failing conditions, with ~50% not failing
    time = input_tbl.Time;
    mins10 = 10 / (24*60);
    tStep = time(2) - time(1);
    num10Mins = floor((max(time) - min(time) + tStep) / mins10);
    blockSize = repmat(round(mins10 / tStep), [1, num10Mins]);
%     blockSize(end+1) = round((((max(time) - min(time)) / mins10) - ...
%         num10Mins)*blockSize(1));
%     blockSize(blockSize == 0) = [];
    num10Mins = numel(blockSize);
    
    % Iterate over each 10-minute block of data
    muRPM = 1;
    muSTW = 10;
    muSOG = 9;
    muRUD = 2;
    
    failingVar = cell(1, num10Mins);
    failingVar(1:2:end) = {'none'};
    fourParamsNames_c = {'rpm', 'stw', 'sog', 'rud'};
    fourParams_c = repmat(fourParamsNames_c', [1, floor( numel(failingVar)/2 )]);
    fourParams_c = fourParams_c(:);
    failingVar(2:2:end) = fourParams_c(1:floor( numel(failingVar)/2 ));
    
    % Error if any of the four parameters has not had one failing block
    allFailOnce_l = all(ismember(fourParamsNames_c, failingVar ));
    if ~allFailOnce_l
        
        errid = 'testVal:NeedMoreTime';
        errmsg = ['Insufficient 10-minute intervals in data to test each '...
            'validation criterion'];
        error(errid, errmsg);
    end
    
    for di = 1:num10Mins
        
        currFailingVar = failingVar{di};
        
        switch currFailingVar
            
            case 'rpm'
                
                rpmSEM = 6;
                stwSEM = 0.25;
                sogSEM = 0.25;
                rudSEM = 0.5;
                
            case 'stw'
                
                rpmSEM = 1.5;
                stwSEM = 1;
                sogSEM = 0.25;
                rudSEM = 0.5;
                
            case 'sog'
                
                rpmSEM = 1.5;
                stwSEM = 0.25;
                sogSEM = 1;
                rudSEM = 0.5;
                
            case 'rud'
                
                rpmSEM = 1.5;
                stwSEM = 0.25;
                sogSEM = 0.25;
                rudSEM = 2;
                
            case 'none'
                
                rpmSEM = 1.5;
                stwSEM = 0.25;
                sogSEM = 0.25;
                rudSEM = 0.5;
        end
        
        nRows = blockSize(di);
        currSize = [nRows, 1];
        rpm_v = randn(currSize)*rpmSEM + muRPM;
        stw_v = randn(currSize)*stwSEM + muSTW;
        sog_v = randn(currSize)*sogSEM + muSOG;
        rud_v = randn(currSize)*rudSEM + muRUD;
        
        startRowI = sum([1, blockSize(1:di - 1)]);
        endRowI = startRowI + nRows - 1;
        
        valid_m(startRowI:endRowI, :) = [rpm_v, stw_v, sog_v, rud_v];
    end
    
    % Rewrite file with new values
    input_tbl.Shaft_Revolutions = valid_m(:, 1);
    input_tbl.STW = valid_m(:, 2);
    input_tbl.Speed_Over_Ground = valid_m(:, 3);
    input_tbl.Rudder_Angle = valid_m(:, 4);
    obj.writeInputTable(input_tbl);
    
    % Load in data, overwriting existing data
    tab = 'RawData';
    cols_c = {'DateTime_UTC',...
                'IMO_Vessel_Number',...
                'Shaft_Revolutions',... Shaft Revs
                'Speed_Through_Water',...
                'Speed_Over_Ground',... SOG
                'Rudder_Angle',... Rudder Angle
                };
    vess = obj.TestVessel;
    vals_c = [cellstr(datestr(input_tbl.Time, 'yyyy-mm-dd HH:MM:SS')), ...
        num2cell(repmat(vess.IMO_Vessel_Number, size(valid_m, 1), 1)), ...
        num2cell(valid_m)];
    vess = vess.insertValuesDuplicate(tab, cols_c, vals_c);
    
    % Call ISO
    vess.ISO19030(false, false, false);
    
    end    
    
    function obj = writeInputTable(obj, tbl)
    % writeInputTable Write table of input raw data
    
        tbl.Time = datestr(tbl.Time, 'yyyy-mm-dd HH:MM:SS');
        writetable(tbl, obj.RawFile, 'FileType', 'text', ...
            'WriteVariableNames', false);
    end
end

methods(Access = protected)
        
    function obj = updateCorrectedDeliveredPower(obj)
    % updateCorrectedDeliveredPower 
    
    % Create tempRawISO, sortOnDateTime
    
    % Get Area
    
    % Get Trim
    
    % Get Wind Reference
    
    % Get Wind Resistance Relative
        
    % Get Air Resistance
    
    % Get Wind Resistance Correction
    
    % Assign to table
    
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
                    'Filter_Reference_Rudder_Angle'
                    'True_Wind_Direction'
                    'True_Wind_Direction_Reference'
                    'True_Wind_Speed'
                    'True_Wind_Speed_Reference'    
                    'Relative_Wind_Speed_Reference'
                    };
        [~, dataDB] = obj.TestVessel.select(dbTab, dbVars);
        dataDB.datetime_utc = datenum(dataDB.datetime_utc, 'dd-mm-yyyy');
        obj.DBISOTable = dataDB;
    end
    
    function obj = readDiagnosticTable(obj)
    % readDiagnosticTable Read diagnostic from file
    
    filename = obj.DiagnosticFile;
    tbl = readtable(filename, 'FileType', 'text', 'ReadVariableNames', true,...
        'Delimiter', ',');
    obj.DiagnosticTable = tbl;
    
    end
    
    function obj = readValidTable(obj)
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
        [obj, outTable] = readOutputTable(obj, pvVars, outFileSuffix);
        
        % Assign
        obj.OutValidTable = outTable;
        
    end
    
    function obj = readFilteredTable(obj)
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
        [obj, outTable] = readOutputTable(obj, pvVars, outFileSuffix);
        
        % Assign
        obj.OutFilteredTable = outTable;
        
    end
    
    function obj = readOutInputTable(obj)
        
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
        [obj, outTable] = readOutputTable(obj, pvVars, outFileSuffix);
        
        % Assign
        obj.OutInputTable = outTable;
        
    end
    
    function obj = readInputTable(obj)
    % readInputTable Read table of input raw data
    
        varnames_c = obj.varNames;
        tbl = readtable(obj.RawFile, 'ReadVariableNames', false);
        tbl.Properties.VariableNames = varnames_c;
        tbl.Time = datenum(tbl.Time, 'yyyy-mm-dd HH:MM:SS');
        obj.InputTable = tbl;
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
    % Input
    db_tbl = testcase.DBISOTable;
    db_filt = logical(db_tbl.validated);
    
    inputDates_v = testcase.OutInputTable.Time;
    validDates_v = testcase.OutValidTable.Time;
    
    file_filt = ismember(inputDates_v, validDates_v);
    
    % Verify
    filt_msg = ['Validation procedure expected to be calculated based on '...
        'formula I7.'];
    testcase.verifyEqual(db_filt, file_filt, filt_msg);
    
    end
    
    function testFiltering(testcase)
    % testFiltering Test that filtering is carried out according to Annex I
    % 1: Test that rows in the output file with suffix "_Validated" match 
    % only FALSE values in column 'Chauvenet_Criteria' of the test table.
    
    % 1
    % Input
    db_tbl = testcase.DBISOTable;
    db_filt = logical(db_tbl.chauvenet_criteria);
    
    inputDates_v = testcase.OutInputTable.Time;
    validDates_v = testcase.OutFilteredTable.Time;
    
    file_filt = ~ismember(inputDates_v, validDates_v);
    
    % Verify
    chauv_msg = ['Chauvenet criterion expected to be calculated based on '...
        'formula I7.'];
    testcase.verifyEqual(db_filt, file_filt, chauv_msg);
    
    end

    function testWindCorrection(testcase)
    % Test the results for wind resistance correction against the software
        
    outVars = {'Time', 'TrueWindSpeed'};
    dbVars = lower({'DateTime_UTC', 'True_Wind_Speed', ...
        'True_Wind_Speed_Reference', 'Relative_Wind_Speed_Reference'});
    
    % Read vars from DB
    dataDB = testcase.DBISOTable(:, dbVars);
    
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
    actPV = dataDB.true_wind_speed;
    exp_PV = dataOut.TrueWindSpeed;
    testcase.verifyEqual(actPV, exp_PV, 'RelTol', 5e-6, dataMsg);
    
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
    testcase.verifyEqual(actPV, exp_PV, 'RelTol', 5e-6, dataMsg);
    
    end
    
    function testCalculationOfPerformanceValues(testcase)
    % testCalculationOfPerformanceValues PV from CorrectedPower
    
    % Inputs
    coeffA = [];
    coeffB = [];
    pv_tbl = testcase.OutPVTable;
    corr = pv_tbl.CorrectedPower;
    datetime_c = cellstr(datestr(pv_tbl.Time, 'yyyy-mm-dd HH:MM:SS'));
    vess = testcase.TestVessel;
    vess.insertValuesDuplicate('tempRawISO', ...
        {'DateTime_UTC', 'IMO_Vessel_Number', 'Corrected_Power'},...
        [datetime_c, num2cell(repmat(vess.IMO_Vessel_Number, size(corr))) ,num2cell(corr)]);
    expDates = pv_tbl.Time;
    
    % Execute Relevant Procedures
    vess.call('updateExpectedSpeed', num2str(vess.IMO_Vessel_Number));
    vess.call('updateSpeedLoss');
    
    % Verify
    [~, act_tbl] = vess.select('tempRawISO', {'DateTime_UTC', 'Speed_Loss',...
        'Corrected_Power', 'NearestTrim', 'NearestDisplacement', ...
        'Speed_Through_Water'});
    actDates = datenum(act_tbl.datetime_utc, 'dd-mm-yyyy');
    exp_sl = pv_tbl.PV;
    
    % Take only the intersection in Time
    [~, commonFromDB, commonFromOut] = intersect(actDates, expDates);
    act_tbl = act_tbl(commonFromDB, :);
    act_sl = act_tbl.speed_loss;
    exp_sl = exp_sl(commonFromOut, :);
    msg_sl = ['Performance Values calculated by Hempel are expected to '...
        'match those of the software.'];
    testcase.verifyEqual(act_sl, exp_sl, 'AbsTol', 1e-2, msg_sl);
    
%     % Plot
%     act_date = datenum(act_tbl.datetime_utc, 'dd-mm-yyyy');
%     figure;
%     scatter(act_date, act_sl, 'b*');
%     exp_date = pv_tbl.Time;
%     hold on;
%     scatter(exp_date, exp_sl, 'ro');
%     hold off;
%     legend({'Hempel Speed Loss', 'Software Speed Loss'});
%     
%     diag = testcase.DiagnosticTable.Diagnostic;
%     text(act_date, act_sl, diag(commonFromDB), 'HorizontalAlignment', 'Right')
    
    end
end

end