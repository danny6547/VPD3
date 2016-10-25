classdef testsortOnDateTime < matlab.unittest.TestCase & testISO19030
%TESTSORTONDATETIME
%   Detailed explanation goes here

properties
end

methods(Test)

    function firsttest(testcase)
        
        x = testcase.x;
        y = 2;
        testcase.verifyEqual(x, y);
        
    end
    
end

end

