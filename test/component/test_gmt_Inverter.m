%% test_gmt_Inverter
% component test class for gmt_Inverter

classdef test_gmt_Inverter < test_gmt_component

    methods (TestMethodSetup)
        function setup(testCase)
            testCase.ClassUnderTest = @gmt_Inverter;
            testCase.initArg = [300,250,375];
            testCase.initArgFail = [300,250,375,400];
        end
    end

end