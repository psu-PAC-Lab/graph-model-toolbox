%% gmt_HeadLoad
% Defines a heat load

%% Class Defintion and Superclass Reference
classdef gmt_HeatLoad < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_HeatLoad(ObjectName)

            % Define Vertices 
            Vertices(1) = gmt_Vertex("Load Temperature","x_dot");
            Vertices(2) = gmt_Vertex("Inlet","x_dot","External");
            Vertices(3) = gmt_Vertex("Outlet","x_dot","External");
            Vertices(4) = gmt_Vertex("Energy Applied","x_dot","External");

            % Define Edges 
            Edges(1) = gmt_Edge("Advection In","cp_f*u1*xt");
            Edges(2) = gmt_Edge("Advection Out","cp_f*u1*xt");
            Edges(3) = gmt_Edge("Power Applied","u2","External");

            % Define Edge Matrix
            EdgeMatrix = [2 1; ...
                          1 3; ...
                          4 1];

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
