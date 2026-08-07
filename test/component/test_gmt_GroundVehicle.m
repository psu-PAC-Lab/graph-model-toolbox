%% test_gmt_GroundVehicle
% component test class for gmt_GroundVehicle

classdef test_gmt_GroundVehicle < test_gmt_component

    methods (TestMethodSetup)
        function setup(testCase)
            testCase.ClassUnderTest = @gmt_GroundVehicle;
            testCase.initArg = [100];
            testCase.initArgFail = [100,200];
            testCase.ctrlInputs = [];
        end
    end

end