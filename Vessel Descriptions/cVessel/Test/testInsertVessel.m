classdef testInsertVessel < matlab.unittest.TestCase & testcVessel
%testInsertVessel Test insert method of cVessel and nested objects
%   Detailed explanation goes here

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
end
end