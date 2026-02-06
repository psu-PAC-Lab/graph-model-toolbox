%% gmt_GraphVertex
% Class used to define vertex properties in graph model
% Note CapacitanceEq syntax 
% Multi-states and multi-control inputs syntax must be defined starting 
% with the variable name "x" or "u" followed by the number "x1" "x2" etc. 
% Single state or single control inputs must be defined only by the variable
% name "x" or "u"

classdef gmt_Vertex
    
    properties
        % User Defined Meta Data
        VertexName string % User specified name to define an vertex object
        CapacitanceEq string % User specified name formula defining the vertex capacitance equation
        VertexType string = gmt_VertexType.Internal % Internally specified vertex type assigned during graph model generation
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
        ComponentStateVariable string = [] % List of algebraic state variables defiend in capacitance equation that are part of the graph but are user defined
        StateVariables string = [] % List of algebraic and dynamic state variables defiend in capacitance equation 
        StateDerVariables string = [] % List of dynamic state variables defined in capacitance equation 
        InputVariables string = [] % List of input variables defined in capacitance equation
        OutputVariables string = [] % List of output variables defined in capacitance equation 
        ParameterVariables string = [] % List of parameter variables defined in capacitance equation 
        % External Meta Data - Auto-Generated based On EdgeMatrix and Edge Objects i.e. a graph model must be defined to define these variables
        GraphDisturbanceType string = "unassigned" % Auto-generated based incidence matrix;
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

            % Generates instance of gmt_GraphVertex object
            Name_data_valid = isa(VertexName,'string');
            CapacitanceEquation_data_valid = isa(CapacitanceEquation,'string');
    
            % Determine if name input is empty
            if Name_data_valid
                Name_blank = logical(strlength(VertexName)==0);
                if Name_blank 
                    error("Name field is empty")
                end
            else
                error("Name field data type is not a string")
            end
    
            % Determine if CapacitanceEquation input is empty
            if CapacitanceEquation_data_valid
                CapacitanceEquation_blank = logical(strlength(CapacitanceEquation)==0);
                if CapacitanceEquation_blank
                    error("Capacitance Equation field is empty")
                end
            else 
                error("Capacitance Equation field data type is not a string")
            end
    
            % Update Object Properties 
            obj.VertexName = VertexName; % Assigns input variable Name to VertexName property 
            obj.CapacitanceEq = CapacitanceEquation; % Assigns input variable Equation to CapacitanceEq property 

            % Determine if user has specified external edge type
            numInputs = length(varargin); % Compute number of variable length input arguments 

            % Check variable length input argument if one is assigned 
            if numInputs == 1 
                if strcmpi(varargin{1},gmt_VertexType.External) % Case-insensitive string compare
                    obj.VertexType = gmt_VertexType.External; % Assign vertex type to available enumeration 
                else % Return error is variable input argument does not match upper or lower class spelling
                    error("Check spelling, user specified vertex type other than 'External'. Users only need to define external vertex types, internal edge type is default assumption.")
                end
            elseif numInputs > 1 % More than one variable return error 
                error("More than one variable length input argument has been assigned. Object only accepts one variable input argument for external vertex types.")
            end

            % Compute Internal Metadata
            obj = gmt_VertexUpdate(obj);

        end
    
        %% Internal Metadata Method
        % Updates based vertex specific information 
        function obj = gmt_VertexUpdate(obj)

            % Determine State Type (Dynamic or Algebraic) 
            if contains(obj.CapacitanceEq,"_dot") == true
                obj.StateType = gmt_StateType.Dynamic;
            else
                obj.StateType = gmt_StateType.Algebraic;
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
            CapacitanceEq_var_tmp = split(obj.CapacitanceEq,[gmt_Symbols().Symbols,"(",")","^"]);

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
                if obj.StateType == gmt_StateType.Algebraic
                    obj.StateVariables = obj.InputVariables;
                end
            end

            % Number of Outputs Determination
            if obj.StateType == gmt_StateType.Algebraic 
                obj.NvY = 1;
                obj.OutputVariables = "y";
            end

            % Vertex Capacitance 
            if obj.StateType == gmt_StateType.Dynamic 
                Capacitance_tmp = erase(obj.CapacitanceEq, obj.StateDerVariables);
                % Create regular expression pattern to remove strings ending in math operator
                pattern = "(" + strjoin(gmt_Symbols().Symbols, "|") + ")$";
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
            special_cond1 = obj.VertexType == gmt_VertexType.External;
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
        function obj = gmt_VertexDisturanceType(obj,DisturbanceType)
            obj.GraphDisturbanceType = DisturbanceType;
        end

    end
end

