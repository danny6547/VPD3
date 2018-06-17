classdef testISO19030 < matlab.unittest.TestCase
%testISO19030 Test suite for the ISO 19030 Database methods
%   testISO19030 contains a suite of tests for the stored procedures of a
%   given database. These tests will execute the procedures on table
%   "tempRawISO" tables in the database and compare the result data
%   retrieved from it with expected results found in MATLAB. Therefore it
%   relies on data in other tables and other procedures on which these 
%   procedures depends to be accessible.

properties
    
    TableName = 'tempRawISO';
    TestStaticDatabase = 'static';
    TestInServiceDatabase = 'inservice';
    TestIMO = 1234567;
    TestVesselIdString = '';
    TestVessel = [];
end

properties(Hidden)
    
    Server = 'localhost';
    Database = 'test';
    Uid = 'root';
    Pwd = 'HullPerf2016';
end

properties(Constant, Hidden)
    
    DateTimeFormSQL = 'yyyy-mm-dd HH:MM:SS';
    DateTimeFormAdodb = 'dd-mm-yyyy HH:MM:SS';
%     InvalidIMO = sprintf('%u', [1:6, 8]);
    minTemp = 2;
    MinWind = 0;
    MaxWind = 7.9;
    GravitationalAcceleration = 9.80665;
    MaxRudder = 5;
    
end

methods(TestClassSetup)
    
    function vessel = insertTestVessel(testcase)
    % insertTestVessel Insert data for test vessel into table "Vessels"
    
    vessel = cVessel('Database', testcase.TestStaticDatabase);
    vessel.InServiceDB = testcase.TestInServiceDatabase;
    vessel.IMO = testcase.TestIMO;
    vessel.Configuration.Breadth_Moulded = 42.8;
    vessel.Configuration.Length_Overall = 334;
    vessel.Configuration.Transverse_Projected_Area_Design = 1330;
    vessel.Configuration.Draft_Design = 15;
    vessel.Configuration.LBP = 319;
    vessel.Configuration.Anemometer_Height = 40;
    vessel.Configuration.Wind_Reference_Height_Design = 15;
    vessel.Configuration.Vessel_Configuration_Description = 'Test Config';
    vessel.Configuration.Fuel_Type = 'HFO';
    vessel.Configuration.Speed_Power_Source = 'Sea Trial';
    
    coeffs_v = [-0.67766500
                    -0.74222815
                    -0.77252740
                    -0.73429870
                    -0.66942290
                    -0.40641463
                    -0.25761423
                    -0.22303768
                    -0.27221212
                    -0.06631846
                    0.34516430
                    0.67289070
                    0.88259417
                    0.83342505
                    0.64720550];
    dirs_v = linspace(0, 180, length(coeffs_v));
    wind_cvw = vessel.WindCoefficient;
    wind_cvw.Direction = dirs_v;
    wind_cvw.Coefficient = coeffs_v;
    wind_cvw = wind_cvw.mirrorAlong180();
    vessel.WindCoefficient = wind_cvw;
    
    engine = vessel.Engine;
    engine.Lowest_Given_Brake_Power = 22840.84;
    engine.Highest_Given_Brake_Power = 67544.40;
    SFOCCoefficients = [-6949.127353, 7.918354135, -0.000132468];
    engine.X0 = SFOCCoefficients(1);
    engine.X1 = SFOCCoefficients(2);
    engine.X2 = SFOCCoefficients(3);
    engine.Minimum_FOC_ph = 3989.96;
    engine.Engine_Model = 'Test Vessel Engine';
    vessel.Engine = engine;
    
    sp = vessel.SpeedPower;
    sp.Coefficient_A = 7.07170;
    sp.Coefficient_B = -50.54008;
    sp.Displacement = 114050;
    sp.Trim = 0;
    sp.Minimum_Power = 28534;
    sp.Maximum_Power = 9e4;
    sp.Propulsive_Efficiency = 2;
    vessel.SpeedPower = sp;
    
    % Insert displacement so won't error
    disp = vessel.Displacement;
    disp.Draft_Mean = 1:5;
    disp.Trim = zeros(1, 5);
    disp.Displacement = 1e5:1e4:1.4e5;
    vessel.Displacement = disp;
    
    % Insert dry-dock so won't error
    dd = vessel.DryDock;
    dd.Start_Date = '2000-01-01';
    dd.End_Date = '2000-01-14';
    vessel.DryDock = dd;
    
    vessel.insert();
    
    testcase.TestVessel = vessel;
    testcase.TestVesselIdString = num2str(vessel.Vessel_Id);
    
    end
    
    function createTable(testcase)
    % createTable Creates test table in database if none exists
    
    vessel = testcase.TestVessel;
    vessel.InServiceSQLDB.call('createTempRawISO', num2str(testcase.TestIMO));
    end
    
end

methods(TestClassTeardown)
    
    function dropTable(obj)
    % dropTable Drops test table in database if none exists
    
    vessel = obj.TestVessel;
    vessel.InServiceSQLDB.drop('TABLE', 'tempRawISO');
    
    end
end

methods(Static)
    
    function R = randInThreshold(sz, varargin)
    % randInThreshold Random values within thresholds
    
    % Input
    R = [];
    validateattributes(sz, {'numeric'}, {'integer', 'positive', 'vector'}, ...
        'testISO19030.randInThreshold', 'sz', 1);
    if nargin == 1
       R = rand(sz);
       return;
    end
    
    % Check that conditions have accompanying values
    conditionValue_c = varargin;
    validateattributes(numel(conditionValue_c)/2, {'numeric'}, {'integer'},...
        'randOutThreshold', 'condition,value', 2);
    cellfun(@(x) validateattributes(x, {'function_handle'}, {'scalar'},...
        'randOutThreshold', 'condition', 2), conditionValue_c(1:2:end));
    cellfun(@(x) validateattributes(x, {'numeric'}, {'scalar'},...
        'randOutThreshold', 'value', 3), conditionValue_c(2:2:end));
    
    funcNames_c = cellfun(@func2str, conditionValue_c(1:2:end), 'Uni', 0);
    if any(~ismember(funcNames_c, {'gt', 'ge', 'lt', 'le'}))
       
       errid = 'db:randThresh:UnknownOperator';
       errmsg = 'Input operator must be from the set gt, ne, lt, le.';
       error(errid, errmsg);
    end
    
    % Assign Defaults
    maximum = 1;
    minimum = 0;
    
    % Create vector
    squareInputs = [conditionValue_c(1:2:end)', conditionValue_c(2:2:end)'];
    [gt_l, gt_i] = ismember('gt', funcNames_c);
    [ge_l, ge_i] = ismember('ge', funcNames_c);
    [lt_l, lt_i] = ismember('lt', funcNames_c);
    [le_l, le_i] = ismember('le', funcNames_c);
    if gt_l
        maximum = squareInputs{gt_i, 2};
    end
    if ge_l
        maximum = squareInputs{ge_i, 2};
    end
    if lt_l
        minimum = squareInputs{lt_i, 2};
    end
    if le_l
        minimum = squareInputs{le_i, 2};
    end
    R = minimum + (maximum - minimum).*rand(sz);
    
    end
    
    function [R, in, out] = randOutThreshold(sz, varargin)
    % Random data with some, but not all, values within thresholds
    
    % Input
    R = [];
    in = [];
    out = [];
    if nargin == 1
       R = rand(sz);
    else
       R = nan(sz);
    end
    
    if prod(sz) == 1
        
       errid = 'db:randThresh:InsufficientSize';
       errmsg = ['Input data size, SZ, must correspond to two or more ',...
           'elements in order to return values within and without ',...
           'thresholds.'];
       error(errid, errmsg);
    end
    
    % Check that conditions have accompanying values
    conditionValue_c = varargin;
    validateattributes(numel(conditionValue_c)/2, {'numeric'}, {'integer'},...
        'randOutThreshold', 'condition,value', 2);
    cellfun(@(x) validateattributes(x, {'function_handle'}, {'scalar'},...
        'randOutThreshold', 'condition', 2), conditionValue_c(1:2:end));
    cellfun(@(x) validateattributes(x, {'numeric'}, {'scalar'},...
        'randOutThreshold', 'value', 3), conditionValue_c(2:2:end));
    
    funcNames_c = cellfun(@func2str, conditionValue_c(1:2:end), 'Uni', 0);
    if any(~ismember(funcNames_c, {'gt', 'ne', 'lt', 'le'}))
       errid = 'db:randThresh:UnknownOperator';
       errmsg = 'Input operator must be from the set gt, ne, lt, le.';
       error(errid, errmsg);
    end
    
    % Prepare conditions
    squareInputs = [conditionValue_c(1:2:end)', conditionValue_c(2:2:end)'];
    
    % Get indices of data to fail and pass condition
    nData = prod(sz);
    nOut = floor(nData / 2);
    outI = randperm(nData, nOut);
    out_l = ismember(1:nData, outI);
    in_l = ~out_l;
    nIn = numel(find(in_l));
    
    % Get ranges of passing and failing values
    minVal_l = cellfun(@(x) isequal(x, @gt), squareInputs(:, 1));
    minVal = min(cell2mat(squareInputs(minVal_l, 2)));
    
    maxVal_l = cellfun(@(x) isequal(x, @lt), squareInputs(:, 1));
    maxVal = max(cell2mat(squareInputs(maxVal_l, 2)));
    
    eqVal_l = cellfun(@(x) isequal(x, @eq), squareInputs(:, 1));
    eqVal = cell2mat(squareInputs(eqVal_l, 2));
    
    neqVal_l = cellfun(@(x) isequal(x, @ne), squareInputs(:, 1));
    neqVal = cell2mat(squareInputs(neqVal_l, 2));
    
    if ~isempty(minVal) && isempty(maxVal)
        
        passes_v = minVal + rand(1, nIn);
        fails_v = minVal - rand(1, nOut);
        
    end
    if ~isempty(maxVal) && isempty(minVal)
        
        passes_v = maxVal - rand(1, nIn);
        fails_v = maxVal + rand(1, nOut);
        
    end
    if ~isempty(maxVal) && ~isempty(minVal)
        
        passes_v = minVal + (maxVal - minVal).* rand(1, nIn);
        fails_v = minVal - rand(1, nOut);
        
    end
    if ~isempty(neqVal)
        
        passes_v = randn(1, nIn);
        while ~isempty(passes_v(passes_v == neqVal))
            passes_v(passes_v == neqVal) = randn(numel(...
                find(passes_v == neqVal)));
        end
        fails_v = repmat(neqVal, 1, nOut);
    end
    if ~isempty(eqVal)
        passes_v = repmat(eqVal, 1, nIn);
    end
    
    R(in_l) = passes_v;
    R(out_l) = fails_v;
    
    in = in_l;
    out = out_l;
    
    end
    
    function datecell = datetime_utc(testSize)
    % Cell array of strings compatible with column 'DateTime_UTC'.
    
    in_DateTimeUTC = linspace(floor(now), floor(now)+1, prod(testSize));
    datecell = cellstr(datestr(in_DateTimeUTC, 'yyyy-mm-dd HH:MM:SS.FFF'));
    
    end
    
    function [inDisp_v, inTrim_v] = randDispTrim(testSz, spDisp, spTrim)
    % randDispTrim Random vector of displacements, trim around threshold
    
    bothValid_l = false;
    while ~any(bothValid_l) || all(bothValid_l)
        
        lowerDisp = (1/1.05)*spDisp;
        upperDisp = (1/0.95)*spDisp;
        inDisp_v = testISO19030.randOutThreshold(testSz, @lt, upperDisp, ...
            @gt, lowerDisp);
        lbp = testISO19030.LBP;
        
        lowerTrim = spTrim - 0.002*lbp;
        upperTrim = spTrim + 0.002*lbp;
        inTrim_v = testISO19030.randOutThreshold(testSz, @lt, upperTrim, ...
            @gt, lowerTrim);
        
        bothValid_l = spDisp >= inDisp_v.*0.95 & spDisp <= inDisp_v.*1.05 & ...
                      spTrim <= inTrim_v + 0.002*lbp & spTrim >= inTrim_v - 0.002*lbp;
        
    end
        
    end
end

methods(Test)

    function testsortOnDateTime(testcase)
    % Test table has been sorted ascending by column named DateTime
    % 1: Test that data returned by database reading function matches that
    % returned by the SORT function, with the second output used to index
    % the non-DateTime data.
    
    % 1.
    % Inputs
    today = floor(now) + 0.1;
    date = today+1:-1:today-1;
    x = (3:-1:1)';
    
    date_c = cellstr(datestr(date, testcase.DateTimeFormSQL));
    input = [date_c, num2cell(x)];
    names = {'Timestamp', 'Speed_Loss'};
    [startrow, numrows] = testcase.insert(names, input);
    
    [exp_date, datei] = sort(date, 'ascend');
    exp_date = cellstr(datestr(exp_date, testcase.DateTimeFormAdodb));
    exp_x = num2cell(x(datei));
    exp_sorted = cell2table([exp_date, exp_x], 'VariableNames', lower(names));
    
    % Execute
    testcase.call('sortOnDateTime');
    
    % Verify
    act_sorted = testcase.select(names, startrow, numrows);
    
    msg_sorted = ['All data read from table expected to be sorted based on'...
        ' the values of the "DateTime" column.'];
    testcase.verifyEqual(act_sorted, exp_sorted, msg_sorted);
    
    end
    
    function testupdateAirDensity(testcase)
    % Test that procedure updateAirDensity will update appropriate values.
    % 1: Test that the values for column 'airDensity' will be updated with
    % those from the appropriate columns as descirbed by equation G5 in IMO
    % standard ISO/DIS 19030-2, namely:
    % airDensity = airPressure / SpecificGasConstant * (AirTemp + 273.15)
    
    % Inputs
    in_press = [1.225, 1.2, 1.1];
    in_R = 287.058;
    in_Temp = [25, 30, 27];
    exp_dens = (in_press ./ (in_R.*(in_Temp + 273.15)) )';
    
    names_c = {'Air_Pressure', 'Air_Temperature'};
    [startrow, numrows] = testcase.insert(names_c, [in_press', in_Temp']);
    
    % Execute
    testcase.call('updateAirDensity');
    
    % Verify
    dens_tbl = testcase.select('Air_Density', startrow, numrows);
    act_dens = [dens_tbl{:, :}];
    msg_dens = ['Data for column ''Air_Density'' should have values ',...
        'matching those given for Equation G5 in standard ISO 19030'];
    testcase.verifyEqual(act_dens, exp_dens, 'AbsTol', 1e-9, msg_dens);
    
    end
    
    function testupdateBrakePower(testcase)
    % Test that BrakePower will be calculated based on the standard.
    % This test assumes that the data given in property 'SFOCCoefficients'
    % matches that for 'Engine_Model' value 'k98me-c712' in the table
    % 'SFOCCoefficients' in the database given by TESTCASE. It also assumes
    % that the table 'Vessels' has been updated with for the vessel named
    % 'CMA CGM ALMAVIVA', which contains this engine model.
    % 1: Test that the column Brake_Power will be updated following call to
    % procedure "updateBrakePower" based on the calculations described in
    % ISO standard 19030-2, Annexes C and D. 
    
    % Inputs
    vessel = testcase.TestVessel;
    in_massfoc = [1e5, 1.5e5, 2e5];
    in_lcv = [42, 41.9, 43];
    in_data = [in_massfoc', in_lcv'];
    in_names = {'Mass_Consumed_Fuel_Oil', 'Lower_Caloirifc_Value_Fuel_Oil'};
    [startrow, numrows] = testcase.insert(in_names, in_data);
    
    x = in_massfoc.* (in_lcv ./ 42.7) ./ 24;
    coeff = [vessel.Engine.X0, vessel.Engine.X1, vessel.Engine.X2];
    exp_brake = (coeff(3)*x.^2 + coeff(2)*x + coeff(1))';
    
    % Execute
    testcase.call('updateBrakePower', num2str(vessel.Vessel_Id));
    
    % Verify
    act_brake = testcase.select('Brake_Power', startrow, numrows);
    act_brake = [act_brake{:, :}];
    msg_brake = ['Updated Brake Power is expected to match that calculated',...
        ' from mass of fuel oil consumed and the SFOC curve'];
    testcase.verifyEqual(act_brake, exp_brake, 'RelTol', 1e-6, msg_brake);
    
    end
    
    function testupdateDisplacement(testcase)
    % Test that displacement will be calculated either from the block
    % coefficient or by looking up a hydrostatic table.
    % 1: Test that when no data is given for vessel in hydrostatic table
    % but a block coefficient is given in the 'Vessels' table, the latter
    % will be used to approximate the displacement.
    
    % 1
    % Input
    in_draftFore = [10, 12, 11]';
    in_draftAft = [10, 11, 13]';
    in_Length = testcase.AlmavivaLength;
    in_Breadth = testcase.AlmavivaBreadth;
    in_Cb = testcase.AlmavivaBlockCoefficient;
    [startrow, count] = testcase.insert([in_draftFore, in_draftAft],...
        {'Static_Draught_Fore', 'Static_Draught_Aft'});
    
    exp_disp = num2cell(...
        mean([in_draftFore'; in_draftAft'])*(in_Length*in_Breadth*in_Cb))';
    
    % Execute
    testcase.call('updateDisplacement', testcase.AlmavivaIMO);
    
    % Verify
    act_disp = testcase.read('Displacement', startrow, count);
    msg_disp = ['Displacement should equal the block coefficient ',...
        'multiplied by the extreme lengths in three dimensions.'];
    testcase.verifyEqual(act_disp, exp_disp, 'RelTol', 1e-9, msg_disp);
    
    end
    
    function testupdateMassFOC(testcase)
    % Test that calculation of mass of fuel oil consumed from volume flow 
    % meter measurements matches that described in the standard. 
    % 1. Test that the mass of fuel oil consumed will match that returned
    % by formula C2 in Annex C of the ISO 19030-2 standard.
        
    % Input
    in_vol = 100:20:140;
    in_den15 = repmat(500, 1, 3);
    in_denChange = repmat(10, 1, 3);
    in_tempFuel = 50:5:60;
    data = [in_vol', in_den15', in_denChange', in_tempFuel'];
    names = {'Volume_Consumed_Fuel_Oil', 'Density_Fuel_Oil_15C',...
        'Density_Change_Rate_Per_C', 'Temp_Fuel_Oil_At_Flow_Meter'};
    [startrow, count] = testcase.insert(names, data);
    
    exp_mass = (in_vol.*(in_den15 - in_denChange.*(in_tempFuel - 15)))';
    
    % Execute
    testcase.call('updateMassFuelOilConsumed', testcase.TestVesselIdString);
    
    % Verify
    act_mass = testcase.select('Mass_Consumed_Fuel_Oil', startrow, count);
    act_mass = [act_mass{:, :}];
    msg_mass = ['Mass of fuel oil consumed is expected to match that ',...
        'calculated from formula C2 of ISO 19030-2.'];
    testcase.verifyEqual(act_mass, exp_mass, 'RelTol', 1e-9, msg_mass);
    
    end
    
    function testupdateShaftPower(testcase)
    % Test that shaft power will be calculated as described in the standard
    % 1: Test that, as given in Equation B1 in Annex B of the ISO 19030-2
    % standard, shaft power will be calculated as the product of torque,
    % rpm and a conversion factor to radians per second.
    
    % Input
    in_torque = 50:25:100;
    in_rpm = 10:12;
    names = {'Shaft_Torque', 'Shaft_Revolutions'};
    data = [in_torque', in_rpm'];
    [startrow, count] = testcase.insert(names, data);
    
    exp_shaft = ( in_torque.*in_rpm.*(2*pi/60) )';
    
    % Execute
    testcase.call('updateShaftPower', testcase.TestVesselIdString);
    
    % Verify
    act_shaft = testcase.select('Shaft_Power', startrow, count);
    act_shaft = [act_shaft{:, :}];
    msg_shaft = ['Shaft power expected to be torque multiplied by angular ',...
        'velocity'];
    testcase.verifyEqual(act_shaft, exp_shaft, 'RelTol', 1e-7, msg_shaft);
    end
    
    function testupdateSpeedLoss(testcase)
    % Test that speed loss is calculated as described in the standard.
    % 1: Test that speed loss will be calculated as the relative difference
    % between vessel speed through water and the expected speed expressed
    % as a percentage, as described in equation 4 of the ISO 19030-2
    % standard.
    
    % Input
    in_sog = [13, 10, 20];
    in_speedexp = [14, 12, 17];
    names = {'Speed_Through_Water', 'Expected_Speed_Through_Water'};
    data = [in_sog', in_speedexp'];
    [startrow, count] = testcase.insert(names, data);
    
    exp_loss = (((in_sog - in_speedexp) ./ in_speedexp) .* 100)';
    
    % Execute
    testcase.call('updateSpeedLoss')
    
    % Verify
    act_loss = testcase.read('Speed_Loss', startrow, count);
    act_loss = [act_loss{:, :}];
    msg_loss = ['Speed loss expected to be relative difference between ',...
        'speed over ground and expected speed, as a percentage.'];
    testcase.verifyEqual(act_loss, exp_loss, 'RelTol', 1e-6, msg_loss);
    
    end
    
    function testupdateExpectedSpeed(testcase)
    % Test that expected speed is calculated according to the standard
    % 1: Test that the values for column 'Expected_Speed_Through_Water' in
    % the test table are calculated by interpolating the appropriate
    % speed-power curve fitted to an exponential model as described in 
    % equation 3 of the ISO 19030-3 standard.
    % 2: Test that the values for column 'Expected_Speed_Through_Water' in
    % the test table will be read from the appropriate speed power curve
    % based on the conditions described in section 4.4 of the ISO 19030-2
    % standard, where speed values corresponding to displacements and trims
    % which fail the condition will be corrected for using the Admiralty
    % formula.
    
    % 1
    % Input
    in_DeliveredPower = 30e4:10e4:50e4;
    in_Displacement = 114049:114051;
    in_Trim = zeros(1, 3);
    vessel = testcase.TestVessel;
    in_A = vessel.SpeedPower.Coefficient_A;
    in_B = vessel.SpeedPower.Coefficient_B;
    in_times = now:1:now+length(in_DeliveredPower)-1 + 0.5;
    in_times = cellstr(datestr(in_times, testcase.DateTimeFormSQL));
    names = {'Timestamp', 'Corrected_Power', 'Displacement', 'Trim'};
    data = num2cell([in_DeliveredPower', in_Displacement', in_Trim']);
    data = [in_times(:), data];
    [startrow, count] = testcase.insert(names, data);
    
    exp_espeed = (in_DeliveredPower/exp(in_B)).^(1/in_A)'; 
    % ( in_A(1).*log(in_DeliveredPower) + in_B )';
    
    % Execute
    testcase.call('filterSpeedPowerLookup', testcase.TestVesselIdString);
    testcase.call('updateExpectedSpeed', testcase.TestVesselIdString);
    
    % Verify
    act_espeed = testcase.select('Expected_Speed_Through_Water', count, ...
        startrow);
    act_espeed = [act_espeed{:, :}];
    msg_espeed = ['Expected speed is expected to be calculated based on ',...
        'the speed-power curve for this vessel.'];
    testcase.verifyEqual(act_espeed, exp_espeed, 'RelTol', 1e-5, msg_espeed);
    
    % 2
    % Input
    testSz = [1, 4];
%     in_IMO = repmat(str2double(testcase.AlmavivaIMO), testSz);
    
    dispReference = vessel.SpeedPower.Displacement; % testcase.AlmavivaSpeedPowerDispTrim(1);
    lowerDisp = dispReference*1/(1.05);
    in_Displacement = testcase.randOutThreshold(testSz, @lt, lowerDisp);
    
    lowerTrim = - vessel.Configuration.LBP * 0.002;
    in_Trim = testcase.randOutThreshold(testSz, @lt, lowerTrim);
    
    in_DeliveredPower = linspace(1e4, 5e4, prod(testSz));
    in_A = vessel.SpeedPower.Coefficient_A;
    in_B = vessel.SpeedPower.Coefficient_B;
    exp_espeed = (in_DeliveredPower/exp(in_B)).^(1/in_A)';  % in_A.*log(in_DeliveredPower) + in_B;
    
    dispReference_v = repmat(dispReference, testSz);
    dispCriteria_l = ~(dispReference_v >= in_Displacement*0.95 & ...
        dispReference_v <= in_Displacement*1.05);
    exp_espeed(dispCriteria_l) = exp_espeed(dispCriteria_l)' .*...
        (in_Displacement(dispCriteria_l).^(2/3) ./ ...
        dispReference.^(2/3)).^(1/3);
    exp_espeed = num2cell(exp_espeed(:));
    in_times = now + 0.5:1:now + 0.5 + length(in_DeliveredPower)-1;
    in_times = cellstr(datestr(in_times, testcase.DateTimeFormSQL));
    names = {'Timestamp', 'Corrected_Power', 'Displacement', 'Trim'};
    data = num2cell([in_DeliveredPower', in_Displacement', in_Trim']);
    data = [in_times(:), data];
    [startrow, count] = testcase.insert(names, data);
    
    % Execute
    testcase.call('filterSpeedPowerLookup', testcase.TestVesselIdString);
    testcase.call('updateExpectedSpeed', testcase.TestVesselIdString);
    
    % Verify
    act_espeed = testcase.select('Expected_Speed_Through_Water', count,...
        startrow);
    act_espeed = [act_espeed{:, :}];
    msg_espeed = ['Expected_Speed_Through_Water is expected to be corrected'...
        'for displacement using the Admiralty formula when displacement is '...
        'out of range.'];
    testcase.verifyEqual(act_espeed, exp_espeed, 'RelTol', 1e-5, msg_espeed);
    
    end
    
    function testupdateWindResistanceCorrection(testcase)
    % Test that wind resistance correction is calculated as in the standard
    % 1: Test that the wind resistance correction is calculated according
    % to the procedure given in Equation G2, Annex G of the ISO 19030-2
    % standard.
    
    % Input
    vessel = testcase.TestVessel;
    in_DeliveredPower = 10e3:1e3:12e3;
    in_SOG = 15:2:19;
    in_PropulsCalm = repmat(2, size(in_SOG)); % vessel.SpeedPower.Propulsive_Efficiency; %testcase.AlmavivaPropulsiveEfficiency;
    in_PropulsActual = repmat(0.7, size(in_PropulsCalm));
    testSz = [1, 3];
    in_NearDisp = repmat(114050, testSz);
    in_NearTrim = zeros(testSz);
%     in_IMO = repmat(str2double(testcase.AlmavivaIMO), testSz);
    
    airResist = 0.1:0.1:0.3;
    windResist = 0.3:0.2:0.7;
    names = {'Wind_Resistance_Relative', 'Air_Resistance_No_Wind', ...
        'Speed_Over_Ground', 'Delivered_Power', 'Nearest_Displacement', ...
        'Nearest_Trim'};
    data = [windResist', airResist', in_SOG', in_DeliveredPower', in_NearDisp',...
        in_NearTrim'];
    [startrow, count] = testcase.insert(names, data);
    exp_wind = (((windResist - airResist).*in_SOG)./ in_PropulsCalm + ...
        in_DeliveredPower.*(1 - in_PropulsActual./in_PropulsCalm))';
    
    % Execute
    testcase.call('updateWindResistanceCorrection', testcase.TestVesselIdString);
    
    % Verify
    act_wind = testcase.select('Wind_Resistance_Correction', count, startrow);
    act_wind = [act_wind{:, :}];
    msg_wind = ['Wind resistance correction values should match those ',...
        'calculated with Equation G2 in the standard.'];
    testcase.verifyEqual(act_wind, exp_wind, 'RelTol', 1e-3, msg_wind);
    
    end
    
    function testupdateWindResistanceRelative(testcase)
    % Test that relative wind resistance is described by the standard
    % 1: Test that wind resistance due to relative wind is being calculated
    % according to equation G2 of the ISO 19030-2 standard.
    
    % Input
    vessel = testcase.TestVessel;
    Coeffs = vessel.WindCoefficient.Coefficient(:)';
    Dirs = vessel.WindCoefficient.Direction(:)';
    dirStep = Dirs(2) - Dirs(1);
    
    RelWindDir = [30, 44, 0];
    CoeffDirEdges = -dirStep/2 : dirStep : 360;
    [~, relwind_i] = histc(RelWindDir, CoeffDirEdges);
    CoeffRelWind = Coeffs(relwind_i);
    
    Air_Dens = [1.22, 1.21, 1.23];
    RelWindSpeed = [10, 15, 25];
    TransArea = abs(randn(1, 3)*1000);
    
    exp_rel = (0.5 * Air_Dens .* RelWindSpeed.^2 .* TransArea ...
        .* CoeffRelWind)';
    names = {'Air_Density', 'Relative_Wind_Speed_Reference', 'Relative_Wind_Direction_Reference',...
        'Transverse_Projected_Area_Current'};
    data = [Air_Dens', RelWindSpeed', RelWindDir', TransArea'];
    [startrow, count] = testcase.insert(names, data);
    
    % Execute
%     testcase.call('updateTransProjArea', testcase.AlmavivaIMO);
    testcase.call('updateWindResistanceRelative', testcase.TestVesselIdString);
    
    % Verify
    act_rel = testcase.select({'Wind_Resistance_Relative'}, count, startrow);
    act_rel = [act_rel{:, :}];
    msg_rel = ['Relative wind resistance expected to match definition given',...
        'by equation G2 in the standard.'];
    testcase.verifyEqual(act_rel, exp_rel, 'RelTol', 1e-3, msg_rel);
    
    end
    
    function testupdateAirResistance(testcase)
    % Test that air resistance in no-wind condition conforms to standard
    % 1: Test that the air resistance in no-wind condition is calculated
    % according to equation G2 in the ISO 19030-2 standard.
    
    % Input
    vessel = testcase.TestVessel;
    Coeffs = vessel.WindCoefficient.Coefficient(:)';
    Air_Dens = [1.22, 1.21, 1.23];
    SOG = [10, 15, 25];
    CoeffHeadWind = Coeffs(1);
    TransArea = abs(randn(1, 3))*1000;
    
    exp_air = (0.5 * Air_Dens .* SOG.^2 .* TransArea .* CoeffHeadWind)';
    names = {'Air_Density', 'Speed_Over_Ground', 'Transverse_Projected_Area_Current'};
    data = [Air_Dens', SOG', TransArea'];
    [startrow, count] = testcase.insert(names, data);
    
    % Execute
    testcase.call('updateAirResistanceNoWind', testcase.TestVesselIdString);
    
    % Verify
    act_air = testcase.select({'Air_Resistance_No_Wind'}, count, startrow);
    act_air = [act_air{:, :}];
    msg_air = ['Air resistance expected to match definition given',...
        'by equation G2 in the standard.'];
    testcase.verifyEqual(act_air, exp_air, 'RelTol', 1e-4, msg_air);
    end
    
    function testupdateTransProjAreaCurrent(testcase)
    % Test that transverse projected area in current loading condition is
    % calculated as described in the standard.
    % 1: Test that the transverse projected area in current loading
    % condition is calculated based on equations G3 and G4 in the IS0 
    % 19030-2 standard.
    
    % Input
    vessel = testcase.TestVessel;
    designArea = vessel.Configuration.Transverse_Projected_Area_Design;
    designDraft = vessel.Configuration.Draft_Design;
    draftFore = [11, 13, 9];
    draftAft = [9, 11, 7];
    currentDraft = mean([draftFore; draftAft]);
    shipWidth = vessel.Configuration.Breadth_Moulded;
    names = {'Static_Draught_Fore', 'Static_Draught_Aft'};
    data = [draftFore', draftAft'];
    [startrow, count] = testcase.insert(names, data);
    
    exp_area = (designArea + ...
        (designDraft - currentDraft).*shipWidth)';
    
    % Execute
    testcase.call('updateTransProjArea', testcase.TestVesselIdString);
    
    % Verify
    act_area = testcase.select('Transverse_Projected_Area_Current', count, ...
        startrow);
    act_area = [act_area{:, :}];
    msg_area = ['Transverse projected area in current loading condition ',...
        'should be calculated from equations G3 and G4 in the standard'];
    testcase.verifyEqual(act_area, exp_area, 'RelTol', 1e-7, msg_area);
    end
    
    function testupdatecorrectPower(testcase)
    % Test that the corrected power is power minues wind-correction
    
    % Input
    in_delivered = 10e3:1e3:12e3;
    in_correction = 1e3:0.5e3:2e3;
    name = {'Delivered_Power', 'Wind_Resistance_Correction'};
    data = [in_delivered', in_correction'];
    [startrow, count] = testcase.insert(name, data);
    
    exp_corr = ( in_delivered - in_correction )';
    
    % Execute
    testcase.call('updateCorrectedPower');
        
    % Verify
    act_corr = testcase.select('Corrected_Power', count, startrow);
    act_corr = [act_corr{:, :}];
    msg_corr = ['The corrected power is expected to be the difference ',...
        'between delivered power and wind resistance correction.'];
    testcase.verifyEqual(act_corr, exp_corr, msg_corr);
    end
    
    function testupdateDeliveredPower(testcase)
    % Test that delivered power will be updated based on shaft power data 
    % if available or on fuel consumption data otherwise. 
    % 1: Test that delivered power will be given the values of shaft power
    % if shaft power is available.
    % 2: Test that, if shaft power is not available and brake power is,
    % delivered power will be given the values of brake power.
    % 3: Test that, if neither shaft power nor brake power are available,
    % an error will be returned.
    
    % 1
    testcase.dropTable;
    testcase.createTable;
    
    % Input
    in_torque = 1e4:1e4:3e4;
    in_revs = 10:10:30;
    names = {'Shaft_Torque', 'Shaft_Revolutions'};
    data = [in_torque', in_revs'];
    [startrow, count] = testcase.insert(names, data);
    
    % Execute
    testcase.call('updateDeliveredPower', testcase.TestVesselIdString);
    
    % Verify
    act_del = testcase.select('Delivered_Power', count, startrow);
    act_del = [act_del{:, :}];
    act_allNull = all(isnan(act_del));
    msg_del = ['Delivered Power is expected to be equal to shaft power when',...
        'shaft power is available'];
    testcase.verifyFalse(act_allNull, msg_del);
    
    % 2
    % Input
    testcase.dropTable;
    testcase.createTable;
    
    in_LCV = 0.2:0.1:0.4;
    in_VFOC = 20:5:30;
    in_FuelDens = 300:5:310;
    in_DensChange = 1:3;
    in_FuelTemp = 50:52;
    names = {'Lower_Caloirifc_Value_Fuel_Oil', ...
                        'Volume_Consumed_Fuel_Oil',...
                        'Density_Fuel_Oil_15C',...
                        'Density_Change_Rate_Per_C',...
                        'Temp_Fuel_Oil_At_Flow_Meter'};
    data = [in_LCV', in_VFOC', in_FuelDens', in_DensChange', in_FuelTemp'];
    [startrow, count] = testcase.insert(names, data);
    
    % Execute
    testcase.call('updateDeliveredPower', testcase.TestVesselIdString);
    
    % Verify
    act_del = testcase.select('Delivered_Power', count, startrow);
    act_del = [act_del{:, :}];
    act_allNull = all(isnan(act_del));
    msg_brake = ['Delivered Power is expected to be equal to brake power when',...
        ' shaft power is unavailable but brake power is.'];
    testcase.verifyFalse(act_allNull, msg_brake);
    
    % 3
    % Input
    testcase.dropTable;
    testcase.createTable;
    
    in_LCV = 0.2:0.1:0.4;
    in_VFOC = 20:5:30;
    in_FuelDens = 300:5:310;
    in_DensChange = 1:3;
    in_FuelTemp = nan(1, 3);
    data = [in_LCV', in_VFOC', in_FuelDens', in_DensChange', in_FuelTemp'];
    testcase.insert(names, data)
    
    % Execute
    exec_f = @() testcase.call('updateDeliveredPower', testcase.TestVesselIdString);
    
    % Verify
    exp_errid = 'MATLAB:COM:E2147500037';
    msg_error = 'An error is expected when power cannot be calculated.';
    testcase.verifyError(exec_f, exp_errid, msg_error);
    end
    
    function testisShaftPowerAvailable(testcase)
    % Test that if torque and rpm data for shaft available, return true
    % Test that if all the rows of both Shaft_Torque and Shaft_Revolutions
    % are not NULL, then the procedure will return TRUE to indicate that
    % Shaft_Power can be calculated.
    % 1: Test that if both Shaft_Torque and Shaft_Revolutions are not all
    % NULL, procedure will return TRUE.
    % 2: Test that if either Shaft_Torque or Shaft_Revolutions are all
    % NULL, procedure will return FALSE.
    
    % 1
    % Input
    in_ShaftTorque = [10, nan, 12];
    in_ShaftRPM = 12:2:16;
    testcase.insert([in_ShaftTorque', in_ShaftRPM'], ...
        {'Shaft_Torque', 'Shaft_Revolutions'});
    
    % Execute
    testcase.call('isShaftPowerAvailable',...
        testcase.InvalidIMO, '@out');
    
    % Verify
    [~, act_isAvail] = adodb_query(testcase.Connection, 'SELECT @out;');
    act_isAvail = logical(str2double([act_isAvail{:}]));
    msg_isAvail = ['Shaft power is expected to be available when shaft ',...
        'torque and rpm are available.'];
    testcase.verifyTrue(act_isAvail, msg_isAvail);
    
    % 2
    % Input
    testcase.dropTable;
    testcase.createTable;
    in_ShaftTorque = nan(1, 3);
    in_ShaftRPM = 12:2:16;
    testcase.insert([in_ShaftTorque', in_ShaftRPM'], ...
        {'Shaft_Torque', 'Shaft_Revolutions'});
    
    % Execute
    testcase.call('isShaftPowerAvailable', testcase.InvalidIMO,...
        '@out');
        
    % Verify
    [~, act_isAvail] = adodb_query(testcase.Connection, 'SELECT @out;');
    act_isAvail = logical(str2double([act_isAvail{:}]));
    msg_isAvail = ['Shaft power is expected not to be available when shaft ',...
        'torque and rpm are available.'];
    testcase.verifyFalse(act_isAvail, msg_isAvail);
    
    end
    
    function testisBrakePowerAvailable(testcase)
    % Test that if data sufficient for brake power calculation, return true
    % Test that if data for the equation of brake power, C1 in the ISO
    % 19030-2 standard, is available then the procedure will return TRUE.
    % 1: Test that, if data is available for Lower_Caloirifc_Value_Fuel_Oil
    % and Mass_Consumed_Fuel_Oil, procedure will return TRUE.
    % 2: Test that, if data is unavailable or cannot be calculated for 
    % either Lower_Caloirifc_Value_Fuel_Oil or Mass_Consumed_Fuel_Oil,
    % procedure will return FALSE.
    
    % 1:
    % Input
    in_LCV = 42:44;
    in_VFOC = 20:5:30;
    in_FuelDens = 300:5:310;
    in_DensChange = 1:3;
    in_FuelTemp = 50:52;
    testcase.insert([in_LCV', in_VFOC', in_FuelDens', in_DensChange', ...
        in_FuelTemp'], {'Lower_Caloirifc_Value_Fuel_Oil', ...
                        'Volume_Consumed_Fuel_Oil',...
                        'Density_Fuel_Oil_15C',...
                        'Density_Change_Rate_Per_C',...
                        'Temp_Fuel_Oil_At_Flow_Meter'});
    
    % Execute
    testcase.call('isBrakePowerAvailable', testcase.InvalidIMO, '@out',...
        '@needVolume');
    
    % Verify
    [~, act_isAvail] = adodb_query(testcase.Connection, 'SELECT @out;');
    act_isAvail = logical(str2double([act_isAvail{:}]));
    msg_avail = ['Output expected to be true when MFOC and LCV are both ',...
        'given or can be calculated.'];
    testcase.verifyTrue(act_isAvail, msg_avail);
    
    % 2:
    % Input
    testcase.dropTable;
    testcase.createTable;
    
    in_LCV = 42:44;
    in_VFOC = 20:5:30;
    in_FuelDens = 300:5:310;
    in_DensChange = 1:3;
    in_FuelTemp = nan(1, 3);
    testcase.insert([in_LCV', in_VFOC', in_FuelDens', in_DensChange', ...
        in_FuelTemp'], {'Lower_Caloirifc_Value_Fuel_Oil', ...
                        'Volume_Consumed_Fuel_Oil',...
                        'Density_Fuel_Oil_15C',...
                        'Density_Change_Rate_Per_C',...
                        'Temp_Fuel_Oil_At_Flow_Meter'});
    
    % Execute
    testcase.call('isBrakePowerAvailable', testcase.InvalidIMO, '@out',...
        '@needVolume');
    
    % Verify
    [~, act_isAvail] = adodb_query(testcase.Connection, 'SELECT @out;');
    act_isAvail = logical(str2double([act_isAvail{:}]));
    msg_avail = ['Output expected to be false when either MFOC or LCV cannot ',...
        'be calculated.'];
    testcase.verifyFalse(act_isAvail, msg_avail);
    
    end
    
    function testupdateFromBunkerNote(testcase)
    % Test that LCV and density of fuel are read from table appropriately 
    % 1: Test that values of column Lower_Caloirifc_Value_Fuel_Oil will be
    % updated based on the corresponding value under column
    % Lower_Heating_Value in table BunkerDeliveryNote of the column
    % BDN_Number.
    % 2: Test that values of column Density_Fuel_Oil_15C will be updated
    % based on the corresponding value under column Density_At_15dg in
    % table BunkerDeliveryNote of the column
    % BDN_Number.
    
    % Change table name and create tempraw for this procedure
    originalTable_s = testcase.TableName;
    testcase.TableName = 'tempRaw';
    adodb_query(testcase.Connection, 'DROP TABLE IF EXISTS tempRaw;'); 
    adodb_query(testcase.Connection, 'CREATE TABLE tempRaw LIKE dnvglraw;');
    testcase.call('convertDNVGLRawToRawData');
    
    % 1:
    % Input
    LCV_v = [40.5, 42.8, 49.32, 46.5, 40.5, 42.7, 42.7];
    bdnAll_c = {'Default_HFO'
                'Default_LFO'
                'Default_LNG'
                'Default_LPG'
                'Default_LSHFO'
                'Default_MDO'
                'Default_MGO'};
    bdn_c = {'Default_HFO', 'Default_LNG'};
    bdn_l = ismember(bdnAll_c, bdn_c);
    
%     sqlAddCol_s = 'ALTER TABLE tempRawISO ADD ME_Fuel_BDN VARCHAR(40);';
    
    [startrow, count] = testcase.insert(bdn_c', {'ME_Fuel_BDN'});
    exp_lcv = num2cell( LCV_v(bdn_l) )';
    
    % Execute
    testcase.call('updateFromBunkerNote', testcase.AlmavivaIMO);
    
    % Verify
    act_lcv = testcase.read('Lower_Caloirifc_Value_Fuel_Oil', startrow, ...
        count);
    msg_lcv = ['LCV values expected to match those in table '...
        'BunkerDeliveryNote for the corresponding rows of BDN_Number.'];
    testcase.verifyEqual(act_lcv, exp_lcv, msg_lcv);
    
    % 2:
    % Input
    dens_v = [0.991, 0.98, 0.44, 0.58, 0.986, 0.9, 0.89];
    bdn_l = ismember(bdnAll_c, bdn_c);
    [startrow, count] = testcase.insert(bdn_c', {'ME_Fuel_BDN'});
    exp_lcv = num2cell( dens_v(bdn_l) )';
    
    % Execute
    testcase.call('updateFromBunkerNote', testcase.AlmavivaIMO);
    
    % Verify
    act_lcv = testcase.read('Density_Fuel_Oil_15C', startrow, count);
    msg_lcv = ['LCV values expected to match those in table '...
        'BunkerDeliveryNote for the corresponding rows of BDN_Number.'];
    testcase.verifyEqual(act_lcv, exp_lcv, msg_lcv);
    
    % Reassign table name
    testcase.TableName = originalTable_s;
    
    end
    
    function testremoveInvalidRecords(testcase)
    % Test that records marked invalid based on conditions are removed
    % 1: Test that records with zero Mass_Consumed_Fuel_Oil are removed.
    
    import matlab.unittest.constraints.EveryElementOf;
    import matlab.unittest.constraints.IsGreaterThan;
    
    % 1
    % Input
    nData = 2;
    nZero = 1;
    mfoc_v = abs(randn(1, nData));
    zeroI = randperm(nData, nZero);
    mfoc_v(zeroI) = -randi([0, 1]);
    
    [startrow, count] = testcase.insert(mfoc_v', {'Mass_Consumed_Fuel_Oil'});
    
    % Execute
    testcase.call('removeInvalidRecords');
    
    % Verify
    mfoc_act = testcase.read('Mass_Consumed_Fuel_Oil', startrow, count);
    mfoc_act = [mfoc_act{:}];
    ZeroMfoc_act = EveryElementOf(mfoc_act);
    ZeroMfoc_cons = IsGreaterThan(0);
    ZeroMfoc_Msg = ['All elements of Mass_Consumed_Fuel_Oil are expected '...
            'to be greater than 0.'];
    testcase.verifyThat(ZeroMfoc_act, ZeroMfoc_cons, ZeroMfoc_Msg);
    
    end
    
    function testremoveFOCBelowMinimum(testcase)
    % Test that rows are removed for MFOC values below engine minimum.
    % 1: Test that values of Mass_Consumed_Fuel_Oil below the corresponding
    % value of Minimum_FOC_ph for the corresponding engine will be removed
    % for corresponding reporting frequencies.
    
    import matlab.unittest.constraints.EveryElementOf;
    import matlab.unittest.constraints.IsGreaterThan;
    import matlab.unittest.constraints.AnyElementOf;
    import matlab.unittest.constraints.IsTrue;
    import matlab.unittest.constraints.HasNaN;
    
    % 1
    % Input
    minFOCph = testcase.MinimumFOCph;
    minFOC = minFOCph*24;
    maxFOC = minFOC + 1e3;
    nData = 10;
    nBelow = 1;
    mfoc_v = (maxFOC - minFOC).*rand(1, nData) + minFOC;
    belowI = randperm(nData, nBelow);
    mfoc_v(belowI) = randi([0, floor(minFOC) - 1]);
    [startrow, count] = testcase.insert(mfoc_v', {'Mass_Consumed_Fuel_Oil'});
    
    % Execute
    testcase.call('removeFOCBelowMinimum', testcase.AlmavivaIMO);
    
    % Verify
    mfoc_act = testcase.read('Mass_Consumed_Fuel_Oil', startrow, count);
    mfocFilt_act = testcase.read('Filter_SFOC_Out_Range', startrow, count);
    testcase.assertNotEmpty(mfoc_act, 'MFOC cannot be empty for test to run.')
    
    mfocFilt_act = [mfocFilt_act{:}];
    testcase.assertThat(EveryElementOf(mfocFilt_act), ~HasNaN, ...
        'Filter_SFOC_Out_Range must have some TRUE values.')
    mfocFilt_act = logical(mfocFilt_act);
    testcase.assertThat(AnyElementOf(mfocFilt_act), IsTrue, ...
        'Filter_SFOC_Out_Range must have some TRUE values.')
    mfoc_act = [mfoc_act{:}];
    mfoc_act(isnan(mfoc_act)) = [];
    mfoc_act = mfoc_act(~mfocFilt_act);
    
    minfoc_act = EveryElementOf(mfoc_act);
    minfoc_cons = IsGreaterThan(minFOC);
    minfoc_msg = ['All elements of Mass_Consumed_Fuel_Oil are expected to ',...
        'be above the minimum foc for the engine.'];
    testcase.verifyThat(minfoc_act, minfoc_cons, minfoc_msg);
    
    end
    
    function testfilterReferenceConditions(testcase)
    % Test that values are filtered based on reference conditions
    % Test that values for the reference conditions outlined in section
    % 6.2.1 of the ISO 19030-2 standard are fullfilled.
    % 1: Test that values of Seawater_Temperature below 2 are removed.
    % 2: Test that only values of Relative_Wind_Speed between 0 and 7.9
    % remain after call.
    % 3: Test that values of Water_Depth less than the greater of the two
    % formulae 5 and 6 in the standard are removed.
    % 4: Test that values of Rudder_Angle above 5 are removed.
    
    % 1
    % Input
    import matlab.unittest.constraints.EveryElementOf;
    import matlab.unittest.constraints.IsGreaterThan;
    import matlab.unittest.constraints.IsLessThan;
    import matlab.unittest.constraints.IsTrue;
    import matlab.unittest.constraints.AnyElementOf;
    testSz = [1, 2];
    
    mintemp = testcase.minTemp;
    
    inTemp_v = testcase.randOutThreshold(testSz, @lt, mintemp);
    inputData_m = inTemp_v';
    inputNames_c = {'Seawater_Temperature'};
    [startrow, count] = testcase.insert(inputData_m, inputNames_c);
    
    % Execute
    testcase.call('filterReferenceConditions', testcase.AlmavivaIMO);
    
    % Verify
    temp_act = testcase.read('Seawater_Temperature', startrow, count, 'id');
    tempFilt_act = testcase.read('Filter_Reference_Seawater_Temp', startrow,...
        count, 'id');
    temp_act = [temp_act{:}];
    tempFilt_act = logical([tempFilt_act{:}]);
    testcase.assertThat(AnyElementOf(tempFilt_act), IsTrue, ['Filt_Reference_Seawater_Temp must '...
        'have some true values in order to be tested.']);
    temp_act = temp_act(~tempFilt_act);
    
%     testcase.assertNotEmpty(temp_act, ['Filt_Reference_Seawater_Temp must '...
%         'ahve some true values in order to be tested.']);
    reftemp_act = EveryElementOf(temp_act);
    reftemp_cons = IsGreaterThan(mintemp);
    temp_msg = ['Water temperatures at or below 2 degrees Celsius should ',...
        'be removed.'];
    testcase.verifyThat(reftemp_act, reftemp_cons, temp_msg);
    
    % 2
    
    % Input
    minWind = testcase.MinWind;
    maxWind = testcase.MaxWind;
    
    inputNames_c = {'Relative_Wind_Speed'};
    inWindSpeed_v = testcase.randOutThreshold(testSz, @lt, 7.9);
    inputData_m = inWindSpeed_v';
    [startrow, count] = testcase.insert(inputData_m, inputNames_c);
    
    % Execute
    testcase.call('filterReferenceConditions', testcase.AlmavivaIMO);
    
    % Verify
    rudder_act = testcase.read('Relative_Wind_Speed', startrow, count,...
        'id');
    rudderFilt_act = testcase.read('Filter_Reference_Wind_Speed', startrow, count,...
        'id');
    rudderFilt_act = logical([rudderFilt_act{:}]);
    testcase.assertThat(AnyElementOf(rudderFilt_act), IsTrue, ...
        ['Filter_Reference_Wind_Speed must have some true values in order '...
        'to be tested.']);
    rudder_act = [rudder_act{:}];
    rudder_act = rudder_act(~rudderFilt_act);
    rudder_act(isnan(rudder_act)) = [];
    refwind_act = EveryElementOf(rudder_act);
    refwind1_cons = IsGreaterThan(minWind);
    refwind2_cons = IsLessThan(maxWind);
    temp_msg = ['Wind speeds outside of the range of 0 to 7.9 m/s should ',...
        'be removed.'];
    testcase.assertNotEmpty(rudder_act, ['Wind speed must not be non-empty ',...
        'to be tested.']);
    testcase.verifyThat(refwind_act, refwind1_cons, temp_msg);
    testcase.verifyThat(refwind_act, refwind2_cons, temp_msg);
    
    % 3
    
    % Input
    inputNames_c = {'Water_Depth', 'Static_Draught_Fore', ...
        'Static_Draught_Aft', 'Speed_Through_Water'};
    
    breadth = testcase.AlmavivaBreadth;
    g = testcase.GravitationalAcceleration;
    
    aftDraft = [12, 0];
    forDraft = [9, 1];
    speed = [15, 25];
    meanDraft = mean([aftDraft; forDraft]);
    formula5 = 3 .* sqrt(breadth * meanDraft);
    formula6 = 2.75 .* speed.^2 ./ g;
    
    depth5 = testcase.randOutThreshold(testSz, @gt, formula5(1));
    depth6 = testcase.randOutThreshold(testSz, @gt, formula6(2));
    depth_v = [depth5, depth6];
    
    forDraft = repmat(forDraft, [2, 1]);
    aftDraft = repmat(aftDraft, [2, 1]);
    speed = repmat(speed, [2, 1]);
    
    datetime_s = datestr(now-3:now, 'yyyy-mm-dd HH:MM:SS');
    inputData_m = [depth_v(:), forDraft(:), aftDraft(:), speed(:)];
    [startrow, count] = testcase.insert(inputData_m, inputNames_c);
    
    [~, id_c] = adodb_query(testcase.Connection, ...
        'SELECT id FROM tempRawISO');
    id_v = [id_c{:}];
    
%     update1_s = ['UPDATE ' testcase.TableName ' SET DateTime_UTC = ''' ...
%         datetime_s(1, :) ''' WHERE id = ' num2str(id_v(3)) ';'];
%     update2_s = ['UPDATE ' testcase.TableName ' SET DateTime_UTC = ''' ...
%         datetime_s(2, :) ''' WHERE id = ' num2str(id_v(3 + 1)) ';'];
%     update3_s = ['UPDATE ' testcase.TableName ' SET DateTime_UTC = ''' ...
%         datetime_s(3, :) ''' WHERE id = ' num2str(id_v(3 + 2)) ';'];
%     update4_s = ['UPDATE ' testcase.TableName ' SET DateTime_UTC = ''' ...
%         datetime_s(4, :) ''' WHERE id = ' num2str(id_v(3 + 3)) ';'];
    
    update1_s = ['UPDATE ' testcase.TableName ' SET DateTime_UTC = ''' ...
        datetime_s(1, :) ''' WHERE id = ' num2str(max(id_v) - 3) ';'];
    update2_s = ['UPDATE ' testcase.TableName ' SET DateTime_UTC = ''' ...
        datetime_s(2, :) ''' WHERE id = ' num2str(max(id_v) - 2) ';'];
    update3_s = ['UPDATE ' testcase.TableName ' SET DateTime_UTC = ''' ...
        datetime_s(3, :) ''' WHERE id = ' num2str(max(id_v) - 1) ';'];
    update4_s = ['UPDATE ' testcase.TableName ' SET DateTime_UTC = ''' ...
        datetime_s(4, :) ''' WHERE id = ' num2str(max(id_v)) ';'];
    adodb_query(testcase.Connection, update1_s);
    adodb_query(testcase.Connection, update2_s);
    adodb_query(testcase.Connection, update3_s);
    adodb_query(testcase.Connection, update4_s);
    
    % Execute
    testcase.call('filterReferenceConditions', testcase.AlmavivaIMO);
    
    % Verify
    depth5_act = testcase.read('Water_Depth', startrow, 2, 'id');
    depth6_act = testcase.read('Water_Depth', startrow + 2, 2, 'id');
    depth5Filt_act = testcase.read('Filter_Reference_Water_Depth', ...
        startrow, 2, 'id');
    depth6Filt_act = testcase.read('Filter_Reference_Water_Depth', ...
        startrow + 2, 2, 'id');
    testcase.assertNotEmpty(depth5_act, ['Water_Depth must not be non-empty ',...
        'to be tested.']);
    testcase.assertNotEmpty(depth6_act, ['Water_Depth must not be non-empty ',...
        'to be tested.']);
    depth5_act = [depth5_act{:}];
    depth5_act(isnan(depth5_act)) = [];
    depth6_act = [depth6_act{:}];
    depth6_act(isnan(depth6_act)) = [];
    
    depth5Filt_act = [depth5Filt_act{:}];
    depth5Filt_act = logical(depth5Filt_act);
    depth5_act = depth5_act(~depth5Filt_act);
    depth6Filt_act = [depth6Filt_act{:}];
    depth6Filt_act = logical(depth6Filt_act);
    depth6_act = depth6_act(~depth6Filt_act);
    testcase.assertThat(AnyElementOf(depth5Filt_act), IsTrue, ...
        ['Filter_Reference_Water_Depth must have some true values in order '...
        'to be tested.']);
    testcase.assertThat(AnyElementOf(depth6Filt_act), IsTrue, ...
        ['Filter_Reference_Water_Depth must have some true values in order '...
        'to be tested.']);
    
    refdepth5_act = EveryElementOf(depth5_act);
    refdepth5_cons = IsGreaterThan(formula5(1));
    refdepth6_act = EveryElementOf(depth6_act);
    refdepth6_cons = IsGreaterThan(formula6(2));
    dep_msg = ['Depths less than the greater of those returned by formula ',...
        '5 or 6 in the standard should be removed by procedure.'];
    testcase.assertNotEmpty(depth5_act, ['Water_Depth must not be non-empty ',...
        'to be tested.']);
    testcase.assertNotEmpty(depth6_act, ['Water_Depth must not be non-empty ',...
        'to be tested.']);
    testcase.verifyThat(refdepth5_act, refdepth5_cons, dep_msg);
    testcase.verifyThat(refdepth6_act, refdepth6_cons, dep_msg);
    
    % 4
    % Input
    maxRudder = testcase.MaxRudder;
    inputNames_c = {'Rudder_Angle'};
    inRudderAngle_v = testcase.randOutThreshold(testSz, @lt, maxRudder);
    inputData_m = inRudderAngle_v';
    [startrow, count] = testcase.insert(inputData_m, inputNames_c);
    
    % Execute
    testcase.call('filterReferenceConditions', testcase.AlmavivaIMO);
    
    % Verify
    rudder_act = testcase.read('Rudder_Angle', startrow, count, 'id');
    rudderFilt_act = testcase.read('Filter_Reference_Rudder_Angle', startrow, count, 'id');
    testcase.assertNotEmpty(rudder_act, ['Rudder angle must not be non-empty ',...
        'to be tested.']);
    rudder_act = [rudder_act{:}];
    rudder_act(isnan(rudder_act)) = [];
    
    rudderFilt_act = logical([rudderFilt_act{:}]);
    rudder_act = rudder_act(~rudderFilt_act);
    rudder_act = EveryElementOf(rudder_act);
    rudder_cons = IsLessThan(maxRudder);
    rudder_msg = ['Rudder angles above 5 degrees should be removed by ',...
        'procedure.'];
    testcase.assertNotEmpty(rudder_act, ['Rudder angle must not be non-empty ',...
        'to be tested.']);
    testcase.verifyThat(rudder_act, rudder_cons, rudder_msg);
    
    end
    
    function testfilterSpeedPowerLookup(testcase)
    % Test that power values outside displacement and trim ranges removed
    % 1: Test that values of delivered power which simultaneously 
    % correspond to those of displacement beyond +/- 5% of the displacement
    % of the speed, power data and to trim values beyond +/- 0.2% of the 
    % LBP of the trim of the speed, power data will correspond to a 
    % FilterSPDispTrim value of TRUE.
    % 2: Test that values of NearestDisplacement and NearestTrim will
    % correspond to values of the Displacement and Trim respectively
    % which are within the ranges given in test 1.
    
    % 1
    % Input
    import matlab.unittest.constraints.EveryElementOf;
    import matlab.unittest.constraints.IsGreaterThanOrEqualTo;
    import matlab.unittest.constraints.IsLessThanOrEqualTo;
    testSz = [1, 4];
    
    spDisp = 114050;
    spTrim = testcase.SPTrim;
    [inDisp_v, inTrim_v] = testcase.randDispTrim(testSz, spDisp, spTrim);
    inDelPower_v = testcase.randOutThreshold(testSz, @gt, 0);
    
%     bothValid_l = false;
%     while ~any(bothValid_l) || all(bothValid_l)
%         
%         lowerDisp = (1/1.05)*spDisp;
%         upperDisp = (1/0.95)*spDisp;
%         inDisp_v = testcase.randOutThreshold(testSz, @lt, upperDisp, ...
%             @gt, lowerDisp);
%         lbp = testcase.LBP;
%         
%         lowerTrim = spTrim - 0.002*lbp;
%         upperTrim = spTrim + 0.002*lbp;
%         inTrim_v = testcase.randOutThreshold(testSz, @lt, upperTrim, ...
%             @gt, lowerTrim);
%         
%         bothValid_l = spDisp >= inDisp_v.*0.95 & spDisp <= inDisp_v.*1.05 & ...
%                       spTrim <= inTrim_v + 0.002*lbp & spTrim >= inTrim_v - 0.002*lbp;
%         
%     end
    inStatic_Draught_Aft = randi([0, 2], testSz);
    inStatic_Draught_Fore = inTrim_v + inStatic_Draught_Aft;
    imo = repmat(str2double(testcase.AlmavivaIMO), testSz);
    
    inputData_m = [imo', inDelPower_v', inDisp_v', inTrim_v', ...
        inStatic_Draught_Fore', inStatic_Draught_Aft'];
    inputNames_c = {'IMO_Vessel_Number', 'Delivered_Power', 'Displacement', 'Trim', ...
        'Static_Draught_Fore', 'Static_Draught_Aft'};
    [startrow, count] = testcase.insert(inputData_m, inputNames_c);
    
    % Execute
    testcase.call('filterSpeedPowerLookup', testcase.AlmavivaIMO);
    
    % Verify
    filt_act = testcase.read('Filter_SpeedPower_Disp_Trim', startrow, count, 'id');
    disp_v = testcase.read('Displacement', startrow, count, 'id');
    testcase.assertNotEmpty(disp_v, ['Displacement cannot be empty',...
        ' for test.']);
    testcase.assertNotEmpty(filt_act, ['Filter_SpeedPower_Disp_Trim cannot be empty',...
        ' for test.']);
    disp_v = [disp_v{:}];
    disp_v(isnan(disp_v)) = [];
    filt_act = [filt_act{:}];
    filt_act(isnan(filt_act)) = [];
    testcase.assertNotEmpty(disp_v, ['Displacement cannot be empty',...
        ' for test.']);
    testcase.assertNotEmpty(filt_act, ['Filter_SpeedPower_Disp_Trim cannot be empty',...
        ' for test.']);
    disp_act = EveryElementOf(repmat(spDisp, 1, numel(disp_v(~filt_act))));
    minDisp_cons = IsGreaterThanOrEqualTo(disp_v(~filt_act)*0.95);
    minDisp_msg = ['Elements of Filter_SpeedPower_Disp corresponding to those ',...
        'below the minimum power values in the speed power curve are ',...
        'expected to be TRUE.'];
    testcase.verifyThat(disp_act, minDisp_cons, minDisp_msg);
    minDisp_cons = IsLessThanOrEqualTo(disp_v(~filt_act)*1.05);
    minDisp_msg = ['Elements of Filter_SpeedPower_Disp corresponding to those ',...
        'above the maximum power values in the speed power curve are ',...
        'expected to be TRUE.'];
    testcase.verifyThat(disp_act, minDisp_cons, minDisp_msg);
    
    trim_c = testcase.read('Trim', startrow, count, 'id');
    trim_v = [trim_c{:}];
    trim_v(isnan(filt_act)) = [];
%     filt_act = testcase.read('FilterSPDispTrim', startrow, count, 'id');
%     filt_act = [filt_act{:}];
%     filt_act(isnan(filt_act)) = [];
    trim_act = EveryElementOf(repmat(spTrim, 1, numel(trim_v(~filt_act))));
    minTrim_cons = IsGreaterThanOrEqualTo(trim_v(~filt_act) - 0.002*lbp);
    minTrim_msg = ['Elements of Filter_SpeedPower_Trim corresponding to those ',...
        'outside of +/- 0.2% of the LBP of the vessel are expected to be ',...
        'FALSE.'];
    testcase.verifyThat(trim_act, minTrim_cons, minTrim_msg);
    minTrim_cons = IsLessThanOrEqualTo(trim_v(~filt_act) + 0.002*lbp);
    minTrim_msg = ['Elements of Filter_SpeedPower_Trim corresponding to those ',...
        'outside of +/- 0.2% of the LBP of the vessel are expected to be ',...
        'FALSE.'];
    testcase.verifyThat(trim_act, minTrim_cons, minTrim_msg);
    
    end
    
    function testfilterPowerBelowMinimum(testcase)
    % Test that column FilterSPBelow is true when Delivered_Power is lower
    % than the minimum of the appropriate speed power curve.
    % 1: Test that procedure returns TRUE for values of Delivered_Power
    % lower than the minimum of the speed, power curve for this vessel at
    % the nearest displacement and trim values.
    
    % 1
    % Input
    import matlab.unittest.constraints.EveryElementOf;
    import matlab.unittest.constraints.IsGreaterThanOrEqualTo;
    import matlab.unittest.constraints.HasSize;
    
    testSz = [1, 2];
    lowerPower = testcase.LowestPower;
    inPower_v = testcase.randOutThreshold(testSz, @lt, lowerPower);
    inNearTrim_v = zeros(testSz);
    inNearDisp_v = repmat(114050, testSz);
    inIMO_v = repmat(str2double(testcase.AlmavivaIMO), testSz);
    [startrow, count] = testcase.insert(...
        [inPower_v', inNearTrim_v', inNearDisp_v', inIMO_v'], ...
        {'Delivered_Power', 'NearestTrim', 'NearestDisplacement', 'IMO_Vessel_Number'});
    
    % Execute
    testcase.call('filterPowerBelowMinimum', testcase.AlmavivaIMO);
    
    % Verify
    outPower_v = testcase.read('Delivered_Power', startrow, count, 'id');
    outPower_v = [outPower_v{:}];
    outPower_v(isnan(outPower_v)) = [];
    filt_act = testcase.read('Filter_SpeedPower_Below', startrow, count, 'id');
    filt_act = [filt_act{:}];
    filt_act(isnan(filt_act)) = [];
    size_msg = ['FilterSPBelow is expected to have some values TRUE before ',...
        'procedure can be verified.'];
    testcase.assertThat(outPower_v(~filt_act), ~HasSize(size(inPower_v)),...
        size_msg)
    power_act = EveryElementOf(outPower_v(~filt_act));
    minPower_cons = IsGreaterThanOrEqualTo(lowerPower);
    minPower_msg = ['Elements of Delivered_Power corresponding to those ',...
        'below the minimum value of Power at the corresponding displacement ',...
        'and trim in the table SpeedPower are expected to be FALSE.'];
    testcase.verifyThat(power_act, minPower_cons, minPower_msg);
    
    end
    
    function testnormaliseHigherFreq(testcase)
    % Test that high frequency data is averaged to a lower frequency.
    % 1: Test that all data in table will be averaged over the frequency 
    % input resulting in average values at that lower frequency.
    
    % 1
    testcase.dropTable;
    testcase.createTable;
    
    % Input
    import matlab.unittest.constraints.HasSize;
    testSz = [1, 10];
    in_SpeedGPS = randi([1, 15], testSz);
    in_SpeedGPS(1:2:end) = nan;
    in_DateTimeUTC = linspace(floor(now), floor(now)+1, prod(testSz));
    in_Depth = randi([50, 200], testSz);
    
    input_m = [cellstr(datestr(in_DateTimeUTC, 'yyyy-mm-dd HH:MM:SS.FFF')),...
        num2cell([in_SpeedGPS', in_Depth'])];
    [startrow, count] = testcase.insert(input_m, ...
        {'DateTime_UTC', 'Speed_Over_Ground', 'Water_Depth'});
    
    % Execute
    testcase.call('normaliseHigherFreq');
    
    % Verify
    outDepth_c = testcase.read('Water_Depth', startrow, count, 'id');
    outDepth_v = [outDepth_c{:}];
    outDepth_v(isnan(outDepth_v)) = [];
    speed_msg = ['High-frequency data is expected to be averaged over the '...
        'lower frequency given.'];
    
    testcase.verifyThat(outDepth_v, ~HasSize(testSz), speed_msg);
    testcase.verifyEqual(mean(in_Depth), mean(outDepth_v), speed_msg);
    
    end
    
    function testnormaliseLowerFreq(testcase)
    % Test that low frequency data is repeated at a higher frequency.
    % 1: Test that values of secondary parameters will be repeated at the
    % frequency of the primary parameters when the primary parameters are
    % at a higher frequency.
    
    % 1
    % Input
    import matlab.unittest.constraints.HasSize;
    testSz = [1, 10];
    in_SpeedGPS = randi([1, 15], testSz);
    in_DateTimeUTC = linspace(floor(now), floor(now)+1, prod(testSz));
    in_Depth = randi([50, 200], testSz);
    in_Depth(2:2:end) = nan;
    
    input_m = [cellstr(datestr(in_DateTimeUTC, 'yyyy-mm-dd HH:MM:SS.FFF')),...
        num2cell([in_SpeedGPS', in_Depth'])];
    [startrow, count] = testcase.insert(input_m, ...
        {'DateTime_UTC', 'Speed_Over_Ground', 'Water_Depth'});
    
    % Execute
    testcase.call('normaliseLowerFreq');
    
    % Verify
    outDepth_c = testcase.read('Water_Depth', startrow, count, 'id');
    outDepth_v = [outDepth_c{:}];
    outDepth_v(isnan(outDepth_v)) = [];
    speed_msg = ['Low-frequency data is expected to be repeated over the '...
        'higher-frequency primary parameter timestep.'];
    
    testcase.verifyThat(outDepth_v, HasSize(size(in_SpeedGPS)), speed_msg);
    testcase.verifyEqual(nanmean(in_Depth), mean(outDepth_v), speed_msg);
    
    end
    
    function testupdateChauvenetCriteria(testcase)
    % Test that Chauvenet's criteria is caluclated based on formula I7
    % 1: Test that after calling the procedure, the column
    % "Chauvenet_Criteria" will have value TRUE for every row at which
    % Chauvenet's criteria, defined in Formula I7 in the standard, is met.
    % 2: Test that, if the input data is of a frequency less than once very
    % ten minutes, the procedure will not affect the data.
    
    import matlab.unittest.constraints.IsFalse;
    import matlab.unittest.constraints.EveryElementOf;
    
    % 1
    % Input
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
    
    mSpeed = mean(reshape(in_SpeedOverGround, [nBlock, N/nBlock]));
    mSpeed = repmat(mSpeed, [nBlock, 1]);
    mSpeed = mSpeed(:)';
    stdSpeed = std(reshape(in_SpeedOverGround, [nBlock, N/nBlock]), 1);
    stdSpeed = repmat(stdSpeed, [nBlock, 1]);
    stdSpeed = stdSpeed(:)';
    mWind = mean(reshape(in_RelWindSpeed, [nBlock, N/nBlock]));
    mWind = repmat(mWind, [nBlock, 1]);
    mWind = mWind(:)';
    stdWind = std(reshape(in_RelWindSpeed, [nBlock, N/nBlock]), 1);
    stdWind = repmat(stdWind, [nBlock, 1]);
    stdWind = stdWind(:)';
    
    in_RudderAngle = reshape(in_RudderAngle, [nBlock, N/nBlock]);
    mur = atan2(mean(sin(in_RudderAngle)), mean(cos(in_RudderAngle)));
    mur = repmat(mur, [nBlock, 1]);
    ri = mod(abs(in_RudderAngle - mur), 360);
    riAbove180 = ri > 180;
    deltar = nan(size(in_RudderAngle));
    deltar(riAbove180) = 360 - ri(riAbove180);
    deltar(~riAbove180) = ri(~riAbove180);
    % deltar = reshape(deltar, [nBlock, N/nBlock]);
    sigmar = sqrt(mean( deltar.^2));
    sigmar = repmat(sigmar, [nBlock, 1]);
    sigmar = sigmar(:)';
    in_RudderAngle = in_RudderAngle(:)';
    mur = mur(:)';
    
    y_f = @(x, N) erfc( x ).* nBlock;
    t_f = @(x) 1 ./ (1 + x.*0.3275911);
    x_f = @(z) abs(z - mSpeed) ./ ( stdSpeed - sqrt(2) );
    x_f = @(z) abs(z - mWind) ./ ( stdWind - sqrt(2) );
    
    chav_f = @(delta, sigma, N) erfc(delta ./ (sigma - sqrt(2)))*N < 0.5;
    chauvSpeed = chav_f(abs(in_SpeedOverGround - mSpeed),...
        stdSpeed, nBlock);
    chauvWind = chav_f(abs(in_RelWindSpeed - mWind),...
        stdWind, nBlock);
    chauvRudder = chav_f(abs(in_RudderAngle - mur),...
        sigmar, nBlock);
    exp_Chauv = chauvSpeed | chauvWind | chauvRudder;
    
    % Execute
    testcase.call('updateChauvenetCriteria');
    
    % Verify
    outChauv_c = testcase.read('Chauvenet_Criteria', startrow, count, 'id');
    outChauv_v = [outChauv_c{:}];
    outChauv_v(isnan(outChauv_v)) = [];
    actChauv = logical(outChauv_v);
    chauv_msg = ['Chauvenet criterion expected to be calculated based on '...
        'formula I7.'];
    testcase.verifyEqual(actChauv, exp_Chauv, 'RelTol', 1.5E-7, chauv_msg);
    
    % 2
    % Input
    testcase.dropTable
    testcase.createTable
    N = 10;
    
    in_SpeedOverGround = abs(randn([1, N])*10);
    in_RelWindSpeed = abs(randn([1, N])*10);
    tstep = 1 / (24*(60/11));
    in_DateTimeUTC = linspace(now, now+(tstep*(N-1)), N);
    
    [startrow, count] = testcase.insert([cellstr(datestr(...
        in_DateTimeUTC, 'yyyy-mm-dd HH:MM:SS.FFF')), ...
        num2cell(in_SpeedOverGround)',...
        num2cell(in_RelWindSpeed)'], ...
        {'DateTime_UTC', 'Speed_Over_Ground', 'Relative_Wind_Speed'});
    
    % Execute
    testcase.call('updateChauvenetCriteria');
    
    % Verify
    outSpeed_c = testcase.read('Speed_Over_Ground', startrow, count, 'id');
    outWind_c = testcase.read('Relative_Wind_Speed', startrow, count, 'id');
    outChauv_c = testcase.read('Chauvenet_Criteria', startrow, count, 'id');
    
    out_Speed = [outSpeed_c{:}];
    out_Wind = [outWind_c{:}];
    out_Chauv = [outChauv_c{:}];
    out_Chauv = logical(out_Chauv);
    
    chauv_msg = ['Chauvenet criterion expected to not affect data when '...
        'frequency is greater than once per 10 minutes.'];
    relTol = 9e-3;
    testcase.verifyEqual(out_Speed, in_SpeedOverGround, 'RelTol', relTol, chauv_msg);
    testcase.verifyEqual(out_Wind, in_RelWindSpeed, 'RelTol', relTol, chauv_msg);
    
    chauvFalse_msg = ['Chauvenet Criteria expected to be false for data '...
        'with a lower frequency than 10 minutes'];
    testcase.verifyThat(EveryElementOf(out_Chauv), IsFalse, chauvFalse_msg);
    
    end
    
    function testupdateValidated(testcase)
    % Test that variable "Validated" is updated according to Annex J.
    % 1. Test that, for the four variables described in Annex J of the
    % standard, where the values of their standard error of the mean exceed
    % the stated threshold, the corresponding values of the variable
    % "Validated" for the entire 10-minute block of data will be FALSE, 
    % and otherwise they will be TRUE.
    % 2. Test that, if the data has a frequency less than once per 10
    % minutes, the data will be unaffected and the variable "validated"
    % will contain only FALSE values.
    
    import matlab.unittest.constraints.IsFalse;
    import matlab.unittest.constraints.EveryElementOf;
    testcase.dropTable
    testcase.createTable
    
    % 1
    % Input
    N = 5E2;
    nBlock = 5;
    k = 1.65;
    
    in_RPM = abs(randn([1, N])*3*k);
    in_SpeedThroughWater = abs(randn([1, N])*0.5*k);
    in_SpeedOverGround = abs(randn([1, N])*0.5*k);
    in_RudderAngle = abs(randn([1, N])*k);
    tstep = 1 / (24*(60/2));
    in_DateTimeUTC = linspace(now, now+(tstep*(N-1)), N);
    
    [startrow, count] = testcase.insert([cellstr(datestr(...
        in_DateTimeUTC, 'yyyy-mm-dd HH:MM:SS.FFF')), ...
        num2cell(in_RPM)',...
        num2cell(in_SpeedThroughWater)', ...
        num2cell(in_SpeedOverGround)',...
        num2cell(in_RudderAngle)'], ...
        {'DateTime_UTC', 'Shaft_Revolutions', 'Speed_Through_Water', ...
        'Speed_Over_Ground', 'Rudder_Angle'});
    
    stdRPM = std(reshape(in_RPM, [nBlock, N/nBlock]), 1);
    stdRPM = repmat(stdRPM, [nBlock, 1]);
    stdRPM = stdRPM(:)';
    stdSpeedThroughWater = std(reshape(in_SpeedThroughWater, [nBlock, N/nBlock]), 1);
    stdSpeedThroughWater = repmat(stdSpeedThroughWater, [nBlock, 1]);
    stdSpeedThroughWater = stdSpeedThroughWater(:)';
    stdSpeedOverGround = std(reshape(in_SpeedOverGround, [nBlock, N/nBlock]), 1);
    stdSpeedOverGround = repmat(stdSpeedOverGround, [nBlock, 1]);
    stdSpeedOverGround = stdSpeedOverGround(:)';
    
    deltaRudderAngle = nan(size(in_RudderAngle));
    in_RudderAngle = reshape(in_RudderAngle, [nBlock, N/nBlock]);
    mRudder = atan2(mean(sin(in_RudderAngle)), mean(cos(in_RudderAngle)));
    mRudder = repmat(mRudder, [nBlock, 1]);
    ri = mod(abs(in_RudderAngle - mRudder), 360);
    rudderAbove180 = ri > 180;
    deltaRudderAngle(rudderAbove180) = 360 - ri(rudderAbove180);
    deltaRudderAngle(~rudderAbove180) = ri(~rudderAbove180);
    deltaRudderAngle = reshape(deltaRudderAngle, [nBlock, N/nBlock]);
    stdRudderAngle = sqrt(mean(deltaRudderAngle.^2));
    stdRudderAngle = repmat(stdRudderAngle, [nBlock, 1]);
    stdRudderAngle = stdRudderAngle(:)';
    
    invalid_RPM = stdRPM > 3;
    invalid_SpeedThroughWater = stdSpeedThroughWater > 0.5;
    invalid_SpeedOverGround = stdSpeedOverGround > 0.5;
    invalid_RudderAngle = stdRudderAngle > 1;
    
    exp_validated = ~invalid_RPM & ~invalid_SpeedThroughWater & ...
        ~invalid_SpeedOverGround & ~invalid_RudderAngle;
    
    % Execute
    testcase.call('updateValidated');
    
    % Verify
    outValidated_c = testcase.read('Validated', startrow, count, 'id');
    outValidated_v = [outValidated_c{:}];
    outValidated_v(isnan(outValidated_v)) = [];
    actValidated = logical(outValidated_v);
    validated_msg = ['Field name ''Validated'' expected to be true when '...
        'standard devaitions of all four fields given in Annex J are not '...
        'exceeded.'];
    testcase.verifyEqual(actValidated, exp_validated, validated_msg);
    
    % 2
    testcase.dropTable
    testcase.createTable
    
    % Input
    N = 10;
    in_SpeedThroughWater = abs(randn([1, N]));
    in_SpeedOverGround = abs(randn([1, N]));
    in_RudderAngle = abs(randn([1, N]));
    tstep = 1 / (24*(60/11));
    in_DateTimeUTC = linspace(now, now+(tstep*(N-1)), N);
    
    [startrow, count] = testcase.insert([cellstr(datestr(...
        in_DateTimeUTC, 'yyyy-mm-dd HH:MM:SS.FFF')), ...
        num2cell(in_SpeedThroughWater)', ...
        num2cell(in_SpeedOverGround)',...
        num2cell(in_RudderAngle)'], ...
        {'DateTime_UTC', 'Speed_Through_Water', ...
        'Speed_Over_Ground', 'Rudder_Angle'});
    
    % Execute
    testcase.call('updateValidated');
    
    % Verify
    outValidated_c = testcase.read('Validated', startrow, count, 'id');
    outValidated_v = [outValidated_c{:}];
    outValidated_v(isnan(outValidated_v)) = [];
    actValidated = logical(outValidated_v);
    validated_msg = ['Field name ''Validated'' expected to be false when '...
        'data frequency is less than once per 10 minutes.'];
    testcase.verifyThat(EveryElementOf(actValidated), IsFalse, validated_msg);
    
    outSTW_c = testcase.read('Speed_Through_Water', startrow, count, 'id');
    outSOG_c = testcase.read('Speed_Over_Ground', startrow, count, 'id');
    outRA_c = testcase.read('Rudder_Angle', startrow, count, 'id');
    
    outSTW = [outSTW_c{:}];
    outSOG = [outSOG_c{:}];
    outRA = [outRA_c{:}];
    
    validated_msg = ['Input data should be unaffected when frequency is '...
        'less than onece per 10 minutes.'];
    sqlTol = 9e-3;
    testcase.verifyEqual(outSTW, in_SpeedThroughWater, 'RelTol', sqlTol,...
        validated_msg);
    testcase.verifyEqual(outSOG, in_SpeedOverGround, 'RelTol', sqlTol, validated_msg);
    testcase.verifyEqual(outRA, in_RudderAngle, 'RelTol', sqlTol, validated_msg);
    
    end
    
    function testfilterSFOCOutOfRange(testcase)
    % Test the filter for when engine's tested range exceeded in ship data.
    % 1. Test that, when the brake power is below the minimum or above the
    % maximum of the engine brake power for which there is data for it's
    % fuel consumption, the filter value will be positive and otherwise,
    % negative.
    
    % 1
    % Input
    import matlab.unittest.constraints.IsTrue;
    import matlab.unittest.constraints.IsFalse;
    import matlab.unittest.constraints.EveryElementOf;
    
    minEngine = testcase.EngineMinPower;
    maxEngine = testcase.EngineMaxPower;
    testSz = [1, 2];
    inBrake_v = testcase.randOutThreshold(testSz, @lt, minEngine);
    inBrake_v = [inBrake_v, testcase.randOutThreshold(testSz, @gt, maxEngine)];
    expTrue_l = inBrake_v < minEngine | inBrake_v > maxEngine;
    testSz = [1, 4];
    in_DateTimeUTC = linspace(floor(now), floor(now)+1, prod(testSz));
    data_m = [cellstr(datestr(in_DateTimeUTC, 'yyyy-mm-dd HH:MM:SS.FFF')),...
        num2cell(inBrake_v')];
    [startrow, count] = testcase.insert(data_m, ...
        {'DateTime_UTC', 'Brake_Power'});
    IMO_s = testcase.AlmavivaIMO;
    
    % Execute
    testcase.call('filterSFOCOutOfRange', IMO_s);
    
    % Verify
    outFilt_c = testcase.read('Filter_SFOC_Out_Range', startrow, count, 'id');
    outFilt_v = logical([outFilt_c{:}]);
    msgFilt = ['Values at indices where brake power is out of range '...
        'are expected to be TRUE'];
    testcase.verifyThat(EveryElementOf(outFilt_v(expTrue_l)), IsTrue, msgFilt);
    testcase.verifyThat(EveryElementOf(outFilt_v(~expTrue_l)), IsFalse, msgFilt);
    
    end
    
    function testupdateTrim(testcase)
    % Test that Trim will be calculated from static draft fore and aft.
    % 1. Test that procedure will return in column Trim the difference
    % between the static forward draft and the static aft draft.
    
    % 1
    % Input
    testSz = [2, 1];
    input_DraftFore = testcase.randOutThreshold(testSz, @gt, 0);
    input_DraftAft = testcase.randOutThreshold(testSz, @gt, 0);
    exp_Trim = input_DraftFore - input_DraftAft;
    in_DateTimeUTC = testISO19030.datetime_utc(testSz);
    in_Data = [in_DateTimeUTC, num2cell([input_DraftFore, input_DraftAft])];
    in_Names = {'DateTime_UTC', 'Static_Draught_Fore', 'Static_Draught_Aft'};
    [startrow, count] = testcase.insert(in_Data, in_Names);
    
    % Execute
    testcase.call('updateTrim');
    
    % Verify
    act_Trimc = testcase.read({'Trim'}, startrow, count);
    act_Trim = [act_Trimc{:}];
    msg_Trim = ['Trim expected to be the difference between fore and '...
        'aft draft.'];
    testcase.verifyEqual(act_Trim, exp_Trim', 'RelTol', 9e-3, msg_Trim);
    
    end
    
    function testupdatewindRef(testcase)
    % Test calculation of relative wind speed and direction, refernce height
    % 1. Test that procedure will return in columns 
    % Relative_Wind_Direction_Reference and Relative_Wind_Speed_Reference
    % the results of formulae specified in equations E.4 and E.5 of the
    % standard.
    
    % 1
    % Input
    testSz = [1, 3];
    
    T = abs(randn(testSz)); % testcase.randOutThreshold(testSz, @gt, 0);
    vr = abs(randn(testSz));
    vg = abs(randn(testSz));
    psir = abs(randn(testSz))*90;
    psi0 = testcase.randOutThreshold(testSz, @lt, 180); % abs(randn(testSz))*50; 
    input_DraftFore = abs(randn(testSz));
    input_DraftAft = 2*T - input_DraftFore;
    
    Ades = testcase.AlmavivaTransProjArea;
    Zrefdes = testcase.Wind_Reference_Height_Design;
    Tdes = testcase.AlmavivaDesignDraft;
    delT = Tdes - T;
    B = testcase.AlmavivaBreadth;
    A = Ades + delT.* B;
    zref = (Ades.*(Zrefdes + delT) + 0.5.* B.* delT.^2) ./ A;
    
    vt = sqrt(vr.^2 + vg.^2 - 2.* vr.* vg.* cosd(psir) );
    za = testcase.AlmavivaAnemometerHeight + delT;
    vtref = vt.* (zref/za).^(1/7);
    condition = vr.* cosd(psir + psi0) - vg.* cosd(psi0) >= 0;
    psit = atand( (vr.* sind(psir + psi0) - vg.*sind(psi0)) ./...
        (vr.* cosd(psir + psi0) - vg.* cosd(psi0) ));
    psit(~condition) = psit(~condition) + 180;
    vrref = sqrt(vtref.^2 + vg.^2 + 2.* vtref.* vg.*cosd(psit + psi0));
    
    condition1 = vg + vtref.* cosd(psit - psi0) >= 0;
    psirref = atand( (vtref.* sind(psit - psi0))./ ...
        (vg + vtref.* cosd(psit - psi0)) );
    psirref(~condition1) = psirref(~condition1) + 180;
    
    in_DateTimeUTC = testISO19030.datetime_utc(testSz);
    input_IMO = repmat(str2double(testcase.AlmavivaIMO), [1, prod(testSz)]);
    input_NumericCols = [input_IMO; vr; psir; input_DraftFore;...
        input_DraftAft; vg; psi0];
    in_Data = [in_DateTimeUTC, num2cell(input_NumericCols)'];
    in_Names = {'DateTime_UTC', 'IMO_Vessel_Number', 'Relative_Wind_Speed', ...
        'Relative_Wind_Direction', 'Static_Draught_Fore', ...
        'Static_Draught_Aft', 'Speed_Over_Ground', 'Ship_Heading'};
    [startrow, count] = testcase.insert(in_Data, in_Names);
    testcase.call('updateTransProjArea', testcase.AlmavivaIMO);
    
    % Execute
    testcase.call('updateWindReference');
    
    % Verify
    act_Speedc = testcase.read({'True_Wind_Speed'},...
        startrow, count);
    act_Speed = [act_Speedc{:}];
    msg_Speed = ['True wind speed should be '...
        'calculated according to Annex E.'];
    exp_Speed = vt;
    testcase.verifyEqual(act_Speed, exp_Speed, 'RelTol', 9e-3, msg_Speed);
    
    act_Dirc = testcase.read({'True_Wind_Direction'},...
        startrow, count);
    act_Dir = [act_Dirc{:}];
    msg_Dir = ['True wind direction at reference height should be '...
        'calculated according to Annex E.'];
    exp_Dir = psit;
    testcase.verifyEqual(act_Dir, exp_Dir, 'RelTol', 9e-3, msg_Dir);
    
    act_Heightc = testcase.read({'Wind_Reference_Height'},...
        startrow, count);
    act_Height = [act_Heightc{:}];
    msg_Height = ['Wind reference height should be '...
        'calculated according to Annex E.'];
    exp_Height = zref;
    testcase.verifyEqual(act_Height, exp_Height, 'RelTol', 9e-3, msg_Height);
    
    act_Speedc = testcase.read({'True_Wind_Speed_Reference'},...
        startrow, count);
    act_Speed = [act_Speedc{:}];
    msg_Speed = ['True wind speed at reference height should be '...
        'calculated according to Annex E.'];
    exp_Speed = vtref;
    testcase.verifyEqual(act_Speed, exp_Speed, 'RelTol', 9e-3, msg_Speed);
    
    act_Speedc = testcase.read({'Relative_Wind_Speed_Reference'},...
        startrow, count);
    act_Speed = [act_Speedc{:}];
    msg_Speed = ['Relative wind speed at reference height should be '...
        'calculated according to Annex E.'];
    exp_Speed = vrref;
    testcase.verifyEqual(act_Speed, exp_Speed, 'RelTol', 9e-3, msg_Speed);
    
    act_Dirc = testcase.read({'Relative_Wind_Direction_Reference'},...
        startrow, count);
    act_Dir = [act_Dirc{:}];
    msg_Dir = ['Relative wind direction at reference height should be '...
        'calculated according to Annex E.'];
    exp_Dir = psirref;
    testcase.verifyEqual(act_Dir, exp_Dir, 'RelTol', 9e-3, msg_Dir);
    
    end
end

methods
    
    function call(testcase, funcname, varargin)
    % CALL Execute procedure call given procedure name and inputs
    % call(testcase, funcname) will call the stored procedure FUNCNAME in
    % the database given by input object TESTCASE. 
    % call(testcase, funcname, inputs) will, in addition to the above, call
    % procedure FUNCNAME with inputs given by string or cell of strings
    % INPUTS. 
    
    narginchk(2, 3)
    
    vessel = testcase.TestVessel;
    msql = vessel.InServiceSQLDB;
    msql.call(funcname, varargin{:});
    
%     conn = testcase.Connection;
%     inputs_s = '()';
%     if nargin > 2
%         v = varargin;
%         v = cellfun(@cellstr, v);
%         inputs_s = ['(' strjoin(v, ', ') ')'];
%     end
%     
%     sql_s = ['CALL ' funcname, inputs_s, ';'];
%     adodb_query(conn, sql_s);
    
    end
    
    function [data, colnames] = select(obj, varargin)
    % READ Reads the database with optional specified parameters
    % data = read(obj) will return in DATA a cell array containing all rows
    % for all columns in the database table specified by input object OBJ.
    % data = read(obj, names) will return in DATA all data from the table
    % specified in OBJ for the column name(s) given by string or cell array
    % of strings NAMES.
    % data = read(obj, names, startrow, count) will, in addition to the 
    % above, return only the data from row number STARTROW and having the 
    % number of rows given by COUNT. Inputting COUNT without a STARTROW 
    % will result in COUNT having no effect.
    
    vessel = obj.TestVessel;
    msql = vessel.InServiceSQLDB;
    tab = obj.TableName;
    
    % Input
    names = '*';
    if nargin > 1
        names = varargin{1};
    end
    where_ch = '';
    otherInputs = {};
    if nargin > 2
        otherInputs = varargin(2:end);
    end
    
    [~, data] = msql.select(tab, names, where_ch, otherInputs{:});
    colnames = data.Properties.VariableNames;
    
    data = table2cell(data);
    data(cellfun(@isnumeric, data)) = ...
        num2cell(cellfun(@double, data(cellfun(@isnumeric, data))));
    data = cell2table(data);
    
%     singleCols_l = varfun(@(x) isa(x, 'single'), data, 'OutputFormat', 'Uni');
%     dbl_tbl = varfun(@double, data(:, singleCols_l));
%     data(:, singleCols_l) = [];
%     data = [data, dbl_tbl];
    data.Properties.VariableNames = colnames;
    
%         start_s = '';
%         if nargin > 2
%             start_row = varargin{2};
%             start_s = num2str(start_row);
%         end
%         
%         count_s = '1';
%         if nargin > 3
%             count_d = varargin{3};
%             count_s = num2str(count_d);
%         end
%         
%         order_s = '';
%         if nargin > 4
%             order_s = varargin{4};
%             if ~isempty(order_s)
%                 order_s = [' ORDER BY ', order_s];
%             end
%         end
%         
%         % Establish Connection
%         sqlConn = obj.Connection;
%         
%         % Read command
%         sql_read = ['SELECT ', names_s, ' FROM ' obj.TableName, order_s];
%         if ~isempty(start_s)
%             sql_read = [sql_read, ' LIMIT ', start_s, ', ', count_s];
%         end
%         [~, out] = adodb_query(sqlConn, sql_read);
%         
%         % Output
%         colnames = names_c;
%         data = out;
        
    end
    
    function [startrow, numrows] = insert(testcase, names, data, varargin)
    % INSERT Inserts data into table, returning indices to read
    % startrow = insert(testcase, data, names) will call INSERT on the data
    % in DATA with the column names given by cell array of strings NAMES
    % for the database and tables given by object TESTCASE. NAMES must have
    % as many elements as columns in DATA.
    
    tab = testcase.TableName;
    vessel = testcase.TestVessel;
    msql = vessel.InServiceSQLDB;
    
    sql_numrows = ['SELECT COUNT(*) FROM ' testcase.TableName];
    [~, startrow_c] = adodb_query(msql.Connection, sql_numrows);
    startrow = str2double( [startrow_c{:}] );
    numrows = size(data, 1);
    
    if isnumeric(data)
        
        data = num2cell(data);
    end
    
    % Concatenate any missing required data
    if ~ismember('Vessel_Id', names)
        
        names = [names, {'Vessel_Id'}];
        vid_c = repmat({vessel.Vessel_Id}, size(data, 1), 1);
        data = [data, vid_c];
    end
    
    if ~ismember('Vessel_Configuration_Id', names)
        
        names = [names, {'Vessel_Configuration_Id'}];
        vid_c = repmat({vessel.Configuration.Model_ID}, size(data, 1), 1);
        data = [data, vid_c];
    end
    
    if ~ismember('Raw_Data_Id', names)
        
        names = [names, {'Raw_Data_Id'}];
        vid_c = num2cell(1:size(data, 1))';
        data = [data, vid_c];
    end
    
    if ~ismember('Timestamp', names)
        
        names = [names, {'Timestamp'}];
        dates = now:1:now+(size(data, 1)-1);
        vid_c = cellstr(datestr(dates, testcase.DateTimeFormSQL));
        data = [data, vid_c];
    end
    
    
    msql.insertValues(tab, names, data);
    
%     % Establish Connection
%     sqlConn = testcase.Connection;
%     
%     update_l = false;
%     if nargin > 3
%         update_l = varargin{1};
%     end
%         
%     % Insert command
%     if isnumeric(data)
%         
%         w = mat2str(data);
%         e = strrep(w, ' ', ', ');
%         r = strrep(e, ';', '),(');
%         t = strrep(r, '[', '(');
%         data_str = strrep(t, ']', ')');
%         
%         if isscalar(data)
%             data_str = ['(', data_str, ')'];
%         end
%         
%     elseif iscell(data)
%         
%         % Assume first column is date data
%         data(:, 1) = strcat('''', data(:, 1), '''');
%         
%         data(:, 2:end) = cellfun(@num2str, data(:, 2:end), 'Uni', 0);
%         for qi = 1:size(data, 1)
%             data(qi, 1) = { strjoin(data(qi, :), ', ') };
%         end
%         data(:, 2:end) = [];
%         
%         data_c = cellfun(@(x) ['(' strrep(x, '  ', ', ') '),'],...
%             data, 'Uni', 0);
%         data_c = data_c(:)';
%         data_str = [data_c{:}];
%         data_str(end) = [];
%     end
%     
%     names_str = ['(', strjoin(names, ', '), ')'];
%     
%     
%     if update_l
%         nameNoBracker_str = strrep(names_str, '(', '');
%         nameNoBracker_str = strrep(nameNoBracker_str, ')', '');
%         sql_insert = ['UPDATE ' testcase.TableName ' SET ' nameNoBracker_str, ...
%             ' ', data_str, ';'];
%     else
%         sql_insert = ['INSERT INTO ' testcase.TableName ' ' names_str ' VALUES ' , ...
%             ' ', data_str, ';'];
%     end
%     sql_insert = strrep(sql_insert, 'NaN', 'NULL');
%     adodb_query(sqlConn, sql_insert);
%     
    end
    
end

    % 1
    % Input
    
    % Execute
    
    % Verify
end