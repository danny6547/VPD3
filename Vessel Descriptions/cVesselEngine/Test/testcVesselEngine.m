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
    % POWERPCT*MCR/100, and that all relevant data has been added to the
    % object properties.
    
    % 1
    % Input
    szIn = [1, 1e3];
    FOC = abs(randn(szIn)) * 1e3;
    a = 1.1; b = 2; c = 0.5;
    Power = FOC.^2.*a + FOC.*b + c;
    input_MCR = max(Power);
    input_SFOC = FOC./Power;
    input_Power = (Power/input_MCR) * 100;
    input_obj = cVesselEngine();
    
    expObj = cVesselEngine();
    expObj.MCR = input_MCR;
    expObj.Power = Power;
    expObj.SFOC = input_SFOC;

    expObj.X0 = c;
    expObj.X1 = b;
    expObj.X2 = a;
    expObj.limitsOfData;
    
    % Execute
    actObj = input_obj.fitData2Quadratic(input_MCR, input_SFOC, input_Power);
    
    % Verify
    msgObj = ['Object is expected to have coefficient values assigned to'...
        ' properties after method call.'];
    reltol = 1e-8;
    testcase.verifyEqual(actObj.X0, expObj.X0, 'RelTol', reltol, msgObj);
    testcase.verifyEqual(actObj.X1, expObj.X1, 'RelTol', reltol, msgObj);
    testcase.verifyEqual(actObj.X2, expObj.X2, 'RelTol', reltol, msgObj);
    
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
    Power = abs(randn(szIn)) * 1e4;
    input_MCR = max(Power);
    input_SFOC = SFOC;
    input_Power = (Power/input_MCR) * 100;
    input_obj = cVesselEngine();
    input_obj.MCR = input_MCR;
    input_obj.Power = input_Power;
    input_obj.SFOC = input_SFOC;
    FOC = input_SFOC.*Power;
    expLowFOC = min(FOC);
    expLowPow = min(Power);
    expHiPow = max(Power);
    
    % Execute
    [~, actLowFOC, actLowPow, actHiPow] = input_obj.limitsOfData;
    
    % Verify
    msgLowFOC = 'First output is expected to be the minimum FOC per hour.';
    msgLowPow = 'Second output is expected to be the minimum power value in kW';
    msgHiPow = ['Third output is expected to be the highest value of '...
        'power, in kW.'];
    reltol = 1e-8;
    testcase.verifyEqual(actLowFOC, expLowFOC, 'RelTol', reltol, msgLowFOC);
    testcase.verifyEqual(actLowPow, expLowPow, 'RelTol', reltol, msgLowPow);
    testcase.verifyEqual(actHiPow, expHiPow, 'RelTol', reltol, msgHiPow);
    
    end
    
end

end

% Input

% Execute

% Verify