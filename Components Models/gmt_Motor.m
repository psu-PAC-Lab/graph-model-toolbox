%% gmt_Motor
% Defines a DC electric motor model 

%% Class Defintion and Superclass Reference
classdef gmt_Motor < gmt_ComponentGraph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_Motor(ObjectName)

            % Define Vertices 
            Vertices(1) = gmt_GraphVertex("Current","C*x*x_dot");
            Vertices(2) = gmt_GraphVertex("Angular Velocity","J*x*x_dot");
            Vertices(3) = gmt_GraphVertex("Motor Temperature","Cp*x_dot");
            Vertices(4) = gmt_GraphVertex("Motor Voltage","C*x*x_dot");

            % Define Edges 
            Edges(1) = gmt_GraphEdge("Electrical to Mechanical Power","kv*xt*xh");
            Edges(2) = gmt_GraphEdge("Mechanical Heat Rejected","b*xt^2+c*xt");
            Edges(3) = gmt_GraphEdge("Electrical Heat Rejected","R*xt^2");
            Edges(4) = gmt_GraphEdge("Electrical Input Power","1*xt*xh");

            % Define Edge Matrix
            EdgeMatrix = [1  2; ...
                          2  3; ...
                          1  3; ...
                          4  1]; 

            % Creates an Engine Object 
            obj@gmt_ComponentGraph(ObjectName,EdgeMatrix,Edges,Vertices);
        end
    end
end
