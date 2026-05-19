%% test_wiki_CoreConcepts
classdef test_wiki_CoreConcepts < gmt_WikiTestBase
    methods (Test)

        function test_fileExists(tc)
            tc.assertTrue(isfile(fullfile(tc.WikiDir, 'Core-Concepts.md')), ...
                'Core-Concepts.md does not exist.')
        end

        function test_vertexSectionPresent(tc)
            content = tc.readWikiFile('Core-Concepts.md');
            tc.assertTrue(contains(content, '## Vertices'), ...
                'Core-Concepts.md must have a Vertices section.')
        end

        function test_edgeSectionPresent(tc)
            content = tc.readWikiFile('Core-Concepts.md');
            tc.assertTrue(contains(content, '## Edges'), ...
                'Core-Concepts.md must have an Edges section.')
        end

        function test_dynamicAndAlgebraicVerticesDocumented(tc)
            content = tc.readWikiFile('Core-Concepts.md');
            tc.assertTrue(contains(content, 'dynamic'), ...
                'Core-Concepts.md must describe dynamic vertices.')
            tc.assertTrue(contains(content, 'algebraic'), ...
                'Core-Concepts.md must describe algebraic vertices.')
        end

        function test_dotSuffixDocumented(tc)
            content = tc.readWikiFile('Core-Concepts.md');
            tc.assertTrue(contains(content, '_dot'), ...
                'Core-Concepts.md must document the _dot suffix for dynamic states.')
        end

        function test_edgeMatrixConventionDocumented(tc)
            content = tc.readWikiFile('Core-Concepts.md');
            tc.assertTrue(contains(content, 'tail'), ...
                'Core-Concepts.md must explain tail vertex convention.')
            tc.assertTrue(contains(content, 'head'), ...
                'Core-Concepts.md must explain head vertex convention.')
        end

        function test_groundNodeDocumented(tc)
            content = tc.readWikiFile('Core-Concepts.md');
            tc.assertTrue(contains(content, 'ground'), ...
                'Core-Concepts.md must document the ground/reservoir node convention.')
        end

        function test_parameterTypesTablePresent(tc)
            content = tc.readWikiFile('Core-Concepts.md');
            tc.assertTrue(contains(content, 'Analytical'), ...
                'Core-Concepts.md must document Analytical model type.')
            tc.assertTrue(contains(content, 'Numerical'), ...
                'Core-Concepts.md must document Numerical model type.')
        end

        function test_linearizationSectionPresent(tc)
            content = tc.readWikiFile('Core-Concepts.md');
            tc.assertTrue(contains(content, 'Linearization'), ...
                'Core-Concepts.md must have a Linearization section.')
            tc.assertTrue(contains(content, 'gmt_ControlModel'), ...
                'Core-Concepts.md must reference gmt_ControlModel.')
        end

        function test_systemEquationFormulaPresent(tc)
            content = tc.readWikiFile('Core-Concepts.md');
            tc.assertTrue(contains(content, '\sigma'), ...
                'Core-Concepts.md must include the state equation formula.')
        end

        function test_seeAlsoLinksValid(tc)
            links = {'Toolbox-Classes','Quick-Start','gmt_Graph','gmt_Vertex','gmt_Edge'};
            content = tc.readWikiFile('Core-Concepts.md');
            for i = 1:numel(links)
                tc.assertTrue(contains(content, links{i}), ...
                    sprintf('Core-Concepts.md See Also is missing: %s', links{i}))
            end
        end

    end
end
