%% gmt_InputTest
% Unit tests for the gmt_Input class
% Tests cover: constructor, optional parameters, gmt_GraphInput, gmt_InputParent
%
% Usage:
%   results = runtests('gmt_InputTest');
%   table(results)

classdef test_gmt_Input < matlab.unittest.TestCase

    %% ------------------------------------------------------------------ %
    %  Shared test fixtures
    %% ------------------------------------------------------------------ %
    properties
        DefaultVarName   = "voltage"
        DefaultDesc      = "Input voltage signal"
        MockParent                     % Struct acting as a minimal parent object
        MockParameter                  % Struct acting as a minimal parameter object
    end

    methods (TestMethodSetup)
        function buildMocks(tc)
            % Lightweight stand-ins that satisfy duck-typing used in the class
            tc.MockParent.Name    = "MyComponent";
            tc.MockParameter.Name = "SystemA";
        end
    end

    %% ------------------------------------------------------------------ %
    %  Constructor – required arguments
    %% ------------------------------------------------------------------ %
    methods (Test, TestTags = "Constructor")

        function constructor_SetsVariableName(tc)
            obj = gmt_Input(tc.DefaultVarName, tc.DefaultDesc);
            tc.verifyEqual(obj.VariableName, tc.DefaultVarName, ...
                "VariableName should match the first constructor argument.");
        end

        function constructor_SetsDescription(tc)
            obj = gmt_Input(tc.DefaultVarName, tc.DefaultDesc);
            tc.verifyEqual(obj.Description, tc.DefaultDesc, ...
                "Description should match the second constructor argument.");
        end

        function constructor_DefaultUnitsIsUnassigned(tc)
            obj = gmt_Input(tc.DefaultVarName, tc.DefaultDesc);
            tc.verifyEqual(obj.Units, "unassigned", ...
                "Units should default to 'unassigned' when not provided.");
        end

        function constructor_DependencyIsEmpty(tc)
            obj = gmt_Input(tc.DefaultVarName, tc.DefaultDesc);
            tc.verifyEmpty(obj.Dependency, ...
                "Dependency should be empty after construction.");
        end

        function constructor_DependencyFormulaIsEmpty(tc)
            obj = gmt_Input(tc.DefaultVarName, tc.DefaultDesc);
            tc.verifyEmpty(obj.DependencyFormula, ...
                "DependencyFormula should be empty when not provided.");
        end

        function constructor_GraphVariableNameIsEmpty(tc)
            obj = gmt_Input(tc.DefaultVarName, tc.DefaultDesc);
            tc.verifyEmpty(obj.GraphVariableName, ...
                "GraphVariableName should be empty after construction.");
        end

        function constructor_GraphDescriptionIsEmpty(tc)
            obj = gmt_Input(tc.DefaultVarName, tc.DefaultDesc);
            tc.verifyEmpty(obj.GraphDescription, ...
                "GraphDescription should be empty after construction.");
        end

        function constructor_ParentIsEmpty(tc)
            obj = gmt_Input(tc.DefaultVarName, tc.DefaultDesc);
            tc.verifyEmpty(obj.Parent, ...
                "Parent should be empty after construction.");
        end

    end

    %% ------------------------------------------------------------------ %
    %  Constructor – optional 'Units' parameter
    %% ------------------------------------------------------------------ %
    methods (Test, TestTags = "Constructor")

        function constructor_SetsUnitsWhenProvided(tc)
            obj = gmt_Input(tc.DefaultVarName, tc.DefaultDesc, "Units", "Volts");
            tc.verifyEqual(obj.Units, "Volts", ...
                "Units should be set to the supplied value.");
        end

        function constructor_UnitsRemainsDefaultWhenEmpty(tc)
            tc.verifyError(...
            @() gmt_Input(tc.DefaultVarName, tc.DefaultDesc, "Units", ""), ...
            "MATLAB:InputParser:ArgumentFailedValidation", ...
            "Passing an empty Units string should throw a validation error.");
        end

    end

    %% ------------------------------------------------------------------ %
    %  Constructor – optional 'DependencyFormula' parameter
    %% ------------------------------------------------------------------ %
    methods (Test, TestTags = "Constructor")

        function constructor_SetsDependencyFormulaWhenProvided(tc)
            formula = "x + y";
            obj = gmt_Input(tc.DefaultVarName, tc.DefaultDesc, ...
                "DependencyFormula", formula);
            tc.verifyEqual(obj.DependencyFormula, formula, ...
                "DependencyFormula should be set to the supplied value.");
        end

        function constructor_SetsBothOptionalParameters(tc)
            obj = gmt_Input(tc.DefaultVarName, tc.DefaultDesc, ...
                "Units", "Amps", "DependencyFormula", "I = V/R");
            tc.verifyEqual(obj.Units, "Amps");
            tc.verifyEqual(obj.DependencyFormula, "I = V/R");
        end

    end

    %% ------------------------------------------------------------------ %
    %  Private setters – GraphVariableName & GraphDescription read-only
    %% ------------------------------------------------------------------ %
    methods (Test, TestTags = "AccessControl")

        function graphVariableName_IsNotDirectlySettable(tc)
            obj = gmt_Input(tc.DefaultVarName, tc.DefaultDesc);
            tc.verifyError(@() assignGraphVarName(obj), ...
                "MATLAB:class:SetProhibited", ...
                "Setting GraphVariableName directly should throw an error.");

            function assignGraphVarName(o)
                o.GraphVariableName = "illegal";  %#ok<NASGU>
            end
        end

        function graphDescription_IsNotDirectlySettable(tc)
            obj = gmt_Input(tc.DefaultVarName, tc.DefaultDesc);
            tc.verifyError(@() assignGraphDesc(obj), ...
                "MATLAB:class:SetProhibited", ...
                "Setting GraphDescription directly should throw an error.");

            function assignGraphDesc(o)
                o.GraphDescription = "illegal";  %#ok<NASGU>
            end
        end

        function parent_IsNotDirectlySettable(tc)
            obj = gmt_Input(tc.DefaultVarName, tc.DefaultDesc);
            tc.verifyError(@() assignParent(obj), ...
                "MATLAB:class:SetProhibited", ...
                "Setting Parent directly should throw an error.");

            function assignParent(o)
                o.Parent = "illegal";  %#ok<NASGU>
            end
        end

    end

    %% ------------------------------------------------------------------ %
    %  gmt_GraphInput – standard (non-SystemModel) mode
    %% ------------------------------------------------------------------ %
    methods (Test, TestTags = "GraphInput")

        function graphInput_SetsGraphVariableName(tc)
            obj  = gmt_Input(tc.DefaultVarName, tc.DefaultDesc);
            obj  = obj.gmt_GraphInput(tc.MockParameter, "gv_voltage");
            tc.verifyEqual(obj.GraphVariableName, "gv_voltage", ...
                "GraphVariableName should be set by gmt_GraphInput.");
        end

        function graphInput_BuildsGraphDescriptionWithParameterName(tc)
            obj  = gmt_Input(tc.DefaultVarName, tc.DefaultDesc);
            obj  = obj.gmt_GraphInput(tc.MockParameter, "gv_voltage");
            expected = tc.MockParameter.Name + ": " + tc.DefaultDesc;
            tc.verifyEqual(obj.GraphDescription, expected, ...
                "GraphDescription should be 'ParamName: Description' in normal mode.");
        end

        function graphInput_SystemModel_UsesDescriptionOnly(tc)
            obj  = gmt_Input(tc.DefaultVarName, tc.DefaultDesc);
            obj  = obj.gmt_GraphInput(tc.MockParameter, "gv_voltage", ...
                "SystemModel", true);
            tc.verifyEqual(obj.GraphDescription, tc.DefaultDesc, ...
                "In SystemModel mode, GraphDescription should equal Description alone.");
        end

        function graphInput_SystemModelFalse_IncludesParameterName(tc)
            obj  = gmt_Input(tc.DefaultVarName, tc.DefaultDesc);
            obj  = obj.gmt_GraphInput(tc.MockParameter, "gv_voltage", ...
                "SystemModel", false);
            expected = tc.MockParameter.Name + ": " + tc.DefaultDesc;
            tc.verifyEqual(obj.GraphDescription, expected, ...
                "SystemModel=false should behave the same as the default.");
        end

        function graphInput_DoesNotAlterOtherProperties(tc)
            obj  = gmt_Input(tc.DefaultVarName, tc.DefaultDesc, "Units", "Volts");
            obj  = obj.gmt_GraphInput(tc.MockParameter, "gv_voltage");
            tc.verifyEqual(obj.VariableName, tc.DefaultVarName);
            tc.verifyEqual(obj.Description,  tc.DefaultDesc);
            tc.verifyEqual(obj.Units,         "Volts");
        end

    end

    %% ------------------------------------------------------------------ %
    %  gmt_InputParent
    %% ------------------------------------------------------------------ %
    methods (Test, TestTags = "InputParent")

        function inputParent_SetsParentFromObjectName(tc)
            obj = gmt_Input(tc.DefaultVarName, tc.DefaultDesc);
            obj = obj.gmt_InputParent(tc.MockParent);
            tc.verifyEqual(obj.Parent, tc.MockParent.Name, ...
                "Parent should be set to the Name field of the supplied parent object.");
        end

        function inputParent_DoesNotAlterOtherProperties(tc)
            obj = gmt_Input(tc.DefaultVarName, tc.DefaultDesc, "Units", "Amps");
            obj = obj.gmt_InputParent(tc.MockParent);
            tc.verifyEqual(obj.VariableName, tc.DefaultVarName);
            tc.verifyEqual(obj.Description,  tc.DefaultDesc);
            tc.verifyEqual(obj.Units,         "Amps");
        end

        function inputParent_CanBeOverwritten(tc)
            otherParent.Name = "SecondComponent";
            obj = gmt_Input(tc.DefaultVarName, tc.DefaultDesc);
            obj = obj.gmt_InputParent(tc.MockParent);
            obj = obj.gmt_InputParent(otherParent);
            tc.verifyEqual(obj.Parent, "SecondComponent", ...
                "Calling gmt_InputParent twice should overwrite the previous Parent.");
        end

    end

    %% ------------------------------------------------------------------ %
    %  Value-semantics (MATLAB class copy behaviour)
    %% ------------------------------------------------------------------ %
    methods (Test, TestTags = "ValueSemantics")

        function mutatingCopy_DoesNotAffectOriginal(tc)
            original = gmt_Input(tc.DefaultVarName, tc.DefaultDesc);
            modified = original.gmt_InputParent(tc.MockParent);
            tc.verifyEmpty(original.Parent, ...
                "Assigning Parent on the copy should not mutate the original.");
            tc.verifyEqual(modified.Parent, tc.MockParent.Name);
        end

    end

end