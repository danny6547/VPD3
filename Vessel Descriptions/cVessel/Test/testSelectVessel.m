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
        vessel = cVessel('Database', dbname);
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
    input_obj = cVessel('Database', testcase.TestDatabase);
    
    % Execute
    input_obj.IMO = testcase.TestIMO;
    
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
    exp_obj = testcase.SelectedVessel;
    input_obj = cVessel('Database', testcase.TestDatabase);
    
    % Execute
    input_obj.IMO = testcase.TestIMO;
    
    % Verify
    exp_obj = exp_obj.Configuration;
    input_obj = input_obj.Configuration;
    msgObj = ['cVesselConfiguration object returned with model identifier '...
        'is expected to match that inserted with the same identifier.'];
    testcase.verifyEqual(input_obj, exp_obj, msgObj);
    
    end
    
    function selectVesselInfo(testcase)
    % Test that method will select the relevant object data from table
    % "VesselInfo".
        
    % 1.
    % Input
    exp_obj = testcase.SelectedVessel;
    input_obj = cVessel('Database', testcase.TestDatabase);
    
    % Execute
    input_obj.IMO = testcase.TestIMO;
    
    % Verify
    exp_obj = exp_obj.Info;
    input_obj = input_obj.Info;
    msgObj = ['cVesselInfo object returned with model identifier '...
        'is expected to match that inserted with the same identifier.'];
    testcase.verifyEqual(input_obj, exp_obj, msgObj);
    end
    
    function selectVesselOwner(testcase)
    % Test that method will select the relevant object data from table
    % "VesselOwner".
    
    % 1.
    % Input
    exp_obj = testcase.SelectedVessel;
    input_obj = cVessel('Database', testcase.TestDatabase);
    
    % Execute
    input_obj.IMO = testcase.TestIMO;
    
    % Verify
    exp_obj = exp_obj.Owner;
    input_obj = input_obj.Owner;
    msgObj = ['cVesselOwner object returned with model identifier '...
        'is expected to match that inserted with the same identifier.'];
    testcase.verifyEqual(input_obj, exp_obj, msgObj);
    end
    
    function selectSpeedPower(testcase)
    % Test that method will select the relevant object data into table
    % "SpeedPower".
    % 1. Test that each input OBJ will have its property data assigned from 
    % the similarly-named field of table "SpeedPower".
    
    % 1.
    % Input
%     input_obj = testcase.testVesselInsert();
%     where_sql = testcase.SQLWhereSpeedPower;
    testObj = testcase.SelectedVessel;
    
    % Verify
    actObj = testObj.SpeedPower;
    msgId = 'Object expected to have appropriate Vessel_Id after method call';
    testcase.verifyNotEmpty(actObj, msgId);
    end
end
end