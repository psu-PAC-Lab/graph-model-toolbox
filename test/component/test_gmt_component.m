%% test_gmt_component
% component test class for nondynamic components

classdef (Abstract) test_gmt_component < matlab.unittest.TestCase

    %% Properties 
    properties
        ClassUnderTest  % e.g. @gmt_Tank 
        initArg         % initial condition  that pass
        initArgFail     % initial conditions that fail
        ctrlInputs      % control inputs 
        varInputs       % variable inputs for dynamic components    
    end

    %% test setup
    methods
        function obj = makeObject(testCase, varArg)
        
            % object default name
            objName = "obj_tmp";

            % instantiate component model 
            obj = testCase.ClassUnderTest(objName, varArg{:});

        end
    end

    %% test 
    methods (Test)

        %% test constructor
        function testConstructor(testCase)

            % dynamic inputs
            varInputs = testCase.varInputs;

            % variable input arguments
            if ~isempty(varInputs)
                varArgs = {varInputs{:}};
            else
                varArgs = {};
            end

            % create Object 
            obj_tmp = testCase.makeObject(varArgs);

            % expect object name
            expected = "obj_tmp";
            
            % verify object created
            testCase.verifyNotEmpty(obj_tmp)

            % verify object name matches expected name
            testCase.verifyEqual(obj_tmp.Name,expected)

        end

        %% test build simulation during instantation
        function testBuildSim_Inst(testCase)

            % Save current directory 
            originalDir = pwd;

            % Automatically restore when function exits 
            cleanupObj = onCleanup(@() cd(originalDir));

            % Create temporary folder
            tempDir = tempname;
            mkdir(tempDir);   

            % Automatically remove temporary folder
            cleanupTemp = onCleanup(@() rmdir(tempDir,'s'));
            cd(tempDir);

            % dynamic inputs
            varInputs = testCase.varInputs;

            % variable input arguments
            if ~isempty(varInputs)
                varArgs = {varInputs{:},"BuildSim",string(tempDir)};
            else
                varArgs = {"BuildSim",string(tempDir)};
            end

            % create Object 
            obj_tmp = testCase.makeObject(varArgs);
  
            % Find newly created folders
            d = dir(tempDir);
            d = d([d.isdir]);
            d = d(~ismember({d.name}, {'.', '..'}));
            
            % Verify only one folder created
            testCase.verifyNumElements(d, 1);
            
            % Determine output directory
            outputDir = fullfile(tempDir, d(1).name);

            % Change to output directory 
            cd(outputDir)

            % Verify files created 
            testCase.verifyTrue(isfile("sysFun_obj_tmp.m"))
            testCase.verifyTrue(isfile("sysFun_obj_tmpSimScript.m"))
            testCase.verifyTrue(isfile("sysObj_obj_tmp.mat"))

        end

        %% test build simulation after instantation
        function testSimpleBuildSim_Post(testCase)

            % save current directory 
            originalDir = pwd;

            % automatically restore when function exits 
            cleanupObj = onCleanup(@() cd(originalDir));

            % create temporary folder
            tempDir = tempname;
            mkdir(tempDir);   

            % automatically remove temporary folder
            cleanupTemp = onCleanup(@() rmdir(tempDir,'s'));
            cd(tempDir);

            % dynamic inputs
            varInputs = testCase.varInputs;

            % variable input arguments
            if ~isempty(varInputs)
                varArgs = {varInputs{:}};
            else
                varArgs = {};
            end

            % create Object 
            obj_tmp = testCase.makeObject(varArgs);
  
            % run post build simulation method
            obj_tmp = obj_tmp.gmt_BuildSim(string(pwd));

            % find newly created folders
            d = dir(tempDir);
            d = d([d.isdir]);
            d = d(~ismember({d.name}, {'.', '..'}));
            
            % verify only one folder created
            testCase.verifyNumElements(d, 1);
            
            % determine output directory
            outputDir = fullfile(tempDir, d(1).name);

            % change to output directory 
            cd(outputDir)

            % verify files created 
            testCase.verifyTrue(isfile("sysFun_obj_tmp.m"))
            testCase.verifyTrue(isfile("sysFun_obj_tmpSimScript.m"))
            testCase.verifyTrue(isfile("sysObj_obj_tmp.mat"))

        end

        %% test adding passing initial conditions during instantation
        function testPassInitCon(testCase)
            
            % grab initial conditions 
            initArg = testCase.initArg;

            % dynamic inputs
            varInputs = testCase.varInputs;

            % variable input arguments
            if ~isempty(varInputs)
                varArgs = {varInputs{:},"InitCon",initArg};
            else
                varArgs = {"InitCon",initArg};
            end

            % create Object 
            obj_tmp = testCase.makeObject(varArgs);
            
            % verify Initial Conditions 
            for i = 1:length(initArg)
                testCase.verifyTrue(obj_tmp.InitialConditions(i) == initArg(i));
            end

        end

        %% test adding passing initial conditions after instantation
        function testPassInitCon_Post(testCase)
            
            % grab initial conditions 
            initArg = testCase.initArg;

            % dynamic inputs
            varInputs = testCase.varInputs;

            % variable input arguments
            if ~isempty(varInputs)
                varArgs = {varInputs{:}};
            else
                varArgs = {};
            end

            % create Object 
            obj_tmp = testCase.makeObject(varArgs);
            
            % add initial conditions
            obj_tmp = obj_tmp.gmt_InitCon(initArg);
            
            % verify Initial Conditions
            for i = 1:length(initArg)
                testCase.verifyTrue(obj_tmp.InitialConditions(i) == initArg(i));
            end

        end

        %% test adding initial conditions during instantation
        function testFailInitCon(testCase)
            
            % grab initial conditions 
            initArg = testCase.initArgFail;

            % dynamic inputs
            varInputs = testCase.varInputs;

            % variable input arguments
            if ~isempty(varInputs)
                varArgs = {varInputs{:},"InitCon",initArg};
            else
                varArgs = {"InitCon",initArg};
            end

            try
                testCase.makeObject(varArgs);
                testCase.assertFail('Expected an exception.');
            catch ME
                testCase.verifyEqual( ...
                    ME.message, ...
                    'Number of initial conditions does not match number of states');
            end
            
        end

        %% test adding initial conditions during instantation
        function testFailInitCon_Post(testCase)
   
            % grab initial conditions 
            initArg = testCase.initArgFail;

            % dynamic inputs
            varInputs = testCase.varInputs;

            % variable input arguments
            if ~isempty(varInputs)
                varArgs = {varInputs{:}};
            else
                varArgs = {};
            end

            % create Object 
            obj_tmp = testCase.makeObject(varArgs);

            try
                % add initial conditions
                obj_tmp = obj_tmp.gmt_InitCon(initArg);
                testCase.assertFail('Expected an exception.');
            catch ME
                testCase.verifyEqual( ...
                    ME.message, ...
                    'Number of initial conditions does not match number of states');
            end

        end

    end
end