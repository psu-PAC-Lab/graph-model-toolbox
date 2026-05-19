%% gmt_Parameter
% gmt_Parameter  Class used to define model parameters in the gmt Toolbox.
%
% Documentation authored with assistance from OpenAI ChatGPT.
%
%   OBJ = gmt_Parameter(Description, Variable, Data)
%   creates a model-parameter object using a user-defined description,
%   variable name, and parameter data.
%
%   OBJ = gmt_Parameter(..., Name, Value) specifies optional name-value
%   arguments including optimization flags, common/system parameter flags,
%   and engineering units.
%
%   gmt_Parameter objects define scalar parameters, lookup-table
%   parameters, neural-network parameters, and expression-based parameters
%   used during graph-model generation, equation substitution, simulation
%   code generation, and optimization setup.
%
% Constructor Inputs
%   Description
%       String describing the physical meaning or purpose of the parameter.
%
%   Variable
%       String defining the parameter variable name or parameter expression.
%
%       Scalar example:
%           "C"
%
%       Expression example:
%           "A = pi*r^2"
%
%       Lookup-table example:
%           "interp1(xTable,yTable,u)"
%
%       Neural-network example:
%           "net(u)"
%
%   Data
%       Numeric value, structure, neural-network object, lookup-table data,
%       or other data associated with the parameter.
%
% Name-Value Arguments
%   "Optimization"
%       Logical flag indicating whether the parameter should be treated as
%       an optimization variable.
%
%       Default:
%           false
%
%   "Common"
%       Logical flag indicating whether the parameter is common across the
%       system rather than local to an individual component.
%
%       Default:
%           false
%
%   "Units"
%       String specifying the engineering units associated with the
%       parameter.
%
% User-Defined Properties
%   Description
%       User-defined parameter description.
%
%   Variable
%       Parameter variable name or expression.
%
%   Common
%       Logical flag indicating whether the parameter is shared at the
%       system level.
%
%   Optimization
%       Logical flag indicating whether the parameter is included as an
%       optimization variable.
%
%   Units
%       Engineering units associated with the parameter.
%
%   Data
%       Parameter value or data object.
%
% Auto-Generated Properties
%   ParameterType
%       Parameter classification:
%
%           gmt_ParameterType.Scalar
%           gmt_ParameterType.Lookup
%           gmt_ParameterType.Neural_Network
%
%   Expression
%       Logical flag indicating whether Variable contains an expression
%       assignment using "=".
%
%   Parent
%       Name of the graph or system object associated with the parameter.
%
%   lookupVars
%       Field names extracted from lookup-table data structures.
%
%   lookupDim
%       Lookup-table dimension extracted from the interpolation function
%       name.
%
%   TableOpts
%       Reserved property for lookup-table options.
%
%   NetOpts
%       Reserved property for neural-network options.
%
% Public Methods
%   gmt_ModelParameterParent
%       Assigns the parent graph or system name associated with the
%       parameter.
%
%       obj = obj.gmt_ModelParameterParent(GraphName)
%
% Parameter Type Detection
%   Lookup Parameter
%       If Variable contains "interp", the parameter is classified as:
%
%           gmt_ParameterType.Lookup
%
%       The lookup dimension is extracted from the interpolation function
%       name. For example, "interp1" results in lookupDim = 1.
%
%   Neural-Network Parameter
%       If Variable contains "net", the parameter is classified as:
%
%           gmt_ParameterType.Neural_Network
%
%   Scalar Parameter
%       All other parameter definitions are classified as:
%
%           gmt_ParameterType.Scalar
%
% Notes
%   - Expression parameters are identified when Variable contains "=".
%
%   - Parameters marked with "Optimization", true are preserved as symbolic
%     optimization variables during analytical parameter substitution.
%
%   - Parameters marked with "Common", true are assigned to the system-level
%     parent during component graph construction.
%
%   - Lookup and neural-network parameters cause the graph model to be
%     treated as numerical rather than analytical.
%
% Examples
%   % Scalar parameter
%   P1 = gmt_Parameter( ...
%       "Capacitance", ...
%       "C", ...
%       10.0, ...
%       "Units", "J/K");
%
%   % Optimization parameter
%   P2 = gmt_Parameter( ...
%       "Valve coefficient", ...
%       "Kv", ...
%       0.25, ...
%       "Optimization", true, ...
%       "Units", "kg/(s*Pa)");
%
%   % Common system parameter
%   P3 = gmt_Parameter( ...
%       "Universal gas constant", ...
%       "R", ...
%       287, ...
%       "Common", true, ...
%       "Units", "J/(kg*K)");
%
%   % Expression parameter
%   P4 = gmt_Parameter( ...
%       "Area equation", ...
%       "A = pi*r^2", ...
%       []);
%
% See also gmt_Graph, gmt_Vertex, gmt_Edge, gmt_Input,
%          gmt_ParameterType

classdef gmt_Parameter
    
    properties
        Description string
        Variable string
        Common logical = false
        Optimization logical = false
        Units string
        Data = []
    end

    properties (SetAccess = protected) 
        ParameterType gmtEnumE.gmt_ParameterType
        Expression logical = false
        Parent string
        lookupVars string
        lookupDim 
        TableOpts 
        NetOpts 
    end

    methods
    
        %% Constructor Method (User Defined and Internal Meta Data Update) 
        function obj = gmt_Parameter(Description,Variable,Data,varargin)

            % Input Parsing
            p = inputParser;
            addParameter(p, 'Optimization',false, @(x) islogical(x) && isscalar(x));
            addParameter(p, 'Common',false, @(x) islogical(x) && isscalar(x));
            addParameter(p, 'Units',[], @(x) isstring(x));
            parse(p, varargin{:});

            % Required User Properties 
            obj.Description = Description;
            obj.Variable = Variable;

            % Optional User Properties
            if ~isempty(p.Results.Units)
                obj.Units = p.Results.Units;
            end

            if ~isempty(p.Results.Common)
                obj.Common = p.Results.Common;
            end

            if ~isempty(p.Results.Optimization)
                obj.Optimization = p.Results.Optimization;
            end

            if contains(Variable,"=")
                obj.Expression = true;
            end

            % Determine Parameter Type
            switch true 

                % Lookup Function Case 
                case contains(Variable, 'interp')
                    obj.ParameterType = gmtEnumE.gmt_ParameterType.Lookup;
                    lookupDim_tmp = extractBefore(extractAfter(Variable,"interp"),"(");
                    is_digit_array = isstrprop(lookupDim_tmp, 'digit');

                    if is_digit_array
                        obj.lookupDim = str2double(lookupDim_tmp);
                    else
                        obj.lookupDim = lookupDim_tmp;
                    end
                     
                    if ~isempty(Data)
                        obj.Data = Data;
                        obj.lookupVars = string(fieldnames(obj.Data));
                    end

                    % if ~isempty(Opts)
                    %     obj.TableOpts = Opts;
                    % end
                % Neural Network Case     
                case contains(Variable, 'net')
                    obj.ParameterType = gmtEnumE.gmt_ParameterType.Neural_Network;
                    obj.Data = Data;
                    % if ~isempty(Opts)
                    %     obj.NetOpts = Opts;
                    % end

                % All others assume scalars     
                otherwise
                    obj.ParameterType = gmtEnumE.gmt_ParameterType.Scalar;
                    obj.Data = Data;

            end
                          
        end

        %% Update Model Parameter Parent Name
        function obj = gmt_ModelParameterParent(obj,GraphName)
            obj.Parent = GraphName;    
        end

    end

end

