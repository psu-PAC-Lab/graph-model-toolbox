%% gmt_Input
% Class used for user defined graph model connections points. Simplifies component connections 
% 01/05/2025 add intelligence to avoid duplicate connection ports 

%% Class Defintion
classdef gmt_Input
    
    properties
        VariableName string
        Description string 
    end

    properties (GetAccess = public, SetAccess = private)
        GraphVariableName string
        GraphDescription string
    end

    methods
        
        %% Constructor Method
        function obj = gmt_Input(VariableName,Description)
            obj.VariableName = VariableName;
            obj.Description = Description;
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


