%% gmt_GraphEdge
% Class used to define edge properties in graph model
% EdgeEq syntax
% State variables must be defined by a "head" or "tail" state denoted by "xh" or "xt" respectively 
% Note Multi-states and Multi-Control Inputs Case
% Multi-states and multi-control inputs syntax must be defined starting with the variable 
% name "xt", "xh" or "u" followed by the number "xh1" "xh2" etc, the numbering of multi-variables
% starts from 1 and ends at max number of multi-variables. Below is a two head state variable example. 
% Valid Example: "xh1 + xh2"
% Invalid Example: "xh1 + xh3"
% Syntax applies to both multi-state and multi-control inputs. 
% Note Single State or Single Control Input Case
% State or control input variables must not have append numbers. Only the variable needs 
% to be defined if it is applicable. Below is an example of a head state variable and control input. 
% Valid Example: "xh + u" 
% Invaid Example: "xh1 + u" or "xh + u1"
% Syntax applies to both single-state and single-control inputs.
% The number of state variables does not need to match the number of control inputs. 
classdef gmt_Edge

properties
    % User Defined Meta Data
    EdgeName string % User specified name to define an edge object
    EdgeEq string % User specified formula defining the edge equation
end

properties (SetAccess = private)
    %  Internal Meta Data - Auto-Generated based edge object, runs during constructor method i.e. only an edge object must be defined to define these variables  
    EdgeType string = gmt_EdgeType.Internal % All edges are assumed to be internal unless specified as external by user
    NeTS double % Number of tail states in edge equation 
    NeHS double % Number of head states in edge equation
    %NeS double % Number of states that are not head or tail state. Future development.
    NeU double % Number of control inputs in edge equation
    HeadStateVariables string = [] % List of head state variables defined in edge equation 
    TailStateVariables string = [] % List of tail state variables defined in edge quation 
    InputVariables string = [] % List of input variables defined in edge equation
    ParameterVariables string = [] % List of parameter variables defined in edge equation 
    % External Meta Data - Auto-Generated based On EdgeMatrix and Edge Objects i.e. a graph model must be defined to define these variables  
    HeadVertexNum (1,1) = "Unassigned" % Auto assigned graph head vertex number based on EdgeMatrix defintion  
    TailVertexNum (1,1) = "Unassigned" % Auto assigned graph tail vertex number based on EdgeMatrix defintion
    GraphHeadStateVariables string = [] % List of head state variables defined in edge equation 
    GraphTailStateVariables string = [] % List of tail state variables defined in edge quation 
    GraphEdgeEq string % Auto generated graph equation based on graph model data (Vertices, and EdgeMatrix)
end

methods

        %% Constructor Method
        % Generates instance of gmt_GraphEdge object
        function obj = gmt_Edge(EdgeName,EdgeEq,varargin)
            % Verify edge name is a string 
            Name_data_valid = isa(EdgeName,'string');
            % Verify edge equation is a string
            Equation_data_valid = isa(EdgeEq,'string');
    
            % Determine if edge name input is empty
            if Name_data_valid
                Name_blank = logical(strlength(EdgeName)==0);
                if Name_blank 
                    error("Name field is empty")
                end
            else
                error("Name field data type is not a string")
            end
    
            % Determine if edge equation input is empty
            if Equation_data_valid
                Equation_blank = logical(strlength(EdgeEq)==0);
                if Equation_blank
                    error("Equation field is empty")
                end
            else 
                error("Equation field data type is not a string")
            end
            
            % Assign input variable name to EdgeName property 
            obj.EdgeName = EdgeName; 

            % Assign input variable equation to EdgeEq property 
            obj.EdgeEq = EdgeEq;

            % Determine if user has specified external edge type
            numInputs = length(varargin); % Compute number of variable length input arguments 

            % Check variable length input argument if one is assigned 
            if numInputs == 1 
                if strcmpi(varargin{1},gmt_EdgeType.External) % Case-insensitive string compare
                    obj.EdgeType = gmt_EdgeType.External; % Assign edge type to available enumeration 
                else % Return error is variable input argument does not match upper or lower class spelling
                    error("Check spelling, user specified edge type other than 'External'. Users only need to define external edge types, internal edge type is default assumption.")
                end
            elseif numInputs > 1 % More than one variable return error 
                error("More than one variable length input argument has been assigned. Object only accepts one variable input argument for external edge types.")
            end

            % Update Internal Metadata
            obj = gmt_EdgeUpdate(obj);

        end

        %% Internal Metadata Update
        function obj = gmt_EdgeUpdate(obj)

            % Split String By Mathematical Operators and Parentheses
            capeq_var_tmp = split(obj.EdgeEq,[gmt_Symbols().Symbols,"(",")","^"]);

            % Tail State Number Determination 
            pattern_regex = '^xt\d|^xt$';
            match_tmp = regexp(capeq_var_tmp, pattern_regex);

            % Convert From Cell to Array
            if iscell(match_tmp)
                match_tmp = ~cellfun('isempty',match_tmp);
            elseif isempty(match_tmp)
                match_tmp = false;
            end

            % Compute number of tail states and store variables into list 

            if any(match_tmp) % There is atleast one matching variable found 
                match_idx = find(match_tmp); % Find the indices for matching variable 
                varnamx_tmp = capeq_var_tmp(match_idx); % Return matching variables 
                varnumx_tmp = extractAfter(varnamx_tmp,"xt"); % Return suffix of state variable x
                % Valid syntax is either a single state or multiple states 
                isstrempty = strlength(varnumx_tmp) == 0;
                if all(isstrempty) 
                    NeTS_tmp = 1;
                else 
                    assert(~any(isstrempty),"Capacitance equation combines single state vertex syntax 'xt' and multi-state vertex syntax 'xt1, xt2, xt3 ...', review capacitance equation.")
                    varnumx_tmp = unique(sort(str2double(varnumx_tmp)));
                    NeTS_tmp = length(varnumx_tmp);
                end
                obj.TailStateVariables = unique(varnamx_tmp');
            else
                NeTS_tmp = 0;
            end

            obj.NeTS = NeTS_tmp; % Assign number of tail states  

            % Head State Number Determination 
            pattern_regex = '^xh\d|^xh$';
            match_tmp = regexp(capeq_var_tmp, pattern_regex);

            % Convert From Cell to Array
            if iscell(match_tmp)
                match_tmp = ~cellfun('isempty',match_tmp);
            elseif isempty(match_tmp)
                match_tmp = false;
            end

            % Compute number of head states and store variables into list 

            if any(match_tmp) % There is atleast one matching variable found 
                match_idx = find(match_tmp); % Find the indices for matching variable 
                varnamx_tmp = capeq_var_tmp(match_idx); % Return matching variables 
                varnumx_tmp = extractAfter(varnamx_tmp,"xh"); % Return suffix of state variable x
                % Valid syntax is either a single state or multiple states 
                isstrempty = strlength(varnumx_tmp) == 0;
                if all(isstrempty) 
                    NeHS_tmp = 1;
                else 
                    assert(~any(isstrempty),"Capacitance equation combines single state vertex syntax 'xh' and multi-state vertex syntax 'xh1, xh2, xh3 ...', review capacitance equation.")
                    varnumx_tmp = unique(sort(str2double(varnumx_tmp)));
                    NeHS_tmp = length(varnumx_tmp);
                end
                obj.HeadStateVariables = unique(varnamx_tmp');
            else
                NeHS_tmp = 0;
            end

            obj.NeHS = NeHS_tmp; % Assign number of head states 

             % Control Input Number Determination 
            pattern_regexu = '^[u]\d|^[u]$';

            matchu_tmp = regexp(capeq_var_tmp, pattern_regexu);

            % Convert From Cell to Array
            if iscell(matchu_tmp)
                matchu_tmp = ~cellfun('isempty',matchu_tmp);
            elseif isempty(matchu_tmp)
                matchu_tmp = false;
            end

            % Compute number of control inputs and store variables into list 
            
            if any(matchu_tmp) % There is atleast one matching variable found 
                matchu_idx = find(matchu_tmp); % Find the indices for matching variable 
                varnamu_tmp = capeq_var_tmp(matchu_idx); % Return matching variables 
                varnumu_tmp = extractAfter(varnamu_tmp,"u"); % Return suffix of state variable x
                % Valid syntax is either a single state or multiple states 
                isstrempty = strlength(varnumu_tmp) == 0;
                if all(isstrempty) 
                    NeU_tmp = 1;
                else 
                    assert(~any(isstrempty),"Capacitance equation combines single control input syntax 'u' and multi-control input syntax 'u1, u2, u3 ...', review capacitance equation.")
                    varnumu_tmp = unique(sort(str2double(varnumu_tmp)));
                    NeU_tmp = length(varnumu_tmp);
                end
                obj.InputVariables = unique(varnamu_tmp');
            else
                NeU_tmp = 0;
            end

            obj.NeU = NeU_tmp; % Assign number of control inputs  
       
        end


        %% Graph Model Update
        function obj = gmt_EdgeGraphModelUpdate(obj)
            if isempty(obj.GraphEdgeEq)
                obj.GraphEdgeEq = obj.EdgeEq;
            end
        end

        %% Update Head Vertex Number 
        function obj = gmt_UpdateHeadVertexNum(obj,VertexNum)
            obj.HeadVertexNum = VertexNum;
        end

        %% Update Tail Vertex Number 
        function obj = gmt_UpdateTailVertexNum(obj,VertexNum)
            obj.TailVertexNum = VertexNum;
        end
        %% Update Graph Specific Head State Variables 
        function obj = gmt_UpdateGraphHeadStateVar(obj,GraphHeadStateVar_tmp)
            obj.GraphHeadStateVariables = GraphHeadStateVar_tmp;
            GraphEdgeEq_tmp = obj.GraphEdgeEq;
            obj.GraphEdgeEq = regexprep(GraphEdgeEq_tmp, obj.HeadStateVariables, obj.GraphHeadStateVariables);
        end

        %% Update Graph Specific Tail State Variables 
        function obj = gmt_UpdateGraphTailStateVar(obj,GraphTailStateVar_tmp)
            obj.GraphTailStateVariables = GraphTailStateVar_tmp;
            GraphEdgeEq_tmp = obj.GraphEdgeEq;
            obj.GraphEdgeEq = regexprep(GraphEdgeEq_tmp, obj.TailStateVariables, obj.GraphTailStateVariables);
        end

    end
end