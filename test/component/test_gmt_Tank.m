%% test_gmt_tank
% component test class for gmt_Tank

classdef test_gmt_Tank < test_gmt_component

    methods (TestMethodSetup)
        function setup(testCase)
            testCase.ClassUnderTest = @gmt_Tank;
            testCase.initArg = [300,6000];
            testCase.initArgFail = [300,6000,8000];
            testCase.ctrlInputs = [0.10, 0.15];
        end
    end

end