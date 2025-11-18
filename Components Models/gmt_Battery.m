%% gmt_Battery
% Defines a Battery Model 

%% Class Defintion and Superclass Reference
classdef gmt_Battery < gmt_ComponentGraph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_Battery(ObjectName)

            % Define Hardcoded Coefficients

            % Define User Define Values 

            % If User Defines UserDefined Populated Grab Values
            % Pick Battery Type and Grab
           
            % Else Use Default Parmeters 

            % Define Vertices 
            Vertices(1) = gmt_GraphVertex("SOC","3600*x_dot");
            Vertices(2) = gmt_GraphVertex("Battery Voltage 1","C1*x*x_dot");
            Vertices(3) = gmt_GraphVertex("Battery Voltage 2","C2*x*x_dot");
            Vertices(4) = gmt_GraphVertex("Battery Cell Temperature","Ct*x_dot");
            Vertices(5) = gmt_GraphVertex("Battery Surface Temperature","Ct*x_dot");
            Vertices(6) = gmt_GraphVertex("Battery Current","L*x_dot");

            % Define Edges 
            Edges(1) = gmt_GraphEdge("Battery Charge Rate","VocvP");
            Edges(2) = gmt_GraphEdge("Battery Cell 1 Power Rate","xt*xh");
            Edges(3) = gmt_GraphEdge("Battery Cell 2 Power Rate","xt*xh");
            Edges(4) = gmt_GraphEdge("Battery Cell Thermal Transfer","xt^2");
            Edges(5) = gmt_GraphEdge("Battery Cell 1 Thermal Transfer","xt^2");
            Edges(6) = gmt_GraphEdge("Battery Cell 2 Thermal Transfer","xt^2");
            Edges(7) = gmt_GraphEdge("Battery Cell to Surface Thermal Transfer","xt^2");

            % Define Edge Matrix
            EdgeMatrix = [6  1; ...
                          6  2; ...
                          6  3; ...
                          6  4; ...
                          2  4; ...
                          3  4; ...
                          4  5];

            % Creates an Battery Object 
            obj@gmt_ComponentGraph(ObjectName,EdgeMatrix,Edges,Vertices);
        end
    end
end
