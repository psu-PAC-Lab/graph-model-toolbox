%% gmt_Motor
% Defines a DC electric motor model 

%% Class Defintion and Superclass Reference
classdef gmt_Motor < gmt_Graph

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
            Vertices(4) = gmt_GraphVertex("Motor Voltage","C*x*x_dot","External");
            Vertices(5) = gmt_GraphVertex("Vehicle Velocity","J*x_dot","External");

            % Define Edges 
            Edges(1) = gmt_GraphEdge("Electrical to Mechanical","kv*xt*xh");
            Edges(2) = gmt_GraphEdge("Electrical to Thermal","R*xt^2");
            Edges(3) = gmt_GraphEdge("Mechanical to Thermal","b*xt^2+c*xt");
            Edges(4) = gmt_GraphEdge("Electrical Input","1*xt*xh");
            Edges(5) = gmt_GraphEdge("Mechanical Output","1*xt*xh");

            % Define Edge Matrix
            EdgeMatrix = [1  2; ...
                          1  3; ...
                          2  3; ...
                          4  1; ...
                          2  5]; 

            % Creates an Engine Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edges,Vertices);

            % Define Available Connection Ports 
            % obj.ConnectionPorts(1) = gmt_ConnectionPort(obj,"EdgeConnection",1,"Electrical");
            % obj.ConnectionPorts(2) = gmt_ConnectionPort(obj,"EdgeConnection",5,"Mechanical");

        end
    end
end
