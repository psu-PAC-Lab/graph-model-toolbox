%% test_wiki_Home
classdef test_wiki_Home < gmt_WikiTestBase
    methods (Test)

        function test_homeMdExists(tc)
            tc.assertTrue(isfile(fullfile(tc.WikiDir, 'Home.md')), ...
                'Home.md does not exist in the wiki directory.')
        end

        function test_contentsTableHasAllSections(tc)
            links = {'Quick-Start','Core-Concepts','Toolbox-Classes', ...
                     'Model-Interaction','Component-Models','Creating-Systems', ...
                     'Simulating-Systems','Creating-Components','Tutorial'};
            content = tc.readWikiFile('Home.md');
            for i = 1:numel(links)
                tc.assertTrue(contains(content, links{i}), ...
                    sprintf('Home.md is missing a link to: %s', links{i}))
            end
        end

        function test_classHierarchyListsCoreClasses(tc)
            classes = {'gmt_Graph','gmt_Vertex','gmt_Edge', ...
                       'gmt_Parameter','gmt_Input','gmt_Port'};
            content = tc.readWikiFile('Home.md');
            for i = 1:numel(classes)
                tc.assertTrue(contains(content, classes{i}), ...
                    sprintf('Home.md class hierarchy is missing: %s', classes{i}))
            end
        end

        function test_classHierarchyListsComponentModels(tc)
            components = {'gmt_Tank','gmt_HeatLoad','gmt_SplitJunction'};
            content = tc.readWikiFile('Home.md');
            for i = 1:numel(components)
                tc.assertTrue(contains(content, components{i}), ...
                    sprintf('Home.md class hierarchy is missing component: %s', components{i}))
            end
        end

        function test_workflowDiagramPresent(tc)
            content = tc.readWikiFile('Home.md');
            tc.assertTrue(contains(content, 'Workflow'), ...
                'Home.md is missing the workflow section.')
        end

        function test_noStaleLinks(tc)
            stale = {'Getting-Started','Examples','API-Reference', ...
                     'Enumeration-Classes','Utility-Functions','gmt_Plotting'};
            content = tc.readWikiFile('Home.md');
            for i = 1:numel(stale)
                tc.assertFalse(contains(content, stale{i}), ...
                    sprintf('Home.md contains a stale link to: %s', stale{i}))
            end
        end

    end
end
