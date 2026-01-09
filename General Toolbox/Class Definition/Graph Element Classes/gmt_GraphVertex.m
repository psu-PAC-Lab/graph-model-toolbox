%% gmt_GraphVertex
% Class used to define vertex properties in graph model
% Note CapacitanceEq syntax 
% Multi-states and multi-control inputs syntax must be defined starting 
% with the variable name "x" or "u" followed by the number "x1" "x2" etc. 
% Single state or single control inputs must be defined only by the variable
% name "x" or "u"

classdef gmt_GraphVertex
    
    properties
        % User Defined Meta Data
        VertexName string % User specified name to define an vertex object
        CapacitanceEq string % User specified name formula defining the vertex capacitance equation
    end

    properties (SetAccess = protected)
        % Internal Meta Data - Defined Only Based On Vertex Object
        StateType string % Internally specified state type based on user define capitance equation formulation
        VertexType string = gmt_VertexType.Internal % Internally specified vertex type assigned during graph model generation
        NvSa (1,1) double % Number of independent algebraic states within vertex  
        NvSd (1,1) double % Number of independent dynamic state within vertex 
        NvS (1,1) double % Total number of independent states within vertex 
        NvU (1,1) double % Number of control inputs within vertex
        Capacitance string % Internally computed capacitance based on user defined capacitance equation
        StateVariables string = [] % List of algebraic and dynamic state variables defiend in capacitance equation 
        StateDerVariables string = [] % List of dynamic state variables defined in capacitance equation 
        InputVariables string = [] % List of input variables defined in capacitance equation
        % External Meta Data - Defined Based On EdgeMatrix and Edge Objects 
        GraphStateVariables string = [] % Auto-generated list of state variables based on graph model
        GraphStateDerVaribles string = [] %% Auto-generated list of state derivative variables based on graph model
        GraphCapacitanceEq string = [] % Auto-generated graph specific capacitance equation 
        GraphCapacitance string = [] % Auto-generated graph specifif capacitance equation 
        NvE double = [] % Number of edges connected to vertex 
        GraphPowerEq string % Internally specified vertex total power equation after post processing edge equations, and edge matrix
        GraphVertexEq string % Internall computed state derivative equation
        GenStateVariable string = "Unassigned" % Internally specified state variable x1, x2, x3, etc. assigned during graph model generation
        UserStateVariable string = "Unassigned" % User specified state variable name for human readability assigned during graph model generation
    end

    methods
    
        %% Constructor Method (User Defined and Internal Meta Data Update) 
        function obj = gmt_GraphVertex(VertexName,CapacitanceEquation,varargin)

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

            % Determines StateType using _dot phrase 
            if contains(CapacitanceEquation,"_dot") == true
                obj.StateType = gmt_StateType.Dynamic;
            else
                obj.StateType = gmt_StateType.Algebraic;
            end

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
            pattern_regex = '^x\d+_dot$|^x_dot$';

            match_tmp = regexp(CapacitanceEq_var_tmp, pattern_regex);

            % Convert From Cell to Array
            if iscell(match_tmp)
                match_tmp = ~cellfun('isempty',match_tmp);
            elseif isempty(match_tmp)
                match_tmp = false;
            end

            % Compute number of states derivatives and store variables into list  

            if any(match_tmp) % There is atleast one matching variable found 
                match_idx = find(match_tmp); % Find the indices for matching variable 
                varnamxd_tmp = CapacitanceEq_var_tmp(match_idx); % Return matching variables 
                varnumxd_tmp = extractBefore(extractAfter(varnamxd_tmp,"x"),"_dot"); % Return suffix of state variable x
                % Valid syntax is either a single state or multiple states 
                isstremptyd = strlength(varnumxd_tmp) == 0;

                if exist('isstrempty','var')
                    assert(any(isstremptyd)==any(isstrempty),"State variable syntax does not match state derivative syntax. There is mismatch between number state variables and numbering state derivative variables.")
                end
                
                if all(isstremptyd) 
                    NvSd_tmp = 1;
                else 
                    assert(~any(isstremptyd),"Capacitance equation combines single state derivative vertex syntax 'x_dot' and multi-state vertex syntax 'x1_dot, x2_dot, x3_dot ...', review capacitance equation.")
                    varnumxd_tmp = unique(sort(str2double(varnumxd_tmp)));
                    isx_consecutive = all(diff(varnumxd_tmp) == 1);
                    assert(isx_consecutive,"State derivative variables indexing is not monotically increasing")
                    isx_strt_one = min(varnumxd_tmp) == 1;
                    assert(isx_strt_one,"State derivative variable indexing does not start from one.")
                    NvSd_tmp = max(varnumxd_tmp);
                end
                obj.StateDerVariables = unique(varnamxd_tmp');
            else
                NvSd_tmp = 0;
            end

            obj.NvSd = NvSd_tmp;

            % Compute number of states and store variables into list  

            % State Number Determination 
            pattern_regex = '^[x]\d$|^[x]$';

            match_tmp = regexp(CapacitanceEq_var_tmp, pattern_regex);

            % Convert From Cell to Array
            if iscell(match_tmp)
                match_tmp = ~cellfun('isempty',match_tmp);
            elseif isempty(match_tmp)
                match_tmp = false;
            end

            if any(match_tmp) % There is atleast one matching variable found 
                match_idx = find(match_tmp); % Find the indices for matching variable 
                varnamx_tmp = CapacitanceEq_var_tmp(match_idx); % Return matching variables 
                varnumx_tmp = extractAfter(varnamx_tmp,"x"); % Return suffix of state variable x
                % Valid syntax is either a single state or multiple states 
                isstrempty = strlength(varnumx_tmp) == 0;
                if all(isstrempty) 
                    NvS_tmp = 1;
                else 
                    assert(~any(isstrempty),"Capacitance equation combines single state vertex syntax 'x' and multi-state vertex syntax 'x1, x2, x3 ...', review capacitance equation.")
                    varnumx_tmp = unique(sort(str2double(varnumx_tmp)));
                    isx_consecutive = all(diff(varnumx_tmp) == 1);
                    assert(isx_consecutive,"State variables indexing is not monotically increasing")
                    isx_strt_one = min(varnumx_tmp) == 1;
                    assert(isx_strt_one,"State variable indexing does not start from one.")
                    NvS_tmp = max(varnumx_tmp);
                end
                obj.StateVariables = unique(varnamx_tmp');
            else
                NvS_tmp = 0;
            end

            obj.NvSa = NvS_tmp;

            % Add Dynamic State Variables to State Variables 
            % Compute Total Number of States
            if ~isempty(obj.StateDerVariables)
                StateVar_tmp = unique([obj.StateVariables, extractBefore(obj.StateDerVariables,"_dot")']);
                obj.StateVariables = StateVar_tmp;
                obj.NvS = length(StateVar_tmp);
            end

            % Control Input Number Determination 
            pattern_regexu = '^[u]\d|^[u]$';

            matchu_tmp = regexp(CapacitanceEq_var_tmp, pattern_regexu);

            % Convert From Cell to Array
            if iscell(matchu_tmp)
                matchu_tmp = ~cellfun('isempty',matchu_tmp);
            elseif isempty(matchu_tmp)
                matchu_tmp = false;
            end


            % Compute number of control inputs and store variables into list 
            
            if any(matchu_tmp) % There is atleast one matching variable found 
                matchu_idx = find(matchu_tmp); % Find the indices for matching variable 
                varnamu_tmp = CapacitanceEq_var_tmp(matchu_idx); % Return matching variables 
                varnumu_tmp = extractAfter(varnamu_tmp,"u"); % Return suffix of state variable x
                % Valid syntax is either a single state or multiple states 
                isstrempty = strlength(varnumu_tmp) == 0;
                if all(isstrempty) 
                    NvU_tmp = 1;
                else 
                    assert(~any(isstrempty),"Capacitance equation combines single control input syntax 'u' and multi-control input syntax 'u1, u2, u3 ...', review capacitance equation.")
                    varnumu_tmp = unique(sort(str2double(varnumu_tmp)));
                    % Removed 01/06/2025 this should only be required for state variable in capacitance equation 
                    % isu_consecutive = all(diff(varnumu_tmp) == 1);
                    % assert(isu_consecutive,"Control input variables indexing is not monotically increasing")
                    % isi_strt_one = min(varnumu_tmp) == 1;
                    % assert(isi_strt_one,"Control input variable indexing does not start from one.")
                    % NvU_tmp = max(varnumu_tmp);
                    NvU_tmp = length(varnumu_tmp);
                end
                obj.InputVariables = unique(varnamu_tmp');
            else
                NvU_tmp = 0;
            end

            obj.NvU = NvU_tmp;

            % Vertex Capacitance 
            Capacitance_tmp = erase(obj.CapacitanceEq, obj.StateDerVariables);
            % Create regular expression pattern to remove strings ending in math operator
            pattern = "(" + strjoin(gmt_Symbols().Symbols, "|") + ")$";
            % Run regular expression and remove operator if present at end of string
            obj.Capacitance = regexprep(Capacitance_tmp, pattern, "");    
        end
    
        %% External MetaData Methods

        % Updates graph specific information 
        function obj = gmt_GraphVertexUpdate(obj,Ds_var_tmp, As_var_tmp)

            % Assign Graph Specifics to Vertex 
            obj.GraphStateDerVaribles = Ds_var_tmp;
            obj.GraphStateVariables = As_var_tmp;
            
            % Create Old and New List for Replacement 
            genVars = [obj.StateVariables,obj.StateDerVariables];
            graphVars = [obj.GraphStateVariables,obj.GraphStateDerVaribles];

            % Update Graph Specific Equations 
            obj.GraphCapacitanceEq = replace(obj.CapacitanceEq, genVars, graphVars);
            obj.GraphCapacitance = replace(obj.Capacitance, genVars, graphVars);

        end

        % Updates Power Equations
        function obj = gmt_GraphVertexEqUpdate(obj,final_tmp)
            % Updates vertex power flow based on edge matrix analysis, and edge equations
            obj.GraphPowerEq = "(" + final_tmp + ")";
            obj.GraphVertexEq = "(1/(" + obj.GraphCapacitance + "))*" + obj.GraphPowerEq;
        end

        % %% Function to Update NvE 
        % % Assign NvE from component graph  
        % function obj = gmt_VertexNvE(obj,NvE_tmp)
        %     obj.NvE = NvE_tmp;
        % end

        % function obj = gmt_VertexCapacitance(obj)
        %     % Determine Capitance by removing states, operators, and symbols intelligently 
        %     % Remove state derivative "x_dot" from string.
        %     % NOTE: MUST HAPPEN BEFORE REMOVING "x" FROM STRING, REMOVING "x" BEFORE "x_dot" COULD RESULT IN "_dot" IF "x_dot" PRESENT
        %     cap_tmp = erase(obj.CapacitanceEq,"x_dot");
        %     % Determine if state division is required 
        %     %% Does the capacitance equation contain a state variable 
        %     if contains(obj.CapacitanceEq,"x") == true
        %     % Check if capacitance state matches states in power equation
        %         if contains(obj.Power_Eq,obj.GenStateVariable)
        %             % Compute the length of power equation string 
        %             char_len_tmp = strlength(obj.Power_Eq);
        %             % Convert Power Flow Equation into Char Array for Search
        %             pwr_char_tmp = char(obj.Power_Eq);
        %             % Initalize Operator Counter
        %             num_ops_tmp = 0;
        %             % Initalize State Counter
        %             num_st_tmp = 0;
        %             % Intialize Search Index
        %             idx_strt_tmp = 1;
        %             % Determine if state is present 
        %             for i = 1:char_len_tmp
        %                 % Is this character element an addition or subtraction operator?
        %                 if contains(pwr_char_tmp(i),"+") || contains(pwr_char_tmp(i),"-") 
        %                     % Increment Operator Counter 
        %                     num_ops_tmp = num_ops_tmp + 1;
        %                     % Does the state lie between the next operator and current operator 
        %                     if contains(pwr_char_tmp(idx_strt_tmp:i),obj.GenStateVariable)
        %                         % Increment State Counter
        %                         num_st_tmp = num_st_tmp + 1;
        %                     end
        %                     % Increment Search Index
        %                     idx_strt_tmp = i;
        %                 end
        %             end
        %             % Check if remaining expressions have state variable
        %             if num_st_tmp >0 && contains(pwr_char_tmp(idx_strt_tmp:end),obj.GenStateVariable)
        %                 % Increment State Counter
        %                 num_st_tmp = num_st_tmp + 1;
        %             end
        %             % Check if number of operators is equal to numbers of states. 
        %             if num_st_tmp == num_ops_tmp 
        %                 % State division is required, remove state variable "x" from string 
        %                 cap_tmp = erase(cap_tmp,"x");
        %                 %% 12/01/2025 Stopped Here, Need to figure out how to intelligent do state division 
        %             end
        %         end
        %     end
        % 
        %     % Convert reduce string to character array for operator search 
        %     cap_char_tmp = char(cap_tmp);
        %     % Compute character array length and store for future use 
        %     cap_char_len = length(cap_char_tmp);
        %     % Initialize Symbol Counter Array and Indexing Search Number
        %     sym_idx_tmp = []; 
        %     idx_tmp = 1; 
        %     % Search through character array for operator or other symbols {+, -, *, /}
        %     for j = 1:cap_char_len
        %         % If the character is a symbol, indication in an array. 
        %         if contains(cap_char_tmp(j),gmt_Symbols().Symbols) == false
        %             % Assign Array Value Cooresponding To Symbol
        %             sym_idx_tmp(idx_tmp) = j; 
        %             % Increment Index
        %             idx_tmp = idx_tmp + 1; 
        %         end
        %     end
        %     % Remove indexes with symbols
        %     obj.Capacitance = string(cap_char_tmp(sym_idx_tmp));
        % end

        %% Compute State Derivative Equation 
        % Computes State Derivative Equation
        function obj = gmt_XDotEq(obj)

            % Determine if parentheses required
            pr_tmp = false;
            if obj.NvE > 1 
                % Parentheses required is more than one edge
                pr_tmp = true;
            end

            % Compute New Power Equation 
            if pr_tmp == false
                % No modificatons required 
                pwr_eq_tmp = obj.Power_Eq;
            elseif pr_tmp == true
                % Add parentheses 
                pwr_eq_tmp = strcat("(",obj.Power_Eq,")");
            end 
 
            % Divide by capacitance 
            obj.X_Dot_Eq = strcat("(1/(",obj.Capacitance,"))*",pwr_eq_tmp);
        end
    end
end

