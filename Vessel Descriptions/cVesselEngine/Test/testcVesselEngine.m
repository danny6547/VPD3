classdef testcVesselEngine < matlab.unittest.TestCase
%TESTCSHIPENGINE
%   Detailed explanation goes here

properties
end

methods(Test)

    function testfitData2Quadratic(testcase)
    % Test that method will fit SFOC, Power data to a quadratic function.
    % 1. Test that the object returned by the method will have coefficients
    % calculated using the method of least squares on the input SFOC and
    % PERCENTMCR*MCR/100, and that all relevant data has been added to the
    % object properties.
    
    % 1
    % Input

    % Execute

    % Verify

    
    end
    
    function testlimitsOfData(testcase)
    % Test that method will return limits of SFOC, Power data in properties
    % 1. Test that method will return the appropriate minimum of input FOC
    % in output LowestFOCph and minima and maxima respectively of input
    % POWER in outputs LowestPower and HighestPower.
        
    % 1
    % Input
    szIn = [1, 3];
    SFOC = abs(randn(szIn)) * 1e2;
    MCR = max(SFOC);
    input_SFOC = (SFOC/MCR) * 100;
    input_Power = abs(randn(szIn)) * 1e4;
    input_obj = cVesselEngine();
    input_obj.Power = input_Power;
    input_obj.SFOC = input_SFOC;
    FOC = input_SFOC.*input_Power;
    expLowFOC = min(FOC);
    expLowPow = min(input_Power);
    expHiPow = max(input_Power);

    % Execute
    [actLowFOC, actLowPow, actHiPow] = input_obj.limitsOfData;

    % Verify
    msgLowFOC = 'First output is expected to be the minimum FOC per hour.';
    msgLowPow = 'Second output is expected to be the minimum power value in kW';
    msgHiPow = ['Third output is expected to be the highest value of '...
        'power, in kW.'];
    testcase.verifyEqual(actLowFOC, expLowFOC, msgLowFOC);
    testcase.verifyEqual(actLowPow, expLowPow, msgLowPow);
    testcase.verifyEqual(actHiPow, expHiPow, msgHiPow);
        
    end
end

end

% Input

% Execute

% Verify