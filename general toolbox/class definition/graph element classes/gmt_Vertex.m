%% gmt_Vertex
% gmt_Vertex  Class used to define vertex properties in a graph model.
%
% Documentation authored with assistance from OpenAI ChatGPT.
%
%   OBJ = gmt_Vertex(VertexName, CapacitanceEquation)
%   creates a graph vertex object using a user-defined vertex name and
%   capacitance equation.
%
%   OBJ = gmt_Vertex(..., Name, Value) specifies optional name-value
%   arguments including vertex type and state-variable units.
%
%   gmt_Vertex objects define the state behavior associated with graph
%   vertices within the gmt Toolbox framework. The class automatically
%   parses the capacitance equation to determine dynamic/algebraic state
%   behavior, state variables, input variables, parameter variables, and
%   graph-specific metadata used during graph-model generation.
%
% Capacitance Equation Syntax
%   Multi-state and multi-input systems must use indexed variable naming:
%
%       x1, x2, x3, ...
%       u1, u2, u3, ...
%
%   Dynamic states must use derivative notation:
%
%       x1_dot
%       x2_dot
%
%   Single-state and single-input systems may use:
%
%       x
%       u
%
% Constructor Inputs
%   VertexName            - String defining the vertex name.
%   CapacitanceEquation   - String defining the vertex capacitance equation.
%
% Name-Value Arguments
%   "External"
%       Logical flag indicating the vertex is external to the graph model.
%
%       Example:
%           gmt_Vertex(..., "External", true)
%
%   "Units"
%       String specifying the engineering units associated with the state
%       variable represented by the vertex.
%
%       Example:
%           gmt_Vertex(..., "Units", "Pa")
%
% User-Defined Properties
%   VertexName
%       User-defined name assigned to the vertex object.
%
%   CapacitanceEq
%       User-defined capacitance equation used to define vertex dynamics.
%
%   VertexType
%       Vertex classification:
%           gmt_VertexType.Internal
%           gmt_VertexType.External
%
%   Units
%       Optional engineering units associated with the state variable.
%
% Auto-Generated Internal Metadata
%   StateType
%       Automatically detected state classification:
%           gmt_StateType.Dynamic
%           gmt_StateType.Algebraic
%
%   NvSa
%       Number of algebraic states associated with the vertex.
%
%   NvSd
%       Number of dynamic states associated with the vertex.
%
%   NvS
%       Total number of independent states.
%
%   NvU
%       Number of control inputs referenced in the capacitance equation.
%
%   NvY
%       Number of outputs associated with the vertex.
%
%   Capacitance
%       Automatically extracted capacitance term from the capacitance
%       equation.
%
%   ComponentStateVariable
%       User-defined algebraic state variables referenced within the
%       capacitance equation.
%
%   StateVariables
%       Independent state variables detected from the capacitance equation.
%
%   StateDerVariables
%       Dynamic state-derivative variables detected from the capacitance
%       equation.
%
%   InputVariables
%       Input variables detected from the capacitance equation.
%
%   OutputVariables
%       Output variables associated with the vertex.
%
%   ParameterVariables
%       Parameter variables detected from the capacitance equation.
%
% Auto-Generated Graph Metadata
%   GraphStateVariables
%       Graph-specific state variables assigned during graph construction.
%
%   GraphStateDerVariables
%       Graph-specific state-derivative variables assigned during graph
%       construction.
%
%   GraphOutputVariables
%       Graph-specific output variables.
%
%   GraphCapacitanceEq
%       Graph-specific capacitance equation after variable substitution.
%
%   GraphCapacitance
%       Graph-specific capacitance term after graph-variable mapping.
%
%   GraphPowerEq
%       Graph-specific power equation generated during graph assembly.
%
%   GraphNvE
%       Number of graph edges connected to the vertex.
%
%   GraphVertexEq
%       Final graph-specific vertex equation generated during model
%       assembly.
%
% Public Methods
%   gmt_VertexUpdate
%       Parses the capacitance equation and computes vertex metadata
%       including state variables, derivative variables, input variables,
%       state type, and capacitance.
%
%   gmt_GraphVertexUpdate
%       Updates graph-specific variable naming and graph capacitance
%       equations during graph-model generation.
%
%       obj = obj.gmt_GraphVertexUpdate(Ds_var_tmp, As_var_tmp, y_var_tmp)
%
%   gmt_GraphVertexEqUpdate
%       Updates graph-specific power equations and final vertex equations.
%
%       obj = obj.gmt_GraphVertexEqUpdate(final_tmp, NvE_tmp)
%
% Notes
%   - Dynamic vertices are identified by the presence of "_dot" in the
%     capacitance equation.
%
%   - Dynamic-state capacitance is automatically extracted from the
%     left-hand multiplicative term associated with the derivative state.
%
%   - External vertices with a single input may directly map graph state
%     variables to input variables.
%
%   - Graph-specific variable names are assigned automatically during graph
%     model generation by gmt_Graph.
%
% Example
%   % Dynamic vertex
%   V1 = gmt_Vertex( ...
%       "Pressure Node", ...
%       "C*x_dot = q_in - q_out", ...
%       "Units", "Pa");
%
%   % External algebraic boundary vertex
%   V2 = gmt_Vertex( ...
%       "Boundary Pressure", ...
%       "u", ...
%       "External", true, ...
%       "Units", "Pa");
%
% See also gmt_Graph, gmt_Edge, gmt_Parameter, gmt_StateType,
%          gmt_VertexType
classdef gmt_Vertex
    
    properties
        % User Defined Meta Data
        VertexName string % User specified name to define an vertex object
        CapacitanceEq string % User specified name formula defining the vertex capacitance equation
        VertexType string = gmtEnumE.gmt_VertexType.Internal % Internally specified vertex type assigned during graph model generation
        Units % Optional argument to specify units for state variable
    end

    properties (SetAccess = protected)
        %  Internal Meta Data - Auto-Generated based vertex object, runs during constructor method i.e. only an vertex object must be defined to define these variables 
        StateType string % Internally specified state type based on user define capitance equation formulation
        NvSa (1,1) double = 0 % Number of independent algebraic states within vertex  
        NvSd (1,1) double = 0 % Number of independent dynamic state within vertex 
        NvS (1,1) double = 0 % Total number of independent states within vertex 
        NvU (1,1) double = 0 % Number of control inputs within vertex
        NvY (1,1) double = 0 % Number of outputs within vertex
        Capacitance string = []% Internally computed capacitance based on user defined capacitance equation
        ComponentStateVariable string = "" % List of algebraic state variables defiend in capacitance equation that are part of the graph but are user defined
        StateVariables string = [] % List of algebraic and dynamic state variables defiend in capacitance equation 
        StateDerVariables string = [] % List of dynamic state variables defined in capacitance equation 
        InputVariables string = [] % List of input variables defined in capacitance equation
        OutputVariables string = [] % List of output variables defined in capacitance equation 
        ParameterVariables string = [] % List of parameter variables defined in capacitance equation 
        % External Meta Data - Auto-Generated based On EdgeMatrix and Edge Objects i.e. a graph model must be defined to define these variables
        %GraphDisturbanceType string = "unassigned" % Auto-generated based incidence matrix;
        GraphStateVariables string = [] % Auto-generated list of state variables based on graph model
        GraphStateDerVariables string = [] % Auto-generated list of state derivative variables based on graph model
        GraphOutputVariables string = [] % Auto-generated list of output variables based on graph model
        GraphCapacitanceEq string = [] % Auto-generated graph specific capacitance equation 
        GraphCapacitance string = [] % Auto-generated graph specific capacitance equation 
        GraphPowerEq string % Auto-generated graph specific power equation 
        GraphNvE % Auto-generated number of edges connected to verte
        GraphVertexEq string % Auto-generated graph specific vertex equation 
    end

    methods
    
        %% Constructor Method (User Defined and Internal Meta Data Update) 
        function obj = gmt_Vertex(VertexName,CapacitanceEquation,varargin)

            p = inputParser;
            p.KeepUnmatched = true;
            addParameter(p, "External",false, @(x) islogical(x) && isscalar(x));
            addParameter(p, 'Units',[], @(x) isstring(x));
            parse(p, varargin{:});

            % assert VertexName datatype 
            assert(isa(VertexName,'string'),"VertexName datatype is not string")

            % assert CapacitanceEquation datatype
            assert(isa(CapacitanceEquation,'string'),"CapacitanceEquation datatype is not string")
            
            % assert VertexName not empty 
            assert(strlength(strtrim(VertexName)) > 0,"VertexName is field is empty" )
    
            % assert CapacitanceEquation not empty
            assert(strlength(strtrim(CapacitanceEquation)) > 0,"CapacitanceEquation is field is empty" )
    
            % Update Object Properties 
            obj.VertexName = VertexName; % Assigns input variable Name to VertexName property 
            obj.CapacitanceEq = CapacitanceEquation; % Assigns input variable Equation to CapacitanceEq property 

            % Update Vertex Type if User Specified 
            if ~isempty(p.Results.External)
                if p.Results.External == true
                    obj.VertexType = gmtEnumE.gmt_VertexType.External;
                end
            end

            % Update Units if User Specified
            if ~isempty(p.Results.Units)
                obj.Units = p.Results.Units;
            end

            % Compute Internal Metadata
            obj = gmt_VertexUpdate(obj);

        end
    
        %% Internal Metadata Method
        % Updates based vertex specific information 
        function obj = gmt_VertexUpdate(obj)

            % Determine State Type (Dynamic or Algebraic) 
            if contains(obj.CapacitanceEq,"_dot") == true
                obj.StateType = gmtEnumE.gmt_StateType.Dynamic;
            else
                obj.StateType = gmtEnumE.gmt_StateType.Algebraic;
            end

            % Capacitance Equation Parsing
            % Number of State Variables 
            % Number of States 
            % Number of Control Inputs
            % Number of Neural Networks 
            % Number of 1D lookup functions
            % Number of 2D lookup functions
            % Number of 3D lookup functions

            % Number of States within Capacitance Equation
            % Currently can only handle single digit numbers and does not check if the number sequencing is correct.
            % There can be one state or multiple states defined in equation

            % Split String By Mathematical Operators and Parentheses
            CapacitanceEq_var_tmp = split(obj.CapacitanceEq,[gmtEnumE.gmt_Symbols().Symbols,"(",")","^"]);

            % State Derivative Number Determination 
            pattern_regex = 'x\d+_dot|x_dot';
            match_tmp = regexp(obj.CapacitanceEq, pattern_regex,'match');
            StateDerhasDigit = contains(match_tmp, digitsPattern);
 
            % NOTE: Add Check for Numbering Order

            % Compute Number of State Derivatives
            if ~isempty(match_tmp)
                obj.NvSd = length(match_tmp);
                obj.StateDerVariables = unique(match_tmp);
            end

            stateder_tmp = extractBefore(obj.StateDerVariables,"_dot");

            % State Number Determination 
            pattern_regex = '(?<![A-Za-z0-9_])x\d*(?![A-Za-z0-9_])';
            match_tmp = regexp(obj.CapacitanceEq, pattern_regex,'match');
            StatehasDigit = contains(match_tmp, digitsPattern);

            % Update Dependent State Variables
            numDependent = max(sum(StatehasDigit) - sum(StateDerhasDigit),0);
            numStateVar_tmp = length(match_tmp);
            if numDependent > 0
                if numStateVar_tmp == 1 
                    obj.ComponentStateVariable = match_tmp;
                else
                    statedep_tmp = setdiff(match_tmp,stateder_tmp);
                    obj.ComponentStateVariable = unique(statedep_tmp);
                end
            end

            % Update Independent State Variables
            stateind_tmp = intersect(match_tmp,stateder_tmp);
            if isempty(stateind_tmp) && obj.NvSd > 0
                stateind_tmp = stateder_tmp;
            elseif isempty(stateind_tmp) && ~isempty(match_tmp)
                stateind_tmp = unique(match_tmp);
            end

            obj.NvS = length(unique(stateind_tmp));
            obj.StateVariables = unique(stateind_tmp);

            % Control Input Number Determination 
            pattern_regexu = '(?<![A-Za-z0-9_])u\d*(?![A-Za-z0-9_])';
            matchu_tmp = regexp(obj.CapacitanceEq, pattern_regexu,'match');
            if ~isempty(matchu_tmp)
                obj.NvU = length(matchu_tmp);
                obj.InputVariables = unique(matchu_tmp);
                if obj.StateType == gmtEnumE.gmt_StateType.Algebraic
                    obj.StateVariables = obj.InputVariables;
                end
            end

            % Number of Outputs Determination
            % if obj.StateType == gmt_StateType.Algebraic 
            %     obj.NvY = 1;
            %     obj.OutputVariables = "y";
            % end

            % Vertex Capacitance 
            if obj.StateType == gmtEnumE.gmt_StateType.Dynamic 
                Capacitance_tmp = erase(obj.CapacitanceEq, obj.StateDerVariables);
                % Create regular expression pattern to remove strings ending in math operator
                pattern = "(" + strjoin(gmtEnumE.gmt_Symbols().Symbols, "|") + ")$";
                % Run regular expression and remove operator if present at end of string             
                match_tmp = regexprep(Capacitance_tmp, pattern, "");    
                if strlength(match_tmp) == 0
                    obj.Capacitance = "1";
                else
                    obj.Capacitance = match_tmp;
                end
            else
                obj.Capacitance = "1";
            end

        end

        %% External Metadata Methods
        % Updates based graph specific information 
        function obj = gmt_GraphVertexUpdate(obj,Ds_var_tmp, As_var_tmp, y_var_tmp)

            % Assign Graph Specifics to Vertex 
            obj.GraphStateDerVariables = Ds_var_tmp;
            obj.GraphOutputVariables = y_var_tmp;

            % Special Case 
            special_cond1 = obj.VertexType == gmtEnumE.gmt_VertexType.External;
            special_cond2 = obj.NvU == 1;
            special_cond3 = isempty(As_var_tmp);
            specialcase = all([special_cond1,special_cond2,special_cond3]);

            if specialcase 
                obj.GraphStateVariables = obj.InputVariables;
                genVars_stateold = obj.InputVariables;
            else
                obj.GraphStateVariables = As_var_tmp;
                genVars_stateold = obj.StateVariables;
            end

            % Create Old and New List for Replacement 
            genVars = [genVars_stateold,obj.StateDerVariables];
            graphVars = [obj.GraphStateVariables,obj.GraphStateDerVariables];

            CapacitanceEq_tmp = obj.CapacitanceEq;
            Capacitance_tmp = obj.Capacitance;

            for i = 1:length(genVars)
                % Build regex to match whole variable
                expr = "(?<![A-Za-z0-9_])" + regexptranslate('escape', genVars(i)) + "*(?![A-Za-z0-9_])";
        
                % Replace with new variable
                CapacitanceEq_tmp = regexprep(CapacitanceEq_tmp, expr, graphVars(i));
                Capacitance_tmp = regexprep(Capacitance_tmp, expr, graphVars(i));
            end

            % Update Graph Specific Equations 
            obj.GraphCapacitanceEq = CapacitanceEq_tmp;
            obj.GraphCapacitance = Capacitance_tmp;

        end

        % Updates Power Equations
        function obj = gmt_GraphVertexEqUpdate(obj,final_tmp,NvE_tmp)
            % Update vertex number of edge connections 
            obj.GraphNvE = NvE_tmp;
            % Updates vertex power flow based on edge matrix analysis, and edge equations
            obj.GraphPowerEq = "(" + final_tmp + ")";
            obj.GraphVertexEq = "(1/(" + obj.GraphCapacitance + "))*" + obj.GraphPowerEq;
            
        end

        % Updates Disturbance Type
        % function obj = gmt_VertexDisturanceType(obj,DisturbanceType)
        %     obj.GraphDisturbanceType = DisturbanceType;
        % end

    end
end

