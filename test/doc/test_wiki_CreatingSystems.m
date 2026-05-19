%% test_wiki_CreatingSystems
classdef test_wiki_CreatingSystems < gmt_WikiTestBase
    methods (Test)

        function test_fileExists(tc)
            tc.assertTrue(isfile(fullfile(tc.WikiDir, 'Creating-Systems.md')), ...
                'Creating-Systems.md does not exist.')
        end

        function test_fiveStepsPresent(tc)
            content = tc.readWikiFile('Creating-Systems.md');
            tc.assertTrue(contains(content, 'Step 1'), 'Creating-Systems.md must have Step 1.')
            tc.assertTrue(contains(content, 'Step 2'), 'Creating-Systems.md must have Step 2.')
            tc.assertTrue(contains(content, 'Step 3'), 'Creating-Systems.md must have Step 3.')
            tc.assertTrue(contains(content, 'Step 4'), 'Creating-Systems.md must have Step 4.')
            tc.assertTrue(contains(content, 'Step 5'), 'Creating-Systems.md must have Step 5.')
        end

        function test_gmtCombineSignatureCorrect(tc)
            content = tc.readWikiFile('Creating-Systems.md');
            tc.assertTrue(contains(content, 'PrimaryObj'), ...
                'Creating-Systems.md must document PrimaryObj in gmt_Combine.')
            tc.assertTrue(contains(content, 'SecondaryObj'), ...
                'Creating-Systems.md must document SecondaryObj in gmt_Combine.')
            tc.assertTrue(contains(content, 'ObjectArray'), ...
                'Creating-Systems.md must document ObjectArray.')
            tc.assertTrue(contains(content, 'PortArray'), ...
                'Creating-Systems.md must document PortArray.')
        end

        function test_gmtCombineCallPresent(tc)
            content = tc.readWikiFile('Creating-Systems.md');
            tc.assertTrue(contains(content, 'gmt_Combine'), ...
                'Creating-Systems.md must show a gmt_Combine call.')
        end

        function test_inputMatchingWarningPresent(tc)
            content = tc.readWikiFile('Creating-Systems.md');
            tc.assertTrue(contains(content, 'not'), ...
                'Creating-Systems.md must warn that input dependencies are not auto-resolved.')
            tc.assertTrue(contains(content, 'gmt_InputCommon'), ...
                'Creating-Systems.md must document gmt_InputCommon.')
        end

        function test_portConnectionRulesPresent(tc)
            content = tc.readWikiFile('Creating-Systems.md');
            tc.assertTrue(contains(content, 'EnergyDomain'), ...
                'Creating-Systems.md must state that energy domains must match.')
        end

        function test_fuelSystemComponentsUsedAsExample(tc)
            components = {'gmt_Tank','gmt_HeatLoad','gmt_SplitJunction'};
            content = tc.readWikiFile('Creating-Systems.md');
            for i = 1:numel(components)
                tc.assertTrue(contains(content, components{i}), ...
                    sprintf('Creating-Systems.md should use %s in its example.', components{i}))
            end
        end

    end
end
