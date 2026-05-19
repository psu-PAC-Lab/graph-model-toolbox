classdef test_gmt_Vertex < matlab.unittest.TestCase
    % test_gmt_Vertex  Unit tests for the gmt_Vertex class.
    %
    % Run with:
    %   results = runtests('test_gmt_Vertex');
    %   disp(results);

    %% ---------------------------------------------------------------
    %  Constructor – valid inputs
    %% ---------------------------------------------------------------
    methods (Test, TestTags = {'Constructor', 'Valid'})

        function test_constructor_basic_dynamic(tc)
            % Single dynamic state: C*x_dot = ...
            v = gmt_Vertex("ThermalNode", "C*x_dot");
            tc.verifyEqual(v.VertexName,    "ThermalNode");
            tc.verifyEqual(v.CapacitanceEq, "C*x_dot");
        end

        function test_constructor_basic_algebraic(tc)
            % Algebraic vertex (no _dot term)
            v = gmt_Vertex("PressureNode", "x");
            tc.verifyEqual(v.VertexName,    "PressureNode");
            tc.verifyEqual(v.CapacitanceEq, "x");
        end

        function test_constructor_with_units(tc)
            v = gmt_Vertex("VoltageNode", "C*x_dot", "Units", "V");
            tc.verifyEqual(v.Units, "V");
        end

        function test_constructor_external_flag(tc)
            v = gmt_Vertex("Source", "u", "External", true);
            tc.verifyEqual(v.VertexType, gmtEnumE.gmt_VertexType.External);
        end

        function test_constructor_default_vertex_type(tc)
            v = gmt_Vertex("Node", "x_dot");
            tc.verifyEqual(v.VertexType, gmtEnumE.gmt_VertexType.Internal);
        end

    end

    %% ---------------------------------------------------------------
    %  Constructor – invalid inputs
    %% ---------------------------------------------------------------
    methods (Test, TestTags = {'Constructor', 'Invalid'})

        function test_empty_name_errors(tc)
            tc.verifyError(@() gmt_Vertex("", "C*x_dot"), ?MException);
        end

        function test_empty_capacitance_eq_errors(tc)
            tc.verifyError(@() gmt_Vertex("Node", ""), ?MException);
        end

        function test_non_string_name_errors(tc)
            % Passing a char array instead of a string should error
            tc.verifyError(@() gmt_Vertex('Node', "C*x_dot"), ?MException);
        end

        function test_non_string_capacitance_eq_errors(tc)
            tc.verifyError(@() gmt_Vertex("Node", 42), ?MException);
        end

    end

    %% ---------------------------------------------------------------
    %  StateType detection
    %% ---------------------------------------------------------------
    methods (Test, TestTags = {'StateType'})

        function test_state_type_dynamic(tc)
            v = gmt_Vertex("Node", "C*x_dot");
            tc.verifyEqual(v.StateType, gmtEnumE.gmt_StateType.Dynamic);
        end

        function test_state_type_algebraic(tc)
            v = gmt_Vertex("Node", "x");
            tc.verifyEqual(v.StateType, gmtEnumE.gmt_StateType.Algebraic);
        end

        function test_state_type_algebraic_control_input(tc)
            v = gmt_Vertex("Source", "u");
            tc.verifyEqual(v.StateType, gmtEnumE.gmt_StateType.Algebraic);
        end

    end

    %% ---------------------------------------------------------------
    %  Single-state dynamic vertex
    %% ---------------------------------------------------------------
    methods (Test, TestTags = {'SingleState', 'Dynamic'})

        function test_single_dynamic_state_count(tc)
            v = gmt_Vertex("Node", "C*x_dot");
            tc.verifyEqual(v.NvSd, 1);
            tc.verifyEqual(v.NvS,  1);
        end

        function test_single_dynamic_state_variables(tc)
            v = gmt_Vertex("Node", "C*x_dot");
            tc.verifyEqual(v.StateDerVariables, "x_dot");
            tc.verifyEqual(v.StateVariables,    "x");
        end

        function test_single_dynamic_capacitance(tc)
            % Capacitance should strip x_dot and trailing operator
            v = gmt_Vertex("Node", "C*x_dot");
            tc.verifyEqual(v.Capacitance, "C");
        end

        function test_unit_capacitance_when_only_x_dot(tc)
            % "x_dot" alone → capacitance = "1"
            v = gmt_Vertex("Node", "x_dot");
            tc.verifyEqual(v.Capacitance, "1");
        end

    end

    %% ---------------------------------------------------------------
    %  Multi-state dynamic vertex
    %% ---------------------------------------------------------------
    methods (Test, TestTags = {'MultiState', 'Dynamic'})

        function test_multi_dynamic_state_count(tc)
            v = gmt_Vertex("Node", "C1*x1_dot + C2*x2_dot");
            tc.verifyEqual(v.NvSd, 2);
            tc.verifyEqual(v.NvS,  2);
        end

        function test_multi_dynamic_state_variables(tc)
            v = gmt_Vertex("Node", "C1*x1_dot + C2*x2_dot");
            % Both derivative variables should be detected
            tc.verifyTrue(any(v.StateDerVariables == "x1_dot"));
            tc.verifyTrue(any(v.StateDerVariables == "x2_dot"));
        end

        function test_multi_state_variables_without_dot(tc)
            v = gmt_Vertex("Node", "C1*x1_dot + C2*x2_dot");
            tc.verifyTrue(any(v.StateVariables == "x1"));
            tc.verifyTrue(any(v.StateVariables == "x2"));
        end

    end

    %% ---------------------------------------------------------------
    %  Algebraic vertex (state variable, no _dot)
    %% ---------------------------------------------------------------
    methods (Test, TestTags = {'Algebraic'})

        function test_algebraic_no_state_derivatives(tc)
            v = gmt_Vertex("Node", "x");
            tc.verifyEqual(v.NvSd, 0);
        end

        function test_algebraic_state_count(tc)
            v = gmt_Vertex("Node", "x");
            tc.verifyEqual(v.NvS, 1);
        end

        function test_algebraic_capacitance_is_one(tc)
            v = gmt_Vertex("Node", "x");
            tc.verifyEqual(v.Capacitance, "1");
        end

    end

    %% ---------------------------------------------------------------
    %  Control input vertex
    %% ---------------------------------------------------------------
    methods (Test, TestTags = {'ControlInput'})

        function test_single_control_input_count(tc)
            v = gmt_Vertex("Source", "u");
            tc.verifyEqual(v.NvU, 1);
        end

        function test_single_control_input_variable(tc)
            v = gmt_Vertex("Source", "u");
            tc.verifyEqual(v.InputVariables, "u");
        end

        function test_multi_control_input_count(tc)
            v = gmt_Vertex("Source", "u1 + u2");
            tc.verifyEqual(v.NvU, 2);
        end

        function test_multi_control_input_variables(tc)
            v = gmt_Vertex("Source", "u1 + u2");
            tc.verifyTrue(any(v.InputVariables == "u1"));
            tc.verifyTrue(any(v.InputVariables == "u2"));
        end

        function test_algebraic_state_variable_set_to_input(tc)
            % For an algebraic vertex with control input, StateVariables = InputVariables
            v = gmt_Vertex("Source", "u");
            tc.verifyEqual(v.StateVariables, v.InputVariables);
        end

    end

    %% ---------------------------------------------------------------
    %  Capacitance parsing – various expressions
    %% ---------------------------------------------------------------
    methods (Test, TestTags = {'Capacitance'})

        function test_capacitance_simple_constant(tc)
            v = gmt_Vertex("Node", "5*x_dot");
            tc.verifyEqual(v.Capacitance, "5");
        end

        function test_capacitance_expression(tc)
            v = gmt_Vertex("Node", "(m*Cp)*x_dot");
            tc.verifyEqual(v.Capacitance, "(m*Cp)");
        end

    end

    %% ---------------------------------------------------------------
    %  gmt_GraphVertexUpdate – external metadata
    %% ---------------------------------------------------------------
    methods (Test, TestTags = {'GraphUpdate'})

        function test_graph_vertex_update_assigns_variables(tc)
            v = gmt_Vertex("Node", "C*x_dot");

            Ds = "x_T1_dot";
            As = "x_T1";
            Ys = "y_T1";

            v = gmt_GraphVertexUpdate(v, Ds, As, Ys);

            tc.verifyEqual(v.GraphStateDerVariables, Ds);
            tc.verifyEqual(v.GraphStateVariables,    As);
            tc.verifyEqual(v.GraphOutputVariables,   Ys);
        end

        function test_graph_vertex_update_renames_capacitance_eq(tc)
            v = gmt_Vertex("Node", "C*x_dot");

            v = gmt_GraphVertexUpdate(v, "x_T1_dot", "x_T1", "y_T1");

            % Generic x → x_T1 and x_dot → x_T1_dot in the capacitance eq
            tc.verifyTrue(contains(v.GraphCapacitanceEq, "x_T1_dot"));
            tc.verifyFalse(contains(v.GraphCapacitanceEq, "x_dot") && ...
                           ~contains(v.GraphCapacitanceEq, "x_T1_dot"));
        end

        function test_graph_vertex_update_renames_capacitance(tc)
            v = gmt_Vertex("Node", "C*x_dot");

            v = gmt_GraphVertexUpdate(v, "x_N1_dot", "x_N1", "y_N1");

            % Capacitance itself (C) should be unchanged; x is not part of it
            tc.verifyEqual(v.GraphCapacitance, "C");
        end

    end

    %% ---------------------------------------------------------------
    %  gmt_GraphVertexEqUpdate
    %% ---------------------------------------------------------------
    methods (Test, TestTags = {'PowerEq'})

        function test_graph_vertex_eq_update_power(tc)
            v = gmt_Vertex("Node", "C*x_dot");
            v = gmt_GraphVertexUpdate(v, "x_T1_dot", "x_T1", "y_T1");
            v = gmt_GraphVertexEqUpdate(v, "Q1 - Q2", 2);

            tc.verifyEqual(v.GraphPowerEq, "(Q1 - Q2)");
            tc.verifyEqual(v.GraphNvE, 2);
        end

        function test_graph_vertex_eq_update_vertex_eq(tc)
            v = gmt_Vertex("Node", "C*x_dot");
            v = gmt_GraphVertexUpdate(v, "x_T1_dot", "x_T1", "y_T1");
            v = gmt_GraphVertexEqUpdate(v, "Q_in - Q_out", 2);

            expected = "(1/(C))*(Q_in - Q_out)";
            tc.verifyEqual(v.GraphVertexEq, expected);
        end

    end

end