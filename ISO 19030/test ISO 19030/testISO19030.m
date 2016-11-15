classdef testISO19030 < matlab.unittest.TestCase
%testISO19030 Test suite for the ISO 19030 Database methods
%   testISO19030 contains a suite of tests for the stored procedures of a
%   given database. These tests will execute the procedures on table
%   "tempRawISO" tables in the database and compare the result data
%   retrieved from it with expected results found in MATLAB. Therefore it
%   relies on data in other tables and other procedures on which these 
%   procedures depends to be accessible.

properties
    
    Connection = [];
    TableName = 'tempRawISO';
    
end

properties(Hidden)
    
    Server = 'localhost';
    Database = 'test2';
    Uid = 'root';
    Pwd = 'HullPerf2016';
    
end

properties(Constant, Hidden)
    
    DateTimeFormSQL = 'yyyy-mm-dd HH:MM:SS';
    DateTimeFormAdodb = 'dd-mm-yyyy HH:MM:SS';
    SFOCCoefficients = [-6949.127353, 7.918354135, -0.000132468];
    InvalidIMO = sprintf('%u', [1:6, 8]);
    AlmavivaIMO = sprintf('%u', 9450648);
    AlmavivaBreadth = 42.8;
    AlmavivaLength = 334;
    AlmavivaBlockCoefficient = 0.62;
    AlmavivaSpeedPowerCoefficients = [6.037644473511698, -40.659732310548080];
    AlmavivaTransProjArea = 1330;
    AlmavivaWindResistCoeffHead = 0.0001512;
    AlmavivaDesignDraft = 15;
    AlmavivaPropulsiveEfficiency = 0.71;
    MinimumFOCph = 3989.96;
    minTemp = 2;
    MinWind = 0;
    MaxWind = 7.9;
    GravitationalAcceleration = 9.80665;
    MaxRudder = 5;
    LBP = 319;
    LowestPower = 28534;
    
end

methods(TestClassSetup)
    
    function establishConnection(obj)
    % establishConnection Create connection to database if none exists
        
        if isempty(obj.Connection)
            
            conn_ch = ['driver=MySQL ODBC 5.3 ANSI Driver;', ...
                        'Server=' obj.Server ';',  ...
                        'Database=', obj.Database, ';',  ...
                        'Uid=' obj.Uid ';',  ...
                        'Pwd=' obj.Pwd ';'];
            obj.Connection = adodb_connect(conn_ch);
            
        end
    end
    
    function createTable(testcase)
    % createTable Creates test table in database if none exists
    
    testcase.establishConnection;
    call(testcase, 'createTempRawISO', testcase.InvalidIMO);
    
    end
    
end

methods(TestClassTeardown)
    
    function closeConnection(obj)
    % closeConnection Close connection to database if it exists
        
        if ~isempty(obj.Connection)
            
            obj.dropTable;
            
            obj.Connection.release;
            obj.Connection = [];
            
        end
    end
    
    function dropTable(obj)
    % dropTable Drops test table in database if none exists
    
    if ~isempty(obj.Connection)
    
    sql_s = ['DROP TABLE IF EXISTS ' obj.TableName ';'];
	adodb_query(obj.Connection, sql_s);
    
    end
    
    end
    
end

methods(Static)
    
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
end

methods(Test)

    function testsortOnDateTime(testcase)
    % Test table has been sorted ascending by column named DateTime
    % 1: Test that data returned by database reading function matches that
    % returned by the SORT function, with the second output used to index
    % the non-DateTime data.
    
    % Inputs
    today = floor(now) + 0.1;
    date = today+1:-1:today-1;
    x = (3:-1:1)';
    
    date_c = cellstr(datestr(date, testcase.DateTimeFormSQL));
    input = [date_c, num2cell(x)];
    names = {'DateTime_UTC', 'Speed_Loss'};
    [startrow, numrows] = testcase.insert(input, names);
    
    [exp_date, datei] = sort(date, 'ascend');
    exp_date = cellstr(datestr(exp_date, testcase.DateTimeFormAdodb));
    exp_x = num2cell(x(datei));
    exp_sorted = [exp_date, exp_x];
    
    % Execute
    testcase.call('sortOnDateTime');
    
    % Verify
    act_sorted = testcase.read(names, startrow, numrows);
    
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
    exp_dens = num2cell( in_press ./ (in_R.*(in_Temp + 273.15)) )';
    
    names_c = {'Air_Pressure', 'Air_Temperature'};
    [startrow, numrows] = testcase.insert([in_press', in_Temp'], names_c);
    
    % Execute
    testcase.call('updateAirDensity');
    
    % Verify
    act_dens = testcase.read('Air_Density', startrow, numrows);
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
    in_massfoc = [1e5, 1.5e5, 2e5];
    in_lcv = [42, 41.9, 43];
    in_data = [in_massfoc', in_lcv'];
    in_names = {'Mass_Consumed_Fuel_Oil', 'Lower_Caloirifc_Value_Fuel_Oil'};
    in_IMO = testcase.AlmavivaIMO;
    [startrow, numrows] = testcase.insert(in_data, in_names);
    
    x = in_massfoc.* (in_lcv ./ 42.7) ./ 24;
    coeff = testcase.SFOCCoefficients;
    exp_brake = num2cell(coeff(3)*x.^2 + coeff(2)*x + coeff(1))';
    
    % Execute
    testcase.call('updateBrakePower', in_IMO);
    
    % Verify
    act_brake = testcase.read('Brake_Power', startrow, numrows);
    msg_brake = ['Updated Brake Power is expected to match that calculated',...
        ' from mass of fuel oil consumed and the SFOC curve'];
    testcase.verifyEqual(act_brake, exp_brake, 'RelTol', 1e-8, msg_brake);
    
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
    [startrow, count] = testcase.insert([in_vol', in_den15', in_denChange',...
        in_tempFuel'], {'Volume_Consumed_Fuel_Oil', 'Density_Fuel_Oil_15C',...
        'Density_Change_Rate_Per_C', 'Temp_Fuel_Oil_At_Flow_Meter'});
    
    exp_mass = num2cell(...
        in_vol.*(in_den15 - in_denChange.*(in_tempFuel - 15)))';
    
    % Execute
    testcase.call('updateMassFuelOilConsumed', testcase.InvalidIMO);
    
    % Verify
    act_mass = testcase.read('Mass_Consumed_Fuel_Oil', startrow, count);
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
    [startrow, count] = testcase.insert([in_torque', in_rpm'], ...
        {'Shaft_Torque', 'Shaft_Revolutions'});
    
    exp_shaft = num2cell( in_torque.*in_rpm.*(2*pi/60) )';
    
    % Execute
    testcase.call('updateShaftPower', testcase.InvalidIMO);
    
    % Verify
    act_shaft = testcase.read('Shaft_Power', startrow, count);
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
    [startrow, count] = testcase.insert([in_sog', in_speedexp'], ...
        {'Speed_Through_Water', 'Expected_Speed_Through_Water'});
    
    exp_loss = num2cell(((in_sog - in_speedexp) ./ in_speedexp) .* 100)';
    
    % Execute
    testcase.call('updateSpeedLoss')
    
    % Verify
    act_loss = testcase.read('Speed_Loss', startrow, count);
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
    in_A = testcase.AlmavivaSpeedPowerCoefficients(1);
    in_B = testcase.AlmavivaSpeedPowerCoefficients(2);
    [startrow, count] = testcase.insert(...
        [in_DeliveredPower', in_Displacement'], ...
        {'Delivered_Power', 'Displacement'});
    
    exp_espeed = num2cell( in_A(1).*log(in_DeliveredPower) + in_B )';
    
    % Execute
    testcase.call('filterSpeedPowerLookup', testcase.AlmavivaIMO);
    testcase.call('updateExpectedSpeed', testcase.AlmavivaIMO);
    
    % Verify
    act_espeed = testcase.read('Expected_Speed_Through_Water', startrow,...
        count);
    msg_espeed = ['Expected speed is expected to be calculated based on ',...
        'the speed-power curve for this vessel.'];
    testcase.verifyEqual(act_espeed, exp_espeed, 'RelTol', 1e-5, msg_espeed);
    
    end
    
    function testupdateWindResistanceCorrection(testcase)
    % Test that wind resistance correction is calculated as in the standard
    % 1: Test that the wind resistance correction is calculated according
    % to the procedure given in Equation G2, Annex G of the ISO 19030-2
    % standard.
    
    % Input
    in_DeliveredPower = 10e3:1e3:12e3;
    in_SOG = 15:2:19;
    in_PropulsCalm = testcase.AlmavivaPropulsiveEfficiency;
    in_PropulsActual = 0.7;
    
    airResist = 0.1:0.1:0.3;
    windResist = 0.3:0.2:0.7;
    [startrow, count] = testcase.insert(...
        [windResist', airResist', in_SOG', in_DeliveredPower'],...
        {'Wind_Resistance_Relative', 'Air_Resistance_No_Wind', ...
        'Speed_Over_Ground', 'Delivered_Power'});
    
    exp_wind = num2cell(((windResist - airResist).*in_SOG)./ in_PropulsCalm + ...
        in_DeliveredPower.*(1 - in_PropulsActual./in_PropulsCalm))';
    
    % Execute
    testcase.call('updateWindResistanceCorrection', testcase.AlmavivaIMO);
    
    % Verify
    act_wind = testcase.read('Wind_Resistance_Correction', startrow, count);
    msg_wind = ['Wind resistance correction values should match those ',...
        'calculated with Equation G2 in the standard.'];
    testcase.verifyEqual(act_wind, exp_wind, 'RelTol', 1e-7, msg_wind);
    
    end
    
    function testupdateWindResistanceRelative(testcase)
    % Test that relative wind resistance is described by the standard
    % 1: Test that wind resistance due to relative wind is being calculated
    % according to equation G2 of the ISO 19030-2 standard.
    
    % Input
    Coeffs = [testcase.AlmavivaWindResistCoeffHead, [0.2:0.1:0.6, ...
        0.55:-0.1:0.05].*1e-5];
    RelWindDir = [30, 45, 0];
    CoeffDirEdges = 0:30:360;
    [~, relwind_i] = histc(RelWindDir, CoeffDirEdges);
    CoeffRelWind = Coeffs(relwind_i);
    
    Air_Dens = [1.22, 1.21, 1.23];
    RelWindSpeed = [10, 15, 25];
    TransArea = testcase.AlmavivaTransProjArea;
    exp_rel = num2cell(0.5 * Air_Dens .* RelWindSpeed.^2 .* TransArea ...
        .* CoeffRelWind)';
    [startrow, count] = testcase.insert(...
        [Air_Dens', RelWindSpeed', RelWindDir'], ...
        {'Air_Density', 'Relative_Wind_Speed', 'Relative_Wind_Direction'});
    
    % Execute
    testcase.call('updateWindResistanceRelative', testcase.AlmavivaIMO);
    
    % Verify
    act_rel = testcase.read({'Wind_Resistance_Relative'}, startrow, count);
    msg_rel = ['Relative wind resistance expected to match definition given',...
        'by equation G2 in the standard.'];
    testcase.verifyEqual(act_rel, exp_rel, 'RelTol', 1e-5, msg_rel);
    
    end
    
    function testupdateAirResistance(testcase)
    % Test that air resistance in no-wind condition conforms to standard
    % 1: Test that the air resistance in no-wind condition is calculated
    % according to equation G2 in the ISO 19030-2 standard.
    
    % Input
    Air_Dens = [1.22, 1.21, 1.23];
    SOG = [10, 15, 25];
    CoeffHeadWind = testcase.AlmavivaWindResistCoeffHead;
    TransArea = testcase.AlmavivaTransProjArea;
    
    exp_air = num2cell(0.5 * Air_Dens .* SOG.^2 .* TransArea .* CoeffHeadWind)';
    [startrow, count] = testcase.insert([Air_Dens', SOG'], ...
        {'Air_Density', 'Speed_Over_Ground'});
    
    % Execute
    testcase.call('updateAirResistanceNoWind', testcase.AlmavivaIMO);
    
    % Verify
    act_air = testcase.read({'Air_Resistance_No_Wind'}, startrow, count);
    msg_air = ['Air resistance expected to match definition given',...
        'by equation G2 in the standard.'];
    testcase.verifyEqual(act_air, exp_air, 'RelTol', 1e-6, msg_air);
    
    end
    
    function testupdateTransProjAreaCurrent(testcase)
    % Test that transverse projected area in current loading condition is
    % calculated as described in the standard.
    % 1: Test that the transverse projected area in current loading
    % condition is calculated based on equations G3 and G4 in the IS0 
    % 19030-2 standard.
    
    % Input
    designArea = testcase.AlmavivaTransProjArea;
    designDraft = testcase.AlmavivaDesignDraft;
    draftFore = [11, 13, 9];
    draftAft = [9, 11, 7];
    currentDraft = mean([draftFore; draftAft]);
    shipWidth = testcase.AlmavivaBreadth;
    [startrow, count] = testcase.insert([draftFore', draftAft'], ...
        {'Static_Draught_Fore', 'Static_Draught_Aft'});
    
    exp_area = num2cell(designArea + ...
        (designDraft - currentDraft).*shipWidth)';
    
    % Execute
    testcase.call('updateTransProjArea', testcase.AlmavivaIMO);
    
    % Verify
    act_area = testcase.read('Transverse_Projected_Area_Current', ...
        startrow, count);
    msg_area = ['Transverse projected area in current loading condition ',...
        'should be calculated from equations G3 and G4 in the standard'];
    testcase.verifyEqual(act_area, exp_area, msg_area);
    
    end
    
    function testupdatecorrectPower(testcase)
    % Test that the corrected power is power minues wind-correction
    
    % Input
    in_delivered = 10e3:1e3:12e3;
    in_correction = 1e3:0.5e3:2e3;
    [startrow, count] = testcase.insert([in_delivered', in_correction'],...
        {'Delivered_Power', 'Wind_Resistance_Correction'});
    
    exp_corr = num2cell( in_delivered - in_correction )';
    
    % Execute
    testcase.call('updateCorrectedPower');
        
    % Verify
    act_corr = testcase.read('Corrected_Power', startrow, count);
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
    % Input
    in_torque = 1e4:1e4:3e4;
    in_revs = 10:10:30;
    [startrow, count] = testcase.insert([in_torque', in_revs'], ...
        {'Shaft_Torque', 'Shaft_Revolutions'});
    
    % Execute
    testcase.call('updateDeliveredPower', testcase.AlmavivaIMO);
    
    % Verify
    act_del = testcase.read('Delivered_Power', startrow, count);
    act_allNull = any(cellfun(@isnan, act_del));
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
    [startrow, count] = testcase.insert([in_LCV', in_VFOC', in_FuelDens',...
        in_DensChange', in_FuelTemp'], {'Lower_Caloirifc_Value_Fuel_Oil', ...
                        'Volume_Consumed_Fuel_Oil',...
                        'Density_Fuel_Oil_15C',...
                        'Density_Change_Rate_Per_C',...
                        'Temp_Fuel_Oil_At_Flow_Meter'});
    
    % Execute
    testcase.call('updateDeliveredPower', testcase.AlmavivaIMO);
    
    % Verify
    act_del = testcase.read('Delivered_Power', startrow, count);
    act_allNull = any(cellfun(@isnan, act_del));
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
    testcase.insert([in_LCV', in_VFOC', in_FuelDens', in_DensChange', ...
        in_FuelTemp'], {'Lower_Caloirifc_Value_Fuel_Oil', ...
                        'Volume_Consumed_Fuel_Oil',...
                        'Density_Fuel_Oil_15C',...
                        'Density_Change_Rate_Per_C',...
                        'Temp_Fuel_Oil_At_Flow_Meter'});
    
    % Execute
    exec_f = @() testcase.call('updateDeliveredPower', testcase.AlmavivaIMO);
    
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
    
    sqlAddCol_s = 'ALTER TABLE tempRawISO ADD ME_Fuel_BDN VARCHAR(40);';
    adodb_query(testcase.Connection, sqlAddCol_s);
    
    [startrow, count] = testcase.insert(bdn_c', {'ME_Fuel_BDN'});
    exp_lcv = num2cell( LCV_v(bdn_l) )';
    
    % Execute
    testcase.call('updateFromBunkerNote');
    
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
    testcase.call('updateFromBunkerNote');
    
    % Verify
    act_lcv = testcase.read('Density_Fuel_Oil_15C', startrow, count);
    msg_lcv = ['LCV values expected to match those in table '...
        'BunkerDeliveryNote for the corresponding rows of BDN_Number.'];
    testcase.verifyEqual(act_lcv, exp_lcv, msg_lcv);
    
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
    
    % 1
    % Input
    minFOCph = testcase.MinimumFOCph;
    minFOC = minFOCph*24;
    maxFOC = minFOC + 1e3;
    nData = 2;
    nBelow = 1;
    mfoc_v = (maxFOC - minFOC).*rand(1, nData) + minFOC;
    belowI = randperm(nData, nBelow);
    mfoc_v(belowI) = randi([0, floor(minFOC) - 1]);
    [startrow, count] = testcase.insert(mfoc_v', {'Mass_Consumed_Fuel_Oil'});
    
    % Execute
    testcase.call('removeFOCBelowMinimum', testcase.AlmavivaIMO);
    
    % Verify
    mfoc_act = testcase.read('Mass_Consumed_Fuel_Oil', startrow - 2, count);
    testcase.assertNotEmpty(mfoc_act, 'MFOC cannot be empty for test.')
    mfoc_act = [mfoc_act{:}];
    mfoc_act(isnan(mfoc_act)) = [];
    minfoc_act = EveryElementOf(mfoc_act);
    minfoc_cons = IsGreaterThan(minFOC);
    minfoc_msg = ['All elements of Mass_Consumed_Fuel_Oil are expected to ',...
        'be above the minimum foc for the engine.'];
    testcase.verifyThat(minfoc_act, minfoc_cons, minfoc_msg);
    
    end
    
    function testdeleteWithReferenceConditions(testcase)
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
    testSz = [1, 2];
    
    mintemp = testcase.minTemp;
    
    inTemp_v = testcase.randOutThreshold(testSz, @lt, mintemp);
    inputData_m = inTemp_v';
    inputNames_c = {'Seawater_Temperature'};
    [startrow, count] = testcase.insert(inputData_m, inputNames_c);
    
    % Execute
    testcase.call('deleteWithReferenceConditions', testcase.AlmavivaIMO);
    
    % Verify
    temp_act = testcase.read('Seawater_Temperature', startrow, count, 'id');
    temp_act = [temp_act{:}];
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
    inWindSpeed_v = testcase.randOutThreshold(testSz, @lt, 7.9, @gt, 0);
    inputData_m = inWindSpeed_v';
    [startrow, count] = testcase.insert(inputData_m, inputNames_c);
    
    % Execute
    testcase.call('deleteWithReferenceConditions', testcase.AlmavivaIMO);
    
    % Verify
    rudder_act = testcase.read('Relative_Wind_Speed', startrow - 1, count,...
        'id');
    rudder_act = [rudder_act{:}];
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
    testcase.call('deleteWithReferenceConditions', testcase.AlmavivaIMO);
    
    % Verify
    depth5_act = testcase.read('Water_Depth', startrow, 1, 'id');
    depth6_act = testcase.read('Water_Depth', startrow + 1, 1, 'id');
    testcase.assertNotEmpty(depth5_act, ['Water_Depth must not be non-empty ',...
        'to be tested.']);
    testcase.assertNotEmpty(depth6_act, ['Water_Depth must not be non-empty ',...
        'to be tested.']);
    depth5_act = [depth5_act{:}];
    depth5_act(isnan(depth5_act)) = [];
    depth6_act = [depth6_act{:}];
    depth6_act(isnan(depth6_act)) = [];
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
    testcase.call('deleteWithReferenceConditions', testcase.AlmavivaIMO);
    
    % Verify
    rudder_act = testcase.read('Rudder_Angle', startrow, count, 'id');
    testcase.assertNotEmpty(rudder_act, ['Rudder angle must not be non-empty ',...
        'to be tested.']);
    rudder_act = [rudder_act{:}];
    rudder_act(isnan(rudder_act)) = [];
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
    % 1: Test that values of delivered power corresponding to those of
    % displacement beyond +/- 5% of the displacement of the speed, power
    % data will correspond to a FilterSPDist value of TRUE.
    % 2: Test that values of delivered power corresponding to those of
    % trim beyond +/- 0.2% of the LBP of the trim of the speed, power
    % data will correspond to a FilterSPTrim value of TRUE.
    
    % 1
    % Input
    import matlab.unittest.constraints.EveryElementOf;
    import matlab.unittest.constraints.IsGreaterThanOrEqualTo;
    import matlab.unittest.constraints.IsLessThanOrEqualTo;
    testSz = [1, 2];
    
    lowerDisp = 0.95*114050;
    upperDisp = 1.05*114050;
    inDelPower_v = testcase.randOutThreshold(testSz, @gt, 0);
    inDisp_v = testcase.randOutThreshold(testSz, @lt, upperDisp, ...
        @gt, lowerDisp);
    lbp = testcase.LBP;
    
    inTrim_v = testcase.randOutThreshold(testSz, @lt, lbp*2e-3, @gt, -lbp*2e-3);
    lowerTrim = - 0.002*lbp;
    upperTrim =   0.002*lbp;
    
    inStatic_Draught_Aft = randi([0, 2], testSz);
    inStatic_Draught_Fore = inTrim_v + inStatic_Draught_Aft;
    
    inputData_m = [inDelPower_v', inDisp_v', inTrim_v', ...
        inStatic_Draught_Fore', inStatic_Draught_Aft'];
    inputNames_c = {'Delivered_Power', 'Displacement', 'Trim', ...
        'Static_Draught_Fore', 'Static_Draught_Aft'};
    [startrow, count] = testcase.insert(inputData_m, inputNames_c);
    
    % Execute
    testcase.call('filterSpeedPowerLookup', testcase.AlmavivaIMO);
    
    % Verify
    filt_act = testcase.read('FilterSPDisp', startrow, count, 'id');
    disp_v = testcase.read('Displacement', startrow, count, 'id');
    testcase.assertNotEmpty(disp_v, ['Displacement cannot be empty',...
        ' for test.']);
    testcase.assertNotEmpty(filt_act, ['FilterSPDist cannot be empty',...
        ' for test.']);
    disp_v = [disp_v{:}];
    disp_v(isnan(disp_v)) = [];
    filt_act = [filt_act{:}];
    filt_act(isnan(filt_act)) = [];
    disp_act = EveryElementOf(disp_v(~filt_act));
    minDisp_cons = IsGreaterThanOrEqualTo(lowerDisp);
    minDisp_msg = ['Elements of FilterSPDist corresponding to those ',...
        'below the minimum power values in the speed power curve are ',...
        'expected to be TRUE.'];
    testcase.verifyThat(disp_act, minDisp_cons, minDisp_msg);
    minDisp_cons = IsLessThanOrEqualTo(upperDisp);
    minDisp_msg = ['Elements of FilterSPDist corresponding to those ',...
        'above the maximum power values in the speed power curve are ',...
        'expected to be TRUE.'];
    testcase.verifyThat(disp_act, minDisp_cons, minDisp_msg);
    
    trim_c = testcase.read('Trim', startrow, count, 'id');
    trim_v = [trim_c{:}];
    trim_v(isnan(filt_act)) = [];
    filt_act = testcase.read('FilterSPTrim', startrow, count, 'id');
    filt_act = [filt_act{:}];
    filt_act(isnan(filt_act)) = [];
    trim_act = EveryElementOf(trim_v(~filt_act));
    minTrim_cons = IsGreaterThanOrEqualTo(lowerTrim);
    minTrim_msg = ['Elements of FilterSPTrim corresponding to those ',...
        'outside of +/- 0.2% of the LBP of the vessel are expected to be ',...
        'FALSE.'];
    testcase.verifyThat(trim_act, minTrim_cons, minTrim_msg);
    minTrim_cons = IsLessThanOrEqualTo(upperTrim);
    minTrim_msg = ['Elements of FilterSPTrim corresponding to those ',...
        'outside of +/- 0.2% of the LBP of the vessel are expected to be ',...
        'FALSE.'];
    testcase.verifyThat(trim_act, minTrim_cons, minTrim_msg);
    
    end
    
    function testfilterPowerBelowMinimum(testcase)
    % Test that column FilterSPBelow is true when Delivered_Power is lower
    % than the minimum of the speed power curve.
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
    [startrow, count] = testcase.insert(inPower_v', {'Delivered_Power'});
    
    % Execute
    testcase.call('filterPowerBelowMinimum', testcase.AlmavivaIMO);
    
    % Verify
    outPower_v = testcase.read('Delivered_Power', startrow, count, 'id');
    outPower_v = [outPower_v{:}];
    outPower_v(isnan(outPower_v)) = [];
    filt_act = testcase.read('FilterSPBelow', startrow, count, 'id');
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
end

methods
    
    function call(testcase, funcname, varargin)
    % CALL Execute procedure call given procedure name and inputs
    % call(testcase, funcname) will call the stored procedure FUNCNAME in
    % the database given by input object TESTCASE. 
    % call(testcase, funcname, inputs) will, in addition to the above, call
    % procedure FUNCNAME with inputs given by string or cell of strings
    % INPUTS. 
    
    conn = testcase.Connection;
    inputs_s = '()';
    if nargin > 2
        v = varargin;
        v = cellfun(@cellstr, v);
        inputs_s = ['(' strjoin(v, ', ') ')'];
    end
    
    sql_s = ['CALL ' funcname, inputs_s, ';'];
    adodb_query(conn, sql_s);
    
    end
    
    function [data, colnames] = read(obj, varargin)
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
    
        % Input
        names_s = '*';
        if nargin > 1
            names_c = varargin{1};
            names_c = cellstr(names_c);
            names_s = strjoin(names_c, ', ');
        end
        
        start_s = '';
        if nargin > 2
            start_row = varargin{2};
            start_s = num2str(start_row);
        end
        
        count_s = '1';
        if nargin > 3
            count_d = varargin{3};
            count_s = num2str(count_d);
        end
        
        order_s = '';
        if nargin > 4
            order_s = varargin{4};
            if ~isempty(order_s)
                order_s = [' ORDER BY ', order_s];
            end
        end
        
        % Establish Connection
        sqlConn = obj.Connection;
        
        % Read command
        sql_read = ['SELECT ', names_s, ' FROM ' obj.TableName, order_s];
        if ~isempty(start_s)
            sql_read = [sql_read, ' LIMIT ', start_s, ', ', count_s];
        end
        [~, out] = adodb_query(sqlConn, sql_read);
        
        % Output
        colnames = names_c;
        data = out;
        
    end
    
    function [startrow, numrows] = insert(testcase, data, names, varargin)
    % INSERT Inserts data into table, returning indices to read
    % startrow = insert(testcase, data, names) will call INSERT on the data
    % in DATA with the column names given by cell array of strings NAMES
    % for the database and tables given by object TESTCASE. NAMES must have
    % as many elements as columns in DATA.
    
    % Establish Connection
    sqlConn = testcase.Connection;
    
    update_l = false;
    if nargin > 3
        update_l = varargin{1};
    end
        
    % Insert command
    if isnumeric(data)
        
        w = mat2str(data);
        e = strrep(w, ' ', ', ');
        r = strrep(e, ';', '),(');
        t = strrep(r, '[', '(');
        data_str = strrep(t, ']', ')');
        
        if isscalar(data)
            data_str = ['(', data_str, ')'];
        end
        
    elseif iscell(data)
        
        % Assume first column is date data
        data(:, 1) = strcat('''', data(:, 1), '''');
        
        data(:, 2:end) = cellfun(@num2str, data(:, 2:end), 'Uni', 0);
        for qi = 1:size(data, 1)
            data(qi, 1) = { strjoin(data(qi, :), ', ') };
        end
        data(:, 2:end) = [];
        
        data_c = cellfun(@(x) ['(' strrep(x, '  ', ', ') '),'],...
            data, 'Uni', 0);
        data_c = data_c(:)';
        data_str = [data_c{:}];
        data_str(end) = [];
    end
    
    names_str = ['(', strjoin(names, ', '), ')'];
    
    sql_numrows = ['SELECT COUNT(*) FROM ' testcase.TableName];
    [~, startrow_c] = adodb_query(sqlConn, sql_numrows);
    startrow = str2double( [startrow_c{:}] );
    numrows = size(data, 1);
    
    if update_l
        nameNoBracker_str = strrep(names_str, '(', '');
        nameNoBracker_str = strrep(nameNoBracker_str, ')', '');
        sql_insert = ['UPDATE ' testcase.TableName ' SET ' nameNoBracker_str, ...
            ' ', data_str, ';'];
    else
        sql_insert = ['INSERT INTO ' testcase.TableName ' ' names_str ' VALUES ' , ...
            ' ', data_str, ';'];
    end
    sql_insert = strrep(sql_insert, 'NaN', 'NULL');
    adodb_query(sqlConn, sql_insert);
    
    end
    
end

end
