classdef testSelectVessel < matlab.unittest.TestCase & testcVessel
%testSelectVessel
%   Detailed explanation goes here

properties
    
    SelectedVessel;
    SelectedVesselConfiguarationId;
end

methods(TestClassSetup)

    function selectVessel(testcase)
    % Select test vessel from DB and assign to property
        
        imo = testcase.TestIMO;
        dbname = testcase.TestDatabase;
        vessel = cVessel('DB', dbname);
        vessel.IMO = imo;
        
        % Remove all Model ID so data matches the expected (uninserted) obj
        testcase.SelectedVesselConfiguarationId = ...
            vessel.Configuration.Model_ID;
        
        testcase.SelectedVessel = vessel;
    end
end

methods(Test)

    function selectVessel1(testcase)
    % Test that method will select the relevant object data from table
    % "Vessel".
    % 1. Test that each input OBJ will have its property data assigned to 
    % from similarly-named fields of table "Vessel".
    
    % 1.
    % Input
    exp_obj = testcase.SelectedVessel;
    input_obj = testcase.SelectedVessel;
    
    % Verify
    msgObj = ['cVessel object returned with model identifier is expected '...
        'to match that inserted with the same identifier.'];
    testcase.verifyEqual(input_obj, exp_obj, msgObj);
    end
    
    function selectVesselConfiguration(testcase)
    % Test that method will select the relevant object data from table
    % "VesselConfiguration".
    
    % 1.
    % Input
    exp_obj = testcase.TestVessel.Configuration;
    input_obj = testcase.SelectedVessel.Configuration;
    
    % Verify
    msgObj = ['cVesselConfiguration object returned with model identifier '...
        'is expected to match that inserted with the same identifier.'];
    testcase.verifyEqual(input_obj, exp_obj, msgObj);
    
    end
    
    function selectVesselInfo(testcase)
    % Test that method will select the relevant object data from table
    % "VesselInfo".
        
    % 1.
    % Input
    exp_obj = testcase.TestVessel.Info;
    input_obj = testcase.SelectedVessel.Info;
    
    % Verify
    msgObj = ['cVesselInfo object returned with model identifier '...
        'is expected to match that inserted with the same identifier.'];
    testcase.verifyEqual(input_obj, exp_obj, msgObj);
    end
    
    function selectVesselOwner(testcase)
    % Test that method will select the relevant object data from table
    % "VesselOwner".
    
    % 1.
    % Input
    exp_obj = testcase.TestVessel.Owner;
    input_obj = testcase.SelectedVessel.Owner;
    
    % Verify
    msgObj = ['cVesselOwner object returned with model identifier '...
        'is expected to match that inserted with the same identifier.'];
    testcase.verifyEqual(input_obj, exp_obj, msgObj);
    end
    
    function selectSpeedPower(testcase)
    % Test that method will select the relevant object data from table
    % "SpeedPower".
    % 1. Test that each input OBJ will have its property data assigned from 
    % the similarly-named field of table "SpeedPower".
    
    % 1.
    % Input
    exp_obj = testcase.TestVessel.SpeedPower;
    input_obj = testcase.SelectedVessel.SpeedPower;
    
    % Verify
    msgObj = ['cVesselSpeedPower object returned with model identifier '...
        'is expected to match that inserted with the same identifier.'];
    testcase.verifyEqual(input_obj, exp_obj, msgObj);
    end
    
    function selectDisplacement(testcase)
    % Test that method will select the relevant object data from table
    % "Displacement".
    % 1. Test that each input OBJ will have its property data assigned from 
    % the similarly-named field of table "Displacement".
    
    % 1.
    % Input
    exp_obj = testcase.TestVessel.Displacement;
    input_obj = testcase.SelectedVessel.Displacement;
    
    % Verify
    msgObj = ['cVesselDisplacement object returned with model identifier '...
        'is expected to match that inserted with the same identifier.'];
    testcase.verifyEqual(input_obj, exp_obj, msgObj);
    end
    
    function selectEngine(testcase)
    % Test that method will select the relevant object data from table
    % "EngineModel".
    % 1. Test that each input OBJ will have its property data assigned from 
    % the similarly-named field of table "EngineModel".
    
    % 1.
    % Input
    exp_obj = testcase.TestVessel.Engine;
    input_obj = testcase.SelectedVessel.Engine;
    
    % Verify
    msgObj = ['cVesselEngine object returned with model identifier '...
        'is expected to match that inserted with the same identifier.'];
    testcase.verifyEqual(input_obj, exp_obj, msgObj);
    end
    
    function selectWind(testcase)
    % Test that method will select the relevant object data from table
    % "WindCoefficient".
    % 1. Test that each input OBJ will have its property data assigned from 
    % the similarly-named field of table "WindCoefficient".
    
    % 1.
    % Input
    exp_obj = testcase.TestVessel.WindCoefficient;
    input_obj = testcase.SelectedVessel.WindCoefficient;
    
    % Verify
    msgObj = ['cVesselWindCoefficient object returned with model identifier '...
        'is expected to match that inserted with the same identifier.'];
    testcase.verifyEqual(input_obj, exp_obj, msgObj);
    end
    
    function selectDryDock(testcase)
    % Test that method will select the relevant object data from table
    % "DryDock".
    % 1. Test that each input OBJ will have its property data assigned from 
    % the similarly-named field of table "DryDock".
    
    % 1.
    % Input
    exp_obj = testcase.TestVessel.DryDock;
    input_obj = testcase.SelectedVessel.DryDock;
    
    % Verify
    msgObj = ['cVesselDryDock object returned with model identifier '...
        'is expected to match that inserted with the same identifier.'];
    testcase.verifyEqual(input_obj, exp_obj, msgObj);
    end
    
    function selectInService(testcase)
    % Test that method will synchronise data from CalculatedData and
    % RawData tables to InService table if exists, and will assign table
    % there otherwise.
    % 1. Test that, with empty InService property, table will be assigned
    % into property
    % 2. Test that, with non-empty InService property, table will be
    % synchronised with existing table and only expected columns will be
    % found.
    % 3. Test input DATEFROM and DATETO work as expected.
    % 4. Test input COLS work as expected.
    % 5. Test input CONFIGS work as expected.
    
    % 1
    % Input
    % Extract this code to insertTestVessel method later
    times_v = now:now+1;
    times_dt = datetime(times_v, 'ConvertFrom', 'datenum');
    expRawCols_c = {'Timestamp', 'Vessel_Id', 'Raw_Data_Id', 'Relative_Wind_Speed', 'Speed_Through_Water'};
    expRawData_m = [times_v; 1, 1; 1, 2; randn(1, 2)*5; randn(1, 2)*10]';
    expRawData_c = num2cell(expRawData_m);
    expRawData_c(:, 1) = cellstr(datestr([expRawData_c{:, 1}], 'yyyy-mm-dd HH:MM:SS'));
    expCalcCols_c = {'Raw_Data_Id', 'Vessel_Configuration_Id', 'Speed_Loss', 'Wind_Resistance_Relative'};
    
    vcId_v = repmat(double(testcase.SelectedVesselConfiguarationId), 1, 2);
    expCalcData_m = [1, 2; vcId_v; randn(2, 2)*100]';
    obj = testcase.TestVessel;
    
    tab = 'RawData';
    obj.InServicePreferences.SQL.insertValuesDuplicate(tab, expRawCols_c, expRawData_c);
    
    tab = 'CalculatedData';
    obj.InServicePreferences.SQL.insertValuesDuplicate(tab, expCalcCols_c, expCalcData_m);
    
    expRaw_tbl = array2timetable(expRawData_m(:, 2:end),...
        'RowTimes', times_dt, 'VariableNames', expRawCols_c(2:end));
    expRaw_tbl.Properties.DimensionNames{1} = 'Timestamp';
    expCalc_tbl = array2timetable(expCalcData_m, ...
        'RowTimes', times_dt, 'VariableNames', expCalcCols_c);
    expCalc_tbl.Properties.DimensionNames{1} = 'Timestamp';
    expAll_tbl = join(expRaw_tbl, expCalc_tbl, 'Keys', 'Raw_Data_Id');
    
    % Execute
    obj = obj.selectInService();
    
    % Verify
    expCols = {'Speed_Loss'};
    [~, coli] = ismember(expCols, expAll_tbl.Properties.VariableNames);
    exp_tbl = expAll_tbl(:, coli);
    exp_m = table2array(exp_tbl);
    
    act_tbl = obj.InService;
    act_m = double(table2array(act_tbl));
    msg_tbl = ['In-Service table should have all RawData and CalculatedData '...
        'for this vessel configuration when called with no inputs.'];
    testcase.verifyEqual(act_m, exp_m, 'RelTol', 0.001, msg_tbl);
    
    % 2
    % Execute
    obj = obj.selectInService(expCalcCols_c, expRawCols_c);
    
    % Verify
    % Table columns are ordered by Timestamp, calc, raw
    x = expRawCols_c;
    [~, ii] = ismember({'Timestamp', 'Raw_Data_Id'}, expRawCols_c);
    x(ii) = [];
    newColOrder = [expCalcCols_c, x];
    [~, reorder_i] = ismember(newColOrder, expAll_tbl.Properties.VariableNames);
    expAll_tbl = expAll_tbl(:, reorder_i);
    
    act_tbl = obj.InService;
    varNames = act_tbl.Properties.VariableNames;
    act_tbl = varfun(@double, act_tbl);
    act_tbl.Properties.VariableNames = varNames;
    act_m = double(table2array(act_tbl));
    exp_m = double(table2array(expAll_tbl));
    msg_tbl = ['In-Service table should have all RawData and CalculatedData '...
        'for this vessel configuration when called with no inputs.'];
    testcase.verifyEqual(act_m, exp_m, 'RelTol', 0.001, msg_tbl);
    
    end
end
end