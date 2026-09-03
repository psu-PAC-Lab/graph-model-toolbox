%% gmt_Graph
% gmt_Graph  Superclass for graph-based component and system models.
%
% Documentation authored with assistance from OpenAI ChatGPT.
%
%   OBJ = gmt_Graph(NAME, EDGEMATRIX, EDGES, VERTICES, PARAMETERS, INPUTS, PORTS)
%   creates a graph model from an edge matrix, edge objects, vertex objects,
%   parameter objects, input objects, and port objects.
%
%   OBJ = gmt_Graph(..., Name, Value) specifies optional model-building
%   arguments parsed by gmt_parseSuperclass. Supported options include model
%   parameter overrides, system-model construction, initial conditions, and
%   simulation-code generation.
%
%   gmt_Graph is the common superclass used to represent both standalone
%   component models and combined system models. The class stores graph
%   topology, symbolic model equations, model metadata, simulation code,
%   parameter data, port data, state/input/output names, and a MATLAB
%   digraph object for visualization.
%
% Constructor Inputs
%   NAME          - String name of the graph model.
%   EDGEMATRIX    - Ne-by-2 matrix of directed edge connections. Each row
%                   defines [tailVertex headVertex].
%   EDGES         - Vector of gmt_Edge objects.
%   VERTICES      - Vector of gmt_Vertex objects.
%   PARAMETERS    - Vector of gmt_Parameter objects.
%   INPUTS        - Vector of gmt_Input objects.
%   PORTS         - Vector of gmt_Port objects.
%
% Key Properties
%   Name                 - Graph model name.
%   EdgeMatrix           - Directed edge connection matrix.
%   Edges                - Vector of gmt_Edge objects.
%   Vertices             - Vector of gmt_Vertex objects.
%   Properties           - gmt_Properties object containing graph dimensions,
%                          incidence matrix, validity flags, and state/input
%                          indexing.
%   DiGraph              - MATLAB digraph object used for plotting.
%   Inputs               - String array of system input variable names.
%   InputData            - gmt_Input objects associated with active inputs.
%   States               - String array of internal state variable names.
%   Outputs              - String array of output variable names.
%   Disturbances         - String array of external algebraic variables used
%                          by the system equations.
%   Optimization         - String array of parameter variables marked for
%                          optimization.
%   ModelParameters      - gmt_Parameter objects used for model
%                          parameterization.
%   SystemEquations      - Struct containing symbolic equation inputs, LHS,
%                          RHS, and full expressions.
%   SystemEquationsSubs  - Struct containing symbolic equations after
%                          substituting non-optimization parameter values.
%   InitialConditions    - Numeric vector of initial state values.
%   ModelMetadata        - Struct containing model type, generated function
%                          name, generated m-file code, generated parameter
%                          code, and mass matrix.
%   Ports                - gmt_Port objects defining component connection
%                          points.
%
% Public Methods
%   gmt_ControlModel
%       Linearizes the model using first-order Taylor expansion and returns
%       symbolic A, B, and affine offset Z matrices.
%
%       [A,B,Z] = obj.gmt_ControlModel()
%       [A,B,Z] = obj.gmt_ControlModel("Simplify",true)
%       [A,B,Z] = obj.gmt_ControlModel("NumSub",true)
%       [A,B,Z] = obj.gmt_ControlModel("Discrete",dt)
%
%       Name-Value Options:
%           "Simplify" - Simplify symbolic Jacobians. Default: false.
%           "NumSub"   - Use parameter-substituted equations. Default: false.
%           "Discrete" - If supplied, discretize A and B using sample time dt.
%
%   gmt_ReportGraph
%       Displays vertex and edge tables for the full graph model, including
%       state variables, units, capacitance equations, power equations, input
%       variables, and edge equations.
%
%   gmt_ReportInitCon
%       Displays internal state variables and their assigned initial
%       conditions.
%
%   gmt_ReportParameter
%       Displays all model parameters, including parent, variable name,
%       description, units, parameter type, common/system flag, and
%       optimization flag.
%
%   gmt_ReportConnection
%       Displays port connection information, including port number, parent,
%       description, port type, and associated element number.
%
%   gmt_ReportInput
%       Displays active input variables, parent components, descriptions,
%       and units.
%
%   gmt_ReportFull
%       Displays graph, parameter, input, and connection reports.
%
%   gmt_DiGraphUpdate
%       Rebuilds the MATLAB digraph object from EdgeMatrix and updates node
%       labels, edge labels, node colors, and edge colors.
%
%   gmt_PlotGraph
%       Plots the MATLAB digraph representation of the graph model with
%       node labels, edge labels, edge direction arrows, and color coding.
%
%   gmt_ModelUpdate
%       Rebuilds graph-derived model data after topology, edge, vertex,
%       input, or parameter changes. This method validates graph dimensions,
%       updates graph state variables, constructs symbolic system equations,
%       identifies inputs, outputs, disturbances, optimization parameters,
%       model type, and generated simulation-function code.
%
%   gmt_InputCommon
%       Replaces selected input variables with common input expressions and
%       reconstructs the graph model.
%
%       obj = obj.gmt_InputCommon(InputMatching)
%
%       InputMatching is an N-by-2 string array:
%           column 1 - existing input variable or expression
%           column 2 - replacement input variable or expression
%
%   gmt_ParamCommon
%       Replaces selected parameter variables with common parameter
%       expressions and reconstructs the graph model.
%
%       obj = obj.gmt_ParamCommon(ParamMatching)
%
%       ParamMatching is an N-by-2 string array:
%           column 1 - existing parameter variable
%           column 2 - replacement parameter variable
%
%   gmt_ParamOpt
%       Updates parameter optimization flags and reconstructs the model.
%
%       obj = obj.gmt_ParamOpt(ParamOpt)
%
%       ParamOpt is an N-by-2 string array:
%           column 1 - parameter variable
%           column 2 - "true" or "false"
%
%   gmt_ParamVals
%       Updates scalar parameter values and reconstructs the model.
%
%       obj = obj.gmt_ParamVals(ParamVals)
%
%       ParamVals is an N-by-2 string array:
%           column 1 - parameter variable
%           column 2 - numeric value represented as a string
%
%   gmt_InitCon
%       Assigns initial condition values.
%
%       obj = obj.gmt_InitCon(InitConVals)
%
%   gmt_BuildSim
%       Writes generated simulation files to disk. The generated folder
%       contains a system function m-file, a simulation script, and a MAT-file
%       containing the graph object.
%
%       obj = obj.gmt_BuildSim(filepath)
%
% Static Methods
%   gmt_Combine
%       Combines component graph models into a system model using component
%       object pairs and port connection definitions.
%
%       sys = gmt_Graph.gmt_Combine(CombineName, ObjectArray, PortArray)
%
% Notes
%   - EdgeMatrix rows define directed edges as [tailVertex headVertex].
%   - Internal vertices contribute system state variables.
%   - External algebraic vertices used by the equations are stored as
%     disturbances.
%   - Analytical models support symbolic parameter substitution. Models that
%     include lookup-table or neural-network parameters are treated as
%     numerical models.
%   - Component models automatically prefix edge and vertex names with the
%     component name unless the model is constructed as a system model.
%
% See also gmt_Edge, gmt_Vertex, gmt_Parameter, gmt_Input, gmt_Port,
%          gmt_Properties, digraph

classdef gmt_Graph
    properties (SetAccess = public)
        % User Define Meta Data
        Name string % Name of the graph model
        EdgeMatrix double % An edge matrix defining connections between edges and vertices
        Edges gmt_Edge % A vector of edge objects
        Vertices gmt_Vertex % A vector of vertex objects
        Properties gmtProp.gmt_Properties % Object containing overall graph properties
        DiGraph % MATLAB native directed graph object
        Inputs string = [] % String array of system input variable names
        InputData gmt_Input % Input objects to replace inputs in future
        States string % String array of system state variable names
        Outputs string = [] % String array of system output variable names
        Disturbances string = [] % String array of system disturbance variable names
        Optimization string = [] % String array of system optimization variable names
        ModelParameters gmt_Parameter % Model parameters object to manage model parameterization  
        ModelExergy gmt_Exergy % Array of exergy equations 
        SystemEquations = struct("FunctionInputs",[],"LHS",[],"RHS",[],"Expression",[])  % System of equations with parameterization 
        SystemEquationsSubs = struct("FunctionInputs",[],"LHS",[],"RHS",[],"Expression",[])  % System of equations with parameterization with variable substitution  
        InitialConditions double 
        ModelMetadata = struct("ModelType",[],"FunctionName",[],"mfileCode",[],"mfileCode_param",[],"MassMatrix",[]) 
        Ports gmt_Port % Object containing graph model connection points
    end

    %% Public Methods 
    methods (Access = public)
        %% Constructor Graph 
        function obj = gmt_Graph(ObjectName,EdgeMatrix,EdgeArray,VertexArray,ParameterArray,InputArray,PortArray,varargin)
            
            % Assign Data
            obj.Name = ObjectName;
            obj.EdgeMatrix = EdgeMatrix;
            obj.Edges = EdgeArray;
            obj.Vertices = VertexArray;

            % Compute Basic Graph Properties (Nv, Ne, and M) 
            obj.Properties = gmtProp.gmt_Properties(obj);

            % Variable Input Parsing 
            params = gmt_Graph.gmt_parseSuperclass(obj,varargin{:});
            componentMdl = ~params.SystemModel;
            makeFunc_mfile  = ~isempty(params.BuildSim);
            AddInitCons = ~isempty(params.InitCon);

            % Assign Parameter Array
            if ~isempty(ParameterArray)
                % Update User Specified Data
                if ~isempty(params.ModelParameters)
                    default_vars = [ParameterArray.Variable]';
                    defaultContainsExp  = contains(default_vars,"=");

                    if any(defaultContainsExp)
                        default_vars(defaultContainsExp) = strtrim(extractBefore(default_vars(defaultContainsExp),"="));
                    end
                    
                    user_vars = [params.ModelParameters.Variable]';
                    userContainsExp  = contains(user_vars,"=");

                    if any(userContainsExp)
                        user_vars(userContainsExp) = strtrim(extractBefore(user_vars(userContainsExp),"="));
                    end

                    vars_diff = setdiff(default_vars,user_vars);
                    vars_diff2 = setdiff(user_vars,default_vars);
                    assert(isempty(vars_diff),"User did not define [%s] variable(s) as parameter(s)\nUser defined [%s] variables(s) as parameters(s)",join(vars_diff,", "), join(vars_diff2,", "))
                    obj.ModelParameters = params.ModelParameters;
                else
                    obj.ModelParameters = ParameterArray;
                end

                % Update Model Parameter Name
                if componentMdl 
                    for i = 1:length(obj.ModelParameters)
                        if ~obj.ModelParameters(i).Common
                            obj.ModelParameters(i) = obj.ModelParameters(i).gmt_ModelParameterParent(obj.Name);
                        else
                            obj.ModelParameters(i) = obj.ModelParameters(i).gmt_ModelParameterParent("System");
                        end
                    end
                end
            end
            
            % Assign Input Array 
            % Possibly set this up for varargin 
            if ~isempty(InputArray) 
                obj.InputData = InputArray;
                if ~params.SystemModel
                    for i = 1:length(obj.InputData)
                        obj.InputData(i) = obj.InputData(i).gmt_InputParent(obj);
                    end
                end
            end

            % Assign Port Array
            % Possibly set this up for varargin
            if ~isempty(PortArray)
                for i = 1:length(PortArray)
                obj.Ports(i) = PortArray(i).gmt_ParentPort(obj);
                end
            end

            % DiGraph Update
            obj = gmt_DiGraphUpdate(obj);

            % Build Model
            obj = gmt_ModelUpdate(obj,varargin{:});

            % If Requested, Add Initial Conditions
            if AddInitCons
                obj = gmt_InitCon(obj,params.InitCon);
            end

            % If Requested, Build Simulation
            if makeFunc_mfile 
                obj = gmt_BuildSim(obj,params.BuildSim);
            end
        end

        %% Model Linearization
        % Generates linear model based on first order Taylor series approximation 
        function [A, B, Z] = gmt_ControlModel(obj,varargin)
            
            % Input Parsing 
            p = inputParser;
            p.KeepUnmatched = true;
            addParameter(p, 'Simplify',false, @(x) islogical(x) && isscalar(x));
            addParameter(p, 'NumSub',false, @(x) islogical(x) && isscalar(x));
            addParameter(p, 'Discrete',[], @(x) isnumeric(x) && isscalar(x));
            addParameter(p, 'DiscreteType',[], @(x) mustBeMember(x, {'ForwardEuler', 'RK4'}))
            parse(p, varargin{:});

            % Variable Hand-Off
            numSubFlg = p.Results.NumSub;
            simplifyFlg = p.Results.Simplify;
            dt = p.Results.Discrete;
            discreteFlg = ~isempty(dt);
            discreteType = p.Results.DiscreteType;
            inputsFlg = ~isempty([obj.Inputs]);

            % Data Validation 
            analyticalModelFlg = (obj.ModelMetadata.ModelType == gmtEnumE.gmt_ModelType.Analytical);
            discreteMismatchFlg = ~(~discreteFlg && ~isempty(discreteType));
            assert(analyticalModelFlg,"Linearization and discretization only supported ")
            assert(discreteMismatchFlg,"Discretization type specified without discretization rate")

            % Update Discretization Type
           if isempty(discreteType)
                discreteType = "FowardEuler";
            end

            % Symbolic System of Equations 
            switch numSubFlg
                case 0 
                    SysEqn = symfun(obj.SystemEquations.RHS,sym([obj.States,obj.Inputs]));
                case 1
                    SysEqn = symfun(obj.SystemEquationsSubs.RHS,sym([obj.States,obj.Inputs]));
            end

            % Linearized Jacobian 
            switch simplifyFlg
                case 0 
                    A = jacobian(SysEqn,[sym([obj.States])]);
                    B = jacobian(SysEqn,[sym([obj.Inputs])]);
                case 1 
                    A = simplify(jacobian(SysEqn,[sym([obj.States])]));
                    B = simplify(jacobian(SysEqn,[sym([obj.Inputs])]));
            end

            % Affine Term Computation 
            switch inputsFlg
                case 0
                    Z = SysEqn - A*sym([obj.States]).';
                case 1 
                    Z = SysEqn - A*sym([obj.States]).' - B*sym([obj.Inputs]).';
            end
            
            % Discretization 
            if discreteFlg
                switch discreteType
                    case "FowardEuler"
                        n = size(A,1);
                        A = eye(n) + A*dt; 
                        B = B*dt;
                        Z = Z*dt;
                    case "RK4"
                        error("Code Not Developed")
                end
            end

        end

        %% Graph Report
        % Generates then displays vertex and edge report of entire model
        function gmt_ReportGraph(obj)
            % Vertex Table
            varNames_tmp = ["Vertex Name","Vertex Type","State Type","Vertex State Variable","State Variable Units","Capacitance Inputs","Capacitance","Capacitance Equation","Power Equation"];
            for idx_tmp = 1:length(varNames_tmp)
                varTypes_tmp(1,idx_tmp) = {'string'};
            end
            sz = [obj.Properties.Nv length(varNames_tmp)];
            table_tmp = table('Size',sz,'VariableTypes',varTypes_tmp,'VariableNames',varNames_tmp);
            % Assembly Table Data 
            for i = 1:obj.Properties.Nv
                table_tmp(i,1) = {obj.Vertices(i).VertexName};
                table_tmp(i,2) = {obj.Vertices(i).VertexType};
                table_tmp(i,3) = {obj.Vertices(i).StateType};
                if isempty(obj.Vertices(i).GraphStateVariables)
                    if isempty(obj.Vertices(i).GraphOutputVariables)
                        table_tmp(i,4) = {""};
                    else
                       table_tmp(i,4) = {obj.Vertices(i).GraphOutputVariables}; 
                    end
                else
                    table_tmp(i,4) = {obj.Vertices(i).GraphStateVariables};
                end

                if isempty(obj.Vertices(i).Units)
                    table_tmp(i,5) = {"Undefined"};
                else
                    table_tmp(i,5) = {obj.Vertices(i).Units};
                end

                if isempty(obj.Vertices(i).InputVariables)
                    table_tmp(i,6) = {""};
                else
                    table_tmp(i,6) = {join([obj.Vertices(i).InputVariables],", ")};
                end
                table_tmp(i,7) = {obj.Vertices(i).GraphCapacitance};
                table_tmp(i,8) = {str2sym(obj.Vertices(i).GraphCapacitanceEq)};
                table_tmp(i,9) = {str2sym(obj.Vertices(i).GraphPowerEq)};
            end

            fprintf('\n');
            gmtInt.gmt_PrintTable(table_tmp,[false, false, false, true, true, false, false, false, false])


            % Edge Table
            varNames2_tmp = ["Edge Name","Edge Type","Inputs","Edge Equation"];
            for idx2_tmp = 1:length(varNames2_tmp)
                varTypes2_tmp(1,idx2_tmp) = {'string'};
            end
            sz2 = [obj.Properties.Ne length(varNames2_tmp)];
            table2_tmp = table('Size',sz2,'VariableTypes',varTypes2_tmp,'VariableNames',varNames2_tmp);
            % Assembly Table Data 
            for i = 1:obj.Properties.Ne
                table2_tmp(i,1) = {obj.Edges(i).EdgeName};
                table2_tmp(i,2) = {obj.Edges(i).EdgeType};
                if isempty(obj.Edges(i).InputVariables)
                    table2_tmp(i,3) = {""};
                else
                    table2_tmp(i,3) = {join([obj.Edges(i).InputVariables],", ")};
                end

                table2_tmp(i,4) = {str2sym(obj.Edges(i).GraphEdgeEq)};   
            end

            fprintf('\n'); 
            gmtInt.gmt_PrintTable(table2_tmp,[false, false, false, false])



        end

        %% Initial Condition Report
        function gmt_ReportInitCon(obj)
            
            % Inital Condtion Table
            varNames_tmp = ["Vertex Name","Vertex State Variable","Initial Condition","State Variable Units",];
            for idx_tmp = 1:length(varNames_tmp)
                varTypes_tmp(1,idx_tmp) = {'string'};
            end

            intFlg = [obj.Vertices.VertexType] == gmtEnumE.gmt_VertexType.Internal;
            rowSize = sum(intFlg);
            lookupVector = find(intFlg);

            sz = [rowSize  length(varNames_tmp)];
            table_tmp = table('Size',sz,'VariableTypes',varTypes_tmp,'VariableNames',varNames_tmp);

            % Assembly Table Data 
            for j = 1:length(lookupVector)
                i = lookupVector(j);
                table_tmp(j,1) = {obj.Vertices(i).VertexName};
                table_tmp(j,2) = {obj.Vertices(i).GraphStateVariables};
                if ~isempty(obj.InitialConditions) 
                    table_tmp(j,3) = {obj.InitialConditions(j)};
                else
                    table_tmp(j,3) = {"Unassigned"};
                end
                table_tmp(j,4) = {obj.Vertices(i).Units};
            end

            % Convert string columns to cellstr to suppress quotes in display
            Tdisp = table_tmp;
            for v = 1:width(Tdisp)
                if isstring(Tdisp.(v))
                    Tdisp.(v) = cellstr(Tdisp.(v));
                end
            end

            fprintf('\n');
            gmtInt.gmt_PrintTable(table_tmp,[false,true,true,true])

        end
        %% Parameter Report
        % Generates then displays parameter report of all model parameterization 
        function gmt_ReportParameter(obj)
            num_params = length(obj.ModelParameters);
            varNames_tmp = ["Parent", "Parameter", "Description", "Units", "Parameter Type", "System Parameter", "Optimization Parameter"];
            for idx_tmp = 1:length(varNames_tmp)
                varTypes_tmp(1,idx_tmp) = {'string'};
            end
            sz = [num_params length(varNames_tmp)];
            table_tmp = table('Size',sz,'VariableTypes',varTypes_tmp,'VariableNames',varNames_tmp);
            for i = 1:num_params
                table_tmp(i,1) = {obj.ModelParameters(i).Parent};
                table_tmp(i,2) = {obj.ModelParameters(i).Description};
                table_tmp(i,3) = {obj.ModelParameters(i).Variable};
                if  ~isempty(obj.ModelParameters(i).Units)
                    table_tmp(i,4) = {obj.ModelParameters(i).Units};
                else
                    table_tmp(i,4) = {"Not Defined"};
                end
                table_tmp(i,5) = {obj.ModelParameters(i).ParameterType};
                table_tmp(i,6) = {obj.ModelParameters(i).Common};
                table_tmp(i,7) = {obj.ModelParameters(i).Optimization};
                
            end

            [~, sortIdx] = sort(lower([obj.ModelParameters.Variable]));

            fprintf('\n'); 
            gmtInt.gmt_PrintTable(table_tmp(sortIdx,:),[false, false, true, true, true, true, true])

        end

        %% Connection Report  
        % Returns the port connection data in easy to read format
        function gmt_ReportConnection(obj)
            num_params = length(obj.Ports);
            varNames_tmp = ["Port Number","Parent","Description","Energy Domain","PortType", "Element Number"];
            for idx_tmp = 1:length(varNames_tmp)
                varTypes_tmp(1,idx_tmp) = {'string'};
            end
            sz = [num_params length(varNames_tmp)];
            table_tmp = table('Size',sz,'VariableTypes',varTypes_tmp,'VariableNames',varNames_tmp);
            for i = 1:num_params
                table_tmp(i,1) = {i};
                table_tmp(i,2) = {obj.Ports(i).ParentName};
                table_tmp(i,3) = {obj.Ports(i).Description};
                table_tmp(i,4) = {obj.Ports(i).EnergyDomain};
                table_tmp(i,5) = {obj.Ports(i).PortType};
                table_tmp(i,6) = {obj.Ports(i).ElementNumber};
                
            end

            fprintf('\n'); 
            gmtInt.gmt_PrintTable(table_tmp,[true, true, false, true, true, true])

        end

        %% Input Report  
        % Returns the port connection data in easy to read format
        function gmt_ReportInput(obj)

            if ~isempty(obj.InputData)

            num_params = length(obj.InputData);
            varNames_tmp = ["Variable","Parent","Description","Units"];
            for idx_tmp = 1:length(varNames_tmp)
                varTypes_tmp(1,idx_tmp) = {'string'};
            end
            sz = [num_params length(varNames_tmp)];
            table_tmp = table('Size',sz,'VariableTypes',varTypes_tmp,'VariableNames',varNames_tmp);
            for i = 1:num_params
                table_tmp(i,1) = {obj.InputData(i).VariableName};
                table_tmp(i,2) = {obj.InputData(i).Parent};
                table_tmp(i,3) = {obj.InputData(i).Description};
                if ~isempty(obj.InputData(i).Units)
                    table_tmp(i,4) = {obj.InputData(i).Units};
                else 
                    table_tmp(i,4) = {"Missing Units"};
                end
            end

            fprintf('\n');
            gmtInt.gmt_PrintTable(table_tmp,[true,false,false,true])

            else
                fprintf('\n');
                fprintf('no input data contained in model');
                fprintf('\n');
            end

        end

        %% Full Report 
        % Generates all reports 
        function gmt_ReportFull(obj)

            fprintf('\n<strong>Graph Report</strong>\n');
            gmt_ReportGraph(obj)
            fprintf('<strong>Parameter Report</strong>\n');
            gmt_ReportParameter(obj)
            fprintf('<strong>Input Report</strong>\n');
            gmt_ReportInput(obj)
            fprintf('<strong>Connection Port Report</strong>\n');
            gmt_ReportConnection(obj)

        end

        %% DiGraphUpdate
        function obj = gmt_DiGraphUpdate(obj)

            % Vertex Color Coding
            for i = 1:obj.Properties.Nv
                units_tmp = obj.Vertices(i).Units;
                if ~isempty(units_tmp)
                    unitsStr_tmp = " [" + units_tmp + "]";
                else 
                    unitsStr_tmp = " []";
                end
                Vertices_Names_tmp(i,1) = " V" + string(i) + ": " + obj.Vertices(i).VertexName + unitsStr_tmp;
                if obj.Vertices(i).VertexType == gmtEnumE.gmt_VertexType.External
                    color_tmp(i,:) = [1 0 0];
                else
                    color_tmp(i,:) = [0 0 1];
                end
            end

            % Edge Color Coding 
            for i =1:obj.Properties.Ne
                Edges_Names_tmp(i,1) = " E" + string(i) + ": " + obj.Edges(i).EdgeName;
                Edges_Names_celltmp{i,1} = obj.Edges(i).EdgeName;
                if obj.Edges(i).EdgeType  == gmtEnumE.gmt_EdgeType.External 
                    color_tmp2(i,:) = [1 0 0];
                else
                    color_tmp2(i,:) = [0 0 1];
                end
            end

            % Updates direct graph object propeties 
            obj.DiGraph = digraph(obj.EdgeMatrix(:,1),obj.EdgeMatrix(:,2));

            % Reorganize Edge Labels and Color Codes 
            Edges_Names_rotmp = Edges_Names_tmp;
            color_rotmp2 = color_tmp2;

            for i = 1:obj.Properties.Ne
                if ~isequal(table2array(obj.DiGraph.Edges(i,:)),obj.EdgeMatrix(i,:))
                    for j = 1:obj.Properties.Ne
                        if isequal(table2array(obj.DiGraph.Edges(i,:)),obj.EdgeMatrix(j,:))
                        Edges_Names_rotmp(i) = Edges_Names_tmp(j);
                        color_rotmp2(i) = color_tmp2(j);
                        break
                        end
                    end
                else 
                end
            end

            % Update Labels
            obj.DiGraph.Nodes.NodeLabel = Vertices_Names_tmp;
            obj.DiGraph.Edges.EdgeLabel = Edges_Names_rotmp;
            
            % Update Color
            obj.DiGraph.Nodes.NodeColor = color_tmp;
            obj.DiGraph.Edges.EdgeColor = color_rotmp2;     

        end

        %% Plot DiGraph
        % Function creates MATLAB native graph object and updates properties for plotting 
        % Code modified using ClaudeCode to build more automated plotting function including,
        % moving nodes, text following, and auto-scaling. 
        function gmt_PlotGraph(obj, varargin)
            gmtInt.gmt_Plotting(obj, varargin{:});

        end
       
        %% Model Update 
        % Once all vertices, edges, and edge matrix has been defined a model can be generated 
        function obj = gmt_ModelUpdate(obj,varargin)

            %% Varagin Input Argument Parsing 
            params = gmt_Graph.gmt_parseSuperclass(obj,varargin{:});
            makeFunc_mfile  = ~isempty(params.BuildSim);
            componentMdl = ~params.SystemModel;
            AddInitCons = ~isempty(params.InitCon);

            %% Updates graph properties object and performs validation checks
            if all([obj.Properties.GraphValidity.IncidenceValid,obj.Properties.GraphValidity.VerticesValid,obj.Properties.GraphValidity.EdgesValid])
                % Compute Boundary Vertices
                obj.Properties.Ns = 0;
                for j = 1:obj.Properties.Nv
                    % Grab non-zero elements on each vertices 
                    tmp = obj.Properties.M(j,obj.Properties.M(j,:)~=0);
                    % Determine total number of edges
                    tmp_lgth = length(tmp);
                    % Take the max of all positive or all negative
                    tmp_sum = max(sum(abs(tmp(tmp==-1))),sum(tmp(tmp==1)));
                    % If all the elements match one direction, it is a boundary vertex
                    V_bv(j) = logical(tmp_sum == tmp_lgth);
                    % Update exogeny of each vertex 
                    % obj.Vertices(j) = obj.Vertices(j).gmt_VertexTypeUpdate(V_bv(j)); 
                    % if obj.Vertices(j).VertexType == gmt_VertexType.Internal
                    %     obj.Properties.Ns = obj.Properties.Ns + 1;
                    %     obj.Vertices(j) = obj.Vertices(j).gmt_VertexStateVariableUpdate(obj.Properties.Ns);
                    % end
                end
            elseif not(obj.Properties.GraphValidity.GraphValid)
                error('Error: Edge Matrix is not properly defined. Number of vertices must be greater than or equal to the number of edges')
            elseif not(obj.Properties.GraphValidity.VerticesValid)
                error('Error: Number of Vertices specified does not match dimensions of Edge Matrix')
            elseif not(obj.Properties.GraphValidity.EdgesValid)
                error('Error: Number of Edges specified does not match dimensions of Edge Matrix')
            end

            Tot_Ds_num = 0;
            Tot_As_num = 0;
            Tot_y_num  = 0;

            %% Update graph specific state and state derivative variables 
            Tot_As_num = 1;

            for i = 1:obj.Properties.Nv
                
                Ds_var_tmp = [];
                As_var_tmp = [];
                y_var_tmp = [];

                Ds_var = obj.Vertices(i).StateDerVariables; % Grab vertex specific dynamic state variables name
                Num_Ds = obj.Vertices(i).NvSd; % Grab total number of dynamic state varables 
                As_var = obj.Vertices(i).StateVariables; % Grab vertex specific dynamic state variables name
                Num_As = max(obj.Vertices(i).NvSa,obj.Vertices(i).NvS); % Grab total number of algebraic state varables
                V_var = obj.Vertices(i).OutputVariables; % Grab vertex specific output variables 
                Num_y = obj.Vertices(i).NvY; % Grab total number of output variables 

                if isa(Num_Ds,'double') && Num_Ds ~= 0
                    Tot_Ds_num = i;%(1:Num_Ds) + Tot_Ds_num(end); % Compute graph specific dynamic state variable numbering 
                    if Num_Ds == 1 && strlength(extractAfter(extractBefore(Ds_var,"_dot"),"x")) == 0
                        Ds_var_tmp = strcat("x",num2str(Tot_Ds_num),"_dot");
                    else
                        Ds_var_tmp = regexprep(Ds_var, '\d+', '${num2str(Tot_Ds_num(str2double($0)))}');
                    end
                end

                if isa(Num_As,'double') && Num_As ~= 0
                    if Num_As == 1 && strlength(extractAfter(As_var,"x")) == 0
                        As_var_tmp = strcat("x",num2str(Tot_As_num));
                    else
                        for j = 1:length(As_var_tmp)
                            if ~any(isstrprop(As_var(j), 'digit'))
                                As_var_tmp = [As_var_tmp, strcat("x",num2str(Tot_As_num))];
                            end
                        end
                    end
                    Tot_As_num = Tot_As_num + 1;
                end

                if isa(Num_y,"double") && Num_y ~= 0
                    Tot_y_num = i;%(1:Num_y) + Tot_y_num(end);
                    if Num_y == 1 && strlength(extractAfter(V_var,"y")) == 0
                        y_var_tmp = strcat("y",num2str(Tot_y_num));
                    else
                        y_var_tmp = regexprep(As_var, '\d+', '${num2str(Tot_As_num(str2double($0)))}');
                    end
                end

                obj.Vertices(i) = obj.Vertices(i).gmt_GraphVertexUpdate(Ds_var_tmp,As_var_tmp,y_var_tmp);

                % Update Head and State Vertices Numbers
                for j = 1:obj.Properties.Ne 
                    % Prepare to update graph model 
                    obj.Edges(j) = obj.Edges(j).gmt_EdgeGraphModelUpdate();
                    
                    %if obj.Edges(j).NeHS > 0 && obj.Properties.M(i,j) == 1
                    if obj.Properties.M(i,j) == 1
                       obj.Edges(j) = obj.Edges(j).gmt_UpdateHeadVertexNum(i);
                       obj.Edges(j) = obj.Edges(j).gmt_UpdateGraphHeadStateVar(obj.Vertices(i).GraphStateVariables);
                       % if obj.Vertices(i).VertexType == gmt_VertexType.External
                       %  obj.Vertices(i) = obj.Vertices(i).gmt_VertexDisturanceType("Sink");
                       % end
                     
                    %elseif obj.Edges(j).NeTS > 0 && obj.Properties.M(i,j) == -1
                    elseif obj.Properties.M(i,j) == -1
                       obj.Edges(j) = obj.Edges(j).gmt_UpdateTailVertexNum(i);
                       obj.Edges(j) = obj.Edges(j).gmt_UpdateGraphTailStateVar(obj.Vertices(i).GraphStateVariables);
                       % if obj.Vertices(i).VertexType == gmt_VertexType.External
                       %  obj.Vertices(i) = obj.Vertices(i).gmt_VertexDisturanceType("Source");
                       % end
                    end
                end


            end
            
            %% Update power equation for each edge
            for i = 1:obj.Properties.Nv 
                NvE_tmp = sum(abs(obj.Properties.M(i,:))==1);
                EdgeNum_tmp = find(abs(obj.Properties.M(i,:))==1);
                EdgeNumStr_tmp = string(obj.Properties.M(i,EdgeNum_tmp));
                
                % Define search terms (Longest/most specific first)
                oldVals = {'-1', '1'};

                % Define corresponding replacements
                newVals = {'-', '+'};
                
                % Perform the replacement across the whole cell array
                [oldVals_common, ia, ib] = intersect(EdgeNumStr_tmp, oldVals);
                newVals_common =  string(newVals(ib));
                Operator_tmp = replace(EdgeNumStr_tmp, oldVals_common, newVals_common);
                EdgeEq_tmp = "(" + [obj.Edges(EdgeNum_tmp).GraphEdgeEq] + ")";
                PowerEq_tmp = strjoin(Operator_tmp + EdgeEq_tmp,'');
                obj.Vertices(i) = obj.Vertices(i).gmt_GraphVertexEqUpdate(PowerEq_tmp,NvE_tmp);
            end

            %% Model Summary and Properties Post Processing 
            % Determine Indices for Stacking 
            DynVertices_idx    = find([obj.Vertices.StateType] == gmtEnumE.gmt_StateType.Dynamic); % Dynamic State Variables 
            AlgVertices_idx    = find([obj.Vertices.StateType] == gmtEnumE.gmt_StateType.Algebraic); % Algebraic State Variables 
            IntVertices_idx    = find([obj.Vertices.VertexType] == gmtEnumE.gmt_VertexType.Internal); % Internal State Variables 
            ExtVertices_idx    = find([obj.Vertices.VertexType] == gmtEnumE.gmt_VertexType.External); % External State Variables 
            AlgIntVertices_idx = intersect(AlgVertices_idx,IntVertices_idx); %Algebraic and Internal State Variables
            AlgExtVertices_idx = intersect(AlgVertices_idx,ExtVertices_idx); % Algebraic and External State Variables

            % Update System State Variables
            state_vars_tmp = unique([obj.Vertices(IntVertices_idx).GraphStateVariables]);
            state_nums_tmp = str2double(extractAfter(state_vars_tmp, "x"));
            [~, Ns_idx] = sort(state_nums_tmp);
            state_vars_sorted_tmp = state_vars_tmp(Ns_idx);
            obj.States = state_vars_sorted_tmp;
            obj.Properties = obj.Properties.gmt_PropertiesNs(length(Ns_idx),IntVertices_idx);

            % Update System Input Variables
            if ~isempty([obj.Vertices.InputVariables]) || ~isempty([obj.Edges.InputVariables])
                input_vars_tmp = unique([[obj.Vertices.InputVariables],[obj.Edges.InputVariables]]);
                input_nums_tmp = str2double(extractAfter(input_vars_tmp, "u"));
                [~, Nu_idx] = sort(input_nums_tmp);
                input_vars_sorted_tmp = input_vars_tmp(Nu_idx);
                obj.Inputs = input_vars_sorted_tmp;
                obj.Properties = obj.Properties.gmt_PropertiesNu(length(Nu_idx));
            end

            % Update System Output Variables 
            output_vars_tmp = unique([obj.Vertices.GraphOutputVariables]);
            output_nums_tmp = str2double(extractAfter(output_vars_tmp, "y"));
            [~, Ny_idx] = sort(output_nums_tmp);
            output_vars_sorted_tmp = output_vars_tmp(Ny_idx);
            obj.Outputs = output_vars_sorted_tmp;
            %obj.Properties    = obj.Properties.gmtProp.gmt_PropertiesNy(length(Ny_idx));

            %% Create system of equations 

            % Dynamic State Variable Equations
            sys_dyneq_str_tmp = [obj.Vertices(DynVertices_idx).GraphStateDerVariables]' + " = " + [obj.Vertices(DynVertices_idx).GraphVertexEq]' + ";";

            % DAE Flag 
            daeFlg = ~isempty(AlgIntVertices_idx);

            % Initialize Algebraic Equation
            sys_algeq_str_tmp = [];
            
            if daeFlg

                % Construct Algebraic Equation
                sys_algeq_str_tmp = [obj.Vertices(AlgIntVertices_idx).GraphStateVariables]' + " = " + [obj.Vertices(AlgIntVertices_idx).GraphVertexEq]' + ";";

                % Algebraic Variables 
                algVars_lhs = lhs(str2sym(sys_algeq_str_tmp));
                algVars_lhs_str = string(algVars_lhs);
                algVars_rhs = rhs(str2sym(sys_algeq_str_tmp));
                algVars_rhs_str = string(algVars_rhs);
                algVars_num = length(algVars_lhs);
            
                % Solve Algebraics 
                if algVars_num > 1 
            
                    for i = 1:length(sys_algeq_str_tmp)
                        rhsFlg(i) = contains(algVars_rhs_str(i),algVars_lhs_str);
                    end
                    
                    algVars_lhs_solve = algVars_lhs_str(rhsFlg);
                    algVars_rhs_solve = algVars_rhs_str(rhsFlg);
                    algVars_exp_solve = algVars_lhs_solve + "==" + algVars_rhs_solve;
            
                    sys_algeq_str_old = sys_algeq_str_tmp(~rhsFlg);
            
                    algVars_exp_solve_sym = simplify(str2sym(algVars_exp_solve)./algVars_lhs(rhsFlg));
                    algVars_exp_solved    = solve(algVars_exp_solve_sym,algVars_lhs(rhsFlg));
            
                    for i = 1:length(algVars_lhs_solve)
                        varName_str = string(algVars_lhs_solve(i));
                        sys_algeq_str_solved(i,:) = varName_str+ "=" + string(algVars_exp_solved.(varName_str)) + ";";
                    end
                
                    % update algebraic equation string
                    sys_algeq_str_tmp = [sys_algeq_str_old; sys_algeq_str_solved];
            
                end

            end
            
            % Stack string expression on top of each other
            sys_eq_str_tmp = [sys_dyneq_str_tmp; sys_algeq_str_tmp];

            [~, idx] = sort(double(extractAfter(extractBefore(sys_eq_str_tmp,"_dot"),"x")));
            sys_eq_str_tmp = sys_eq_str_tmp(idx);

            % Create a MATLAB symbolic equation 
            sym_sys_tmp = str2sym(sys_eq_str_tmp);
            obj.SystemEquations.FunctionInputs = symvar(rhs(sym_sys_tmp));
            obj.SystemEquations.LHS = lhs(sym_sys_tmp);
            obj.SystemEquations.RHS = rhs(sym_sys_tmp);
            obj.SystemEquations.Expression = sym_sys_tmp; 

            %% Update System Disturbance Variables 
            disturb_tmp = [obj.Vertices(ExtVertices_idx).GraphStateVariables]';
            
            isFuncOfExtAlg = [];
            for i = 1:length(disturb_tmp)
                isFuncOfExtAlg(i) = contains(strjoin(string([obj.SystemEquations.RHS]')),disturb_tmp(i));
            end

            Nd_idx = ExtVertices_idx(logical(isFuncOfExtAlg));
            obj.Properties    = obj.Properties.gmt_PropertiesNd(length(Nd_idx),Nd_idx);
            obj.Disturbances  = [obj.Vertices(Nd_idx).GraphStateVariables];

            %% Update Optimization Variables
            optvars_idx = find([obj.ModelParameters.Optimization]'==true);
            if ~isempty(optvars_idx)
                optvars_tmp = [obj.ModelParameters(optvars_idx).Variable];
                obj.Optimization = optvars_tmp;
            end

            %% Determine Model Type 
            if any([obj.ModelParameters.ParameterType] == gmtEnumE.gmt_ParameterType.Lookup) || any([obj.ModelParameters.ParameterType] == gmtEnumE.gmt_ParameterType.Neural_Network)
                obj.ModelMetadata.ModelType = gmtEnumE.gmt_ModelType.Numerical;
            else
                obj.ModelMetadata.ModelType = gmtEnumE.gmt_ModelType.Analytical;
            end

            %% Sub Parameter Values in System of Equations 
            if obj.ModelMetadata.ModelType == gmtEnumE.gmt_ModelType.Analytical
                
                % Determine Variables for Substitution 
                sub_idx = find([obj.ModelParameters.Optimization] == false);

                % Determine Parameters that use structure 
                struct_idx = [];
                for i = 1:length(obj.ModelParameters)
                    
                    if isstruct(obj.ModelParameters(i).Data)
                        struct_idx = [struct_idx, i];
                    end

                end

                sub_idx_fin = setdiff(sub_idx,struct_idx);

                if ~isempty(sub_idx_fin)
                    obj.SystemEquationsSubs.LHS = obj.SystemEquations.LHS;
                    obj.SystemEquationsSubs.RHS = subs(rhs(sym_sys_tmp),str2sym([obj.ModelParameters(sub_idx_fin).Variable]),[obj.ModelParameters(sub_idx_fin).Data]);
                    obj.SystemEquationsSubs.Expression = subs(sym_sys_tmp,str2sym([obj.ModelParameters(sub_idx_fin).Variable]),[obj.ModelParameters(sub_idx_fin).Data]);
                else 
                    obj.SystemEquationsSubs.LHS = obj.SystemEquations.LHS;
                    obj.SystemEquationsSubs.RHS = obj.SystemEquations.RHS;
                    obj.SystemEquationsSubs.Expression = obj.SystemEquations.Expression;
                end

                % sub in structure values for expression model parameters 
                for i = 1:length(struct_idx)
                    struct_tmp = obj.ModelParameters(struct_idx(i)).Data;
                    fieldnames_tmp = fieldnames(struct_tmp);
                    for j = 1:length(struct_tmp)
                        obj.SystemEquationsSubs.RHS = subs(obj.SystemEquationsSubs.RHS,str2sym(fieldnames_tmp{j}),struct_tmp.(fieldnames_tmp{j}));
                        obj.SystemEquationsSubs.Expression = subs(obj.SystemEquationsSubs.Expression,(fieldnames_tmp{j}),struct_tmp.(fieldnames_tmp{j}));
                    end
                end

                obj.SystemEquationsSubs.FunctionInputs = symvar(obj.SystemEquationsSubs.RHS);

            end

            %% If Component Model Append Edge and Vertex Names By Component Name
            if componentMdl
                
                for i = 1:length(obj.Edges)
                    obj.Edges(i).EdgeName = obj.Name + ": " + obj.Edges(i).EdgeName; 
                end
    
                for j = 1:length([obj.Vertices])
                    obj.Vertices(j).VertexName = obj.Name + ": " + obj.Vertices(j).VertexName; 
                end
            end

            %% If Inputs and InputData remove input data that is not in input parsing    
            if ~isempty(obj.Inputs) && ~isempty(obj.InputData)

                [Akeep, ia, ib] = intersect([obj.Inputs],[obj.InputData.VariableName], 'stable');
                InputData_Match_tmp = ismember([obj.InputData.VariableName],Akeep);
                obj.InputData = obj.InputData(InputData_Match_tmp);

            end

            %% Check model parameterization 

            % determine default model parameters
            mdlParameters_exp = string(symvar(obj.SystemEquations.RHS));
            stateIdx = ismember(mdlParameters_exp,obj.States);
            disturbIdx = ismember(mdlParameters_exp,obj.Disturbances);
            inputIdx = ismember(mdlParameters_exp,obj.Inputs);
            removeIdx = stateIdx + disturbIdx + inputIdx;
            mdlParameters_exp = mdlParameters_exp(~removeIdx);

            % determine user defined model parameters 
            mdlParameters_nonexpressionIdx = find([obj.ModelParameters.Expression] == false); % non expression defined variables 
            mdlParameters_expressionIdx = find([obj.ModelParameters.Expression] == true); % expression defined variables 
            mdlParameters_lookupIdx = find([obj.ModelParameters.ParameterType] == gmtEnumE.gmt_ParameterType.Lookup);      % expression lookup variables 
            mdlParameters_netIdx = find([obj.ModelParameters.ParameterType] == gmtEnumE.gmt_ParameterType.Neural_Network); % expression neural networks variables 
            mdlParameters_expressionNumerical_idx  = [mdlParameters_lookupIdx,mdlParameters_netIdx]; % numerical expression variables
            mdlParameters_expressionAnalytical_idx = setdiff(mdlParameters_expressionIdx,mdlParameters_expressionNumerical_idx); % analytical expresson variables 
            
            mdlParameters_def = [];

            % non expression based model parameters i.e. scalars 
            if any(mdlParameters_nonexpressionIdx)
                mdlParameterss_def_tmp = [obj.ModelParameters(mdlParameters_nonexpressionIdx).Variable];
                mdlParameters_def = [mdlParameters_def, mdlParameterss_def_tmp];
            end

            varsIgnore = gmtEnumE.gmt_Funcs().Funcs;

            % analytical based expressions 
            mdlParameters_expressionVars = [];
            if any(mdlParameters_expressionAnalytical_idx)

                mdlParameters_def_expression = [obj.ModelParameters(mdlParameters_expressionAnalytical_idx).Variable];

                for z = 1:length(mdlParameters_def_expression)
                    mdlParameters_def_expression_tmp = extractAfter(mdlParameters_def_expression(z),"=");
                    varsTmp = regexp(mdlParameters_def_expression_tmp, '[A-Za-z][A-Za-z0-9_]*', 'match');
                    varsTmp = varsTmp(~ismember(varsTmp,[mdlParameters_exp,obj.States]));
                    varsTmp = varsTmp(~ismember(varsTmp,[mdlParameters_exp,obj.Disturbances]));
                    varsTmp = varsTmp(~ismember(varsTmp,[mdlParameters_exp,obj.Inputs]));
                    varsTmp = varsTmp(~ismember(varsTmp,varsIgnore));
                    varsTmp = unique(varsTmp);
                    mdlParameters_expressionVars{z} = varsTmp;

                end

                mdlParameters_expressionVars = unique([mdlParameters_expressionVars{:}]);

            end

            % numerical based expressions 
            if any(mdlParameters_expressionIdx)
                for i = 1:length(mdlParameters_expressionIdx)
                    idx_tmp = mdlParameters_expressionIdx(i);
                    mdlParameters_def_tmp = strtrim(extractBefore(obj.ModelParameters(idx_tmp).Variable,"="));
                    mdlParameters_def = [mdlParameters_def, mdlParameters_def_tmp];
                end
            end

            % difference between intermediate parameters and total defined model parameters 
            if ~isempty(mdlParameters_expressionVars)
                mdlParameters_def = setdiff(mdlParameters_def,mdlParameters_expressionVars);
            end

            mdlParameters_underdefined = any(~ismember(mdlParameters_exp,mdlParameters_def));
            mdlParameters_overdefined  = any(~ismember(mdlParameters_def,mdlParameters_exp));

            assert(~mdlParameters_underdefined,"model parameterization is underdefined")
            assert(~mdlParameters_overdefined ,"model parameterization is overdefined")

            % Build Simulation Code
            %% MATLAB Function Header and Footer
                if ispc
                    user = getenv('USERNAME');
                else
                    user = getenv('USER');
                end
               
                % Parameter Indices 
                ScalarParams_idx = find([obj.ModelParameters.ParameterType] == gmtEnumE.gmt_ParameterType.Scalar);
   
                ExpressParams_idx = find([obj.ModelParameters.ParameterType] == gmtEnumE.gmt_ParameterType.Expression);
                ExpressParams_struct_idx = [];
                for i = 1:length(ExpressParams_idx)
                     idx_tmp = ExpressParams_idx(i);
                     if isstruct(obj.ModelParameters(idx_tmp).Data)
                        ExpressParams_struct_idx = [ExpressParams_struct_idx, idx_tmp];
                     end
                end

                LookupParams_idx = find([obj.ModelParameters.ParameterType] == gmtEnumE.gmt_ParameterType.Lookup);
                NNParams_idx = find([obj.ModelParameters.ParameterType] == gmtEnumE.gmt_ParameterType.Neural_Network);
    
                % Create System File Preheader Comment       
                sysfun_mfile_preheader = "% Code-Auto Generated By " + user + " using gmt Toolbox on " + string(datetime);
    
                % Grab Boundary Condition Variable Names
                ExtAlgVars = obj.Disturbances';
                
                % Grab Control Input Variable Names
                InputVars = obj.Inputs';

                % Grab Optimization Variable Names
                OptVars = obj.Optimization;
    
                % MATLAB Function Arguments
                sysFun_input_args = "(t,y";
    
                if ~isempty(obj.Inputs) 
                    sysFun_input_args = sysFun_input_args + "," + strjoin(InputVars,",");
                end
    
                if ~isempty(ExtAlgVars)
                    sysFun_input_args = sysFun_input_args + "," + strjoin(ExtAlgVars,",");
                end

                if ~isempty(OptVars)
                    sysFun_input_args = sysFun_input_args + "," + strjoin(OptVars,",");
                end

                % MATLAB Function Name 
                sysfun_FunctionName = "sysFun_" + obj.Name + sysFun_input_args + ")";
               
                % MATLAB Function Header and Footer
                sysfun_mfile_header = "function res = "+ sysfun_FunctionName;
                sysfun_mfile_footer = "end";

            %% MATLAB Function Input Unpacking 
            inputvar_list = [[obj.Vertices(DynVertices_idx).GraphStateVariables],[obj.Vertices(AlgIntVertices_idx).GraphStateVariables]]';
            sysfun_mfile_prefix = "";
            for i = 1:length(inputvar_list)
                sysfun_mfile_prefix(i,1) = inputvar_list(i) + " = y(" + i + ");";
            end
            
            %% MATLAB Function Parameter Unpacking 

            % Scalars 
            ScalarParams_idx_setdiff = setdiff(ScalarParams_idx,ExpressParams_idx);
            scalarParams_idx_inter   = setdiff(ScalarParams_idx_setdiff,optvars_idx);
            sysfun_mfile_scalars_data = [obj.ModelParameters(scalarParams_idx_inter).Variable]' + " = " + [obj.ModelParameters(scalarParams_idx_inter).Data]' + ";";
            
            sysfun_mfile_scalars_express = [];
            for i = 1:length(ExpressParams_struct_idx)
                idx_tmp = ExpressParams_struct_idx(i);
                struct_tmp = obj.ModelParameters(idx_tmp).Data;
                fieldnames_tmp = fieldnames(struct_tmp);
                for j = 1:numel(fieldnames_tmp)
                    sysfun_mfile_scalars_express_tmp = fieldnames_tmp{j} + " = " + string(struct_tmp.(fieldnames_tmp{j}));
                    sysfun_mfile_scalars_express = [sysfun_mfile_scalars_express; sysfun_mfile_scalars_express_tmp];
                end
            end

            sysfun_mfile_scalars_express = [sysfun_mfile_scalars_express; [obj.ModelParameters(ExpressParams_idx).Variable]' + ";"];

            % lookup
            if ~isempty(LookupParams_idx)

                % lookup data fieldnames 
                fields = fieldnames([obj.ModelParameters(LookupParams_idx).Data]);
                lookupFieldNames_Num = length(fields);

                % lookup function variables 
                lookupVariables = [obj.ModelParameters(LookupParams_idx).Variable]';
                lookupVariables_LHS = strtrim(extractBefore(lookupVariables,"="));
                lookupVariables_RHS = strtrim(extractAfter(lookupVariables,"="));
                lookupVariables_FuncName = strtrim(extractBefore(lookupVariables_RHS,"("));
                
                for i = 1:length(lookupVariables_FuncName)
                    lookupVariables_FuncInput = strtrim(extractAfter(lookupVariables_RHS(i),lookupVariables_FuncName(i)));
                    lookupVariables_FuncInputs_tmp = eraseBetween(lookupVariables_FuncInput,1,1);
                    lookupVariables_FuncInputs(i) = eraseBetween(lookupVariables_FuncInputs_tmp,strlength(lookupVariables_FuncInputs_tmp),strlength(lookupVariables_FuncInputs_tmp));
                end

                lookupVariables_cnt  = 0;
                lookupVariables_Vars = [];
                for i = 1:length(lookupVariables_RHS)
                    
                    lookupCode_FuncInputs  = split(lookupVariables_FuncInputs(i),",");
                    

                    for j = 1:length(lookupCode_FuncInputs)
                        lookupCode_FuncInputs_tmp = lookupCode_FuncInputs(j);
                        lookupCode_FuncInputs(j) = regexprep(lookupCode_FuncInputs_tmp, '''$', '');
                    end

                    lookupCode_NumInputs   = length(lookupCode_FuncInputs);
                    lookupCode_DataFields  = string(fieldnames([obj.ModelParameters(LookupParams_idx(i)).Data]));
                    
                    switch lookupCode_NumInputs

                        case 3
                            lookupVariables_cnt  = lookupVariables_cnt + lookupCode_NumInputs - 1;
                            lookupVariables_tmp  = lookupCode_FuncInputs(1:2)';
                            
                        case 5
                            lookupVariables_cnt  = lookupVariables_cnt + lookupCode_NumInputs - 2;
                            lookupVariables_tmp  = lookupCode_FuncInputs(1:3)';

                    end

                    lookupCode_isDefined = all(ismember(lookupVariables_tmp,lookupCode_DataFields));
                    assert(lookupCode_isDefined,"Parameter data is not defined")
                    
                    lookupVariables_Vars = [lookupVariables_Vars,lookupVariables_tmp];
                    
                end

                % find unique names
                [uniqueNames, ~, idx] = unique(lookupVariables_Vars);
                uniqueNames_cnt = accumarray(idx, 1);

                % find where variable is defined 
                uniqueName_find = [];
                for i = 1:length(uniqueNames)
                    uniqueName_find_tmp = find(contains(lookupVariables_RHS,uniqueNames(i)));
                    uniqueName_find{i} = LookupParams_idx(uniqueName_find_tmp);
                end

                % verify match datasets for same variable name
                for i = 1:length(uniqueNames)
                    uniqueName_idx  = uniqueName_find{i};
                    uniqueName_name = uniqueNames(i);
                    dataAxis = [];
                    for j = 1:length(uniqueName_idx)
                        dataTmp     = obj.ModelParameters(uniqueName_idx(j)).Data;
                        dataAxis{j} = dataTmp.(uniqueName_name);
                    end
                    % compare data 
                    dataMatch = [];
                    for k = 1:length(dataAxis)
                        for l = 1:length(dataAxis)
                            dataMatch(k,l) = isequal(dataAxis{k},dataAxis{l});
                        end
                    end
                    dataMatchFlg = all(all(dataMatch));
                    assert(dataMatchFlg,"Model parameter lookupdata has shared name with unique data");
                end

                % create mfileCode data 
                mfileCode_lookupData = [];
                for i = 1:length(uniqueNames)
                    uniqueName_tmp = uniqueNames(i);
                    uniqueName_find_tmp = find(contains(lookupVariables_RHS,uniqueNames(i)));
                    uniqueNameIdx = LookupParams_idx(uniqueName_find_tmp(1));
                    mfileCode_lookupData_rhs = mat2str(obj.ModelParameters(uniqueNameIdx).Data.(uniqueName_tmp));
                    mfileCode_lookupData_lhs = uniqueName_tmp + "=";
                    mfileCode_lookupData_tmp = mfileCode_lookupData_lhs + mfileCode_lookupData_rhs;
                    mfileCode_lookupData = [mfileCode_lookupData;mfileCode_lookupData_tmp];
                end

                % create mfileCode lookup functions 
                mfileCode_lookupFunc = [obj.ModelParameters(LookupParams_idx).Variable]';
              
                % final lookup function and data code
                sysfun_mfile_lookup = mfileCode_lookupData + ";";

            else 

                sysfun_mfile_lookup = [];
                mfileCode_lookupFunc = [];

            end

            % Neural Networks 

            % Parameterization Packaging
            sysfun_mfile_param = [sysfun_mfile_scalars_data;...
                                  sysfun_mfile_lookup;...
                                  mfileCode_lookupFunc; ...
                                  sysfun_mfile_scalars_express];

            %% MATLAB Function Body 
            % Create string expression for each type
            sys_dyneq_str_tmp = [obj.Vertices(DynVertices_idx).GraphStateDerVariables]' + " = " + [obj.Vertices(DynVertices_idx).GraphVertexEq]' + ";";
            
            % DAE Flag 
            daeFlg = ~isempty(AlgIntVertices_idx);

            % Algebraic Equation
            sys_algeq_str_tmp = [];
            
            if daeFlg
                
                % construct equation string  
                sys_algeq_str_tmp = [obj.Vertices(AlgIntVertices_idx).GraphStateVariables]' + " = " + [obj.Vertices(AlgIntVertices_idx).GraphVertexEq]' + ";";
                    
                % algebraic variables 
                algVars_lhs = lhs(str2sym(sys_algeq_str_tmp));
                algVars_lhs_str = string(algVars_lhs);
                algVars_rhs = rhs(str2sym(sys_algeq_str_tmp));
                algVars_rhs_str = string(algVars_rhs);
                algVars_num = length(algVars_lhs);

                % initialize number of solved variables
                slvVars_num = 0;
                rhsFlg = 1;

                % solve algebraics when more than one algebraic variables  
                sys_algeq_str_solved = "";
                
                if algVars_num > 1
    
                    % determine implicit equations
                    rhsFlg = [];
                    for i = 1:length(sys_algeq_str_tmp)
                        rhsFlg(i,1) = contains(algVars_rhs_str(i),algVars_lhs_str);
                    end

                    % solve algebraic equations
                    algVars_lhs_solve = algVars_lhs_str(find(rhsFlg));
                    algVars_rhs_solve = algVars_rhs_str(find(rhsFlg));
                    algVars_exp_solve = algVars_lhs_solve + " == " + algVars_rhs_solve;
                    algVars_exp_solve_sym = simplify(str2sym(algVars_exp_solve)./algVars_lhs(find(rhsFlg)));
                    algVars_exp_solved    = solve(algVars_exp_solve_sym,algVars_lhs(find(rhsFlg)));

                    % number of solved variables 
                    slvVars_num = length(algVars_lhs_solve);

                    % construct solve equation string  
                    for i = 1:slvVars_num
                        varName_str = string(algVars_lhs_solve(i));
                        sys_algeq_str_solved(i,:) = varName_str + "_out" + " = " + string(algVars_exp_solved.(varName_str)) + " - " + varName_str +";";
                    end

                end

                % construct explicit equations
                algExplicit_idx = AlgIntVertices_idx(find(~rhsFlg));
                sys_algeq_exp_str_tmp = "";
                for i = 1:(algVars_num-slvVars_num)
                    sys_algeq_exp_str_tmp = [obj.Vertices(algExplicit_idx).GraphStateVariables]'+ "_out = " + [obj.Vertices(algExplicit_idx).GraphVertexEq]' + " - " + [obj.Vertices(algExplicit_idx).GraphStateVariables]' + ";" ;
                end

                % update algebraic equation string
                sys_algeq_str_tmp = [sys_algeq_exp_str_tmp; sys_algeq_str_solved];

            end

            % Stack string expression on top of each other
            sysfun_mfile_body = [sys_dyneq_str_tmp; sys_algeq_str_tmp];

            %% MATLAB Function Output Packing 
            dynVars_out = [obj.Vertices(DynVertices_idx).GraphStateDerVariables]';
            algVars_out = [obj.Vertices(AlgIntVertices_idx).GraphStateVariables]'+ "_out";
            outputvar_list = [dynVars_out;algVars_out];
            packingCode = "res = [" + strjoin(outputvar_list',";") + "];";
            sysfun_mfile_suffix = packingCode';

            %% MATLAB Function Combine and Save

            sysfun_mfile_combined = ...
                [
                sysfun_mfile_preheader; ...
                sysfun_mfile_header;...
                sysfun_mfile_prefix;...
                sysfun_mfile_param;...
                sysfun_mfile_body;...
                sysfun_mfile_suffix;...
                sysfun_mfile_footer];

            obj.ModelMetadata.mfileCode = sysfun_mfile_combined;
            obj.ModelMetadata.mfileCode_param = sysfun_mfile_param;
            obj.ModelMetadata.FunctionName = sysfun_FunctionName;


            %% Create DAE Mass Matrix 
            NsD_tmp = sum(([obj.Vertices.StateType]==gmtEnumE.gmt_StateType.Dynamic));
            NsA_tmp = sum(all([[obj.Vertices.StateType]'==gmtEnumE.gmt_StateType.Algebraic,[obj.Vertices.VertexType]'==gmtEnumE.gmt_VertexType.Internal],2));
            dynEye = eye(NsD_tmp,NsD_tmp);
            algEye = zeros(NsA_tmp,NsA_tmp);
            obj.ModelMetadata.MassMatrix = blkdiag(dynEye,algEye);

        end
        
        %% Input Commonization 
        function obj = gmt_InputCommon(obj,InputMatching,varargin)

            % Append Varagin
            varargin = [varargin, {"SystemModel"}, {true}]; 
            CombineInputs = InputMatching;

            % Initalization 
            OldInputs = CombineInputs(:,1); % old input variables
            NewInputs = CombineInputs(:,2); % new input variables
            SysInputsVars = [obj.Inputs]; % all variables 
                      
            % Regular expression for variable parsing 
            OldInputsVars = regexp(OldInputs, '[a-zA-Z]\d+', 'match');
            NewInputsVars = regexp(NewInputs, '[a-zA-Z]\d+', 'match');
            if length(OldInputsVars) == 1
                OldInputsVars_vector = string(OldInputsVars);
            else
                OldInputsVars_vector = [OldInputsVars{:}];
            end
            
            if length(NewInputsVars) == 1
                NewInputsVars_vector = string(NewInputsVars);
            else
                NewInputsVars_vector = [NewInputsVars{:}];
            end

            % Validate variables are function of original system 
            OldInputsValid = all(ismember(OldInputsVars_vector, SysInputsVars));
            NewInputsValid = all(ismember(NewInputsVars_vector, SysInputsVars));
            assert(OldInputsValid,"Old inputs are not contained within system");
            assert(NewInputsValid,"New inputs are not contained within system");
    
            % Update Edge Equation
            for i = 1:length(obj.Edges)  
                EdgeEq_tmp = obj.Edges(i).EdgeEq;
                EdgeEq_New = EdgeEq_tmp;
                for j = 1:length(OldInputs)
                    ptr_tmp  = '(?<=[+\-*/=()\s]|^)' +  OldInputs(j) + '(?=[+\-*/=()\s]|$)';
                    EdgeEq_New = regexprep(EdgeEq_New, ptr_tmp, NewInputs(j));  
                end
                obj.Edges(i).EdgeEq = EdgeEq_New;
            end
    
            % Update Capacitance Equation
            for i = 1:length(obj.Vertices)  
                CapEq_tmp = obj.Vertices(i).CapacitanceEq;
                CapEq_New = CapEq_tmp;
                for j = 1:length(OldInputs)
                    ptr_tmp  = '(?<=[+\-*/=()\s]|^)' +  OldInputs(j) + '(?=[+\-*/=()\s]|$)';
                    CapEq_New = regexprep(CapEq_New, ptr_tmp, NewInputs(j));  
                end
               obj.Vertices(i).CapacitanceEq  = CapEq_New;
            end

            % Reconstruct Each Edge 
            for i = 1:length(obj.Edges)
                EdgeName_tmp = obj.Edges(i).EdgeName;
                EdgeEq_tmp = obj.Edges(i).EdgeEq;
                if obj.Edges(i).EdgeType == gmtEnumE.gmt_EdgeType.External
                    EdgeNew(i) = gmt_Edge(EdgeName_tmp,EdgeEq_tmp,"External");
                else
                    EdgeNew(i) = gmt_Edge(EdgeName_tmp,EdgeEq_tmp);
                end
            end

            % Reconstruct Each Vertex
            for i = 1:length(obj.Vertices)
                VertexName_tmp = obj.Vertices(i).VertexName;
                CapEq_tmp = obj.Vertices(i).CapacitanceEq;

                if ~isempty(obj.Vertices(i).Units)
                    varargin2 = [{"Units"}, {obj.Vertices(i).Units}]; 
                else
                    varargin2 = [];
                end

                if obj.Vertices(i).VertexType == gmtEnumE.gmt_VertexType.External && ~isempty(varargin2)
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp,"External",true,varargin2{:});
                elseif obj.Vertices(i).VertexType == gmtEnumE.gmt_VertexType.External
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp,"External",true);
                elseif ~isempty(varargin2)
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp,varargin2{:});
                else
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp);
                end
            end

            obj = gmt_Graph(obj.Name,obj.EdgeMatrix,EdgeNew,VertexNew,obj.ModelParameters,obj.InputData,obj.Ports,varargin{:});

        end

        %% Parameter Commonization 
         function obj = gmt_ParamCommon(obj,ParamMatching,varargin)

            % Append Varagin
            varargin = [varargin, {"SystemModel"}, {true}]; 

            % Initalization 
            OldParams = ParamMatching(:,1); % old input variables
            NewParams = ParamMatching(:,2); % new input variables
            SysParamVars = [obj.ModelParameters.Variable]; % all parameter variables 
                      
            % Validate variables are function of original system 
            OldParamsValid = all(ismember(OldParams, SysParamVars));
            NewParamsValid = all(ismember(NewParams, SysParamVars));
            assert(OldParamsValid,"Old parameters are not contained within system");
            assert(NewParamsValid,"New parameters are not contained within system");
    
            % Update Model Parmameter Objects
            mp_idx = [];
            for i = 1:length(obj.ModelParameters)
                % Update model parameter objects that contain old name
                if contains(obj.ModelParameters(i).Variable,OldParams)
                    for j = 1:length(OldParams)
                        % find index to update 
                        mp_idx_tmp = find([obj.ModelParameters.Variable]'== OldParams(j));
                        mp_idx = [mp_idx,mp_idx_tmp];
                        % update model parameters variable with new variable

                    end
                end
            end

            if ~isempty(mp_idx)
                obj.ModelParameters(mp_idx) = [];
            end
            
            % Update Edge Equation
            for i = 1:length(obj.Edges)  
                EdgeEq_tmp = obj.Edges(i).EdgeEq;
                EdgeEq_New = EdgeEq_tmp;
                for j = 1:length(OldParams)
                    ptr_tmp  = '(?<=[+\-*/=()\s]|^)' +  OldParams(j) + '(?=[+\-*/=()\s]|$)';
                    EdgeEq_New = regexprep(EdgeEq_New, ptr_tmp, NewParams(j));  
                end
                obj.Edges(i).EdgeEq = EdgeEq_New;
            end
    
            % Update Capacitance Equation
            for i = 1:length(obj.Vertices)  
                CapEq_tmp = obj.Vertices(i).CapacitanceEq;
                CapEq_New = CapEq_tmp;
                for j = 1:length(OldParams)
                    ptr_tmp  = '(?<=[+\-*/=()\s]|^)' +  OldParams(j) + '(?=[+\-*/=()\s]|$)';
                    CapEq_New = regexprep(CapEq_New, ptr_tmp, NewParams(j));  
                end
               obj.Vertices(i).CapacitanceEq  = CapEq_New;
            end

            % Reconstruct Each Edge 
            for i = 1:length(obj.Edges)
                EdgeName_tmp = obj.Edges(i).EdgeName;
                EdgeEq_tmp = obj.Edges(i).EdgeEq;
                if obj.Edges(i).EdgeType == gmtEnumE.gmt_EdgeType.External
                    EdgeNew(i) = gmt_Edge(EdgeName_tmp,EdgeEq_tmp,"External");
                else
                    EdgeNew(i) = gmt_Edge(EdgeName_tmp,EdgeEq_tmp);
                end
            end

            % Reconstruct Each Vertex
            for i = 1:length(obj.Vertices)
                VertexName_tmp = obj.Vertices(i).VertexName;
                CapEq_tmp = obj.Vertices(i).CapacitanceEq;

                if ~isempty(obj.Vertices(i).Units)
                    varargin2 = [{"Units"}, {obj.Vertices(i).Units}]; 
                else
                    varargin2 = [];
                end

                if obj.Vertices(i).VertexType == gmtEnumE.gmt_VertexType.External && ~isempty(varargin2)
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp,"External",true,varargin2{:});
                elseif obj.Vertices(i).VertexType == gmtEnumE.gmt_VertexType.External
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp,"External",true);
                elseif ~isempty(varargin2)
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp,varargin2{:});
                else
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp);
                end
            end

            obj = gmt_Graph(obj.Name,obj.EdgeMatrix,EdgeNew,VertexNew,obj.ModelParameters,obj.InputData,obj.Ports,varargin{:});

         end

        %% Update Optimization Variables
        function obj = gmt_ParamOpt(obj,ParamOpt,varargin)

            % Append Varagin
            varargin = [varargin, {"SystemModel"}, {true}]; 

            % Initalization 
            SysParamVars = [obj.ModelParameters.Variable]; % all parameter variables 

            % Validate Dimensions 
            n = size(ParamOpt,1);
            m = size(ParamOpt,2);
            isStr= isstring(ParamOpt);
            logTmp = strcmpi(ParamOpt(:,2), 'true');
                      
            % Validate variables are function of original system 
            ParamsValid = all(ismember(ParamOpt(:,1), SysParamVars));
            assert(ParamsValid,"Parameters are not contained within system");
            assert(isStr,"Parameters are not string datatypes");
            assert(m==2, "Parameters string array is not a single column");
            
            %Determine indices that require update
            mp_idx = [];
            for i = 1:n
                mp_idx_tmp = find([obj.ModelParameters.Variable]'== ParamOpt(i,1));
                mp_idx = [mp_idx, mp_idx_tmp];
            end

            for j = 1:n
                obj.ModelParameters(mp_idx(j)).Optimization = logTmp(j);
            end

            % Update Model 
            obj = gmt_Graph(obj.Name,obj.EdgeMatrix,obj.Edges,obj.Vertices,obj.ModelParameters,obj.InputData,obj.Ports,varargin{:});
        end

        %% Update Parameter Values
        function obj = gmt_ParamVals(obj,ParamVals,varargin)

            % Append Varagin
            varargin = [varargin, {"SystemModel"}, {true}]; 

            % Initalization 
            SysParamVars = [obj.ModelParameters.Variable]; % all parameter variables 

            % Validate Dimensions 
            n = size(ParamVals,1);
            m = size(ParamVals,2);
            isStr= isstring(ParamVals);
            val_tmp = double(ParamVals(:,2));
                      
            % Validate variables are function of original system 
            ParamsValid = all(ismember(ParamVals(:,1), SysParamVars));
            assert(ParamsValid,"Parameters are not contained within system");
            assert(isStr,"Parameters are not string datatypes");
            assert(m==2, "Parameters string array is not a single column");
            assert(any(~isnan(val_tmp)), "NaN detected, check 2nd column to make sure numerical value assigned");
            
            %Determine indices that require update
            mp_idx = [];
            for i = 1:n
                mp_idx_tmp = find([obj.ModelParameters.Variable]'== ParamVals(i,1));
                mp_idx = [mp_idx, mp_idx_tmp];
            end

            % Update Values
            for j = 1:n
                obj.ModelParameters(mp_idx(j)).Data = val_tmp(j);
            end

            % Update Model 
            obj = gmt_Graph(obj.Name,obj.EdgeMatrix,obj.Edges,obj.Vertices,obj.ModelParameters,obj.InputData,obj.Ports,varargin{:});
        end

        %% Add Initial Conditions
        function obj = gmt_InitCon(obj,InitConVals)
                % Validate InitCon Dimensions   
                assert(obj.Properties.Ns == size(InitConVals,2),"Number of initial conditions does not match number of states")
                validInitCon = all(isnumeric(InitConVals),size(InitConVals,1) == 1);
                assert(validInitCon,"Invalid Initial Condition Formatting, Must Be Row Vector With Length Equal to Number of Dynamic States")
                % Add Initial Conditions
                obj.InitialConditions = InitConVals;
        end

        %% Algebraic State Conversion 
        function obj = gmt_Algebraic(obj,algVertices,varargin)
            
            % compute number of rows and columns
            algVertices_numCols = size(algVertices,1);
            algVertices_numRows = size(algVertices,2);

            % determine if a vector 
            isColumnVector_flg  = ((algVertices_numCols == 1) && (algVertices_numRows >= 1));
            isRowVector_flg     = ((algVertices_numCols >= 1) && (algVertices_numRows == 1));
            isVector_flg = isColumnVector_flg || isRowVector_flg;

            % assert vector format
            assert(isVector_flg,"algebraic vertex parameter is a not a vector")

            % convert to column vector
            if isRowVector_flg
                algVertices = algVertices';
                algVertices_numCols = size(algVertices,1);
                algVertices_numRows = size(algVertices,2);
            end

            % decompose model 
            objectName_tmp = obj.Name;
            vertices_tmp = obj.Vertices;
            edges_tmp = obj.Edges;
            edgematrix_tmp = obj.EdgeMatrix;
            parameters_tmp = obj.ModelParameters;
            ports_tmp = obj.Ports;
            inputs_tmp = obj.InputData;

            % loop through algebraic vertices array 
            for i = 1:algVertices_numRows
                vertexNum = algVertices(i);
                % create temporary vertex object
                vertexObj_tmp = obj.Vertices(vertexNum);
                % check if algebraic already 
                algFlg = vertexObj_tmp.StateType == gmtEnumE.gmt_StateType.Algebraic;
                if ~algFlg 
                    % remove x_dot from capacitance equation
                    capEq_tmp = "x";
                    % grab description 
                    vertexName_tmp = vertexObj_tmp.VertexName;
                    % grab units 
                    units_tmp = vertexObj_tmp.Units;
                    % grab externality 
                    if vertexObj_tmp.VertexType == gmtEnumE.gmt_VertexType.External
                        extFlg = true;
                    else
                        extFlg = false;
                    end
                    % create new vertex object
                    vertexObj_new = gmt_Vertex(vertexName_tmp,capEq_tmp,"units",units_tmp,"External",extFlg);
                    % assign new vertex to old vertex
                    vertices_tmp(vertexNum) = vertexObj_new;

                else
                    fprintf('\n vertex %3.0f is already algebraic skipped \n',vertexNum)
                end

            end

            % update graph model 
            obj = gmt_Graph(objectName_tmp,edgematrix_tmp,edges_tmp,vertices_tmp,parameters_tmp,inputs_tmp,ports_tmp,varargin{:});

        end


        %% Build Simulation
        function obj = gmt_BuildSim(obj,filepath)
            
                sysfun_filename_tmp = "sysFun_" + obj.Name + ".m";
                sysobj_filename_tmp = "sysObj_" + obj.Name + ".mat";
                sysname_tmp = "sys_" + obj.Name;

                date_tmp = string(datetime('now','Format','MMDDyyy'));
                time_tmp = string(datetime('now','Format','HHmmss'));

                sys_bld_flder_tmp = sysname_tmp + "_" + date_tmp +  "_" + time_tmp;
                
                sys_bld_path_tmp = fullfile(filepath, sys_bld_flder_tmp);

                mkdir(sys_bld_path_tmp)

                %sysfun_file_save_path = sys_bld_path_tmp + "\" + sysfun_filename_tmp;
                sysfun_file_save_path = fullfile(sys_bld_path_tmp,sysfun_filename_tmp);
                
                syssim_file_save_path = extractBefore(sysfun_file_save_path,'.m') + "SimScript.m";

                %sysobj_file_save_path = sys_bld_path_tmp + "\" + sysobj_filename_tmp;
                sysobj_file_save_path = fullfile(sys_bld_path_tmp, sysobj_filename_tmp);

                writelines(obj.ModelMetadata.mfileCode, sysfun_file_save_path);

                %% Simulation Script Generator 
                if ~isempty([obj.InputData.VariableName])
                    inputstr_tmp = "% Inputs ";
                    inputstr_tmp = [inputstr_tmp ; [obj.InputData.VariableName]'+ " = 0; % " + [obj.InputData.Parent]'+ ": " + [obj.InputData.Description]'+ " (Units: " + string([obj.InputData.Units]')+ ")"];
                else 
                    inputstr_tmp = [];
                end

                if ~isempty(obj.Disturbances)
                    extalgstr_tmp = "% Boundary Conditions";
                    disturb_vertices_tmp = obj.Vertices(obj.Properties.Nd_idx);
                    extalgstr_tmp = [extalgstr_tmp; [disturb_vertices_tmp.GraphStateVariables]' + " = 0; % " + [disturb_vertices_tmp.VertexName]' + " (Units: " + string([disturb_vertices_tmp.Units]')+ ")"];
                else 
                    extalgstr_tmp = [];
                end
                
                simtimstr_tmp = ["% Simulation Time";"SimTEnd = 2000;"];
                
                if isempty(obj.InitialConditions)
                    ic = string(1);
                else 
                    ic = string(obj.InitialConditions)';
                end
                icstr1_tmp = "% Initial Conditions";
                
                dynVertex_idx = find([obj.Vertices.StateType]' == gmtEnumE.gmt_StateType.Dynamic);
                dynVertex_idx = intersect(obj.Properties.Ns_idx,dynVertex_idx);
                algVertex_idx = setdiff(obj.Properties.Ns_idx,dynVertex_idx);
                stateVars_idx = [dynVertex_idx; algVertex_idx'];
                stateVars_tmp = [obj.Vertices(stateVars_idx).GraphStateVariables];

                icstr1_tmp = [icstr1_tmp; stateVars_tmp' + "_0 = "+ ic + ";  % " + [obj.Vertices(stateVars_idx).VertexName]' + " (Units: " + string([obj.Vertices(stateVars_idx).Units]')+ ")"];
                icstr2_tmp = "y0 = [" + strjoin(stateVars_tmp+"_0",",") + "];";
                icstr_tmp = [icstr1_tmp;icstr2_tmp];
                sysFuncName_tmp = obj.ModelMetadata.FunctionName; 

                massMatrix_trace = trace(obj.ModelMetadata.MassMatrix);
                massMatrix_size  = size(obj.ModelMetadata.MassMatrix,1);
                
                if massMatrix_size > massMatrix_trace
                    daeFlg = true;
                else
                    daeFlg = false;
                end

                % update initial conditions and options for DAE
                simanony_tmp = [];
                
                if daeFlg

                    findIC_str = ... 
                        ["M = " + string(obj.Name) + ".ModelMetadata.MassMatrix;"
                        "daeFun = @(t,y)" + sysFuncName_tmp + ";"
                        "y0_guess = y0;"
                        "y0 = findConsistentIC(daeFun,M,y0_guess);"];

                    findConsistentIC_str = ... 
                        ["function x0 = findConsistentIC(daeFun,M,x0_guess)"
                        "% Find algebraic equations from mass matrix"
                        "alg_idx = find(diag(M)==0);"
                        ""
                        "if isempty(alg_idx)"
                        "    x0 = x0_guess;"
                        "    return"
                        "end"
                        ""
                        "% Initial guess for algebraic variables"
                        "xa_guess = x0_guess(alg_idx);"
                        ""
                        "options = optimoptions('fsolve',..."
                        "    'Display','none',..."
                        "    'FunctionTolerance',1e-12);"
                        ""
                        "% Solve algebraic constraints"
                        "xa = fsolve(@(xa) algebraicResidual(..."
                        "    xa,..."
                        "    x0_guess,..."
                        "    alg_idx,..."
                        "    daeFun),..."
                        "    xa_guess,..."
                        "    options);"
                        ""
                        "% Replace algebraic variables"
                        "x0 = x0_guess;"
                        "x0(alg_idx) = xa;"
                        "end"];

                    algebraicResidual_str = ...
                        ["function g = algebraicResidual(xa,x,alg_idx,daeFun)"
                          ""
                          "    x(alg_idx) = xa;"
                          ""
                          "    F = daeFun(0,x);"
                          ""
                          "    g = F(alg_idx);"
                          ""
                          "end"];

                    options_tmp = "options = odeset('Mass',M);";
                    simbody_tmp = [findIC_str; options_tmp; "[t, y] = ode23t(@(t,y) " + sysFuncName_tmp + ", [0 SimTEnd], y0, options);"];
                    simanony_tmp = [findConsistentIC_str; algebraicResidual_str];
                else
                    simbody_tmp = "[t, y] = ode23s(@(t,y) " + sysFuncName_tmp + ", [0 SimTEnd], y0);";
                end
                
                plotstr_tmp =[... 
                "% Plot only internal state types";
                "% Concatenate dynamic and algebraic state variables"
                "dynamicIdx  = find(["+obj.Name+".Vertices.StateType]  == gmtEnumE.gmt_StateType.Dynamic);";
                "algebraicIdx  = find(["+obj.Name+".Vertices.StateType]  == gmtEnumE.gmt_StateType.Algebraic);";
                "internalIdx = find(["+obj.Name+".Vertices.VertexType] == gmtEnumE.gmt_VertexType.Internal);";
                "intDyn_idx  = intersect(dynamicIdx,internalIdx);"
                "intAlg_idx  = intersect(algebraicIdx,internalIdx);"
                "stateIdx    = [intDyn_idx,intAlg_idx];"
                "internalNum = size(y,2);";
                "subplotDim  = max(ceil(sqrt(internalNum)),2);";
                "ylabels_tmp = ["+obj.Name+".Vertices(stateIdx).VertexName];";
                "ylabelsnew_tmp = replace(ylabels_tmp, " + """:"""+ ", newline);";
                
                "figure";
                "for i = 1:internalNum";
                "    subplot(subplotDim,subplotDim,i)";
                "    plot(t,y(:,i))";
                "    xlabel('Time')";
                "    ylabel(ylabelsnew_tmp(i))";
                "end"];

                % Create System File Preheader Comment       
                if ispc
                    user = getenv('USERNAME');
                else
                    user = getenv('USER');
                end
               
                sysfun_mfile_preheader = "% Code-Auto Generated By " + user + " using gmt Toolbox on " + string(datetime);

                % system function header
                simScript_header = [
                                    "% Disable lookup warnings"
                                    "disableLookupWarnings_Flg = false;"
                                    "if disableLookupWarnings_Flg"
                                    "    warning('off','gmt_lookupAxis:upperlimit')"
                                    "    warning('off','gmt_lookupAxis:lowerlimit')"
                                    "else"
                                    "    warning('on','gmt_lookupAxis:upperlimit')"
                                    "    warning('on','gmt_lookupAxis:lowerlimit')"
                                    "end"
                                    ];
                
                SimScriptGen_mfilecode = ...
                    [sysfun_mfile_preheader; ...
                     simScript_header; ...
                     inputstr_tmp; ...
                     extalgstr_tmp; ...
                     simtimstr_tmp; ...
                     icstr_tmp; ...
                     simbody_tmp; ...
                     plotstr_tmp;
                     simanony_tmp];

                writelines(SimScriptGen_mfilecode, syssim_file_save_path);    

                save(sysobj_file_save_path, "obj")

        end

    end
    %% Static Public Methods
    methods (Static)
        
          %% Combine Component Models
          function sys = gmt_Combine(CombineName, ObjectArray, PortArray, varargin)

            %% Append Varargin
            varargin = [varargin, {"SystemModel"}, {true}]; 

            % Input Parsing and Validation
            PrimaryObj = ObjectArray{:,1};
            SecondaryObj = ObjectArray{:,2};

            % Component Connection Information Processing
            NumCon = length(PrimaryObj);
            AllObj = {PrimaryObj{:},SecondaryObj{:}};
            AllObj_num = length(AllObj);

            for i = 1:AllObj_num
                AllObjName(i) = AllObj{i}.Name;
            end

            % Compute Number of Components
            [UniqueObjName, ia, ic] = unique(AllObjName);
            NumComp = length(UniqueObjName);
            UniqueObj = {AllObj{ia}};

            % Compute Combined Incidence Matrix Size
            objC_Nv = 1;
            objC_Ne = 1;
            objC_Nv_prev = 0;
            objC_Ne_prev = 0;
            EdgeTot = [];
            EdgeTot_comp_idx = [];
            VertexTot = [];
            VertexTot_comp_idx = [];
            ParamsTot = [];
            ParamsTot_comp_idx = [];
            InputTot = [];
            InputTot_comp_idx = [];
            PortsTot = [];
            PortsTot_comp_idx = [];
            Mc = [];
            PortsEdge_remove = [];
            NumInputs_prev = 0;
            objC_NumPorts_prev = 0;

            for i = 1:NumComp
                idx = i;
                idx_old = (max(i-1,1));

                objC_Nv_old{i} = 1:UniqueObj{idx}.Properties.Nv;
                objC_Nv = objC_Nv_prev + UniqueObj{idx}.Properties.Nv;
                objC_Nv_new{i} = (objC_Nv_prev+1:objC_Nv);
                objC_Nv_prev = objC_Nv;

                objC_Ne_old{i} = 1:UniqueObj{idx}.Properties.Ne;
                objC_Ne = objC_Ne_prev + UniqueObj{idx}.Properties.Ne;
                objC_Ne_new{i} = (objC_Ne_prev+1:objC_Ne);
                objC_Ne_prev = objC_Ne;

                Mc = blkdiag(Mc,UniqueObj{idx}.Properties.M);     

                EdgeTot = [EdgeTot,UniqueObj{idx}.Edges];
                NumEdge = length(UniqueObj{idx}.Edges);
                EdgeTot_comp_idx_new = ones(1,NumEdge).*i;
                EdgeTot_comp_idx = [EdgeTot_comp_idx, EdgeTot_comp_idx_new];

                VertexTot = [VertexTot,UniqueObj{idx}.Vertices];
                NumVertex = length(UniqueObj{idx}.Vertices);
                VertexTot_comp_idx_new = ones(1,NumVertex).*i;
                VertexTot_comp_idx = [VertexTot_comp_idx, VertexTot_comp_idx_new];

                ParamsTot = [ParamsTot, UniqueObj{idx}.ModelParameters];
                objC_NumParams = length(UniqueObj{idx}.ModelParameters);
                ParamsTot_comp_idx_new = ones(1,objC_NumParams).*i;
                ParamsTot_comp_idx = [ParamsTot_comp_idx, ParamsTot_comp_idx_new];
                objC_Params_old{i} = UniqueObj{idx}.ModelParameters;

                InputTot = [InputTot, UniqueObj{idx}.InputData];
                NumInputs = length(UniqueObj{idx}.InputData);
                InputTot_comp_idx_new = ones(1,NumInputs).*i;
                InputTot_comp_idx = [InputTot_comp_idx, InputTot_comp_idx_new];
                Inputs_old{i} = [UniqueObj{idx}.InputData.VariableName];
                InputNum_strt = (NumInputs_prev + 1);
                InputNum_end = InputNum_strt + NumInputs -1;
                NumInputs_prev = NumInputs_prev + NumInputs;
                Inputs_old{i} = "u" + string(1:NumInputs);
                Inputs_new{i} = "u" +  string(InputNum_strt:InputNum_end);

                NumPorts = length(UniqueObj{idx}.Ports);
                objC_PortNum_old{i} = 1:NumPorts;
                objC_NumPorts = objC_NumPorts_prev + NumPorts;
                objC_PortNum_new{i} = (objC_NumPorts_prev + 1:objC_NumPorts);
                objC_NumPorts_prev = objC_NumPorts;
                PortsTot = [PortsTot, UniqueObj{idx}.Ports];
                PortsTot_comp_idx_new = ones(1,NumPorts).*i;
                PortsTot_comp_idx = [PortsTot_comp_idx, PortsTot_comp_idx_new];
            end

            % Determine Unique Component Incidence Matrix
            Ports_cntr = 1;
            Ports_num_remove = [];
            for i = 1:NumCon 

                % Grab Port Numbers
                objA_PortNum = PortArray(i,1);
                objB_PortNum = PortArray(i,2);

                % Validate Connection Type
                connectionMatch = (PrimaryObj{i}.Ports(objA_PortNum).PortType == SecondaryObj{i}.Ports(objB_PortNum).PortType); 
                connectionMatch2 = (PrimaryObj{i}.Ports(objA_PortNum).EnergyDomain == SecondaryObj{i}.Ports(objB_PortNum).EnergyDomain); 
                assert(all(connectionMatch,connectionMatch2),"Connection types do not match, please check connection port numbers and types")

                % Determine if edge or vertex connection
                is_edgecon = (PrimaryObj{i}.Ports(objA_PortNum).PortType == gmtEnumE.gmt_PortType.EdgeConnection);

                % Determine indices for each component
                PrimaryObjName{i} = PrimaryObj{i}.Name;
                SecondaryObjName{i} = SecondaryObj{i}.Name;
                objA_idx = find(UniqueObjName==PrimaryObjName{i});
                objB_idx = find(UniqueObjName==SecondaryObjName{i});

                table_tmp(i,:) = [string(PrimaryObjName{i}),string(objA_PortNum),PrimaryObj{i}.Ports(objA_PortNum).Description,string(SecondaryObjName{i}),string(objB_PortNum),SecondaryObj{i}.Ports(objB_PortNum).Description];

                % Initalize variables for each loop
                objA_EdgeNumM(i) = -1;
                objB_EdgeNumR(i) = -1;
                objA_VertexNumR(i) = -1;
                objB_VertexNumR(i) = -1;
                objA_VertexNumM(i) = -1;
                objB_VertexNumRvt(i) = -1;

                % Edge Connection Algorithm
                % asssign primary component edge for column concatentation 
                % assign secondary compoent edge for removal and concatentation 
                % assign primary component vertex number for removal
                % assign secondary component vertex number for removal
                if is_edgecon

                    Ports_num_remove{(2*Ports_cntr)-1} = objC_PortNum_new{objA_idx}(objC_PortNum_old{objA_idx}==objA_PortNum);
                    Ports_num_remove{(2*Ports_cntr)} = objC_PortNum_new{objB_idx}(objC_PortNum_old{objB_idx}==objB_PortNum);
                    Ports_cntr = Ports_cntr + 1;

                    objA_EdgeNum = PrimaryObj{i}.Ports(objA_PortNum).ElementNumber;
                    objB_EdgeNum = SecondaryObj{i}.Ports(objB_PortNum).ElementNumber;

                    objA_EdgeNumM(i) = objC_Ne_new{objA_idx}((objC_Ne_old{objA_idx}==objA_EdgeNum));
                    objB_EdgeNumR(i) = objC_Ne_new{objB_idx}((objC_Ne_old{objB_idx}==objB_EdgeNum));

                    % Compute Required Vertex Removal
                    % Edge A
                    objA_hVn = [PrimaryObj{i}.Edges(objA_EdgeNum).HeadVertexNum];
                    objA_tVn = [PrimaryObj{i}.Edges(objA_EdgeNum).TailVertexNum];
                    % Edge B
                    objB_hVn = [SecondaryObj{i}.Edges(objB_EdgeNum).HeadVertexNum];
                    objB_tVn = [SecondaryObj{i}.Edges(objB_EdgeNum).TailVertexNum];

                    % EdgeA HeadTail Vertex Assignment
                    % create truth table 
                    % vertex type and number of edges at each vertex
                    % case 1: external & one edge -> remove
                    % case 2: external % > one edge -> remove
                    % case 3: internal & one edge -> remove
                    % case 4: internal % > one edge -> keep 
                    
                    % primary object
                    objA_hV_removeFlg = PrimaryObj{i}.Vertices(objA_hVn).VertexType == gmtEnumE.gmt_VertexType.External;
                    objA_tV_removeFlg = PrimaryObj{i}.Vertices(objA_tVn).VertexType == gmtEnumE.gmt_VertexType.External;
                    
                    % secondary logic flag determination 
                    objA_secLogic_flg = false;
                    if objA_hV_removeFlg == objA_tV_removeFlg
                        objA_secLogic_flg = true;
                    end

                    % second logic executation 
                    if objA_secLogic_flg

                        % compute number of edges
                        objA_hV_numEdge = PrimaryObj{i}.Vertices(objA_hVn).GraphNvE;
                        objA_tV_numEdge = PrimaryObj{i}.Vertices(objA_tVn).GraphNvE;
                        
                        % determine remove flags 
                        if objA_hV_numEdge > objA_tV_numEdge
                            objA_tV_removeFlg = true;
                            objA_hV_removeFlg = false;
                        elseif objA_tV_numEdge > objA_hV_numEdge
                            objA_tV_removeFlg = false;
                            objA_hV_removeFlg = true;
                        else
                            error("New case identified, notify developer")
                        end

                    end

                    % select vertex for removal 
                    if objA_hV_removeFlg 
                        objA_VertexNumR(i) = objC_Nv_new{objA_idx}((objC_Nv_old{objA_idx}==objA_hVn));
                        objA_VertexNumR_inv(i) = objC_Nv_new{objA_idx}((objC_Nv_old{objA_idx}==objA_tVn));
                    else
                        objA_VertexNumR(i) = objC_Nv_new{objA_idx}((objC_Nv_old{objA_idx}==objA_tVn));
                        objA_VertexNumR_inv(i) = objC_Nv_new{objA_idx}((objC_Nv_old{objA_idx}==objA_hVn));
                    end

                    % primary object
                    objB_hV_removeFlg = SecondaryObj{i}.Vertices(objB_hVn).VertexType == gmtEnumE.gmt_VertexType.External;
                    objB_tV_removeFlg = SecondaryObj{i}.Vertices(objB_tVn).VertexType == gmtEnumE.gmt_VertexType.External;
                    
                    % secondary logic flag determination 
                    objB_secLogic_flg = false;
                    if objB_hV_removeFlg == objB_tV_removeFlg
                        objB_secLogic_flg = true;
                    end

                    % second logic executation 
                    if objB_secLogic_flg

                        % compute number of edges
                        objB_hV_numEdge = PrimaryObj{i}.Vertices(objB_hVn).GraphNvE;
                        objB_tV_numEdge = PrimaryObj{i}.Vertices(objB_tVn).GraphNvE;
                        
                        % determine remove flags 
                        if objB_hV_numEdge > objB_tV_numEdge
                            objB_tV_removeFlg = true;
                            objB_hV_removeFlg = false;
                        elseif objB_tV_numEdge > objB_hV_numEdge
                            objB_tV_removeFlg = false;
                            objB_hV_removeFlg = true;
                        else
                            error("New case identified, notify developer")
                        end

                    end

                    % select vertex for removal 
                    if objB_hV_removeFlg 
                        objB_VertexNumR(i) = objC_Nv_new{objB_idx}((objC_Nv_old{objB_idx}==objB_hVn));
                        objB_VertexNumR_inv(i) = objC_Nv_new{objB_idx}((objC_Nv_old{objB_idx}==objB_tVn));
                    else
                        objB_VertexNumR(i) = objC_Nv_new{objB_idx}((objC_Nv_old{objB_idx}==objB_tVn));
                        objB_VertexNumR_inv(i) = objC_Nv_new{objB_idx}((objC_Nv_old{objB_idx}==objB_hVn));
                    end

                % Vertex Connection Algorithm 
                % assign primary component vertex number for row concatentation 
                % assign secondary component vertex number for removal and concatentation 
                else
                    objA_VertexNum = PrimaryObj{i}.Ports(objA_PortNum).ElementNumber;
                    objB_VertexNum = SecondaryObj{i}.Ports(objB_PortNum).ElementNumber;
                    objA_VertexNumM(i) = objC_Nv_new{objA_idx}((objC_Nv_old{objA_idx}==objA_VertexNum));
                    VertexTot(objA_VertexNumM(i)).VertexType = gmtEnumE.gmt_VertexType.Internal;
                    objB_VertexNumRvt(i) = objC_Nv_new{objB_idx}((objC_Nv_old{objB_idx}==objB_VertexNum));
                end

            end

            % Find Indices Requiring Updates
            objA_EdgeNumM_idx = find(objA_EdgeNumM>0);
            objB_EdgeNumR_idx = find(objB_EdgeNumR>0);
            objA_VertexNumR_idx = find(objA_VertexNumR>0);
            objB_VertexNumR_idx = find(objB_VertexNumR>0);
            objA_VertexNumR_inv_idx = find(objA_VertexNumR_inv>0);
            objB_VertexNumR_inv_idx = find(objB_VertexNumR_inv>0);
            objA_VertexNumM_idx = find(objA_VertexNumM>0);
            objB_VertexNumRvt_idx = find(objB_VertexNumRvt>0);

            % Update Arrays
            objA_EdgeNumM = objA_EdgeNumM(objA_EdgeNumM_idx);
            objB_EdgeNumR = objB_EdgeNumR(objB_EdgeNumR_idx);
            objA_VertexNumR = objA_VertexNumR(objA_VertexNumR_idx);
            objB_VertexNumR = objB_VertexNumR(objB_VertexNumR_idx);
            objA_VertexNumR_inv = objA_VertexNumR_inv(objA_VertexNumR_inv_idx);
            objB_VertexNumR_inv = objB_VertexNumR_inv(objB_VertexNumR_inv_idx);
            objA_VertexNumM = objA_VertexNumM(objA_VertexNumM_idx);
            objB_VertexNumRvt = objB_VertexNumRvt(objB_VertexNumRvt_idx);
            
            % create system incidence matrix

            % order vertices to remove 
            objC_VertexNumR = sort([objA_VertexNumR,objB_VertexNumR,objB_VertexNumRvt]); 
            % concatenate common edge columns together 
            Mc(:,objA_EdgeNumM) = Mc(:,objA_EdgeNumM) + Mc(:,objB_EdgeNumR); 
            % concatenate common edge columns together
            Mc(objA_VertexNumM,:) = Mc(objA_VertexNumM,:) + Mc(objB_VertexNumRvt,:);  

            % remap edge connections from old to new vertex
            objC_EdgeNumK = setdiff(1:size(Mc,2),objA_EdgeNumM);
            Mc(objB_VertexNumR_inv,objC_EdgeNumK) = Mc(objA_VertexNumR,objC_EdgeNumK) + Mc(objB_VertexNumR_inv,objC_EdgeNumK);
            Mc(objA_VertexNumR_inv,objC_EdgeNumK) = Mc(objB_VertexNumR,objC_EdgeNumK) + Mc(objA_VertexNumR_inv,objC_EdgeNumK);

            % remap old to new vertex
            objC_VertexNumR_inv    = [objA_VertexNumR_inv,objB_VertexNumR_inv,objA_VertexNumM];
            objC_VertexNumR_unsort = [objA_VertexNumR,objB_VertexNumR,objB_VertexNumRvt];

            for i = 1:length(objC_VertexNumR_inv)
                    idxNum_tmp = objC_VertexNumR_inv(i);
                    idxNum_remove = sum(objC_VertexNumR <= idxNum_tmp);
                    objC_VertexNumR_inv_new(i) = idxNum_tmp - idxNum_remove;
            end

            % delete associated edge columns and vertex rows 
            Mc(objC_VertexNumR,:) = []; 
            Mc(:,objB_EdgeNumR) = []; 

            % Update Final Dimensions 
            objC_Nv = size(Mc,1);
            objC_Ne = size(Mc,2);

            %% Construct New Edge Matrix from Incidence
            for i = 1:size(Mc,2)
                for j = 1:size(Mc,1)
                    idx_tmp = Mc(j,i);
                    if idx_tmp == 1
                        EdgeMatrixNew(i,2) = j;             
                    elseif idx_tmp == -1
                        EdgeMatrixNew(i,1) = j;
                    end
                end
            end 

            %% Update Parameterization Array
            ParamTot_name = [ParamsTot.Variable];
            ParamTot_comp_idx = ParamsTot_comp_idx;
            ParamTot_expression_idx = ([ParamsTot.Expression] == true);
            ParamTot_nonCommon_idx = ([ParamsTot.Common] == false);

            % Update non-common parameters for scalars and expressions containing non-common variables 
            ParamTot_name(ParamTot_expression_idx) = strtrim(extractBefore(ParamTot_name(ParamTot_expression_idx),"="));
            ParamTot_nonCommon_name = ParamTot_name(ParamTot_nonCommon_idx);
            ParamTot_nonCommon_comp = ParamsTot_comp_idx(ParamTot_nonCommon_idx);
            [ParamTot_nonCommon_name_unique, main_idx,repeat_idx] = unique(ParamTot_nonCommon_name);
            ParamTot_nonCommon_comp_unique = ParamTot_nonCommon_comp(main_idx);

            % Find repeating parameters
            ParamTot_nonCommon_repeat_cnts = accumarray(repeat_idx,1);
            ParamTot_nonCommon_repeat_name_idx = (ParamTot_nonCommon_repeat_cnts > 1);
            % Compute number of repeat values per parameter
            ParamTot_nonCommon_repeat_cnts = ParamTot_nonCommon_repeat_cnts(ParamTot_nonCommon_repeat_name_idx);
            % Compute repeat variable names
            ParamTot_nonCommon_repeat_name = ParamTot_nonCommon_name_unique(ParamTot_nonCommon_repeat_name_idx);
            % Compute number of variable updates required
            ParamTot_totnum_idxUpdates = length(ParamTot_nonCommon_repeat_cnts);
            % compute total number of variable upates requires
            ParamTot_totnum_updates = sum(ParamTot_nonCommon_repeat_cnts);
            % Compute indices that will require updates
            % Create cell array for each variable with associated indices that require updates
            for k = 1:ParamTot_totnum_idxUpdates
                ParamTot_nonCommon_repeat_idx{k} = find(strcmp(ParamTot_name,ParamTot_nonCommon_repeat_name(k)));
                % Compute component number
                ParamTot_nonCommon_repeat_comp{k} = ParamsTot_comp_idx(ParamTot_nonCommon_repeat_idx{k});
                % Compute variable names all
                ParamTot_nonCommon_repeat_name_all{k} = ParamTot_name(ParamTot_nonCommon_repeat_idx{k});
            end

            % add suffix to old variable to create new variable
            % 
            idx_tot = 1;
            
            for i = 1:ParamTot_totnum_idxUpdates

                % initialize suffix numbering
                suffix_tmp = 1; 
                % old variable name to update 
                repeat_name_old = ParamTot_nonCommon_repeat_name(i); 
                % component number index 
                comp_tot_idx = ParamTot_nonCommon_repeat_comp{i};
                % compute total number of update for current variable
                tot_updates = ParamTot_nonCommon_repeat_cnts(i);
                % all indices to update for current variable 
                params_update_idx = ParamTot_nonCommon_repeat_idx{i};

                % Update suffix each time the variable repeats 
                % Verify new suffix is not contained in parameter variable list 
                % Update parmeter variable list when new suffix is created 
                for j = 1:tot_updates
                    % parameter update index 
                    paramUpdate_idx = params_update_idx(j);
                    % expression flag 
                    paramExpresFlg = ParamsTot(paramUpdate_idx).Expression == true;
                    % component number array 
                    comp_idx(idx_tot) = comp_tot_idx(j);
                    % old parameter array 
                    param_old(idx_tot) = repeat_name_old;
                    % loop until suffix does not exist in parameter variable list 
                    while true 
                        % create new variable using suffix 
                        repeat_name_new = repeat_name_old + "_" + string(suffix_tmp);
                        % increment suffix by one 
                        suffix_tmp = suffix_tmp + 1;
                        % if the variable does not exist in parameter list update parameter object variable name 
                        if any(~ismember(ParamTot_name,repeat_name_new))
                            % if parameter is not an expression, replace variable directly
                            if ~paramExpresFlg
                                ParamsTot(paramUpdate_idx).Variable = repeat_name_new;
                            % else parameter is expression, update lhs of expression with new variable name
                            else
                                % temporarily store current expression 
                                expression_tmp = ParamsTot(paramUpdate_idx).Variable;
                                % determine original lhs
                                expression_lhs_old = extractBefore(expression_tmp,"=");
                                % determine rhs
                                expression_rhs_tmp = extractAfter(expression_tmp,"=");
                                % update lhs 
                                expression_lhs_new = replace(expression_lhs_old,repeat_name_old,repeat_name_new);
                                % combine new lhs and original rhs 
                                expression_new = expression_lhs_new + "=" + expression_rhs_tmp;
                                % update parameter object with new expression
                                ParamsTot(paramUpdate_idx).Variable = expression_new;
                            end
                            % new parameter array 
                            param_new(idx_tot) = repeat_name_new;
                            % increment update array index
                            idx_tot = idx_tot + 1;
                            % update variable name list for renmaing
                            ParamTot_name = [ParamsTot.Variable];
                            ParamTot_name(ParamTot_expression_idx) = strtrim(extractBefore(ParamTot_name(ParamTot_expression_idx),"="));
                            break;
                        else
                            fprintf('Error, contained in original list, notify developer')
                        end
                    end
                end
            end

            % grab symbols from class and create regular expression to seperate variables from operators
            operators_tmp = gmtEnumE.gmt_Symbols().Symbols;
            parentheses_tmp = ["(",")",","];
            %functions_tmp = gmtEnumE.gmt_Funcs().Funcs;
            operatorsEscaped = regexptranslate('escape', [operators_tmp,parentheses_tmp]);
            operatorsPattern = "[" + strjoin(cellstr(operatorsEscaped), "") + "]";
            inner = extractBetween(operatorsPattern, 2, strlength(operatorsPattern)-1);
            operatorRegExpr = operatorsPattern + "|[^" + inner + "]+";

            % 
       
            for i = 1:ParamTot_totnum_updates
                CompNum_idx = comp_idx(i);
                ParametersVars_old_tmp = param_old(i);
                ParametersVars_new_tmp = param_new(i);
                EdgeNums = objC_Ne_new{CompNum_idx};
                VertexNums = objC_Nv_new{CompNum_idx};
                if ParametersVars_old_tmp ~= ParametersVars_new_tmp
                    for j = 1:length(EdgeNums)
                        EdgeIdx = EdgeNums(j);
                        EdgeEq_tmp = EdgeTot(EdgeIdx).EdgeEq;
                        EdgeEq_sep = strtrim(regexp(EdgeEq_tmp,operatorRegExpr, "match"));
                        if any(contains(EdgeEq_sep,ParametersVars_old_tmp))
                            edgeVarIdx = find(EdgeEq_sep == ParametersVars_old_tmp);
                            EdgeEq_sep(edgeVarIdx) = ParametersVars_new_tmp;
                            EdgeEq_new = join(EdgeEq_sep,"");
                            EdgeTot(EdgeIdx).EdgeEq = EdgeEq_new;
                        end
                    end
        
                    for j = 1:length(VertexNums)
                        CapEq_tmp = VertexTot(VertexNums(j)).CapacitanceEq;
                        CapEq_sep = strtrim(regexp(CapEq_tmp,operatorRegExpr, "match"));
                        if any(contains(CapEq_sep,ParametersVars_old_tmp))
                            vertexVarIdx = find(CapEq_sep == ParametersVars_old_tmp);
                            CapEq_sep(vertexVarIdx) = ParametersVars_new_tmp;
                            CapEq_new = join(CapEq_sep,"");
                            VertexTot(VertexNums(j)).CapacitanceEq = CapEq_new;
                        end
                    end
                end
            end

            [ParameterUnique, ia, ic] = unique([ParamsTot.Variable]');
            ia = sort(ia);
            ParameterNew = ParamsTot(ia);

            %% Update Exergy Equation Parameter Variables

            %% Update Dependent Vertex State Variables
            VertexStateVar_old = [VertexTot.ComponentStateVariable];
            VertexStateVar_idx = find(VertexStateVar_old ~= "");

            for i = 1:length(VertexStateVar_idx)
                CompNum_idx = VertexTot_comp_idx(VertexStateVar_idx(i));
                OldStateNum(i) = double(extractAfter(VertexStateVar_old(VertexStateVar_idx(i)),"x"));
                NewStateNum(i) = objC_Nv_new{CompNum_idx}(objC_Nv_old{CompNum_idx} == OldStateNum(i));
                NewStateNum_idx = find(objC_VertexNumR_unsort == NewStateNum(i));
                if isempty(NewStateNum_idx)
                    idxNum_remove = sum(objC_VertexNumR <= NewStateNum(i));
                    NewStateNum(i) = NewStateNum(i) - idxNum_remove;
                else
                    NewStateNum(i) = objC_VertexNumR_inv_new(NewStateNum_idx);
                end
                VertexUpdateArray = setdiff(objC_Nv_new{CompNum_idx},objC_VertexNumR);
                NumCapacitance = length(VertexUpdateArray);
                OldStateVar = "x" + string(OldStateNum(i));
                NewStateVar = "x" + string(NewStateNum(i));
                for j = 1:NumCapacitance
                    VertexIdx = VertexUpdateArray(j);
                    VertexTot(VertexIdx).CapacitanceEq = replace(VertexTot(VertexIdx).CapacitanceEq,OldStateVar,NewStateVar);
                end
            end

            %% Update Exergy Equation Dependent State Variables

            %% Update Port Array 

            % Assign Temporary Port Array
            PortsTot_tmp = PortsTot;

            % Remove connected edge port connections 
            if ~isempty(Ports_num_remove)
                Ports_num_remove = [Ports_num_remove{:}];
                PortsTot_tmp(Ports_num_remove) = [];
                PortsTot_comp_idx(Ports_num_remove) = [];
            end

            % Determine edge and vertex connection port indices 
            Ports_edge_locIdx = find([PortsTot_tmp.PortType] == gmtEnumE.gmt_PortType.EdgeConnection);
            Ports_vertex_locIdx = find([PortsTot_tmp.PortType] == gmtEnumE.gmt_PortType.VertexConnection);

            % Renumber all edge connection element numbering
            for i = 1:length(Ports_edge_locIdx)
                PortNum_idx = Ports_edge_locIdx(i);
                CompNum_idx = PortsTot_comp_idx(PortNum_idx);
                OldElementNumber = PortsTot_tmp(PortNum_idx).ElementNumber;
                NewElementNumber = objC_Ne_new{CompNum_idx}(objC_Ne_old{CompNum_idx}==OldElementNumber);
                PortsTot_tmp(PortNum_idx).ElementNumber = NewElementNumber;
            end

            % Renumber all vertex connection element numbering
            for i = 1:length(Ports_vertex_locIdx)
                PortNum_idx = Ports_vertex_locIdx(i);
                CompNum_idx = PortsTot_comp_idx(PortNum_idx);
                OldElementNumber = PortsTot_tmp(PortNum_idx).ElementNumber;
                NewElementNumber = objC_Nv_new{CompNum_idx}(objC_Nv_old{CompNum_idx}==OldElementNumber);
                PortsTot_tmp(PortNum_idx).ElementNumber = NewElementNumber;
            end 

            % Create vectors for mapping old to new element numbers after combination
            objC_Nv_old_vec = [objC_Nv_new{:}];
            objC_Ne_old_vec = [objC_Ne_new{:}];
            objC_Nv_old_vec(objC_VertexNumR) = [];
            objC_Ne_old_vec(objB_EdgeNumR) = [];
            objC_Nv_new_vec = 1:length(objC_Nv_old_vec);
            objC_Ne_new_vec= 1:length(objC_Ne_old_vec);

            % Update edge element numbering 
            Ports_edge_elNum = [PortsTot_tmp(Ports_edge_locIdx).ElementNumber]; % old element numbers before reduced incidence matrix 
            [tf_edge, loc_edge] = ismember(Ports_edge_elNum,objC_Ne_old_vec); % mapping indicies from old to new 
            Ports_edge_elNum_new = objC_Ne_new_vec(loc_edge(tf_edge)); % new element numbers from mapping

            % Identify edge ports that need to be removed
            Ports_num_remove = Ports_edge_locIdx(~tf_edge); 
            Ports_edge_locIdx = Ports_edge_locIdx(tf_edge);

            % Map edge element numbering 
            Ports_vertex_elNum = [PortsTot_tmp(Ports_vertex_locIdx).ElementNumber];
            [tf_vertex, loc_vertex] = ismember(Ports_vertex_elNum,objC_Nv_old_vec);
            Ports_vertex_elNum_new = objC_Nv_new_vec(loc_vertex(tf_vertex));

            % Map vertex element numbering 
            Ports_num_remove = [Ports_num_remove, Ports_vertex_locIdx(~tf_vertex)];
            Ports_vertex_locIdx = Ports_vertex_locIdx(tf_vertex);

            % Update edge element numbering
            for i = 1:length(Ports_edge_locIdx)
                PortsTot_tmp(Ports_edge_locIdx(i)).ElementNumber = Ports_edge_elNum_new(i);
            end

            % Update vertex element numbering
            for i = 1:length(Ports_vertex_locIdx)
                PortsTot_tmp(Ports_vertex_locIdx(i)).ElementNumber = Ports_vertex_elNum_new(i);
            end

            % Remove ports 
            PortsTot_tmp(Ports_num_remove) = [];

            PortsNew = PortsTot_tmp;

            %% Update Input Array
            InputVars_new = [Inputs_new{:}]';
            NumInputVars = length(InputVars_new);

            if isempty(InputVars_new)
                NewInput = [];

            end

            % Update Input Objects
            for i = 1:NumInputVars
                NewInput(i) = InputTot(i);
                NewInput(i).VariableName = InputVars_new(i);
            end

            % Update Edge and Vertex Equations 
            for i = 1:NumComp
                EdgeNums = objC_Ne_new{i};
                VertexNums = objC_Nv_new{i};

                % Update Edge Objects
                for j = 1:length(EdgeNums)
                    EdgeTot(EdgeNums(j)).EdgeEq = replace(EdgeTot(EdgeNums(j)).EdgeEq,Inputs_old{i},Inputs_new{i});
                end

                % Update Vertex Objects
                for j = 1:length(VertexNums)
                    VertexTot(VertexNums(j)).CapacitanceEq = replace(VertexTot(VertexNums(j)).CapacitanceEq,Inputs_old{i},Inputs_new{i});
                end

            end

            %% Update Exergy Equation Input Variables

            %% Create New Edge and Vertex Arrays 
            EdgeTot(objB_EdgeNumR) = [];
            VertexTot(objC_VertexNumR) = [];

            %% Reconstruct Each Edge 
            for i = 1:length(EdgeTot)
                EdgeName_tmp = EdgeTot(i).EdgeName;
                EdgeEq_tmp = EdgeTot(i).EdgeEq;
                if EdgeTot(i).EdgeType == gmtEnumE.gmt_EdgeType.External
                    EdgeNew(i) = gmt_Edge(EdgeName_tmp,EdgeEq_tmp,"External");
                else
                    EdgeNew(i) = gmt_Edge(EdgeName_tmp,EdgeEq_tmp);
                end
            end

            %% Reconstruct Each Vertex
            for i = 1:length(VertexTot)
                VertexName_tmp = VertexTot(i).VertexName;
                CapEq_tmp = VertexTot(i).CapacitanceEq;

                if ~isempty(VertexTot(i).Units)
                    varargin2 = [{"Units"}, {VertexTot(i).Units}]; 
                else
                    varargin2 = [];
                end

                if VertexTot(i).VertexType == gmtEnumE.gmt_VertexType.External && ~isempty(varargin2)
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp,"External",true,varargin2{:});
                elseif VertexTot(i).VertexType == gmtEnumE.gmt_VertexType.External
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp,"External",true);
                elseif ~isempty(varargin2)
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp,varargin2{:});
                else
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp);
                end
            end

            %% Concatenate Exergy Variable Input Argument

            %% Build Graph Model 
            sys = gmt_Graph(CombineName,EdgeMatrixNew,EdgeNew,VertexNew,ParameterNew,NewInput,PortsNew,varargin{:});

          end

        %% Variable Input Argument Data Parsing 
        function params = gmt_parseSuperclass(obj,varargin)  
            % Variable Input Parsing 
            p = inputParser;
            p.KeepUnmatched = true;
            addParameter(p, 'ModelParameters',[], @(x) isa(x,'gmt_Parameter'));
            addParameter(p, 'SystemModel',false, @(x) islogical(x) && isscalar(x));
            addParameter(p, 'InitCon', [], @(x) all(isnumeric(x),size(x,1) == 1));
            addParameter(p, 'BuildSim', [], @(x) isstring(x));
            parse(p, varargin{:});
            params = p.Results;    
        end
    end
end
