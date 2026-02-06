%% gmt_Input
% Class used for user defined graph model connections points. Simplifies component connections 
% 01/05/2025 add intelligence to avoid duplicate connection ports 

%% Class Defintion
classdef gmt_Input
    
    properties
        VariableName string
        Description string 
        Dependency 
        DependencyFormula
        Units 
    end

    properties (GetAccess = public, SetAccess = private)
        GraphVariableName string
        GraphDescription string
    end

    methods
        
        %% Constructor Method
        function obj = gmt_Input(VariableName,Description,varargin)

            % Input Parsing
            p = inputParser;
            addParameter(p, 'DependencyFormula',[], @(x) isstring(x));
            addParameter(p, 'Units',[], @(x) isstring(x));
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


    end
end


