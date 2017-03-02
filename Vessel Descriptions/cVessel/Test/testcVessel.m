classdef testcVessel < matlab.unittest.TestCase
%TESTCVESSEL
%   Detailed explanation goes here

properties
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
end

% Input

% Execute

% Verify
end