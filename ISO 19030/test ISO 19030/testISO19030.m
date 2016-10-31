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
    SFOCCoefficients = [-6949.127353, -0.000132468, 7.918354135];
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
    in_massfoc = [50, 75, 60];
    in_lcv = [42, 41.9, 43];
    in_data = [in_massfoc', in_lcv'];
    in_names = {'Mass_Consumed_Fuel_Oil', 'Lower_Caloirifc_Value_Fuel_Oil'};
    in_IMO = testcase.AlmavivaIMO;
    [startrow, numrows] = testcase.insert(in_data, in_names);
    
    x = in_massfoc.* (in_lcv ./ 42.7);
    coeff = testcase.SFOCCoefficients;
    exp_brake = num2cell(coeff(3)*x.^2 + coeff(2)*x + coeff(1))';
    
    % Execute
    testcase.call('updateBrakePower', in_IMO);
    
    % Verify
    act_brake = testcase.read('Brake_Power', startrow, numrows);
    msg_brake = ['Updated Brake Power is expected to match that calculated',...
        ' from mass of fuel oil consumed and the SFOC curve'];
    testcase.verifyEqual(act_brake, exp_brake, 'RelTol', 1e-9, msg_brake);
    
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
    in_A = testcase.AlmavivaSpeedPowerCoefficients(1);
    in_B = testcase.AlmavivaSpeedPowerCoefficients(2);
    in_DeliveredPower = 30e4:10e4:50e4;
    [startrow, count] = testcase.insert(in_DeliveredPower', ...
        {'Delivered_Power'});
    
    exp_espeed = num2cell( in_A(1).*log(in_DeliveredPower) + in_B )';
    
    % Execute
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
        inputs_c = cellstr(varargin{1});
        inputs_s = ['(' strjoin(inputs_c, ', ') ')'];
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
        
        % Establish Connection
        sqlConn = obj.Connection;
        
        % Read command
        sql_read = ['SELECT ', names_s, ' FROM ' obj.TableName];
        if ~isempty(start_s)
            sql_read = [sql_read, ' LIMIT ', start_s, ', ', count_s];
        end
        [~, out] = adodb_query(sqlConn, sql_read);
        
        % Output
        colnames = names_c;
        data = out;
        
    end
    
    function [startrow, numrows] = insert(testcase, data, names)
    % INSERT Inserts data into table, returning indices to read
    % startrow = insert(testcase, data, names) will call INSERT on the data
    % in DATA with the column names given by cell array of strings NAMES
    % for the database and tables given by object TESTCASE. NAMES must have
    % as many elements as columns in DATA.
    
    % Establish Connection
    sqlConn = testcase.Connection;
    
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
    
    sql_insert = ['INSERT INTO ' testcase.TableName ' ' names_str ' VALUES ' , ...
        ' ', data_str, ';'];
    adodb_query(sqlConn, sql_insert);
    
    end
    
end

end


    % Input
    
    % Execute
        
    % Verify
    