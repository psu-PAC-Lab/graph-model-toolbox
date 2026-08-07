%% test_gmt_Battery
% component test class for gmt_Battery

classdef test_gmt_Battery < test_gmt_component

    methods (TestMethodSetup)
        function setup(testCase)
            testCase.ClassUnderTest = @gmt_Battery;
            testCase.initArg = [300,280,400,1000,2000];
            testCase.initArgFail = [300,280,400,1000,2000,2500];
        end
    end

end