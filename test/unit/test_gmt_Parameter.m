%% test_gmt_Parameter
% Unit tests for the gmt_Parameter class.
% Run with: results = runtests('test_gmt_Parameter')
classdef test_gmt_Parameter < matlab.unittest.TestCase

    %% ---------------------------------------------------------------
    %  Shared test fixtures
    %  ---------------------------------------------------------------
    properties (Constant)
        % Minimal valid inputs reused across tests
        Desc     = "Test Parameter"
        Var      = "x"
        ScalarData = 3.14

        % Lookup table struct (two independent vars + one output)
        LookupData = struct('rpm',  linspace(0, 6000, 10)', ...
                            'temp', linspace(-20, 120, 10)', ...
                            'torque', rand(10,1))

        % A tiny stub network object (just a struct to satisfy ~isempty)
        NetData    = struct('Layers', {{}}, 'Weights', [])
    end

    %% ===============================================================
    %  1. CONSTRUCTOR – required arguments
    %% ===============================================================
    methods (Test, TestTags = {'Constructor','Required'})

        function test_constructorSetsDescription(tc)
            obj = gmt_Parameter(tc.Desc, tc.Var, tc.ScalarData);
            tc.verifyEqual(obj.Description, tc.Desc, ...
                "Description property not set correctly.")
        end

        function test_constructorSetsVariable(tc)
            obj = gmt_Parameter(tc.Desc, tc.Var, tc.ScalarData);
            tc.verifyEqual(obj.Variable, tc.Var, ...
                "Variable property not set correctly.")
        end

        function test_constructorSetsData(tc)
            obj = gmt_Parameter(tc.Desc, tc.Var, tc.ScalarData);
            tc.verifyEqual(obj.Data, tc.ScalarData, ...
                "Data property not set correctly.")
        end

        function test_constructorEmptyData(tc)
            obj = gmt_Parameter(tc.Desc, tc.Var, []);
            tc.verifyEmpty(obj.Data, ...
                "Data should be empty when [] is passed.")
        end

    end

    %% ===============================================================
    %  2. CONSTRUCTOR – optional name-value arguments
    %% ===============================================================
    methods (Test, TestTags = {'Constructor','Optional'})

        function test_defaultOptimizationIsFalse(tc)
            obj = gmt_Parameter(tc.Desc, tc.Var, tc.ScalarData);
            tc.verifyFalse(obj.Optimization, ...
                "Default Optimization should be false.")
        end

        function test_defaultCommonIsFalse(tc)
            obj = gmt_Parameter(tc.Desc, tc.Var, tc.ScalarData);
            tc.verifyFalse(obj.Common, ...
                "Default Common should be false.")
        end

        function test_setOptimizationTrue(tc)
            obj = gmt_Parameter(tc.Desc, tc.Var, tc.ScalarData, ...
                'Optimization', true);
            tc.verifyTrue(obj.Optimization, ...
                "Optimization should be true when explicitly set.")
        end

        function test_setCommonTrue(tc)
            obj = gmt_Parameter(tc.Desc, tc.Var, tc.ScalarData, ...
                'Common', true);
            tc.verifyTrue(obj.Common, ...
                "Common should be true when explicitly set.")
        end

        function test_setUnits(tc)
            obj = gmt_Parameter(tc.Desc, tc.Var, tc.ScalarData, ...
                'Units', "rpm");
            tc.verifyEqual(obj.Units, "rpm", ...
                "Units should match the value passed in.")
        end

        function test_defaultUnitsIsEmpty(tc)
            obj = gmt_Parameter(tc.Desc, tc.Var, tc.ScalarData);
            % Units is a string property with no default assignment when
            % Units is empty – it remains unset (missing string).
            tc.verifyTrue(isempty(obj.Units) || ismissing(obj.Units), ...
                "Units should be empty/missing when not supplied.")
        end

    end

    %% ===============================================================
    %  3. PARAMETER TYPE – Scalar
    %% ===============================================================
    methods (Test, TestTags = {'ParameterType','Scalar'})

        function test_scalarParameterType(tc)
            obj = gmt_Parameter(tc.Desc, tc.Var, tc.ScalarData);
            tc.verifyEqual(obj.ParameterType, gmtEnumE.gmt_ParameterType.Scalar, ...
                "Plain variable should yield Scalar ParameterType.")
        end

        function test_scalarExpressionIsFalse(tc)
            obj = gmt_Parameter(tc.Desc, tc.Var, tc.ScalarData);
            tc.verifyFalse(obj.Expression, ...
                "Expression flag should be false for a plain variable.")
        end

        function test_scalarWithVectorData(tc)
            data = [1 2 3 4 5];
            obj  = gmt_Parameter(tc.Desc, tc.Var, data);
            tc.verifyEqual(obj.ParameterType, gmtEnumE.gmt_ParameterType.Scalar, ...
                "Non-interp, non-net variable should still be Scalar.")
            tc.verifyEqual(obj.Data, data, ...
                "Data should be stored as-is for Scalar type.")
        end

    end

    %% ===============================================================
    %  4. PARAMETER TYPE – Expression
    %% ===============================================================
    methods (Test, TestTags = {'Expression'})

        function test_expressionFlagSetWhenVariableContainsEquals(tc)
            obj = gmt_Parameter(tc.Desc, "y = x + 1", tc.ScalarData);
            tc.verifyTrue(obj.Expression, ...
                "Expression flag should be true when Variable contains '='.")
        end

        function test_expressionFlagFalseWithoutEquals(tc)
            obj = gmt_Parameter(tc.Desc, "myVar", tc.ScalarData);
            tc.verifyFalse(obj.Expression, ...
                "Expression flag should be false when Variable has no '='.")
        end

    end

    %% ===============================================================
    %  5. PARAMETER TYPE – Lookup (interp)
    %% ===============================================================
    methods (Test, TestTags = {'ParameterType','Lookup'})

        function test_lookupParameterType1D(tc)
            obj = gmt_Parameter(tc.Desc, "interp1(rpm,torque,x)", ...
                tc.LookupData);
            tc.verifyEqual(obj.ParameterType, gmtEnumE.gmt_ParameterType.Lookup, ...
                "Variable containing 'interp' should yield Lookup type.")
        end

        function test_lookupDimNumeric(tc)
            obj = gmt_Parameter(tc.Desc, "interp1(rpm,torque,x)", ...
                tc.LookupData);
            tc.verifyEqual(obj.lookupDim, 1, ...
                "lookupDim should be the numeric value 1 for 'interp1'.")
        end

        function test_lookupDimString(tc)
            % When the character after 'interp' is not a digit the raw
            % substring should be kept as a string.
            obj = gmt_Parameter(tc.Desc, "interpN(rpm,torque,x)", ...
                tc.LookupData);
            tc.verifyClass(obj.lookupDim, 'string', ...
                "lookupDim should remain a string when non-numeric suffix.")
        end

        function test_lookupVarsPopulatedFromData(tc)
            obj = gmt_Parameter(tc.Desc, "interp1(rpm,torque,x)", ...
                tc.LookupData);
            expectedVars = string(fieldnames(tc.LookupData));
            tc.verifyEqual(obj.lookupVars, expectedVars, ...
                "lookupVars should match fieldnames of the Data struct.")
        end

        function test_lookupVarsEmptyWhenNoData(tc)
            obj = gmt_Parameter(tc.Desc, "interp1(x,y,z)", []);
            tc.verifyEmpty(obj.lookupVars, ...
                "lookupVars should be empty when Data is [].")
        end

        function test_lookupDataStored(tc)
            obj = gmt_Parameter(tc.Desc, "interp1(rpm,torque,x)", ...
                tc.LookupData);
            tc.verifyEqual(obj.Data, tc.LookupData, ...
                "Data should be stored for Lookup type.")
        end

    end

    %% ===============================================================
    %  6. PARAMETER TYPE – Neural Network
    %% ===============================================================
    methods (Test, TestTags = {'ParameterType','NeuralNetwork'})

        function test_neuralNetworkParameterType(tc)
            obj = gmt_Parameter(tc.Desc, "net_output", tc.NetData);
            tc.verifyEqual(obj.ParameterType, gmtEnumE.gmt_ParameterType.Neural_Network, ...
                "Variable containing 'net' should yield Neural_Network type.")
        end

        function test_neuralNetworkDataStored(tc)
            obj = gmt_Parameter(tc.Desc, "net_output", tc.NetData);
            tc.verifyEqual(obj.Data, tc.NetData, ...
                "Data should be stored for Neural_Network type.")
        end

        function test_neuralNetworkExpressionDefault(tc)
            obj = gmt_Parameter(tc.Desc, "net_output", tc.NetData);
            tc.verifyFalse(obj.Expression, ...
                "Expression should default to false for a net variable.")
        end

    end

    %% ===============================================================
    %  7. PROTECTED PROPERTIES – cannot be set externally
    %% ===============================================================
    methods (Test, TestTags = {'SetAccess'})

        function test_parameterTypeIsProtected(tc)
            obj = gmt_Parameter(tc.Desc, tc.Var, tc.ScalarData);
            tc.verifyError(@() setParameterType(obj), ...
                'MATLAB:class:SetProhibited', ...
                "ParameterType should have protected SetAccess.")
        end

        function test_expressionPropertyIsProtected(tc)
            obj = gmt_Parameter(tc.Desc, tc.Var, tc.ScalarData);
            tc.verifyError(@() setExpression(obj), ...
                'MATLAB:class:SetProhibited', ...
                "Expression should have protected SetAccess.")
        end

        function test_parentPropertyIsProtected(tc)
            obj = gmt_Parameter(tc.Desc, tc.Var, tc.ScalarData);
            tc.verifyError(@() setParent(obj), ...
                'MATLAB:class:SetProhibited', ...
                "Parent should have protected SetAccess.")
        end

    end

    %% ===============================================================
    %  8. gmt_ModelParameterParent method
    %% ===============================================================
    methods (Test, TestTags = {'Method','Parent'})

        function test_parentUpdatedByMethod(tc)
            obj      = gmt_Parameter(tc.Desc, tc.Var, tc.ScalarData);
            graphName = "MyModel";
            obj      = gmt_ModelParameterParent(obj, graphName);
            tc.verifyEqual(obj.Parent, graphName, ...
                "Parent should be updated by gmt_ModelParameterParent.")
        end

        function test_parentDefaultIsEmpty(tc)
            obj = gmt_Parameter(tc.Desc, tc.Var, tc.ScalarData);
            tc.verifyEmpty(obj.Parent, ...
                "Parent should be empty before gmt_ModelParameterParent is called.")
        end

        function test_parentCanBeOverwritten(tc)
            obj = gmt_Parameter(tc.Desc, tc.Var, tc.ScalarData);
            obj = gmt_ModelParameterParent(obj, "FirstGraph");
            obj = gmt_ModelParameterParent(obj, "SecondGraph");
            tc.verifyEqual(obj.Parent, "SecondGraph", ...
                "Parent should reflect the most recent call to gmt_ModelParameterParent.")
        end

    end

    %% ===============================================================
    %  9. EDGE CASES & ROBUSTNESS
    %% ===============================================================
    methods (Test, TestTags = {'EdgeCase'})

        function test_emptyDescriptionAllowed(tc)
            obj = gmt_Parameter("", tc.Var, tc.ScalarData);
            tc.verifyEqual(obj.Description, "", ...
                "Empty description string should be accepted.")
        end

        function test_multipleOptionalArgsTogether(tc)
            obj = gmt_Parameter(tc.Desc, tc.Var, tc.ScalarData, ...
                'Common', true, 'Optimization', true, 'Units', "m/s");
            tc.verifyTrue(obj.Common)
            tc.verifyTrue(obj.Optimization)
            tc.verifyEqual(obj.Units, "m/s")
        end

        function test_variableWithEqualsAndInterp(tc)
            % Expression + Lookup edge case: '=' takes priority for the
            % Expression flag; interp still drives ParameterType.
            obj = gmt_Parameter(tc.Desc, "y = interp1(x,z,v)", tc.LookupData);
            tc.verifyTrue(obj.Expression, ...
                "Expression flag should be true when '=' is present.")
            tc.verifyEqual(obj.ParameterType, gmtEnumE.gmt_ParameterType.Lookup, ...
                "ParameterType should still be Lookup when 'interp' is present.")
        end

        function test_numericDataPreservedForScalar(tc)
            data = magic(4);
            obj  = gmt_Parameter(tc.Desc, tc.Var, data);
            tc.verifyEqual(obj.Data, data, ...
                "Matrix data should be stored unchanged for Scalar type.")
        end

    end

end

%% ---------------------------------------------------------------
%  Local helper functions (used inside verifyError)
%  ---------------------------------------------------------------
function setParameterType(obj)
    obj.ParameterType = gmtEnumE.gmt_ParameterType.Scalar;
end

function setExpression(obj)
    obj.Expression = true;
end

function setParent(obj)
    obj.Parent = "illegal";
end