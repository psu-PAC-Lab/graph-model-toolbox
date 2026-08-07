%% test_gmt_ColdPlate
% component test class for gmt_ColdPlate

classdef test_gmt_ColdPlate < test_gmt_component

    methods (TestMethodSetup)
        function setup(testCase)
            testCase.ClassUnderTest = @gmt_ColdPlate;
            testCase.initArg = [300,280];
            testCase.initArgFail = [300,280,400];
        end
    end

end