%% test_wiki_QuickStart
classdef test_wiki_QuickStart < gmt_WikiTestBase
    methods (Test)

        function test_fileExists(tc)
            tc.assertTrue(isfile(fullfile(tc.WikiDir, 'Quick-Start.md')), ...
                'Quick-Start.md does not exist.')
        end

        function test_installationSectionPresent(tc)
            content = tc.readWikiFile('Quick-Start.md');
            tc.assertTrue(contains(content, 'Installation'), ...
                'Quick-Start.md is missing an Installation section.')
        end

        function test_installationCommandPresent(tc)
            content = tc.readWikiFile('Quick-Start.md');
            tc.assertTrue(contains(content, 'mltbx'), ...
                'Quick-Start.md must reference the .mltbx installation method.')
        end

        function test_coreConstructorsPresent(tc)
            required = {'gmt_Vertex','gmt_Edge','gmt_Parameter','gmt_Graph'};
            content = tc.readWikiFile('Quick-Start.md');
            for i = 1:numel(required)
                tc.assertTrue(contains(content, required{i}), ...
                    sprintf('Quick-Start.md is missing constructor: %s', required{i}))
            end
        end

        function test_edgeMatrixDocumented(tc)
            content = tc.readWikiFile('Quick-Start.md');
            tc.assertTrue(contains(content, 'EdgeMatrix'), ...
                'Quick-Start.md must document the EdgeMatrix.')
        end

        function test_simulationWorkflowPresent(tc)
            content = tc.readWikiFile('Quick-Start.md');
            tc.assertTrue(contains(content, 'gmt_InitCon'), ...
                'Quick-Start.md must reference gmt_InitCon.')
            tc.assertTrue(contains(content, 'gmt_BuildSim'), ...
                'Quick-Start.md must reference gmt_BuildSim.')
        end

        function test_seeAlsoLinksPresent(tc)
            content = tc.readWikiFile('Quick-Start.md');
            tc.assertTrue(contains(content, 'Simulating-Systems'), ...
                'Quick-Start.md must link to Simulating-Systems.')
            tc.assertTrue(contains(content, 'Core-Concepts'), ...
                'Quick-Start.md must link to Core-Concepts.')
        end

        function test_noStaleReferences(tc)
            content = tc.readWikiFile('Quick-Start.md');
            tc.assertFalse(contains(content, 'gmt_Plotting('), ...
                'Quick-Start.md must not call gmt_Plotting directly; use gmt_PlotGraph.')
        end

    end
end
