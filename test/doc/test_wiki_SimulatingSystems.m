%% test_wiki_SimulatingSystems
classdef test_wiki_SimulatingSystems < gmt_WikiTestBase
    methods (Test)

        function test_fileExists(tc)
            tc.assertTrue(isfile(fullfile(tc.WikiDir, 'Simulating-Systems.md')), ...
                'Simulating-Systems.md does not exist.')
        end

        function test_initConStepDocumented(tc)
            content = tc.readWikiFile('Simulating-Systems.md');
            tc.assertTrue(contains(content, 'gmt_InitCon'), ...
                'Simulating-Systems.md must document gmt_InitCon.')
        end

        function test_buildSimStepDocumented(tc)
            content = tc.readWikiFile('Simulating-Systems.md');
            tc.assertTrue(contains(content, 'gmt_BuildSim'), ...
                'Simulating-Systems.md must document gmt_BuildSim.')
        end

        function test_generatedFilesDocumented(tc)
            content = tc.readWikiFile('Simulating-Systems.md');
            tc.assertTrue(contains(content, 'sysFun_'), ...
                'Simulating-Systems.md must document the ODE function file name prefix.')
            tc.assertTrue(contains(content, 'SimScript'), ...
                'Simulating-Systems.md must document the simulation script file.')
            tc.assertTrue(contains(content, '.mat'), ...
                'Simulating-Systems.md must document the .mat object file.')
        end

        function test_odeSolverExamplePresent(tc)
            content = tc.readWikiFile('Simulating-Systems.md');
            tc.assertTrue(contains(content, 'ode45'), ...
                'Simulating-Systems.md must show an ode45 example.')
        end

        function test_stiffSolverMentioned(tc)
            content = tc.readWikiFile('Simulating-Systems.md');
            tc.assertTrue(contains(content, 'ode15s'), ...
                'Simulating-Systems.md must recommend ode15s for stiff systems.')
        end

        function test_constructorShortcutDocumented(tc)
            content = tc.readWikiFile('Simulating-Systems.md');
            tc.assertTrue(contains(content, 'BuildSim'), ...
                'Simulating-Systems.md must show the BuildSim constructor shortcut.')
        end

        function test_reportInitConMentioned(tc)
            content = tc.readWikiFile('Simulating-Systems.md');
            tc.assertTrue(contains(content, 'gmt_ReportInitCon'), ...
                'Simulating-Systems.md must reference gmt_ReportInitCon.')
        end

    end
end
