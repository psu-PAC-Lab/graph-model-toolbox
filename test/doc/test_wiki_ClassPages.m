%% test_wiki_ClassPages
classdef test_wiki_ClassPages < gmt_WikiTestBase

    %% gmt_Graph.md
    methods (Test, TestTags={'gmt_Graph'})

        function test_graphPageExists(tc)
            tc.assertTrue(isfile(fullfile(tc.WikiDir, 'gmt_Graph.md')), ...
                'gmt_Graph.md does not exist.')
        end

        function test_graphConstructorSignaturePresent(tc)
            content = tc.readWikiFile('gmt_Graph.md');
            tc.assertTrue(contains(content, 'EdgeMatrix'), ...
                'gmt_Graph.md must document the EdgeMatrix argument.')
            tc.assertTrue(contains(content, 'Edges'), ...
                'gmt_Graph.md constructor must list Edges argument.')
            tc.assertTrue(contains(content, 'Vertices'), ...
                'gmt_Graph.md constructor must list Vertices argument.')
        end

        function test_graphKeyPropertiesPresent(tc)
            props = {'States','Inputs','Disturbances', ...
                     'SystemEquations','SystemEquationsSubs','InitialConditions'};
            content = tc.readWikiFile('gmt_Graph.md');
            for i = 1:numel(props)
                tc.assertTrue(contains(content, props{i}), ...
                    sprintf('gmt_Graph.md is missing property: %s', props{i}))
            end
        end

        function test_graphAllMethodGroupsPresent(tc)
            content = tc.readWikiFile('gmt_Graph.md');
            tc.assertTrue(contains(content, 'Reporting'), ...
                'gmt_Graph.md must have Reporting methods.')
            tc.assertTrue(contains(content, 'Analysis'), ...
                'gmt_Graph.md must have Analysis methods.')
            tc.assertTrue(contains(content, 'Visualization'), ...
                'gmt_Graph.md must have Visualization methods.')
        end

        function test_graphGmtCombineSignatureCorrect(tc)
            content = tc.readWikiFile('gmt_Graph.md');
            tc.assertTrue(contains(content, 'PrimaryList'), ...
                'gmt_Graph.md gmt_Combine must show PrimaryList syntax.')
            tc.assertTrue(contains(content, 'SecondaryList'), ...
                'gmt_Graph.md gmt_Combine must show SecondaryList syntax.')
        end

        function test_graphInputCommonNotePresent(tc)
            content = tc.readWikiFile('gmt_Graph.md');
            tc.assertTrue(contains(content, 'gmt_InputCommon'), ...
                'gmt_Graph.md must document gmt_InputCommon.')
        end

        function test_graphNoGmtPlottingClassReference(tc)
            content = tc.readWikiFile('gmt_Graph.md');
            tc.assertFalse(contains(content, '[gmt_Plotting]'), ...
                'gmt_Graph.md must not link to the removed gmt_Plotting page.')
        end

    end

    %% gmt_Vertex.md
    methods (Test, TestTags={'gmt_Vertex'})

        function test_vertexPageExists(tc)
            tc.assertTrue(isfile(fullfile(tc.WikiDir, 'gmt_Vertex.md')), ...
                'gmt_Vertex.md does not exist.')
        end

        function test_vertexEquationSyntaxTablePresent(tc)
            content = tc.readWikiFile('gmt_Vertex.md');
            tc.assertTrue(contains(content, 'x_dot'), ...
                'gmt_Vertex.md must document x_dot in syntax table.')
            tc.assertTrue(contains(content, 'x1_dot'), ...
                'gmt_Vertex.md must document x1_dot for multi-state syntax.')
        end

        function test_vertexDynamicExamplePresent(tc)
            content = tc.readWikiFile('gmt_Vertex.md');
            tc.assertTrue(contains(content, 'C*x_dot'), ...
                'gmt_Vertex.md must show a dynamic vertex example.')
        end

        function test_vertexAlgebraicExamplePresent(tc)
            content = tc.readWikiFile('gmt_Vertex.md');
            tc.assertTrue(contains(content, 'External'), ...
                'gmt_Vertex.md must show an algebraic external vertex example.')
        end

        function test_vertexTypeEnumerationPresent(tc)
            content = tc.readWikiFile('gmt_Vertex.md');
            tc.assertTrue(contains(content, 'gmt_VertexType'), ...
                'gmt_Vertex.md must document gmt_VertexType enumeration.')
        end

        function test_stateTypeEnumerationPresent(tc)
            content = tc.readWikiFile('gmt_Vertex.md');
            tc.assertTrue(contains(content, 'gmt_StateType'), ...
                'gmt_Vertex.md must document gmt_StateType enumeration.')
        end

    end

    %% gmt_Edge.md
    methods (Test, TestTags={'gmt_Edge'})

        function test_edgePageExists(tc)
            tc.assertTrue(isfile(fullfile(tc.WikiDir, 'gmt_Edge.md')), ...
                'gmt_Edge.md does not exist.')
        end

        function test_edgeEquationSyntaxTablePresent(tc)
            symbols = {'xh','xt','u'};
            content = tc.readWikiFile('gmt_Edge.md');
            for i = 1:numel(symbols)
                tc.assertTrue(contains(content, symbols{i}), ...
                    sprintf('gmt_Edge.md syntax table must include: %s', symbols{i}))
            end
        end

        function test_edgeExamplesPresent(tc)
            content = tc.readWikiFile('gmt_Edge.md');
            tc.assertTrue(contains(content, 'Cd*A*sqrt(xh - xt)'), ...
                'gmt_Edge.md must include orifice equation example.')
        end

        function test_edgeExternalFlagDocumented(tc)
            content = tc.readWikiFile('gmt_Edge.md');
            tc.assertTrue(contains(content, '"External", true'), ...
                'gmt_Edge.md must show External flag usage.')
        end

        function test_edgeTypeEnumerationPresent(tc)
            content = tc.readWikiFile('gmt_Edge.md');
            tc.assertTrue(contains(content, 'gmt_EdgeType'), ...
                'gmt_Edge.md must document gmt_EdgeType enumeration.')
        end

        function test_mixingNotationWarningPresent(tc)
            content = tc.readWikiFile('gmt_Edge.md');
            tc.assertTrue(contains(content, 'mixed'), ...
                'gmt_Edge.md must warn that single and indexed notation cannot be mixed.')
        end

    end

    %% gmt_Parameter.md
    methods (Test, TestTags={'gmt_Parameter'})

        function test_parameterPageExists(tc)
            tc.assertTrue(isfile(fullfile(tc.WikiDir, 'gmt_Parameter.md')), ...
                'gmt_Parameter.md does not exist.')
        end

        function test_allFourParameterTypesDocumented(tc)
            types = {'Scalar','Lookup','Neural_Network','Expression'};
            content = tc.readWikiFile('gmt_Parameter.md');
            for i = 1:numel(types)
                tc.assertTrue(contains(content, types{i}), ...
                    sprintf('gmt_Parameter.md must document parameter type: %s', types{i}))
            end
        end

        function test_interpDetectionDocumented(tc)
            content = tc.readWikiFile('gmt_Parameter.md');
            tc.assertTrue(contains(content, 'interp'), ...
                'gmt_Parameter.md must document interp detection for Lookup type.')
        end

        function test_optimizationFlagDocumented(tc)
            content = tc.readWikiFile('gmt_Parameter.md');
            tc.assertTrue(contains(content, 'Optimization'), ...
                'gmt_Parameter.md must document the Optimization flag.')
        end

        function test_commonFlagDocumented(tc)
            content = tc.readWikiFile('gmt_Parameter.md');
            tc.assertTrue(contains(content, 'Common'), ...
                'gmt_Parameter.md must document the Common flag.')
        end

        function test_modelTypeEnumerationPresent(tc)
            content = tc.readWikiFile('gmt_Parameter.md');
            tc.assertTrue(contains(content, 'gmt_ModelType'), ...
                'gmt_Parameter.md must document gmt_ModelType enumeration.')
        end

    end

    %% gmt_Input.md
    methods (Test, TestTags={'gmt_Input'})

        function test_inputPageExists(tc)
            tc.assertTrue(isfile(fullfile(tc.WikiDir, 'gmt_Input.md')), ...
                'gmt_Input.md does not exist.')
        end

        function test_variableNameMatchWarningPresent(tc)
            content = tc.readWikiFile('gmt_Input.md');
            tc.assertTrue(contains(content, 'match'), ...
                'gmt_Input.md must state that VariableName must match equation symbols.')
        end

        function test_graphVariableNamePropertyDocumented(tc)
            content = tc.readWikiFile('gmt_Input.md');
            tc.assertTrue(contains(content, 'GraphVariableName'), ...
                'gmt_Input.md must document the GraphVariableName property.')
        end

        function test_renamingNotePresent(tc)
            content = tc.readWikiFile('gmt_Input.md');
            tc.assertTrue(contains(content, 'gmt_Combine'), ...
                'gmt_Input.md must note that inputs are renamed after gmt_Combine.')
        end

        function test_dependencyFormulaDocumented(tc)
            content = tc.readWikiFile('gmt_Input.md');
            tc.assertTrue(contains(content, 'DependencyFormula'), ...
                'gmt_Input.md must document the DependencyFormula property.')
        end

    end

    %% gmt_Port.md
    methods (Test, TestTags={'gmt_Port'})

        function test_portPageExists(tc)
            tc.assertTrue(isfile(fullfile(tc.WikiDir, 'gmt_Port.md')), ...
                'gmt_Port.md does not exist.')
        end

        function test_portConstructorArgumentsPresent(tc)
            args = {'PortType','ElementNumber','EnergyDomain'};
            content = tc.readWikiFile('gmt_Port.md');
            for i = 1:numel(args)
                tc.assertTrue(contains(content, args{i}), ...
                    sprintf('gmt_Port.md constructor must document: %s', args{i}))
            end
        end

        function test_edgeAndVertexConnectionTypesPresent(tc)
            content = tc.readWikiFile('gmt_Port.md');
            tc.assertTrue(contains(content, 'EdgeConnection'), ...
                'gmt_Port.md must document EdgeConnection port type.')
            tc.assertTrue(contains(content, 'VertexConnection'), ...
                'gmt_Port.md must document VertexConnection port type.')
        end

        function test_energyDomainEnumerationComplete(tc)
            domains = {'Hydraulic','Electrical','Thermal','Mechanical'};
            content = tc.readWikiFile('gmt_Port.md');
            for i = 1:numel(domains)
                tc.assertTrue(contains(content, domains{i}), ...
                    sprintf('gmt_Port.md must list energy domain: %s', domains{i}))
            end
        end

        function test_portTypeEnumerationPresent(tc)
            content = tc.readWikiFile('gmt_Port.md');
            tc.assertTrue(contains(content, 'gmt_PortType'), ...
                'gmt_Port.md must document gmt_PortType enumeration.')
        end

        function test_energyDomainMatchingNotePresent(tc)
            content = tc.readWikiFile('gmt_Port.md');
            tc.assertTrue(contains(content, 'must share'), ...
                'gmt_Port.md must state that paired ports must share the same EnergyDomain.')
        end

    end

end
