classdef testcVesselSpeedPower < matlab.unittest.TestCase
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
    InsertIntoSpeedPowerValues = struct('IMO_Vessel_Number', ...
                                num2cell([1234567, 1234567, 1234567, 7654321, 7654321])', ...
                                'Speed', ...
                                num2cell([5, 10, 5, 7, 12])', ...
                                'Power', ...
                                num2cell([1e4, 5e4, 3e4, 2e4, 9e4])', ...
                                'Trim', ...
                                num2cell([1, 1, 0, -1.5, -1.5])', ...
                                'Displacement', ...
                                num2cell([1e5, 1e5, 2e5, 1e4, 1e4])');
    InsertIntoSpeedPowerCoefficientsValues = ...
                                struct('IMO_Vessel_Number', ...
                                num2cell([1234567, 1234567, 7654321])', ...
                                'Exponent_A', ...
                                num2cell(0.7:0.1:0.9)', ...
                                'Exponent_B', ...
                                num2cell(100:100:300)', ...
                                'R_Squared', ...
                                num2cell(0.9:0.03:0.96)', ...
                                'Trim', ...
                                num2cell([1, 0, -1.5])', ...
                                'Displacement', ...
                                num2cell([1e5, 1e5, 2e5])');
    InsertIntoWindCoefficientsValues = ...
                                struct('IMO_Vessel_Number', ...
                                num2cell([1234567, 7654321])', ...
                                'Start_Direction', ...
                                num2cell([45, 90])', ...
                                'End_Direction', ...
                                num2cell([90, 135])', ...
                                'Coefficient', ...
                                num2cell([2, 3])');
    InsertIntoSFOCCoefficientsValues = ...
                                struct('Engine_Model', ...
                                {'Test Engine 1', 'Test Engine 2'}', ...
                                'X0', ...
                                num2cell([1, 1.5])', ...
                                'X1', ...
                                num2cell([0, 1])', ...
                                'X2', ...
                                num2cell([2, 3])',...
                                'Minimum_FOC_ph', ...
                                num2cell([450, 90])', ...
                                'Lowest_Given_Brake_Power', ...
                                num2cell([9000, 1350])', ...
                                'Highest_Given_Brake_Power', ...
                                num2cell([2e4, 1.5e4])');
	SeaTrialGraphData = load(testcVesselSpeedPower.SeaTrialGraphDataFile, 'spgd');
end

properties(Constant)
    
	SeaTrialGraphDataFile = fullfile(fileparts(mfilename('fullpath')), 'Test Data',...
        'SeaTrialGraphData.mat'); 
end

methods
    
%     function vessel = testVessel(testcase)
%     % Return cVessel object connected to test database
%     
%         vessel = cVessel();
%         vessel = vessel.test;
%         vessel = vessel.disconnect;
%         vessel.Connection = testcase.MySQL.Connection;
%     end
%     
%     function requirementsReadFromTable(testcase)
%     % Create DB requirements for method testreadFromTable
%     
%         table = 'testReadFrom';
%         cols{1} = 'Owner';
%         cols{2} = 'Draft_Design';
%         cols{3} = 'IMO_Vessel_Number';
%         types{1} = 'TEXT';
%         types{2} = 'DOUBLE(10, 5)';
%         types{3} = 'INT(7)';
%         
%         tblExist_ch = ['Table ''' lower(table) ''' already exists'];
%         
%         % Drop table
%         testcase.MySQL.drop('TABLE', table, true);
%         
%         % Create table
%         try
%             testcase.MySQL.createTable(table, cols, types);
%             
%         catch e
%             
%             if isempty(strfind(e.message, tblExist_ch))
%                 
%                 rethrow(e);
%             end
%         end
%         
%         % Insert data
%         testcase.MySQL.insertValues(table, cols, ...
%             [{testcase.ReadFromTableVales.Owner}', ...
%             {testcase.ReadFromTableVales.Draft_Design}', ...
%             {testcase.ReadFromTableVales.IMO_Vessel_Number}'])
%         
%     end
%     
%     function requirementsInsertIntoTable(testcase)
%     % Create DB requirements for method testinsertIntoTable
%         
%         table = testcase.InsertIntoTableInputs{1}{1};
%         cols{1} = 'Owner';
%         cols{2} = 'Draft_Design';
%         cols{3} = 'IMO_Vessel_Number';
%         types{1} = 'TEXT';
%         types{2} = 'DOUBLE(10, 5)';
%         types{3} = 'INT(7)';
%         
%         % Drop table
%         testcase.MySQL.drop('TABLE', table, true);
%         
%         % Create table
%         testcase.MySQL.createTable(table, cols, types);
%     end
%     
%     function requirementsinsertIntoDryDockDates(testcase)
%     % Create DB requirements for method testinsertIntoDryDockDates
%         
%         % Delete any existing rows in the test table for test vessels
%         testIMO_c = {testcase.InsertIntoDryDockDatesValues.IMO_Vessel_Number};
%         testIMO_ch = strjoin(cellfun(@num2str, testIMO_c, 'Uni', 0), ', ');
%         testcase.MySQL.execute(['DELETE FROM DryDockDates WHERE '...
%             'IMO_Vessel_Number IN (', testIMO_ch ,')']);
%         
%     end
%     
%     function requirementsinsertIntoSpeedPower(testcase)
%     % Create DB requirements for method testinsertIntoDryDockDates
%         
%         % Delete any existing rows in the test table for test vessels
%         testIMO_c = {testcase.InsertIntoSpeedPowerValues.IMO_Vessel_Number};
%         testIMO_ch = strjoin(cellfun(@num2str, testIMO_c, 'Uni', 0), ', ');
%         testcase.MySQL.execute(['DELETE FROM SpeedPower WHERE '...
%             'IMO_Vessel_Number IN (', testIMO_ch ,')']);
%         
%     end
%     
%     function requirementsinsertIntoSpeedPowerCoefficients(testcase)
%     % Create DB requirements for method testinsertIntoDryDockDates
%         
%         % Delete any existing rows in the test table for test vessels
%         testIMO_c = {testcase...
%             .InsertIntoSpeedPowerValuesCoefficients.IMO_Vessel_Number};
%         testIMO_ch = strjoin(cellfun(@num2str, testIMO_c, 'Uni', 0), ', ');
%         testcase.MySQL.execute(['DELETE FROM SpeedPowerCoefficients WHERE '...
%             'IMO_Vessel_Number IN (', testIMO_ch ,')']);
%         
%     end
%     
%     function requirementsinsertIntoSFOCCoefficients(testcase)
%     % Create DB requirements for method testinsertIntoDryDockDates
%         
%         % Delete any existing rows in the test table for test vessels
%         testModel_c = {testcase...
%             .InsertIntoSpeedPowerValuesCoefficients.Engine_Model};
%         testModel_ch = strjoin(testModel_c, ', ');
%         testcase.MySQL.execute(['DELETE FROM SFOCCoefficients WHERE '...
%             'Engine_Model IN (', testModel_ch ,')']);
%         
%     end
end

methods(TestClassSetup)
%     
%     function connect(testcase)
%     % Create connection object to test DB
%     
%         testcase.MySQL = testcase.MySQL.test;
%         
%     end
%     
%     function requirements(testcase)
%     % Ensure requirements for all methods are met
%     
%         requirementsReadFromTable(testcase);
%         requirementsInsertIntoTable(testcase);
%         requirementsinsertIntoDryDockDates(testcase);
%         requirementsinsertIntoSpeedPower(testcase);
%         
%     end
end

methods(TestClassTeardown)
    
%     function disconnect(testcase)
%     % Create connection object to test DB
%     
%         testcase.MySQL = testcase.MySQL.disconnect;
%     
%     end
    
end

methods(Test)

    function testFit(testcase)
    % Test that data fitted from tabular data matches graph data in report
    % 1. Test that the fit of data assigned to properties Speed and Power
    % matches that of the graph given in the corresponding report. The
    % corrected speed and power data will be fitted according to equation
    % F.3 in ISO15016 and the speeds evaluated at the given power values.
    % The test passes when the relative difference in corresponsing powers
    % is below the threshold.
    
    % Input
    testdata = testcase.SeaTrialGraphData.spgd;
    numTest = size(testdata, 1);
    input_obj = cVesselSpeedPower([1, numTest]);
    exp_pwr = cell(1, size(testdata, 1));
    
    for ti = 1:numTest
        
        input_obj(ti).Speed = testdata{ti, 1};
        input_obj(ti).Power = testdata{ti, 2};
        
        exp_pwr{ti} = testdata{ti, 4};
    end
    
    % Execute
%     input_obj.fit();
    
    % Verify
    evalF3_f = @(speed, a, b, q) a + b.*(speed.^q);
    for ti = 1:numTest
        
        currCoeffs = testdata{ti, 5};
%         currCoeffs = input_obj(ti).Coefficients;
        a = currCoeffs(1);
        b = currCoeffs(2);
        q = currCoeffs(3);
        currSpeed = testdata{ti, 3};
        
        act_pwr = evalF3_f(currSpeed, a, b, q);
        tol = 1e-2;
        curr_test = testdata{ti, 6};
        msg_pwr = ['Power calculated from fitted equation should match that '...
            'of the corresponding speed, power curve in the Sea Trial '...
            'report. Failure occured for Example: ', curr_test];
        testcase.verifyEqual(act_pwr, [exp_pwr{ti}], 'RelTol', tol, msg_pwr);
    end
    end
end

% Input

% Execute

% Verify

end