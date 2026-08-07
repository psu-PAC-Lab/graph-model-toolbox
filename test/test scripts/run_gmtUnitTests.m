function results = run_gmtUnitTests()
    import matlab.unittest.TestSuite
    import matlab.unittest.TestRunner
    import matlab.unittest.plugins.CodeCoveragePlugin
    import matlab.unittest.plugins.DiagnosticsRecordingPlugin

    % Find parent folder
    currentFolder = which('run_gmtUnitTests.m');
    parentFolder = fileparts(fileparts(currentFolder));

    % Folder containing your test classes
    testFolder = fullfile(parentFolder, 'unit');

    % Automatically find all test files/classes
    suite = TestSuite.fromFolder(testFolder, ...
        'IncludingSubfolders', true);

    % Create runner
    runner = TestRunner.withTextOutput('Verbosity', 2);

    % Optional: record diagnostics
    runner.addPlugin(DiagnosticsRecordingPlugin);

    % Run tests
    results = runner.run(suite);

    % Display summary
    disp(table(results))
end