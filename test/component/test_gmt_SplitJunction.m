%% test_gmt_SplitJunction
% component test class for gmt_SplitJunction

classdef test_gmt_SplitJunction < test_gmt_component

    methods (TestMethodSetup)
        function setup(testCase)
            testCase.ClassUnderTest = @gmt_SplitJunction;
            testCase.initArg = 300;
            testCase.initArgFail = [300,250];
            testCase.varInputs = {3,2};
        end
    end

end