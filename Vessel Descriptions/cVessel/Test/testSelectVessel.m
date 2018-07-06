classdef testSelectVessel < matlab.unittest.TestCase & testcVessel
%testSelectVessel
%   Detailed explanation goes here

properties
    
    SelectedVessel;
%     TestDatabase = 'TestStatic';
%     SQLWhereVessel;
%     SQLWhereEngine;
%     SQLWhereSpeedPower;
%     SQLWhereDisplacement;
%     SQLWhereWind;
end

methods
%     
%     function vessel = testVesselInsert(testcase)
%         
%         testDB = testcase.TestDatabase;
%         vessel = cVessel('Database', testDB);
%         
%         % Configuration
%         vessel.Configuration.Transverse_Projected_Area_Design = 1000;
%         vessel.Configuration.Length_Overall = 300;
%         vessel.Configuration.Breadth_Moulded = 50;
%         vessel.Configuration.Draft_Design = 10;
%         vessel.Configuration.Anemometer_Height = 50;
%         vessel.Configuration.Valid_From = '2000-01-01 00:00:00';
%         vessel.Configuration.Valid_To = '2018-01-01 00:00:00';
%         vessel.Configuration.Default_Configuration = true;
%         vessel.Configuration.Speed_Power_Source = 'Sea Trial';
%         vessel.Configuration.Wind_Reference_Height_Design = 30;
%         vessel.Configuration.Vessel_Configuration_Description = 'Test Config';
%         vessel.Configuration.Apply_Wind_Calculations = true;
%         vessel.Configuration.Fuel_Type = 'HFO';
%         
%         % Vessel Info
%         vessel.Info.Vessel_Name = 'Test vessel'; 
%         vessel.Info.Valid_From = '2000-01-01 00:00:00'; 
%         
%         % Owner
%         vessel.Owner.Ownership_Start = '2000-01-01 00:00:00';
%         vessel.Owner.Ownership_End = '2018-01-01 00:00:00';
%         
%         % Engine
%         vessel.Engine.Engine_Model = 'Test Engine';
%         vessel.Engine.X0 = 3;
%         vessel.Engine.X1 = 2;
%         vessel.Engine.X2 = 1;
%         vessel.Engine.Minimum_FOC_ph = 4;
%         vessel.Engine.Lowest_Given_Brake_Power = 5;
%         vessel.Engine.Highest_Given_Brake_Power = 6;
%         
%         % Speed Power
%         sp = cVesselSpeedPower('Size', [1, 2], 'Database', testDB);
%         sp(1).Speed = [10, 15];
%         sp(1).Power = [10, 15]*1e4;
%         sp(1).Trim = 1;
%         sp(1).Displacement = 1e5;
%         sp(1).Model_ID = 1;
%         sp(1).Name = 'Speed Power test 1';
%         sp(1).Description = 'the first one';
%         sp(2).Speed = [5, 10, 15];
%         sp(2).Power = [7, 9.5, 15]*1e4;
%         sp(2).Trim = 0;
%         sp(2).Displacement = 2e5;
%         sp(2).Model_ID = 2;
%         sp(2).Name = 'Speed Power test 2';
%         sp(2).Description = 'the second one';
%         vessel.SpeedPower = sp;
%         
%         % Dry Dock
%         vessel.DryDock.assignDates('2000-01-01', '2000-01-14');
%         
%         % Displacement
%         vessel.Displacement.Model_ID = 1;
%         vessel.Displacement.Draft_Mean = [10, 12];
%         vessel.Displacement.Trim = [0, 1];
%         vessel.Displacement.Displacement = [1e5, 1.5e5];
%         
%         % Wind
%         vessel.WindCoefficient.Model_ID = 1;
%         vessel.WindCoefficient.Direction = [10, 45];
%         vessel.WindCoefficient.Coefficient = [0.5, 1];
%         
%         % Identity
%         vessel.IMO = 1234567;
%         vessel.Vessel_Id = 1;
%         
%         % Assign where SQL
%         vid = vessel.Vessel_Id;
%         spid = [vessel.SpeedPower.Model_ID];
%         did = vessel.Displacement.Model_ID;
%         wid = vessel.WindCoefficient.Model_ID;
%         where_sql = ['Vessel_Id = ', num2str(vid)];
%         whereEngine_sql = ['Engine_Model = ''', vessel.Engine.Engine_Model, ''''];
%         whereSP_sql = ['Speed_Power_Coefficient_Model_Id IN (', sprintf('%u, %u', spid), ')'];
%         whereDisp_sql = ['Displacement_Model_Id = ', num2str(did)];
%         whereWind_sql = ['Wind_Coefficient_Model_Id = ', num2str(wid)];
%         
%         testcase.SQLWhereVessel = where_sql;
%         testcase.SQLWhereEngine = whereEngine_sql;
%         testcase.SQLWhereSpeedPower = whereSP_sql;
%         testcase.SQLWhereDisplacement = whereDisp_sql;
%         testcase.SQLWhereWind = whereWind_sql;
%     end
end

methods(TestClassSetup)

    function selectVessel(testcase)
    % Select test vessel from DB and assign to property
        
        imo = testcase.TestIMO;
        dbname = testcase.TestDatabase;
        vessel = cVessel('SavedConnection', dbname);
        vessel.InServiceDB = testcase.TestInServiceDB;
        vessel.IMO = imo;
        testcase.SelectedVessel = vessel;
    end
end

methods(TestMethodSetup)
    
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
    expCalcCols_c = {'Raw_Data_Id', 'Vessel_Configuration_Id', 'Speed_Loss'};
    expCalcData_m = [1, 2; 1, 1; randn(1, 2)*100]';
    obj = testcase.TestVessel;
    
    tab = 'RawData';
    obj.InServiceSQLDB.insertValuesDuplicate(tab, expRawCols_c, expRawData_c);
    
    tab = 'CalculatedData';
    obj.InServiceSQLDB.insertValuesDuplicate(tab, expCalcCols_c, expCalcData_m);
    
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
    obj = obj.selectInService();
    
    % Verify
    act_tbl = obj.InService;
    act_m = double(table2array(act_tbl));
    msg_tbl = ['In-Service table should have all RawData and CalculatedData '...
        'for this vessel configuration when called with no inputs.'];
    testcase.verifyEqual(act_m, exp_m, 'RelTol', 0.001, msg_tbl);
    
    end
end
end