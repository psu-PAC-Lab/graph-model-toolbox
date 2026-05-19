%% gmt_Edge
% gmt_Edge  Class used to define edge properties in a graph model.
%
% Documentation authored with assistance from OpenAI ChatGPT.
%
%   OBJ = gmt_Edge(EdgeName, EdgeEq)
%   creates a graph edge object using a user-defined edge name and edge
%   equation.
%
%   OBJ = gmt_Edge(..., Name, Value) specifies optional name-value
%   arguments including edge type classification.
%
%   gmt_Edge objects define energy, flow, or interaction relationships
%   between graph vertices within the gmt Toolbox framework. The class
%   automatically parses edge equations to determine head-state variables,
%   tail-state variables, input variables, and graph-specific metadata used
%   during graph-model generation.
%
% Edge Equation Syntax
%   State variables must be defined using head or tail state notation:
%
%       xh   - Head state variable
%       xt   - Tail state variable
%
%   Multi-state systems must use indexed notation:
%
%       xh1, xh2, ...
%       xt1, xt2, ...
%
%   Multi-input systems must use:
%
%       u1, u2, ...
%
% Multi-State Syntax Rules
%   Valid Example:
%
%       "xh1 + xh2 - xt1"
%
%   Invalid Example:
%
%       "xh1 + xh3"
%
%   Variable numbering must begin at 1 and increment sequentially.
%
% Single-State Syntax Rules
%   Single-state systems must omit numeric suffixes:
%
%       Valid:
%           "xh + u"
%
%       Invalid:
%           "xh1 + u"
%           "xh + u1"
%
%   The number of state variables does not need to match the number of
%   control inputs.
%
% Constructor Inputs
%   EdgeName
%       String defining the edge name.
%
%   EdgeEq
%       String defining the edge equation.
%
% Name-Value Arguments
%   "External"
%       Logical flag indicating the edge is external to the graph model.
%
%       Example:
%           gmt_Edge(..., "External", true)
%
% User-Defined Properties
%   EdgeName
%       User-defined name assigned to the edge object.
%
%   EdgeEq
%       User-defined equation associated with the edge.
%
% Auto-Generated Internal Metadata
%   EdgeType
%       Edge classification:
%           gmt_EdgeType.Internal
%           gmt_EdgeType.External
%
%   NeTS
%       Number of tail-state variables referenced in the edge equation.
%
%   NeHS
%       Number of head-state variables referenced in the edge equation.
%
%   NeU
%       Number of control-input variables referenced in the edge equation.
%
%   HeadStateVariables
%       List of head-state variables detected in the edge equation.
%
%   TailStateVariables
%       List of tail-state variables detected in the edge equation.
%
%   InputVariables
%       List of input variables detected in the edge equation.
%
%   ParameterVariables
%       List of parameter variables detected in the edge equation.
%
% Auto-Generated Graph Metadata
%   HeadVertexNum
%       Graph-assigned head-vertex number based on EdgeMatrix definition.
%
%   TailVertexNum
%       Graph-assigned tail-vertex number based on EdgeMatrix definition.
%
%   GraphHeadStateVariables
%       Graph-specific head-state variables assigned during graph-model
%       generation.
%
%   GraphTailStateVariables
%       Graph-specific tail-state variables assigned during graph-model
%       generation.
%
%   GraphEdgeEq
%       Graph-specific edge equation after graph-variable substitution.
%
% Public Methods
%   gmt_EdgeUpdate
%       Parses the edge equation and computes internal edge metadata
%       including head states, tail states, and input variables.
%
%   gmt_EdgeGraphModelUpdate
%       Initializes the graph-specific edge equation during graph-model
%       generation.
%
%       obj = obj.gmt_EdgeGraphModelUpdate()
%
%   gmt_UpdateHeadVertexNum
%       Assigns the graph head-vertex number.
%
%       obj = obj.gmt_UpdateHeadVertexNum(VertexNum)
%
%   gmt_UpdateTailVertexNum
%       Assigns the graph tail-vertex number.
%
%       obj = obj.gmt_UpdateTailVertexNum(VertexNum)
%
%   gmt_UpdateGraphHeadStateVar
%       Replaces symbolic head-state variables in the edge equation with
%       graph-specific state variables.
%
%       obj = obj.gmt_UpdateGraphHeadStateVar(GraphHeadStateVar_tmp)
%
%   gmt_UpdateGraphTailStateVar
%       Replaces symbolic tail-state variables in the edge equation with
%       graph-specific state variables.
%
%       obj = obj.gmt_UpdateGraphTailStateVar(GraphTailStateVar_tmp)
%
% Notes
%   - Head-state variables use the prefix "xh".
%
%   - Tail-state variables use the prefix "xt".
%
%   - Input variables use the prefix "u".
%
%   - Graph-specific state substitution occurs during graph-model assembly
%     within gmt_Graph.
%
%   - Internal edges are assumed by default unless explicitly declared as
%     external.
%
% Example
%   % Internal edge
%   E1 = gmt_Edge( ...
%       "Mass Flow", ...
%       "Cd*A*sqrt(xh - xt)");
%
%   % External input edge
%   E2 = gmt_Edge( ...
%       "Control Valve", ...
%       "Kv*u*(xh - xt)", ...
%       "External", true);
%
% See also gmt_Graph, gmt_Vertex, gmt_Parameter, gmt_EdgeType,
%          gmt_VertexType 

classdef gmt_Edge

properties
    % User Defined Meta Data
    EdgeName string % User specified name to define an edge object
    EdgeEq string % User specified formula defining the edge equation
end

properties (SetAccess = private)
    %  Internal Meta Data - Auto-Generated based edge object, runs during constructor method i.e. only an edge object must be defined to define these variables  
    EdgeType string = gmtEnumE.gmt_EdgeType.Internal % All edges are assumed to be internal unless specified as external by user
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
            
            % assert EdgeName datatype 
            assert(isa(EdgeName,'string'),"EdgeName datatype is not string")

            % assert EdgeEq datatype
            assert(isa(EdgeEq,'string'),"EdgeEq datatype is not string")
            
            % assert EdgeName not empty 
            assert(strlength(strtrim(EdgeName)) > 0,"EdgeName is field is empty" )
    
            % assert EdgeEq not empty
            assert(strlength(strtrim(EdgeEq)) > 0,"EdgeEq is field is empty" )

            % assign user define properties 
            obj.EdgeName = EdgeName;  % assign EdgeName property 
            obj.EdgeEq = EdgeEq;      % assign EdgeEq property 
            
            % variable input parsing 
            p = inputParser;
            p.KeepUnmatched = true;
            addParameter(p, "External",false, @(x) islogical(x) && isscalar(x));
            parse(p, varargin{:});
            
            % update edge type if user defined 
            if ~isempty(p.Results.External)
                if p.Results.External == true
                    obj.EdgeType = gmtEnumE.gmt_EdgeType.External;
                end
            end

            % Update Internal Metadata
            obj = gmt_EdgeUpdate(obj);

        end

        %% Internal Metadata Update
        function obj = gmt_EdgeUpdate(obj)

            % Split String By Mathematical Operators and Parentheses
            capeq_var_tmp = split(obj.EdgeEq,[gmtEnumE.gmt_Symbols().Symbols,"(",")","^"]);
            capeq_var_tmp = strtrim(capeq_var_tmp); % added to remove spacing after split 

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
            obj.GraphEdgeEq = regexprep(GraphEdgeEq_tmp, "xh", obj.GraphHeadStateVariables);
        end

        %% Update Graph Specific Tail State Variables 
        function obj = gmt_UpdateGraphTailStateVar(obj,GraphTailStateVar_tmp)
            obj.GraphTailStateVariables = GraphTailStateVar_tmp;
            GraphEdgeEq_tmp = obj.GraphEdgeEq;
            obj.GraphEdgeEq = regexprep(GraphEdgeEq_tmp, "xt", obj.GraphTailStateVariables);
        end

    end
end