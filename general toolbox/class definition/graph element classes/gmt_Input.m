%% gmt_Input
% gmt_Input  Class used to define graph-model input variables and metadata.
%
% Documentation authored with assistance from OpenAI ChatGPT.
%
%   OBJ = gmt_Input(VariableName, Description)
%   creates an input object used to define user inputs, disturbances,
%   control signals, or external dependencies within the gmt Toolbox
%   framework.
%
%   OBJ = gmt_Input(..., Name, Value) specifies optional name-value
%   arguments including dependency formulas and engineering units.
%
%   gmt_Input objects simplify component and system connections by providing
%   standardized input-variable definitions and metadata management.
%
% Constructor Inputs
%   VariableName
%       String defining the input-variable name.
%
%   Description
%       String describing the physical meaning of the input variable.
%
% Name-Value Arguments
%   "DependencyFormula"
%       String defining a dependency relationship associated with the
%       input variable.
%
%       Example:
%           "u2 = 2*u1"
%
%   "Units"
%       String specifying the engineering units associated with the input
%       variable.
%
%       Example:
%           "Pa"
%           "kg/s"
%           "V"
%
% User-Defined Properties
%   VariableName
%       User-defined variable name associated with the input.
%
%   Description
%       User-defined description associated with the input.
%
%   Dependency
%       Reserved property for future dependency-management features.
%
%   DependencyFormula
%       Optional dependency equation associated with the input variable.
%
%   Units
%       Engineering units associated with the input variable.
%
% Auto-Generated Properties
%   Parent
%       Name of the parent graph object associated with the input.
%
%   GraphVariableName
%       Graph-specific input-variable name assigned during graph-model
%       generation.
%
%   GraphDescription
%       Graph-specific description assigned during graph-model generation.
%
% Public Methods
%   gmt_GraphInput
%       Updates graph-specific input metadata including graph-variable names
%       and graph descriptions.
%
%       obj = obj.gmt_GraphInput(ParameterObj, GraphVariableName)
%
%       obj = obj.gmt_GraphInput(..., "SystemModel", true)
%
%       Name-Value Arguments:
%           "SystemModel"
%               Logical flag indicating the input belongs to a combined
%               system model.
%
%   gmt_InputParent
%       Assigns the parent graph-object name associated with the input.
%
%       obj = obj.gmt_InputParent(ParentObj)
%
% Notes
%   - Input objects are commonly used to define control inputs,
%     disturbances, boundary conditions, or external forcing functions.
%
%   - Graph descriptions are automatically prefixed with the component name
%     unless the input belongs to a system-level graph model.
%
%   - DependencyFormula may be used to describe algebraic relationships
%     between input variables.
%
%   - Units default to "unassigned" if not specified.
%
% Example
%   % Define pressure input
%   U1 = gmt_Input( ...
%       "u1", ...
%       "Supply Pressure", ...
%       "Units", "Pa");
%
%   % Define dependent flow input
%   U2 = gmt_Input( ...
%       "u2", ...
%       "Mass Flow Command", ...
%       "Units", "kg/s", ...
%       "DependencyFormula", "u2 = 0.5*u1");
%
% See also gmt_Graph, gmt_Vertex, gmt_Edge, gmt_Parameter

%% Class Defintion
classdef gmt_Input
    
    properties
        VariableName string
        Description string 
        Dependency 
        DependencyFormula
        Units string = "unassigned"
    end

    properties (GetAccess = public, SetAccess = private)
        Parent
        GraphVariableName string
        GraphDescription string
    end

    methods
        
        %% Constructor Method
        function obj = gmt_Input(VariableName,Description,varargin)

            % Input Parsing
            p = inputParser;
            addParameter(p, 'DependencyFormula',[], @(x) isstring(x));
            addParameter(p, 'Units',[], @(x) isstring(x) && strlength(strtrim(x)) > 0);
            parse(p, varargin{:});

            % Required User Properties 
            obj.VariableName = VariableName;
            obj.Description = Description;

            % Optional User Properties
            if ~isempty(p.Results.Units)
                obj.Units = p.Results.Units;
            end

            if ~isempty(p.Results.DependencyFormula)
                obj.DependencyFormula = p.Results.DependencyFormula;
            end

        end

        %% Graph Date Update
        function obj = gmt_GraphInput(obj,ParameterObj,GraphVariableName,varargin)

            p = inputParser;
            p.KeepUnmatched = true;
            addParameter(p, 'SystemModel',false, @(x) islogical(x) && isscalar(x));
            parse(p, varargin{:});

            obj.GraphVariableName = GraphVariableName;

            if p.Results.SystemModel ~= true
                obj.GraphDescription = ParameterObj.Name + ": " + obj.Description;
            else 
                obj.GraphDescription = obj.Description;
            end

        end
        
        %% Assign Parent Obj
        function obj = gmt_InputParent(obj,ParentObj)

            obj.Parent = ParentObj.Name;
    
        end

    end
end


