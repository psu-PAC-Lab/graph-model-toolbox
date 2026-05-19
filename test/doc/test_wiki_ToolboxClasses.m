%% test_wiki_ToolboxClasses
classdef test_wiki_ToolboxClasses < gmt_WikiTestBase
    methods (Test)

        function test_fileExists(tc)
            tc.assertTrue(isfile(fullfile(tc.WikiDir, 'Toolbox-Classes.md')), ...
                'Toolbox-Classes.md does not exist.')
        end

        function test_allCoreClassesLinked(tc)
            classes = {'gmt_Graph','gmt_Vertex','gmt_Edge', ...
                       'gmt_Parameter','gmt_Input','gmt_Port'};
            content = tc.readWikiFile('Toolbox-Classes.md');
            for i = 1:numel(classes)
                tc.assertTrue(contains(content, classes{i}), ...
                    sprintf('Toolbox-Classes.md is missing: %s', classes{i}))
            end
        end

        function test_allEnumerationsListed(tc)
            enums = {'gmt_EdgeType','gmt_VertexType','gmt_StateType', ...
                     'gmt_ParameterType','gmt_ModelType','gmt_PortType','gmt_EnergyDomain'};
            content = tc.readWikiFile('Toolbox-Classes.md');
            for i = 1:numel(enums)
                tc.assertTrue(contains(content, enums{i}), ...
                    sprintf('Toolbox-Classes.md is missing enumeration: %s', enums{i}))
            end
        end

        function test_removedClassesAbsent(tc)
            removed = {'gmt_Fluid','gmt_Units'};
            content = tc.readWikiFile('Toolbox-Classes.md');
            for i = 1:numel(removed)
                tc.assertFalse(contains(content, removed{i}), ...
                    sprintf('Toolbox-Classes.md must not list removed class: %s', removed{i}))
            end
        end

        function test_enumerationsLinkedToCorrectPage(tc)
            content = tc.readWikiFile('Toolbox-Classes.md');
            tc.assertTrue(contains(content, 'gmt_Edge'), ...
                'Toolbox-Classes.md must link gmt_EdgeType to gmt_Edge.')
            tc.assertTrue(contains(content, 'gmt_Vertex'), ...
                'Toolbox-Classes.md must link gmt_VertexType to gmt_Vertex.')
            tc.assertTrue(contains(content, 'gmt_Port'), ...
                'Toolbox-Classes.md must link gmt_PortType to gmt_Port.')
        end

    end
end
