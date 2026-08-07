%% test_gmt_HeatExchanger
% component test class for test_gmt_HeatExchanger

classdef test_gmt_HeatExchanger < test_gmt_component

    methods (TestMethodSetup)
        function setup(testCase)
            testCase.ClassUnderTest = @gmt_HeatExchanger;
            testCase.initArg = [300,280,400];
            testCase.initArgFail =  [300,280,400,300];
        end
    end

end