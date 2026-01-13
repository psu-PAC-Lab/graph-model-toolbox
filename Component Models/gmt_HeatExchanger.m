%% gmt_HeatExchanger
% Defines a Heat Exchanger Model 
% Two plates, no wall

%% Class Defintion and Superclass Reference
classdef gmt_HeatExchanger < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_HeatExchanger(ObjectName)

            % Define Vertices 
            Vertices(1) = gmt_Vertex("Temperature S1","x_dot");
            Vertices(2) = gmt_Vertex("Temperature S2","x_dot"); 
            Vertices(3) = gmt_Vertex("Inlet S1","x_dot","External"); 
            Vertices(4) = gmt_Vertex("Inlet S2","x_dot","External"); 
            Vertices(5) = gmt_Vertex("Outlet S1","x_dot","External"); 
            Vertices(6) = gmt_Vertex("Outlet S2","x_dot","External"); 

            % Define Edges 
            Edges(1) = gmt_Edge("Heat Transfer 1 In","cp_f1*u1*xt");
            Edges(2) = gmt_Edge("Heat Transfer 1 Out","cp_f1*u1*xt");
            Edges(3) = gmt_Edge("Heat Transfer 2 In","cp_f2*u2*xt");
            Edges(4) = gmt_Edge("Heat Transfer 2 Out","cp_f2*u2*xt");
            Edges(5) = gmt_Edge("Fluid Heat Transfer","HTC*(xt-xh)");

            % Define Edge Matrix
            EdgeMatrix = [3 1; ...
                          1 5; ...
                          4 2; ...
                          2 6; ...
                          1 2];

            % Define Default Model Parameterization 
            Param(1) = gmt_ModelParameter("Specific Heat Fluid 1","cp_f1",1,[]);
            Param(2) = gmt_ModelParameter("Specific Heat Fluid 2","cp_f2",1,[]);
            Param(3) = gmt_ModelParameter("Heat Transfer Coefficient","HTC",1,[]);

            % Creates an Battery Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edges,Vertices,Param);

        end
    end
end
