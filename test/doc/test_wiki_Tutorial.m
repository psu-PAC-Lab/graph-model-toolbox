%% test_wiki_Tutorial
classdef test_wiki_Tutorial < gmt_WikiTestBase
    methods (Test)

        function test_fileExists(tc)
            tc.assertTrue(isfile(fullfile(tc.WikiDir, 'Tutorial.md')), ...
                'Tutorial.md does not exist.')
        end

        function test_twoPartsPresent(tc)
            content = tc.readWikiFile('Tutorial.md');
            tc.assertTrue(contains(content, 'Part 1'), 'Tutorial.md must contain Part 1.')
            tc.assertTrue(contains(content, 'Part 2'), 'Tutorial.md must contain Part 2.')
        end

        function test_part1CoversSingleTank(tc)
            content = tc.readWikiFile('Tutorial.md');
            tc.assertTrue(contains(content, 'gmt_Tank'), ...
                'Tutorial.md Part 1 must use gmt_Tank.')
        end

        function test_initConDocumented(tc)
            content = tc.readWikiFile('Tutorial.md');
            tc.assertTrue(contains(content, 'gmt_InitCon'), ...
                'Tutorial.md must document gmt_InitCon.')
        end

        function test_generatedFileNamesCorrect(tc)
            content = tc.readWikiFile('Tutorial.md');
            tc.assertTrue(contains(content, 'sysFun_'), ...
                'Tutorial.md must use the sysFun_ file naming convention.')
            tc.assertFalse(contains(content, '_fun.m'), ...
                'Tutorial.md must not use the old _fun.m file naming convention.')
        end

        function test_part2FuelSystemComponents(tc)
            components = {'gmt_HeatLoad','gmt_Tank','gmt_SplitJunction'};
            content = tc.readWikiFile('Tutorial.md');
            for i = 1:numel(components)
                tc.assertTrue(contains(content, components{i}), ...
                    sprintf('Tutorial.md Part 2 must use component: %s', components{i}))
            end
        end

        function test_gmtCombineCallPresent(tc)
            content = tc.readWikiFile('Tutorial.md');
            tc.assertTrue(contains(content, 'gmt_Combine'), ...
                'Tutorial.md must show a gmt_Combine call.')
        end

        function test_inputMatchingPresent(tc)
            content = tc.readWikiFile('Tutorial.md');
            tc.assertTrue(contains(content, 'gmt_InputCommon'), ...
                'Tutorial.md must document gmt_InputCommon.')
        end

        function test_domanReferencePresent(tc)
            content = tc.readWikiFile('Tutorial.md');
            tc.assertTrue(contains(content, 'Doman'), ...
                'Tutorial.md must cite the Doman 2016 reference.')
        end

        function test_summaryTablePresent(tc)
            content = tc.readWikiFile('Tutorial.md');
            tc.assertTrue(contains(content, 'Summary'), ...
                'Tutorial.md must include a Summary section.')
        end

        function test_noGmtPlottingCall(tc)
            content = tc.readWikiFile('Tutorial.md');
            tc.assertFalse(contains(content, 'gmt_Plotting('), ...
                'Tutorial.md must not call gmt_Plotting directly.')
        end

        function test_seeAlsoLinksValid(tc)
            content = tc.readWikiFile('Tutorial.md');
            tc.assertFalse(contains(content, 'Getting-Started'), ...
                'Tutorial.md See Also must not link to deleted Getting-Started page.')
            tc.assertFalse(contains(content, 'Examples'), ...
                'Tutorial.md See Also must not link to deleted Examples page.')
        end

    end
end
