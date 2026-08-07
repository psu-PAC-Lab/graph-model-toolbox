%% test_gmt_WyeToDelta
% component test class for gmt_GroundVehicle

classdef test_gmt_WyeToDelta < test_gmt_component

    methods (TestMethodSetup)
        function setup(testCase)
            testCase.ClassUnderTest = @gmt_WyeToDelta;
            testCase.initArg = [100,200];
            testCase.initArgFail = [100,200,300];
            testCase.ctrlInputs = [];
        end
    end

end