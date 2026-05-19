%% test_gmt_Edge.m
% Unit test class for gmt_Edge
% Run with: results = runtests('test_gmt_Edge'); table(results)

classdef test_gmt_Edge < matlab.unittest.TestCase

    % =====================================================================
    % 1. CONSTRUCTOR — HAPPY PATHS
    % =====================================================================
    methods (Test, TestTags = {'Constructor','Happy'})

        function test_constructor_basic(tc)
            % Minimal valid construction stores name and equation
            e = gmt_Edge("e1", "xh - xt");
            tc.verifyEqual(e.EdgeName, "e1");
            tc.verifyEqual(e.EdgeEq,   "xh - xt");
        end

        function test_constructor_default_edge_type_is_internal(tc)
            % EdgeType defaults to Internal when External flag is omitted
            e = gmt_Edge("e1", "xh - xt");
            tc.verifyEqual(e.EdgeType, gmtEnumE.gmt_EdgeType.Internal);
        end

        function test_constructor_external_flag_sets_type(tc)
            % Passing External=true marks the edge as External
            e = gmt_Edge("e1", "xh - xt", "External", true);
            tc.verifyEqual(e.EdgeType, gmtEnumE.gmt_EdgeType.External);
        end

        function test_constructor_external_false_keeps_internal(tc)
            % Explicitly passing External=false leaves type as Internal
            e = gmt_Edge("e1", "xh - xt", "External", false);
            tc.verifyEqual(e.EdgeType, gmtEnumE.gmt_EdgeType.Internal);
        end

    end

    % =====================================================================
    % 2. CONSTRUCTOR — VALIDATION / ERROR PATHS
    % =====================================================================
    methods (Test, TestTags = {'Constructor','Validation'})

        function test_constructor_char_EdgeName_throws(tc)
            % EdgeName must be a string (not char) — assert halts, so use try/catch
            try
                gmt_Edge('e1', "xh - xt");
                tc.verifyFail("Expected an error for char EdgeName but none was thrown.");
            catch e
                tc.verifySubstring(e.message, "EdgeName", ...
                    "Error message should mention EdgeName datatype.");
            end
        end

        function test_constructor_char_EdgeEq_throws(tc)
            % EdgeEq must be a string (not char) — assert halts, so use try/catch
            try
                gmt_Edge("e1", 'xh - xt');
                tc.verifyFail("Expected an error for char EdgeEq but none was thrown.");
            catch e
                tc.verifySubstring(e.message, "EdgeEq", ...
                    "Error message should mention EdgeEq datatype.");
            end
        end

        function test_constructor_empty_EdgeName_throws(tc)
            % Empty EdgeName must raise an assertion — assert halts, so use try/catch
            try
                gmt_Edge("", "xh - xt");
                tc.verifyFail("Expected an error for empty EdgeName but none was thrown.");
            catch e
                tc.verifySubstring(e.message, "EdgeName", ...
                    "Error message should mention EdgeName.");
            end
        end

        function test_constructor_empty_EdgeEq_throws(tc)
            % Empty EdgeEq must raise an assertion — assert halts, so use try/catch
            try
                gmt_Edge("e1", "");
                tc.verifyFail("Expected an error for empty EdgeEq but none was thrown.");
            catch e
                tc.verifySubstring(e.message, "EdgeEq", ...
                    "Error message should mention EdgeEq.");
            end
        end

    end

    % =====================================================================
    % 3. STATE COUNTING — SINGLE STATE SYNTAX
    % =====================================================================
    methods (Test, TestTags = {'StateCount','Single'})

        function test_single_head_state(tc)
            e = gmt_Edge("e1", "xh");
            tc.verifyEqual(e.NeHS, 1);
            tc.verifyEqual(e.NeTS, 0);
        end

        function test_single_tail_state(tc)
            e = gmt_Edge("e1", "xt");
            tc.verifyEqual(e.NeTS, 1);
            tc.verifyEqual(e.NeHS, 0);
        end

        function test_single_head_and_tail_state(tc)
            e = gmt_Edge("e1", "xh - xt");
            tc.verifyEqual(e.NeHS, 1);
            tc.verifyEqual(e.NeTS, 1);
        end

        function test_single_head_single_input(tc)
            e = gmt_Edge("e1", "xh + u");
            tc.verifyEqual(e.NeHS, 1);
            tc.verifyEqual(e.NeU,  1);
        end

        function test_no_states_no_inputs(tc)
            % Edge with only a numeric constant
            e = gmt_Edge("e1", "3.14");
            tc.verifyEqual(e.NeHS, 0);
            tc.verifyEqual(e.NeTS, 0);
            tc.verifyEqual(e.NeU,  0);
        end

    end

    % =====================================================================
    % 4. STATE COUNTING — MULTI-STATE SYNTAX
    % =====================================================================
    methods (Test, TestTags = {'StateCount','Multi'})

        function test_two_head_states(tc)
            e = gmt_Edge("e1", "xh1 + xh2");
            tc.verifyEqual(e.NeHS, 2);
        end

        function test_two_tail_states(tc)
            e = gmt_Edge("e1", "xt1 + xt2");
            tc.verifyEqual(e.NeTS, 2);
        end

        function test_two_head_two_tail_states(tc)
            e = gmt_Edge("e1", "xh1 + xh2 - xt1 - xt2");
            tc.verifyEqual(e.NeHS, 2);
            tc.verifyEqual(e.NeTS, 2);
        end

        function test_three_head_states(tc)
            e = gmt_Edge("e1", "xh1 + xh2 + xh3");
            tc.verifyEqual(e.NeHS, 3);
        end

        function test_multi_inputs(tc)
            e = gmt_Edge("e1", "u1 + u2");
            tc.verifyEqual(e.NeU, 2);
        end

        function test_multi_head_and_multi_input(tc)
            e = gmt_Edge("e1", "xh1 + xh2 + u1 + u2");
            tc.verifyEqual(e.NeHS, 2);
            tc.verifyEqual(e.NeU,  2);
        end

    end

    % =====================================================================
    % 5. INVALID MULTI-STATE SYNTAX (gap in numbering / mixed syntax)
    % =====================================================================
    methods (Test, TestTags = {'StateCount','InvalidSyntax'})

        function test_mixed_single_multi_head_throws(tc)
            % Combining "xh" (no number) with "xh1" is forbidden — assert halts, so use try/catch
            try
                gmt_Edge("e1", "xh + xh1");
                tc.verifyFail("Expected an error for mixed head state syntax but none was thrown.");
            catch e
                tc.verifySubstring(e.message, "xh", ...
                    "Error message should reference head state variable syntax.");
            end
        end

        function test_mixed_single_multi_tail_throws(tc)
            % Combining "xt" (no number) with "xt1" is forbidden — assert halts, so use try/catch
            try
                gmt_Edge("e1", "xt + xt1");
                tc.verifyFail("Expected an error for mixed tail state syntax but none was thrown.");
            catch e
                tc.verifySubstring(e.message, "xt", ...
                    "Error message should reference tail state variable syntax.");
            end
        end

        function test_mixed_single_multi_input_throws(tc)
            % Combining "u" (no number) with "u1" is forbidden — assert halts, so use try/catch
            try
                gmt_Edge("e1", "u + u1");
                tc.verifyFail("Expected an error for mixed input syntax but none was thrown.");
            catch e
                tc.verifySubstring(e.message, "u", ...
                    "Error message should reference control input syntax.");
            end
        end

    end

    % =====================================================================
    % 6. VARIABLE LISTS
    % =====================================================================
    methods (Test, TestTags = {'VariableLists'})

        function test_head_state_variables_single(tc)
            e = gmt_Edge("e1", "xh - xt");
            tc.verifyTrue(ismember("xh", e.HeadStateVariables));
        end

        function test_tail_state_variables_single(tc)
            e = gmt_Edge("e1", "xh - xt");
            tc.verifyTrue(ismember("xt", e.TailStateVariables));
        end

        function test_head_state_variables_multi(tc)
            e = gmt_Edge("e1", "xh1 + xh2");
            tc.verifyTrue(ismember("xh1", e.HeadStateVariables));
            tc.verifyTrue(ismember("xh2", e.HeadStateVariables));
        end

        function test_input_variables_single(tc)
            e = gmt_Edge("e1", "xh + u");
            tc.verifyTrue(ismember("u", e.InputVariables));
        end

        function test_input_variables_multi(tc)
            e = gmt_Edge("e1", "u1 + u2");
            tc.verifyTrue(ismember("u1", e.InputVariables));
            tc.verifyTrue(ismember("u2", e.InputVariables));
        end

        function test_no_duplicate_head_variables(tc)
            % Repeated "xh" in equation should still produce one list entry
            e = gmt_Edge("e1", "xh + xh");
            tc.verifyEqual(numel(e.HeadStateVariables), 1);
        end

        function test_empty_variable_lists_when_no_states(tc)
            e = gmt_Edge("e1", "5 * 2");
            tc.verifyEmpty(e.HeadStateVariables);
            tc.verifyEmpty(e.TailStateVariables);
            tc.verifyEmpty(e.InputVariables);
        end

    end

    % =====================================================================
    % 7. VERTEX NUMBER ASSIGNMENT
    % =====================================================================
    methods (Test, TestTags = {'VertexAssignment'})

        function test_default_head_vertex_unassigned(tc)
            e = gmt_Edge("e1", "xh - xt");
            tc.verifyEqual(e.HeadVertexNum, "Unassigned");
        end

        function test_default_tail_vertex_unassigned(tc)
            e = gmt_Edge("e1", "xh - xt");
            tc.verifyEqual(e.TailVertexNum, "Unassigned");
        end

        function test_update_head_vertex_number(tc)
            e = gmt_Edge("e1", "xh - xt");
            e = e.gmt_UpdateHeadVertexNum(3);
            tc.verifyEqual(e.HeadVertexNum, 3);
        end

        function test_update_tail_vertex_number(tc)
            e = gmt_Edge("e1", "xh - xt");
            e = e.gmt_UpdateTailVertexNum(7);
            tc.verifyEqual(e.TailVertexNum, 7);
        end

    end

    % =====================================================================
    % 8. GRAPH MODEL UPDATE
    % =====================================================================
    methods (Test, TestTags = {'GraphModelUpdate'})

        function test_graph_edge_eq_initially_empty(tc)
            e = gmt_Edge("e1", "xh - xt");
            tc.verifyEmpty(e.GraphEdgeEq);
        end

        function test_graph_model_update_copies_edge_eq(tc)
            e = gmt_Edge("e1", "xh - xt");
            e = e.gmt_EdgeGraphModelUpdate();
            tc.verifyEqual(e.GraphEdgeEq, "xh - xt");
        end

        function test_graph_model_update_idempotent(tc)
            % Calling update twice must not overwrite an already-set GraphEdgeEq
            e = gmt_Edge("e1", "xh - xt");
            e = e.gmt_EdgeGraphModelUpdate();
            e = e.gmt_EdgeGraphModelUpdate();
            tc.verifyEqual(e.GraphEdgeEq, "xh - xt");
        end

        function test_update_graph_head_state_substitutes_token(tc)
            e = gmt_Edge("e1", "xh - xt");
            e = e.gmt_EdgeGraphModelUpdate();
            e = e.gmt_UpdateGraphHeadStateVar("x1");
            tc.verifySubstring(e.GraphEdgeEq, "x1");
        end

        function test_update_graph_tail_state_substitutes_token(tc)
            e = gmt_Edge("e1", "xh - xt");
            e = e.gmt_EdgeGraphModelUpdate();
            e = e.gmt_UpdateGraphTailStateVar("x2");
            tc.verifySubstring(e.GraphEdgeEq, "x2");
        end

        function test_update_graph_head_and_tail_substitution(tc)
            e = gmt_Edge("e1", "xh - xt");
            e = e.gmt_EdgeGraphModelUpdate();
            e = e.gmt_UpdateGraphHeadStateVar("x1");
            e = e.gmt_UpdateGraphTailStateVar("x2");
            tc.verifySubstring(e.GraphEdgeEq, "x1");
            tc.verifySubstring(e.GraphEdgeEq, "x2");
            % Original placeholder tokens should no longer appear bare
            tc.verifyEmpty(regexp(e.GraphEdgeEq, '(?<![0-9a-zA-Z])xh(?![0-9a-zA-Z])', 'match'));
            tc.verifyEmpty(regexp(e.GraphEdgeEq, '(?<![0-9a-zA-Z])xt(?![0-9a-zA-Z])', 'match'));
        end

        function test_update_graph_head_stores_variable(tc)
            e = gmt_Edge("e1", "xh - xt");
            e = e.gmt_EdgeGraphModelUpdate();
            e = e.gmt_UpdateGraphHeadStateVar("x5");
            tc.verifyEqual(e.GraphHeadStateVariables, "x5");
        end

        function test_update_graph_tail_stores_variable(tc)
            e = gmt_Edge("e1", "xh - xt");
            e = e.gmt_EdgeGraphModelUpdate();
            e = e.gmt_UpdateGraphTailStateVar("x9");
            tc.verifyEqual(e.GraphTailStateVariables, "x9");
        end

    end

    % =====================================================================
    % 9. EQUATION COMPLEXITY / EDGE CASES
    % =====================================================================
    methods (Test, TestTags = {'EdgeCases'})

        function test_equation_with_exponent(tc)
            % Exponent operator must not confuse variable parsing
            e = gmt_Edge("e1", "xh^2 - xt^2");
            tc.verifyEqual(e.NeHS, 1);
            tc.verifyEqual(e.NeTS, 1);
        end

        function test_equation_with_parentheses(tc)
            e = gmt_Edge("e1", "(xh - xt) * u");
            tc.verifyEqual(e.NeHS, 1);
            tc.verifyEqual(e.NeTS, 1);
            tc.verifyEqual(e.NeU,  1);
        end

        function test_equation_with_nested_parentheses(tc)
            e = gmt_Edge("e1", "((xh1 + xh2) - (xt1 + xt2)) * u1");
            tc.verifyEqual(e.NeHS, 2);
            tc.verifyEqual(e.NeTS, 2);
            tc.verifyEqual(e.NeU,  1);
        end

        function test_whitespace_only_equation_throws(tc)
            % A blank/whitespace EdgeEq must fail — assert halts, so use try/catch
            try
                gmt_Edge("e1", "   ");
                tc.verifyFail("Expected an error for whitespace-only EdgeEq but none was thrown.");
            catch e
                tc.verifySubstring(e.message, "EdgeEq", ...
                    "Error message should mention EdgeEq.");
            end
        end

        function test_head_state_not_confused_with_parameter(tc)
            % Tokens like "xheat" must not be counted as head states
            e = gmt_Edge("e1", "xheat - xt");
            tc.verifyEqual(e.NeHS, 0);   % "xheat" should NOT match
            tc.verifyEqual(e.NeTS, 1);
        end

    end

end