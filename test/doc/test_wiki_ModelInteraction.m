%% test_wiki_ModelInteraction
classdef test_wiki_ModelInteraction < gmt_WikiTestBase
    methods (Test)

        function test_fileExists(tc)
            tc.assertTrue(isfile(fullfile(tc.WikiDir, 'Model-Interaction.md')), ...
                'Model-Interaction.md does not exist.')
        end

        function test_allReportMethodsDocumented(tc)
            methods_ = {'gmt_ReportGraph','gmt_ReportParameter','gmt_ReportInput', ...
                        'gmt_ReportInitCon','gmt_ReportConnection','gmt_ReportFull'};
            content = tc.readWikiFile('Model-Interaction.md');
            for i = 1:numel(methods_)
                tc.assertTrue(contains(content, methods_{i}), ...
                    sprintf('Model-Interaction.md is missing report method: %s', methods_{i}))
            end
        end

        function test_plotGraphDocumented(tc)
            content = tc.readWikiFile('Model-Interaction.md');
            tc.assertTrue(contains(content, 'gmt_PlotGraph'), ...
                'Model-Interaction.md must document gmt_PlotGraph.')
        end

        function test_simplifyLabelsOptionDocumented(tc)
            content = tc.readWikiFile('Model-Interaction.md');
            tc.assertTrue(contains(content, 'SimplifyLabels'), ...
                'Model-Interaction.md must document the SimplifyLabels option.')
        end

        function test_noDirectGmtPlottingCall(tc)
            content = tc.readWikiFile('Model-Interaction.md');
            tc.assertFalse(contains(content, 'gmt_Plotting('), ...
                'Model-Interaction.md must not call gmt_Plotting directly.')
        end

        function test_linearizationOptionsDocumented(tc)
            options = {'Simplify','NumSub','Discrete'};
            content = tc.readWikiFile('Model-Interaction.md');
            for i = 1:numel(options)
                tc.assertTrue(contains(content, options{i}), ...
                    sprintf('Model-Interaction.md must document gmt_ControlModel option: %s', options{i}))
            end
        end

        function test_affineOffsetZDocumented(tc)
            content = tc.readWikiFile('Model-Interaction.md');
            tc.assertTrue(contains(content, 'affine'), ...
                'Model-Interaction.md must explain the affine offset Z.')
        end

        function test_systemEquationsFieldDocumented(tc)
            content = tc.readWikiFile('Model-Interaction.md');
            tc.assertTrue(contains(content, 'SystemEquations'), ...
                'Model-Interaction.md must document SystemEquations.')
            tc.assertTrue(contains(content, 'SystemEquationsSubs'), ...
                'Model-Interaction.md must document SystemEquationsSubs.')
        end

        function test_paramUpdateMethodsDocumented(tc)
            methods_ = {'gmt_ParamVals','gmt_ParamOpt','gmt_ParamCommon'};
            content = tc.readWikiFile('Model-Interaction.md');
            for i = 1:numel(methods_)
                tc.assertTrue(contains(content, methods_{i}), ...
                    sprintf('Model-Interaction.md is missing method: %s', methods_{i}))
            end
        end

        function test_analyticalOnlyWarningPresent(tc)
            content = tc.readWikiFile('Model-Interaction.md');
            tc.assertTrue(contains(content, 'Analytical'), ...
                'Model-Interaction.md must note that linearization requires an Analytical model.')
        end

    end
end
