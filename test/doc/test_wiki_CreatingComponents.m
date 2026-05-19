%% test_wiki_CreatingComponents
classdef test_wiki_CreatingComponents < gmt_WikiTestBase
    methods (Test)

        function test_fileExists(tc)
            tc.assertTrue(isfile(fullfile(tc.WikiDir, 'Creating-Components.md')), ...
                'Creating-Components.md does not exist.')
        end

        function test_subclassPatternPresent(tc)
            content = tc.readWikiFile('Creating-Components.md');
            tc.assertTrue(contains(content, '< gmt_Graph'), ...
                'Creating-Components.md must show the classdef < gmt_Graph pattern.')
        end

        function test_constructorTemplatePresent(tc)
            content = tc.readWikiFile('Creating-Components.md');
            tc.assertTrue(contains(content, 'varargin'), ...
                'Creating-Components.md must show varargin forwarding to the superclass.')
            tc.assertTrue(contains(content, 'obj@gmt_Graph'), ...
                'Creating-Components.md must show the superclass constructor call.')
        end

        function test_allSevenStepsPresent(tc)
            steps = {'1.','2.','3.','4.','5.','6.','7.'};
            content = tc.readWikiFile('Creating-Components.md');
            for i = 1:numel(steps)
                tc.assertTrue(contains(content, steps{i}), ...
                    sprintf('Creating-Components.md must document step %s', steps{i}))
            end
        end

        function test_portDefinitionPresent(tc)
            content = tc.readWikiFile('Creating-Components.md');
            tc.assertTrue(contains(content, 'gmt_Port'), ...
                'Creating-Components.md must document port definition.')
        end

        function test_commonParameterTipPresent(tc)
            content = tc.readWikiFile('Creating-Components.md');
            tc.assertTrue(contains(content, 'Common'), ...
                'Creating-Components.md must note the Common flag for shared parameters.')
        end

        function test_standaloneTestingExamplePresent(tc)
            content = tc.readWikiFile('Creating-Components.md');
            tc.assertTrue(contains(content, 'gmt_ReportFull'), ...
                'Creating-Components.md must show standalone testing with gmt_ReportFull.')
            tc.assertTrue(contains(content, 'gmt_PlotGraph'), ...
                'Creating-Components.md must show standalone testing with gmt_PlotGraph.')
        end

        function test_noGmtPlottingCall(tc)
            content = tc.readWikiFile('Creating-Components.md');
            tc.assertFalse(contains(content, 'gmt_Plotting('), ...
                'Creating-Components.md must not call gmt_Plotting directly.')
        end

    end
end
