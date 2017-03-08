classdef testcVessel < matlab.unittest.TestCase
%TESTCVESSEL
%   Detailed explanation goes here

properties
    
    Connection = [];
    MySQL = cMySQL();
    
    ReadFromTableInputs = { {'testReadFrom'} };
    ReadFromTableVales = struct('Owner', {'A', 'B'}, ...
                                'Draft_Design', num2cell([1.2345, -1]));
    
end

methods(TestClassSetup)
    
    function connect(testcase)
    % Create connection object to test DB
    
        testcase.Connection = cConnectMySQLDB('Server', 'localhost',...
                                        'Database',  'hull_performance',...
                                        'UserID',  'root',...
                                        'Password',  'HullPerf2016'...
                                              );
    end
    
%     function createTestDBRequirements(testcase)
%     % Check that all DB components exist and if not, create them.
%     
%         
%     
%     end
    
    function requirementsReadFromTable(testcase)
    % Create DB requirements for method testreadFromTable
    
        table = 'testReadFrom';
        cols{1} = 'Owner';
        cols{2} = 'Draft_Design';
        types{1} = 'TEXT';
        types{2} = 'DOUBLE(10, 5)';
        
        tblExist_ch = ['Table ' table ' already exists'];
        
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
            {testcase.ReadFromTableVales.Draft_Design}'])
        
    end
    
end

methods(TestClassTeardown)
    
    function disconnect(testcase)
    % Create connection object to test DB
    
        testcase.Connection = testcase.Connection.disconnect;
        testcase.Connection = [];
    
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
    [uniqueData, uniI] = unique(nonUniDate);
    [expUni.(inputIndex)] = deal(uniqueData);
    
    for ii = 1:numel(inputProp)
        
        inData = expUni.(inputProp{ii});
        [expUni.(inputProp{ii})] = deal(inData(uniI));
    end
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
    % given by OBJ which match the column names of TABLE.
    % 2. Test that, when input IDENTIFIER is given, the length of the 
    % output will equal the number of unique elements of the field matching
    % INDENTIFIER in TABLE, and all elements of COLUMNS will be added as
    % vectors to the appropriate properties of OBJ.
    
    % 1
    % Input
    ownerAB_c = {testcase.ReadFromTableVales.Owner};
    draft_v = {testcase.ReadFromTableVales.Draft_Design};
    
    expObj = cVessel();
    actObj = cVessel();
    for ii = 1:length(ownerAB_c)
    
        expObj(ii).Owner = ownerAB_c{ii};
        expObj(ii).Draft_Design = draft_v(ii);
    end
    
    inputs_c = testcase.ReadFromTableInputs{1};
    
    % Execute
    actObj = actObj.readFromTable(inputs_c{:});
    
    % Verify
    msgObj = ['Objects properties which match those of the fields of '...
        'TABLE are expected to be populated with data from TABLE.'];
    testcase.verifyEqual(actObj, expObj, msgObj);
    
    end
end

end