classdef testInsertVessel < matlab.unittest.TestCase & testcVessel
%TESTCVESSEL
%   Detailed explanation goes here

properties
    
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
    

end

methods(TestMethodSetup)
    
    function insertVessel2Read(testcase)
    % Ensure that vessel for testing read methods is in DB
        
    
    end
end

methods(Test)
    
    function insertVessel1(testcase)
    % Test that method will insert the relevant object data into table
    % "Vessel".
    % 1. Test that each input OBJ will have its property data assigned to 
    % the similarly-named field of table "Vessel".
    
    % 1.
    % Input
    input_obj = testcase.TestcMySQL();
    whereVessel_sql = testcase.SQLWhereVessel;
    
    % Verify
    [~, actId] = input_obj.select('Vessel', '*', whereVessel_sql);
    msgId = 'Object expected to have appropriate Vessel_Id after method call';
    testcase.verifyNotEmpty(actId, msgId);
    end
    
    function insertVesselConfiguration(testcase)
    % Test that method will insert the relevant object data into table
    % "VesselConfiguration".
    % 1. Test that each input OBJ will have its property data assigned to 
    % the similarly-named field of table "VesselConfiguration".
    
    % 1.
    % Input
    input_obj = testcase.TestcMySQL();
    whereVessel_sql = testcase.SQLWhereVessel;
    
    % Verify
    [~, actId] = input_obj.select('VesselConfiguration', '*', whereVessel_sql);
    msgId = 'Object expected to have appropriate Vessel_Id after method call';
    testcase.verifyNotEmpty(actId, msgId);
    end
    
    function insertVesselInfo(testcase)
    % Test that method will insert the relevant object data into table
    % "VesselInfo".
    % 1. Test that each input OBJ will have its property data assigned to 
    % the similarly-named field of table "VesselInfo".
    
    % 1.
    % Input
    input_obj = testcase.TestcMySQL();
    whereVessel_sql = testcase.SQLWhereVessel;
    
    % Verify
    [~, actId] = input_obj.select('VesselInfo', '*', whereVessel_sql);
    msgId = 'Object expected to have appropriate Vessel_Id after method call';
    testcase.verifyNotEmpty(actId, msgId);
    end
    
    function insertVesselOwner(testcase)
    % Test that method will insert the relevant object data into table
    % "VesselOwner".
    % 1. Test that each input OBJ will have its property data assigned to 
    % the similarly-named field of table "VesselOwner".
    
    % 1.
    % Input
    input_obj = testcase.TestcMySQL();
    whereVessel_sql = testcase.SQLWhereVessel;
    
    % Verify
    [~, actId] = input_obj.select('VesselToVesselOwner', '*', whereVessel_sql);
    msgId = 'Object expected to have appropriate Vessel_Id after method call';
    testcase.verifyNotEmpty(actId, msgId);
    end
    
    function insertSpeedPower(testcase)
    % Test that method will insert the relevant object data into table
    % "SpeedPower".
    % 1. Test that each input OBJ will have its property data assigned to 
    % the similarly-named field of table "SpeedPower".
    
    % 1.
    % Input
    input_obj = testcase.TestcMySQL();
    where_sql = testcase.SQLWhereSpeedPower;
    
    % Verify
    [~, actId] = input_obj.select('SpeedPower', '*', where_sql);
    msgId = 'Object expected to have appropriate Vessel_Id after method call';
    testcase.verifyNotEmpty(actId, msgId);
    end
        
    function insertSpeedPowerCoefficientModel(testcase)
    % Test that method will insert the relevant object data into table
    % "SpeedPowerCoefficientModel".
    % 1. Test that each input OBJ will have its property data assigned to 
    % the similarly-named field of table "SpeedPowerCoefficientModel".
    
    % 1.
    % Input
    input_obj = testcase.TestcMySQL();
    where_sql = testcase.SQLWhereSpeedPowerModel;
    
    % Verify
    [~, actId] = input_obj.select('SpeedPowerCoefficientModel', '*', where_sql);
    msgId = 'Object expected to have appropriate Model Id after method call';
    testcase.verifyNotEmpty(actId, msgId);
    end
      
    function insertSpeedPowerCoefficientModelValue(testcase)
    % Test that method will insert the relevant object data into table
    % "SpeedPowerCoefficientModelValue".
    % 1. Test that each input OBJ will have its property data assigned to 
    % the similarly-named field of table "SpeedPowerCoefficientModelValue".
    
    % 1.
    % Input
    input_obj = testcase.TestcMySQL();
    where_sql = testcase.SQLWhereSpeedPower;
    
    % Verify
    [~, actId] = input_obj.select('SpeedPowerCoefficientModelValue', '*', where_sql);
    msgId = 'Object expected to have appropriate Model Id after method call';
    testcase.verifyNotEmpty(actId, msgId);
    end
          
    function insertDryDock(testcase)
    % Test that method will insert the relevant object data into table
    % "DryDock".
    % 1. Test that each input OBJ will have its property data assigned to 
    % the similarly-named field of table "DryDock".
    
    % 1.
    % Input
    input_obj = testcase.TestcMySQL();
    whereVessel_sql = testcase.SQLWhereVessel;
    
    % Verify
    [~, actId] = input_obj.select('DryDock', '*', whereVessel_sql);
    msgId = 'Object expected to have appropriate Vessel_Id after method call';
    testcase.verifyNotEmpty(actId, msgId);
    end
    
    function insertWindCoefficientModel(testcase)
    % Test that method will insert the relevant object data into table
    % "WindCoefficientModel".
    % 1. Test that each input OBJ will have its property data assigned to 
    % the similarly-named field of table "WindCoefficientModel".
    
    % 1.
    % Input
    input_obj = testcase.TestcMySQL();
    where_sql = testcase.SQLWhereWind;
    
    % Verify
    [~, actId] = input_obj.select('WindCoefficientModel', '*', where_sql);
    msgId = 'Object expected to have appropriate Vessel_Id after method call';
    testcase.verifyNotEmpty(actId, msgId);
    end
    
    function insertWindCoefficientModelValue(testcase)
    % Test that method will insert the relevant object data into table
    % "WindCoefficientModelValue".
    % 1. Test that each input OBJ will have its property data assigned to 
    % the similarly-named field of table "WindCoefficientModelValue".
    
    % 1.
    % Input
    input_obj = testcase.TestcMySQL();
    where_sql = testcase.SQLWhereWind;
    
    % Verify
    [~, actId] = input_obj.select('WindCoefficientModelValue', '*', where_sql);
    msgId = 'Object expected to have appropriate Vessel_Id after method call';
    testcase.verifyNotEmpty(actId, msgId);
    end
    
    function insertDisplacementModel(testcase)
    % Test that method will insert the relevant object data into table
    % "DisplacementModel".
    % 1. Test that each input OBJ will have its property data assigned to 
    % the similarly-named field of table "DisplacementModel".
    
    % 1.
    % Input
    input_obj = testcase.TestcMySQL();
    where_sql = testcase.SQLWhereDisplacement;
    
    % Verify
    [~, actId] = input_obj.select('DisplacementModel', '*', where_sql);
    msgId = 'Object expected to have appropriate Vessel_Id after method call';
    testcase.verifyNotEmpty(actId, msgId);
    end
    
    function insertDisplacementModelValue(testcase)
    % Test that method will insert the relevant object data into table
    % "DisplacementModelValue".
    % 1. Test that each input OBJ will have its property data assigned to 
    % the similarly-named field of table "DisplacementModelValue".
    
    % 1.
    % Input
    input_obj = testcase.TestcMySQL();
    where_sql = testcase.SQLWhereDisplacement;
    
    % Verify
    [~, actId] = input_obj.select('DisplacementModelValue', '*', where_sql);
    msgId = 'Object expected to have appropriate Vessel_Id after method call';
    testcase.verifyNotEmpty(actId, msgId);
    end
    
    function insertEngineModel(testcase)
    % Test that method will insert the relevant object data into table
    % "EngineModel".
    % 1. Test that each input OBJ will have its property data assigned to 
    % the similarly-named field of table "EngineModel".
    
    % 1.
    % Input
    input_obj = testcase.TestcMySQL();
    where_sql = testcase.SQLWhereEngine;
    
    % Verify
    [~, actId] = input_obj.select('EngineModel', '*', where_sql);
    msgId = 'Object expected to have appropriate Vessel_Id after method call';
    testcase.verifyNotEmpty(actId, msgId);
    end
%     function selectVesselConfiguration(testcase)
%     % Test that method will insert the relevant object data into table
%     % "VesselConfiguration".
%     % 1. Test that each input OBJ will have its property data assigned to 
%     % the similarly-named field of table "VesselConfiguration".
%     
%     % 1.
%     % Input
%     input_obj = testcase.testVesselInsert();
%     expId = input_obj.Vessel_Id;
%     
% %     % Execute
% %     input_obj.insertVesselConfiguration;
%     
%     % Verify
%     actId = input_obj.Vessel_Id;
%     msgId = 'Object expected to have appropriate Vessel_Id after method call';
%     testcase.verifyEqual(expId, actId, msgId);
%     end
end

% Input

% Execute

% Verify
%     function testinsertIntoDryDockDates(testcase)
%     % Test that method will insert all dry docking dates given into table
%     % "DryDockDates".
%     % 1. Test that each cVesselDryDock in property DryDockDates of input
%     % OBJ will have its property data assigned to the similarly-named field
%     % of table "DryDockDates".
%     
%     % 1.
%     % Input
%     expTable = struct2table(testcase.InsertIntoDryDockDatesValues);
%     testDBTable = 'DryDockDates';
%     inputObj = testcase.testVessel;
%     
%     numDDi = numel(testcase.InsertIntoDryDockDatesValues);
%     inputDDD(numDDi) = cVesselDryDockDates();
%     for si = 1:numDDi
%         
%         inputDDD(si).IMO_Vessel_Number = ...
%             testcase.InsertIntoDryDockDatesValues(si).IMO_Vessel_Number;
%         inputDDD(si) = inputDDD(si).assignDates(...
%             testcase.InsertIntoDryDockDatesValues(si).StartDate,...
%             testcase.InsertIntoDryDockDatesValues(si).EndDate, ...
%             'yyyy-mm-dd');
%     end
%     inputObj.DryDockDates = inputDDD;
%     
%     [inputObj, ~, sql] = inputObj.select(testDBTable, ...
%         {'imo_vessel_number', 'startdate', 'enddate'});
%     [~, sql] = inputObj.determinateSQL(sql);
%     sql = [sql, ' ORDER BY id DESC LIMIT 2;'];
%     
%     % Execute
%     inputObj = inputObj.insertIntoDryDockDates();
%     
%     % Verify
%     [outSt, outC] = inputObj.executeIfOneOutput(nargout, sql, 1);
%     actTable = cell2table(outC, 'VariableNames', fieldnames(outSt));
%     expTable.Properties.VariableNames = ...
%         lower(expTable.Properties.VariableNames);
%     
%     [inputDDD(:).DateStrFormat] = deal('dd-mm-yyyy');
%     expTable.startdate = {inputDDD.StartDate}';
%     expTable.enddate = {inputDDD.EndDate}';
%     expTable = flipud(expTable);
%     msgTable = 'Table of dry docking dates should match that input.';
%     testcase.verifyEqual(actTable, expTable, msgTable);
%     
%     end
%     
end