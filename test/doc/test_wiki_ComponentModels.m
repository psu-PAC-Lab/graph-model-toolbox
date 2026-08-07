%% test_wiki_ComponentModels
classdef test_wiki_ComponentModels < gmt_WikiTestBase
    methods (Test)

        function test_fileExists(tc)
            tc.assertTrue(isfile(fullfile(tc.WikiDir, 'Component-Library.md')), ...
                'Component-Library.md does not exist.')
        end

        function test_allThreeComponentsDocumented(tc)
            components = {'gmt_Tank','gmt_HeatLoad','gmt_SplitJunction'};
            content = tc.readWikiFile('Component-Models.md');
            for i = 1:numel(components)
                tc.assertTrue(contains(content, components{i}), ...
                    sprintf('Component-Models.md is missing: %s', components{i}))
            end
        end

        function test_tankStatesDocumented(tc)
            content = tc.readWikiFile('Component-Models.md');
            tc.assertTrue(contains(content, 'Temperature'), ...
                'Component-Models.md must document tank Temperature state.')
            tc.assertTrue(contains(content, 'Mass'), ...
                'Component-Models.md must document tank Mass state.')
        end

        function test_tankInputsDocumented(tc)
            content = tc.readWikiFile('Component-Models.md');
            tc.assertTrue(contains(content, 'u1'), ...
                'Component-Models.md must document inlet flow input u1.')
            tc.assertTrue(contains(content, 'u2'), ...
                'Component-Models.md must document outlet flow input u2.')
        end

        function test_tankPortsDocumented(tc)
            content = tc.readWikiFile('Component-Models.md');
            tc.assertTrue(contains(content, 'EdgeConnection'), ...
                'Component-Models.md must document port type EdgeConnection.')
        end

        function test_commonParametersDocumented(tc)
            content = tc.readWikiFile('Component-Models.md');
            tc.assertTrue(contains(content, 'cp_f'), ...
                'Component-Models.md must document common parameter cp_f.')
            tc.assertTrue(contains(content, 'Rho'), ...
                'Component-Models.md must document common parameter Rho.')
        end

        function test_splitJunctionConstructorSignatureCorrect(tc)
            content = tc.readWikiFile('Component-Models.md');
            tc.assertTrue(contains(content, 'NumInlets'), ...
                'Component-Models.md must document NumInlets argument.')
            tc.assertTrue(contains(content, 'NumOutlets'), ...
                'Component-Models.md must document NumOutlets argument.')
        end

        function test_noGmtPlottingReference(tc)
            content = tc.readWikiFile('Component-Models.md');
            tc.assertFalse(contains(content, 'gmt_Plotting('), ...
                'Component-Models.md must not call gmt_Plotting directly.')
        end

        function test_noDeadLinks(tc)
            content = tc.readWikiFile('Component-Models.md');
            tc.assertFalse(contains(content, 'Examples'), ...
                'Component-Models.md must not link to the deleted Examples page.')
        end

        function test_seeAlsoLinks(tc)
            content = tc.readWikiFile('Component-Models.md');
            tc.assertTrue(contains(content, 'Creating-Systems'), ...
                'Component-Models.md See Also must link to Creating-Systems.')
            tc.assertTrue(contains(content, 'Tutorial'), ...
                'Component-Models.md See Also must link to Tutorial.')
        end

    end
end
