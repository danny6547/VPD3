classdef testcModelName < matlab.unittest.TestCase & cMySQL
%testcModelName
%   Detailed explanation goes here

properties(Constant)
    
    TestDatabase = 'test15';
    TestModelName = 'Test Model';
    TestModelNameLong = repmat('a', [1, testcModelName.testObj.maxNameLength + 1]);
    TestModelDataName = 'Test Model 1';
    TestModelDataID = 0;
    TestModelData = {...
            10, 10e4, 0, 1e5;...
            12, 12e4, 0, 1e5;...
            14, 14e4, 0, 1e5;...
            };
    TestModelCoefficients = {1.5, 2, 0, 1e5};
    SpecMaxNameLength = 50;
%     Database = testcModelName.TestDatabase;
end

properties
    
    TestObj = testcModelName.testObj();
    TestDataObj = [];
end

methods(TestClassSetup)
    
    function deleteTestModelDataStart(testcase)
        
        testcase.deleteTestModelData();
    end
    
    function deleteTestModel(testcase)
        
        testObj = testcase.testObj();
        tab = 'Models';
        where = ['Name = ', '''' testcase.TestModelName ''''];
        testObj.deleteSQL(tab, where);
        
        tab = 'SpeedPower';
        where = ['Models_id = ', '''' num2str(testcase.TestModelDataID) ''''];
        testObj.deleteSQL(tab, where);
        
        tab = 'SpeedPowerCoefficients';
        where = ['Models_id = ', '''' num2str(testcase.TestModelDataID) ''''];
        testObj.deleteSQL(tab, where);
    end
    
    function insertTestModelDataStart(testcase)
        
        testcase.insertTestModelData();
    end
end

methods(TestMethodSetup)
    
    
end

methods(TestClassTeardown)
    
    function deleteTestModelDataEnd(testcase)
        
       testcase.deleteTestModelData();
    end
end

methods(Static)
    
    function obj = testObj()
    % Return object to be used in any tests 
        
        obj = cVesselSpeedPower();
        obj.Database = testcModelName.TestDatabase;
    end
    
    function isr = isRow(input_obj, table, where)
    % isRow True when specified row found in DB
        
        [~, res_t] = input_obj.select(table, '*', where);
        isr = ~isempty(res_t);
    end
end

methods
    
    function setName(obj, name)
    %  
        
        obj.TestObj.Name = name;
    
    end
    
    function deleteTestModelData(testcase)
        
        testObj = testcase.testObj();
        tab = 'Models';
        where = ['Name = ', ...
            testObj.encloseStringQuotes(testcase.TestModelDataName)];
        [~, mid_t] = testObj.select(tab, 'Models_id', where);
        testObj.deleteSQL(tab, where);
        
        if isempty(mid_t)
            
            return
        end
        
        tab = 'speedPower';
        where = ['Models_id = ', num2str([mid_t{:, :}])];
        testObj.deleteSQL(tab, where);
        
        tab = 'speedPowerCoefficients';
        where = ['Models_id = ', num2str([mid_t{:, :}])];
        testObj.deleteSQL(tab, where);
    end
    
    function insertTestModelData(testcase)
        
        testObj = testcase.testObj();
        
        tab = 'Models';
        cols = {'Name', 'Type'};
%         test_id = testcase.TestModelDataID;
        values = [{testcase.TestModelDataName}, testObj.Type];
        testObj.insertValues(tab, cols, values);
%         testObj.Models_id = test_id;
        testObj.Name = testcase.TestModelDataName;
        test_id = testObj.Models_id;
        
        tab = 'speedPower';
        cols = {'Models_id', 'Speed', 'Power', 'Trim', 'Displacement'};
        values = [repmat({test_id}, size(testcase.TestModelData, 1), 1), ...
            testcase.TestModelData];
        testObj.insertValues(tab, cols, values);
        
        tab = 'speedPowerCoefficients';
        cols = {'Models_id', 'Coefficient_A', 'Coefficient_B', 'Trim', 'Displacement'};
        values = [{test_id}, testcase.TestModelCoefficients];
        testObj.insertValues(tab, cols, values);
    end
end

methods(Test)

    function testmaxNameLength(testcase)
    % testmaxNameLength Method will return specified maximum length
    
    % Input
    exp_Len = testcase.SpecMaxNameLength;
    input_obj = testcase.TestObj;
    
    % Execute
    act_len = input_obj.maxNameLength();
    
    % Verify
    msg_Len = 'Maximum length of name should match that specified.';
    testcase.verifyEqual(act_len, exp_Len, msg_Len);
    
    end
    
    function testsetName(testcase)
    % testreserveModelName Method will write new row for Model in DB
    % 1. Test that DB table Models has row with Name assigning to prop Name
    % 2. Test for error when Name longer than maximumum length
    % 3. Assigning existing Name assigns data to corresponding properties.
    
    % 1.
    % Input
    input_obj = testcase.TestObj;
    input_Name = testcase.TestModelName;
    
    % Execute
    input_obj.Name = input_Name;
    
    % Verify
    table = 'Models';
    where = ['Name = ', '''' input_Name ''''];
    isrow = testcase.isRow(input_obj, table, where);
    msg = ['Method is expected to insert a new row into DB Table ''Models'''...
        'with Name given by input'];
    testcase.verifyTrue(isrow, msg);
    
    % 2.
    % Input
    input_obj = testcase.TestObj;
    input_Name = repmat('a', [1, input_obj.maxNameLength + 1]);
    
    % Verify
    exp_Errid = 'cMN:NameTooLong';
    msg_Err = ['An error relating to the value for property ''Name'' being '...
        'too long is expected when it''s length exceeeds the maximum.'];
    testcase.verifyError(@() testcase.setName(input_Name),...
        exp_Errid, msg_Err);
    
    % 3.
    % Input
%     testcase.insertTestModelData();
    clear input_obj
    input_obj = testcase.testObj;
    input_Name = testcase.TestModelDataName;
    
    % Execute
    input_obj.Name = input_Name;
    
    % Verify
    msg_data = ['Values in data Properties of OBJ are expected to match '...
        'those found for the corresponding Model Name in DB'];
    act_speed = input_obj.Speed;
    exp_speed = [testcase.TestModelData{:, 1}];
    testcase.verifyEqual(act_speed, exp_speed, msg_data);
    act_power = input_obj.Power;
    exp_power = [testcase.TestModelData{:, 2}];
    testcase.verifyEqual(act_power, exp_power, msg_data);
    end
    
    function testdelete(testcase)
    % Test that model deleted from DB when no data inserted
    % 1. Test that, when no matching model_id found in any OBJ.Table, model
    % is deleted from Table models.
        
        % Input
        input_obj = testcase.testObj;
        input_Name = 'Test Model testdelete';
        input_obj.Name = input_Name;
        id = input_obj.Models_id;
        
        % Execute
        input_obj.delete();
        
        % Verify
        emptyObj = testcase.testObj;
        data_msg = ['Data must be removed from all Tables given in '...
            'property ''DBTable'' for test to run.'];
        for ti = 1:numel(emptyObj.DBTable)
            
            isDataRow = testcase.isRow(emptyObj, emptyObj.DBTable{ti}, ...
                ['Models_id = ', num2str(id)]);
            testcase.assertFalse(isDataRow, data_msg);
        end
        
        isRow = testcase.isRow(emptyObj, 'Models', ...
            ['Name = ', emptyObj.encloseStringQuotes(input_Name)]);
        msg = ['Model Name expected to be not found in DB table ''Models'' '...
            'after object deleted when no data has been inserted into DB '...
            'tables given by property ''DBTable''.'];
        testcase.verifyFalse(isRow, msg);
    end
    
    function testinsertIntoTable(testcase)
    % testinsertIntoTable Method will write data to appropriate DB tables 
    % 1. Test that when property 'Name' empty, an error occurs.
    % 2. Test that when property 'Name' non-empty, data from all properties
    % whose names match the fields of tables in property 'DBTable' will be
    % written to those fields in those tables.
    
    % 1.
    % Input
    data_c = testcase.TestModelData;
    input_obj = testcase.testObj;
    input_obj.Speed = [data_c{:, 1}];
    input_obj.Power = [data_c{:, 2}];
    
    % Verify
    err_id = 'cMN:NameMissing';
    err_msg = ['Error expected when attempt to insert model data without'...
        ' Name.'];
    testcase.verifyError(@() input_obj.insertIntoTable, err_id, err_msg);
    
    % 2.
    % Input
    testcase.deleteTestModelData();
    input_obj = testcase.testObj;
    input_obj.Name = testcase.TestModelDataName;
    data_c = testcase.TestModelData;
    input_obj.Speed = [data_c{:, 1}];
    input_obj.Power = [data_c{:, 2}];
    input_obj.Trim = data_c{1, 3};
    input_obj.Displacement = data_c{1, 4};
    input_obj.Coefficients = [testcase.TestModelCoefficients{1:2}];
    
    % Execute
    input_obj.insertIntoTable();
    
    % Verify
    msg_data = ['Values from object''s data fields are expected to be '...
        'inserted into the tables given in ''DBTable'' property at any '...
        'fields matching the properties of OBJ'];
    where_sql = ['Models_id = ', num2str(input_obj.Models_id)];
    for ti = 1:numel(input_obj.DBTable)
        
        isrow = testcase.isRow(input_obj, input_obj.DBTable{ti}, where_sql);
        testcase.verifyTrue(isrow, msg_data);
    end
    
    % Clean up
%     testcase.insertTestModelData();
    
    end
end

% Input

% Execute

% Verify

end