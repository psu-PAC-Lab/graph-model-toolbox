%% test_gmt_DCMotor
% component test class for gmt_DCMotor

classdef test_gmt_DCMotor < test_gmt_component

    methods (TestMethodSetup)
        function setup(testCase)
            testCase.ClassUnderTest = @gmt_DCMotor;
            testCase.initArg = [300,280,400];
            testCase.initArgFail = [300,280,400,500];
        end
    end

end