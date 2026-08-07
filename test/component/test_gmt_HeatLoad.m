%% test_gmt_HeatLoad
% component test class for gmt_HeatLoad

classdef test_gmt_HeatLoad < test_gmt_component

    methods (TestMethodSetup)
        function setup(testCase)
            testCase.ClassUnderTest = @gmt_HeatLoad;
            testCase.initArg = 300;
            testCase.initArgFail = [300,250];
        end
    end

end