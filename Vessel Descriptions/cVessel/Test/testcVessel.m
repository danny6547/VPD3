classdef testcVessel < matlab.unittest.TestCase
%TESTCVESSEL
%   Detailed explanation goes here

properties
    
    MySQL = cMySQL();
    ReadFromTableInputs = { {'testReadFrom', 'IMO_Vessel_Number'} };
    ReadFromTableVales = struct('Owner', {'A', 'B'}, ...
                                'Draft_Design', num2cell([1.2345, -1]),...
                                'IMO_Vessel_Number', num2cell([1234567, 7654321]));
    InsertIntoTableInputs = { {'testInsertInto' } };
    InsertIntoDryDockDatesValues = struct('IMO_Vessel_Number', num2cell([1234567, 7654321])', ...
                                'StartDate', cellstr(datestr(now:now+1, 'yyyy-mm-dd')),...
                                'EndDate', cellstr(datestr(now+2:now+3, 'yyyy-mm-dd')));
    
end

methods
    
    function vessel = testVessel(testcase)
    % Return cVessel object connected to test database
    
        vessel = cVessel();
        vessel = vessel.test;
        vessel = vessel.disconnect;
        vessel.Connection = testcase.MySQL.Connection;
    end
    
    function requirementsReadFromTable(testcase)
    % Create DB requirements for method testreadFromTable
    
        table = 'testReadFrom';
        cols{1} = 'Owner';
        cols{2} = 'Draft_Design';
        cols{3} = 'IMO_Vessel_Number';
        types{1} = 'TEXT';
        types{2} = 'DOUBLE(10, 5)';
        types{3} = 'INT(7)';
        
        tblExist_ch = ['Table ''' lower(table) ''' already exists'];
        
        % Drop table
        testcase.MySQL.drop('TABLE', table, true);
        
        % Create table
        try
            testcase.MySQL.createTable(table, cols, types);
            
        catch e
            
            if isempty(strfind(e.message, tblExist_ch))
                
                rethrow(e);
            end
        end
        
        % Insert data
        testcase.MySQL.insertValues(table, cols, ...
            [{testcase.ReadFromTableVales.Owner}', ...
            {testcase.ReadFromTableVales.Draft_Design}', ...
            {testcase.ReadFromTableVales.IMO_Vessel_Number}'])
        
    end
    
    function requirementsInsertIntoTable(testcase)
    % Create DB requirements for method testinsertIntoTable
        
        table = testcase.InsertIntoTableInputs{1}{1};
        cols{1} = 'Owner';
        cols{2} = 'Draft_Design';
        cols{3} = 'IMO_Vessel_Number';
        types{1} = 'TEXT';
        types{2} = 'DOUBLE(10, 5)';
        types{3} = 'INT(7)';
        
        % Drop table
        testcase.MySQL.drop('TABLE', table, true);
        
        % Create table
        testcase.MySQL.createTable(table, cols, types);
    end
    
    function requirementsinsertIntoDryDockDates(testcase)
    % Create DB requirements for method testinsertIntoDryDockDates
        
        % Delete any existing rows in the test table for test vessels
        testIMO_c = [testcase.InsertIntoDryDockDatesValues.IMO_Vessel_Number];
        testIMO_ch = strjoin(cellfun(@num2str, testIMO_c), ', ');
        testcase.MySQL.execute(['DELETE FROM DryDockDates WHERE '...
            'IMO_Vessel_Number IN (', testIMO_ch ,')']);
        
    end
end

methods(TestClassSetup)
    
    function connect(testcase)
    % Create connection object to test DB
    
        testcase.MySQL = testcase.MySQL.test;
        
    end
    
    function requirements(testcase)
    % Ensure requirements for all methods are met
    
        requirementsReadFromTable(testcase);
        requirementsInsertIntoTable(testcase);
        
    end
end

methods(TestClassTeardown)
    
    function disconnect(testcase)
    % Create connection object to test DB
    
        testcase.MySQL = testcase.MySQL.disconnect;
    
    end
    
end

methods(Test)

    function testfilterOnUniqueIndex(testcase)
    % testfilterOnUniqueIndex Test that method will remove duplicate values
    % of the index data and the corresponding elements of the other data.
    % 1. Test that, when duplicate elements exist for the data in property
    % given by input UNIQUE, the duplicates will be removed and the
    % corresponding elements from the properties given by PROPS will also
    % be deleted.
    
    % 1
    % Input
    inputIndex = 'DateTime_UTC';
    inputProp = {'Speed_Index', 'Performance_Index'};
    nonUniDate = repmat(now-1:now+1, [3, 1]);
    nonUniDate = nonUniDate(:);
    szData = [9, 1];
    shipdata = repmat(struct('DateTime_UTC', nonUniDate, 'Speed_Index', ...
        randn(szData), 'Performance_Index', randn(szData), ...
        'IMO_Vessel_Number', 1234567), [2, 2]);
    inputObj = cVessel('ShipData', shipdata, 'Name', 'Example Vessel');
    expUni = inputObj;
    actUni = inputObj;
    uniqueData = unique(nonUniDate);
    [expUni.(inputIndex)] = deal(uniqueData);
    
%     for ii = 1:numel(inputProp)
%         
%         inData = expUni.(inputProp{ii});
%         [expUni.(inputProp{ii})] = deal(inData(uniI));
%     end
    expUni = expUni.iterReset;
    
    % Execute
    actUni = actUni.filterOnUniqueIndex(inputIndex, inputProp);
    
    % Verify
    msgUni = ['Non-unique elements are expected to be removed from data in '...
        'properties given by UNIQUE and PROPS'];
    testcase.verifyEqual(actUni, expUni, msgUni);
    
    end
    
    function testreadFromTable(testcase)
    % Test that method will read from DB table into object properties
    % 1. Test that, for the given database, method will read values from
    % the table given by input string TABLE into the properties of object
    % given by OBJ which match the column names of TABLE at the rows where
    % values match those of OBJ property IDENTIFIER.
    
    % 1
    % Input
    expObj = testcase.testVessel;
    expObj = repmat(expObj, size(testcase.ReadFromTableVales));
    actObj = testcase.testVessel;
    value_c = struct2cell(testcase.ReadFromTableVales);
    prop_c = fieldnames(testcase.ReadFromTableVales);
    
    for ii = 1:numel(testcase.ReadFromTableVales)
        for pi = 1:length(prop_c)
            
            expObj(ii).(prop_c{pi}) = value_c{pi, ii};
        end
    end
    
    inputs_c = testcase.ReadFromTableInputs{1};
    actObj = repmat(actObj, [1, 2]);
    actObj(1).IMO_Vessel_Number = ...
        testcase.ReadFromTableVales(1).IMO_Vessel_Number;
    actObj(2).IMO_Vessel_Number = ...
        testcase.ReadFromTableVales(2).IMO_Vessel_Number;
    
    % Execute
    actObj = actObj.readFromTable(inputs_c{:});
    
    % Verify
    msgObj = ['Objects properties which match those of the fields of '...
        'TABLE are expected to be populated with data from TABLE.'];
    testcase.verifyEqual(actObj, expObj, msgObj);
    
    end
    
    function testinsertIntoTable(testcase)
    % Test that method will insert data from object into table
    % 1. Test that method will, for each property of OBJ matching the field
    % names of input TABLE, insert values into the appropriate rows.
    
    % 1
    % Input
    expTable = struct2table(testcase.ReadFromTableVales);
    testDBTable = testcase.ReadFromTableInputs{1}{1};
    inputObj = testcase.testVessel;
    prop_c = fieldnames(testcase.ReadFromTableVales);
    value_c = struct2cell(testcase.ReadFromTableVales);
    
    for ii = 1:numel(testcase.ReadFromTableVales)
        for pi = 1:length(prop_c)
            
            inputObj(ii).(prop_c{pi}) = value_c{pi, ii};
        end
    end
    
    input_c = testcase.InsertIntoTableInputs{1};
    
    % Execute
    inputObj.insertIntoTable(input_c{:});
    
    % Verify
    [~, actTable] = testcase.MySQL.select(testDBTable, ...
        expTable.Properties.VariableNames);
    expTable.Properties.VariableNames = ...
        lower(expTable.Properties.VariableNames);
    msgTable = ['Data read from DB table is expected to match that in input'...
        ' OBJ properties.'];
    testcase.verifyEqual(actTable, expTable, msgTable);
    
    end
    
    function testinsertIntoDryDockDates(testcase)
    % Test that method will insert all dry docking dates given into table
    % "DryDockDates".
    % 1. Test that each cVesselDryDock in property DryDockDates of input
    % OBJ will have its property data assigned to the similarly-named field
    % of table "DryDockDates".
    
    % 1.
    % Input
    expTable = struct2table(testcase.InsertIntoDryDockDatesValues);
    testDBTable = 'DryDockDates';
    inputObj = testcase.testVessel;
    
    numDDi = numel(testcase.InsertIntoDryDockDatesValues);
    inputDDD(numDDi) = cVesselDryDockDates();
    for si = 1:numDDi
        
        inputDDD(si).IMO_Vessel_Number = ...
            testcase.InsertIntoDryDockDatesValues(si).IMO_Vessel_Number;
        inputDDD(si) = inputDDD(si).assignDates(...
            testcase.InsertIntoDryDockDatesValues(si).StartDate,...
            testcase.InsertIntoDryDockDatesValues(si).EndDate, ...
            'yyyy-mm-dd');
    end
    inputObj.DryDockDates = inputDDD;
    
    [inputObj, ~, sql] = inputObj.select(testDBTable, ...
        {'imo_vessel_number', 'startdate', 'enddate'});
    [~, sql] = inputObj.determinateSQL(sql);
    sql = [sql, ' ORDER BY id DESC LIMIT 2;'];
    
    % Execute
    inputObj = inputObj.insertIntoDryDockDates();
    
    % Verify
%     [~, actTable] = testcase.MySQL.select(testDBTable, ...
%         expTable.Properties.VariableNames);
    [outSt, outC] = inputObj.executeIfOneOutput(nargout, sql, 1);
    actTable = cell2table(outC, 'VariableNames', fieldnames(outSt));
    expTable.Properties.VariableNames = ...
        lower(expTable.Properties.VariableNames);
    
    [inputDDD(:).DateStrFormat] = deal('dd-mm-yyyy');
    expTable.startdate = {inputDDD.StartDate}';
    expTable.enddate = {inputDDD.EndDate}';
    expTable = flipud(expTable);
    msgTable = 'Table of dry docking dates should match that input.';
    testcase.verifyEqual(actTable, expTable, msgTable);
    
    end
end

end