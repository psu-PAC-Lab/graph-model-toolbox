%% gmt_WikiTestBase
% Abstract base class for gmt wiki unit tests.
%
% Resolves the absolute path to the wiki folder at test-class setup time by
% walking up the directory tree from the concrete test file's location until a
% sibling folder named "wiki" is found.  This approach works on Windows, macOS,
% and Linux regardless of the MATLAB working directory.
%
% Assumed repository layout (siblings at any depth):
%   <repo>/
%     wiki/        <- markdown files
%     tests/       <- test files (may be nested in a subfolder)
%
% Subclass usage:
%   classdef test_wiki_Foo < gmt_WikiTestBase
%       methods (Test)
%           function test_something(tc)
%               content = tc.readWikiFile('Foo.md');
%               tc.assertTrue(contains(content, 'expected text'), 'message')
%           end
%       end
%   end

classdef (Abstract) gmt_WikiTestBase < matlab.unittest.TestCase

    properties (Access = protected)
        WikiDir  % absolute path to the wiki/ folder
    end

    methods (TestClassSetup)
        function resolveWikiPath(tc)
            % Derive the starting directory from the concrete subclass file.
            % mfilename returns the name of the currently running test class,
            % so fullfile(fileparts(which(class(tc)))) gives its folder.
            startDir = fileparts(which(class(tc)));
            wikiDir  = gmt_WikiTestBase.findWikiDir(startDir);
            tc.assertNotEmpty(wikiDir, ...
                sprintf(['Could not locate a ''wiki'' folder by traversing up ' ...
                         'from:\n  %s\n' ...
                         'Ensure the repo has wiki/ and tests/ as siblings.'], startDir))
            tc.WikiDir = wikiDir;
        end
    end

    methods (Access = protected)
        function content = readWikiFile(tc, filename)
            % Return the full text of a wiki markdown file.
            fullPath = fullfile(tc.WikiDir, filename);
            tc.assertTrue(isfile(fullPath), ...
                sprintf('Wiki file does not exist: %s', fullPath))
            content = fileread(fullPath);
        end
    end

    methods (Static, Access = private)
        function wikiDir = findWikiDir(startDir)
            % Walk up the directory tree from startDir, checking at each
            % level whether a subfolder named 'wiki' exists.
            % Returns '' if no such folder is found within 20 levels.
            wikiDir = '';
            current = startDir;
            for k = 1:20
                candidate = fullfile(current, 'wiki');
                if isfolder(candidate)
                    wikiDir = candidate;
                    return
                end
                parent = fileparts(current);
                if strcmp(parent, current)
                    return  % reached filesystem root without finding wiki/
                end
                current = parent;
            end
        end
    end

end
