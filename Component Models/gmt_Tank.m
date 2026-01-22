%% gmt_Tank
% Defines a Fluid Tank

%% Class Defintion and Superclass Reference
classdef gmt_Tank < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_Tank(ObjectName)

            % Define Vertices 
            Vertices(1) = gmt_Vertex("Liquid Temperature","cp_f*x_dot");
            Vertices(2) = gmt_Vertex("Tank Mass","x_dot");
            Vertices(3) = gmt_Vertex("Inlet","x_dot","External");
            Vertices(4) = gmt_Vertex("Outlet Temperature","x_dot","External");
            Vertices(5) = gmt_Vertex("Sink","x_dot","External");

            % Define Edges 
            Edges(1) = gmt_Edge("Advection In","u1*xt");
            Edges(2) = gmt_Edge("Advection Out","u2*xt");
            Edges(3) = gmt_Edge("Advection Tank Sink","(u1-u2)*xt");
            Edges(4) = gmt_Edge("Head Losses","(u1-u2)");

            % Define Edge Matrix
            EdgeMatrix = [3 1; ...
                          1 4; ...
                          1 5; ...
                          5 2];

            % Define Default Model Parameterization 
            Param(1) = gmt_ModelParameter("Fluid Specific Heat","cp_f",1,[]);

            % Creates an Motor Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edges,Vertices,Param,"Component");

            % Define Available Connection Ports
            obj.Ports(1) = gmt_ConnectionPort(obj,"EdgeConnection",1,"Thermal");
            obj.Ports(2) = gmt_ConnectionPort(obj,"EdgeConnection",2,"Thermal");

        end
    end
end
