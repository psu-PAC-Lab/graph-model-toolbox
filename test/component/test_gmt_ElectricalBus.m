%% test_gmt_ElectricalBus
% component test class for gmt_ElectricalBus

classdef test_gmt_ElectricalBus < test_gmt_component

    methods (TestMethodSetup)
        function setup(testCase)
            testCase.ClassUnderTest = @gmt_ElectricalBus;
            testCase.initArg = [300,280,400,1000];
            testCase.initArgFail = [300,280,400,1000,1200];
            testCase.varInputs = {3,2};
        end
    end

end