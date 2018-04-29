classdef testcVessel < matlab.unittest.TestCase
%TESTCVESSEL
%   Detailed explanation goes here

properties
    
    TestDatabase = 'TestStatic';
    TestIMO = 1234567;
    TestVessel_Id = 1;
    TestVessel;
    TestcMySQL;
    SQLWhereVessel;
    SQLWhereEngine;
    SQLWhereSpeedPower;
    SQLWhereSpeedPowerModel;
    SQLWhereDisplacement;
    SQLWhereWind;
end

methods
    
    function vessel = testVesselInsert(testcase)
        
        testDB = testcase.TestDatabase;
        vessel = cVessel('Database', testDB);
        
        % Configuration
        vessel.Configuration.Transverse_Projected_Area_Design = 1000;
        vessel.Configuration.Length_Overall = 300;
        vessel.Configuration.Breadth_Moulded = 50;
        vessel.Configuration.Draft_Design = 10;
        vessel.Configuration.Anemometer_Height = 50;
        vessel.Configuration.Valid_From = '2000-01-01 00:00:00';
        vessel.Configuration.Valid_To = '2018-01-01 00:00:00';
        vessel.Configuration.Default_Configuration = true;
        vessel.Configuration.Speed_Power_Source = 'Sea Trial';
        vessel.Configuration.Wind_Reference_Height_Design = 30;
        vessel.Configuration.Vessel_Configuration_Description = 'Test Config';
        vessel.Configuration.Apply_Wind_Calculations = true;
        vessel.Configuration.Fuel_Type = 'HFO';
%         vessel.Configuration.Speed_Power_Coefficient_Model_Id = 1;
        
        % Vessel Info
        vessel.Info.Vessel_Name = 'Test vessel'; 
        vessel.Info.Valid_From = '2000-01-01 00:00:00'; 
        
        % Owner
        vessel.Owner.Vessel_Owner_Name = 'Hempel';
        vessel.Owner.Ownership_Start = '2000-01-01 00:00:00';
        vessel.Owner.Ownership_End = '2018-01-01 00:00:00';
        
        % Engine
        vessel.Engine.Engine_Model = 'Test Engine';
        vessel.Engine.X0 = 3;
        vessel.Engine.X1 = 2;
        vessel.Engine.X2 = 1;
        vessel.Engine.Minimum_FOC_ph = 4;
        vessel.Engine.Lowest_Given_Brake_Power = 5;
        vessel.Engine.Highest_Given_Brake_Power = 6;
        
        % Speed Power
        sp = cVesselSpeedPower('Size', [1, 2], 'Database', testDB);
        sp(1).Speed = [10, 15];
        sp(1).Power = [10, 15]*1e4;
        sp(1).Trim = 1;
        sp(1).Displacement = 1e5;
%         sp(1).Model_ID = 1;
        sp(1).Name = 'Speed Power test 1';
        sp(1).Description = 'the first one';
        sp(2).Speed = [5, 10, 15];
        sp(2).Power = [7, 9.5, 15]*1e4;
        sp(2).Trim = 0;
        sp(2).Displacement = 2e5;
%         sp(2).Model_ID = 2;
        sp(2).Name = 'Speed Power test 1';
        sp(2).Description = 'the first one';
        vessel.SpeedPower = sp;
        
        % Dry Dock
%         vessel.DryDock.assignDates('2000-01-01', '2000-01-14');
        vessel.DryDock.StartDate = '2000-01-01';
        vessel.DryDock.EndDate = '2000-01-14';
        
        % Displacement
%         vessel.Displacement.Model_ID = 1;
        vessel.Displacement.Draft_Mean = [10, 12];
        vessel.Displacement.Trim = [0, 1];
        vessel.Displacement.Displacement = [1e5, 1.5e5];
        
        % Wind
%         vessel.WindCoefficient.Model_ID = 1;
        vessel.WindCoefficient.Direction = [10, 45];
        vessel.WindCoefficient.Coefficient = [0.5, 1];
        
        % Identity
        vessel.IMO = testcase.TestIMO;
%         vessel.Vessel_Id = 1;
    end
end

methods(TestClassSetup)

    function createDB(testcase)
    % createDB Create database for Vessel if it doesn't exist
    
    obj = cDB();
    [obj, isDB] = obj.existDB(testcase.TestDatabase);
    
    if ~isDB

        obj.InsertStatic = false;
        obj.createTestStatic();
    end
    end
    
    function removeVessel2Insert(testcase)
    % Ensure that vessel for testing insert methods is not in DB
    
%     vessel = testcase.testVesselInsert;
%     
% %     % Remove from each table which could contain data for vessel
% %     vid = vessel.Vessel_Id;
% %     spid = [vessel.SpeedPower.Model_ID];
% %     did = vessel.Displacement.Model_ID;
% %     wid = vessel.WindCoefficient.Model_ID;
% %     where_sql = ['Vessel_Id = ', num2str(vid)];
% %     whereEngine_sql = ['Engine_Model = ''', vessel.Engine.Name, ''''];
% %     whereSP_sql = ['Speed_Power_Coefficient_Model_Id IN (', sprintf('%u, %u', spid), ')'];
% %     whereDisp_sql = ['Displacement_Model_Id = ', num2str(did)];
% %     whereWind_sql = ['Wind_Coefficient_Model_Id = ', num2str(wid)];
%     
%     where_sql = testcase.SQLWhereVessel;
%     whereEngine_sql = testcase.SQLWhereEngine;
%     whereSP_sql = testcase.SQLWhereSpeedPower;
%     whereSPModel_sql = testcase.SQLWhereSpeedPowerModel;
%     whereDisp_sql = testcase.SQLWhereDisplacement;
%     whereWind_sql = testcase.SQLWhereWind;
%     
%     vessel.deleteSQL('EngineModel', whereEngine_sql);
%     vessel.deleteSQL('SpeedPower', whereSP_sql);
%     vessel.deleteSQL('SpeedPowerCoefficientModel', whereSPModel_sql);
%     vessel.deleteSQL('SpeedPowerCoefficientModelValue', whereSPModel_sql);
%     vessel.deleteSQL('DisplacementModel', whereDisp_sql);
%     vessel.deleteSQL('DisplacementModelValue', whereDisp_sql);
%     vessel.deleteSQL('WindCoefficientModel', whereWind_sql);
%     vessel.deleteSQL('WindCoefficientModelValue', whereWind_sql);
%     
%     vessel.deleteSQL('Vessel', where_sql);
%     vessel.deleteSQL('VesselInfo', where_sql);
%     vessel.deleteSQL('VesselConfiguration', where_sql);
%     vessel.deleteSQL('VesselToVesselOwner', where_sql);
%     vessel.deleteSQL('BunkerDeliveryNote', where_sql);
%     vessel.deleteSQL('DryDock', where_sql);
    
    end
    
    function insertVessel(testcase)
    % Insert test vessel into DB
    
    vessel = testcase.testVesselInsert;
    vessel.insert();

    % Assign
    testcase.TestVessel = vessel;
    
    % Assign cMySQL object
    testDB = testcase.TestDatabase;
    testcase.TestcMySQL = cMySQL('Database', testDB);

    % Assign where SQL
    vid = vessel.Model_ID;
    spid = [vessel.SpeedPower.Model_ID];
    did = vessel.Displacement.Model_ID;
    wid = vessel.WindCoefficient.Model_ID;
    spmid = vessel.Configuration.Speed_Power_Coefficient_Model_Id;
    where_sql = ['Vessel_Id = ', num2str(vid)];
    whereEngine_sql = ['Engine_Model = ''', vessel.Engine.Engine_Model, ''''];
    whereSP_sql = ['Speed_Power_Coefficient_Model_Value_Id IN (', sprintf('%u, %u', spid), ')'];
    whereSPModel_sql = ['Speed_Power_Coefficient_Model_Id = ', num2str(spmid)];
    whereDisp_sql = ['Displacement_Model_Id = ', num2str(did)];
    whereWind_sql = ['Wind_Coefficient_Model_Id = ', num2str(wid)];

    testcase.SQLWhereVessel = where_sql;
    testcase.SQLWhereEngine = whereEngine_sql;
    testcase.SQLWhereSpeedPower = whereSP_sql;
    testcase.SQLWhereSpeedPowerModel = whereSPModel_sql;
    testcase.SQLWhereDisplacement = whereDisp_sql;
    testcase.SQLWhereWind = whereWind_sql;
    
    end
end

methods(TestMethodSetup)
    
    function insertVessel2Read(testcase)
    % Ensure that vessel for testing read methods is in DB
        
    
    end
end

methods(Test)

end
end