%% gmt_RecipEngineModel
% Defines a recipocating engine graph model 


%% Class Defintion and Superclass Reference
classdef gmt_RecipEngineModel < gmt_ComponentGraph

    %% Properties
    properties
    end

    methods

        %% Constructor Method
        function obj = gmt_RecipEngineModel(ObjectName)

            % Define Vertices 
            Vertices(1) = gmt_GraphVertex("Tank Mass","Qhv*x_dot");
            Vertices(2) = gmt_GraphVertex("Angular Velocity","J*x*x_dot");
            Vertices(3) = gmt_GraphVertex("Cooling Heat Sink", "1");
            Vertices(4) = gmt_GraphVertex("Ambient Heat Sink", "1");

            % Define Edges 
            Edges(1) = gmt_GraphEdge("Chemical Power","Qhv*xh*u1");
            Edges(2) = gmt_GraphEdge("Cooling Heat Rejection", "0.25*Qhv*xt*u1");
            Edges(3) = gmt_GraphEdge("Ambient Heat Rejection", "0.40*Qhv*xt*u1");

            % Define Edge Matrix 
            EdgeMatrix = [1 2;2 4;2 3];

            % Creates an Engine Object 
            obj@gmt_ComponentGraph(ObjectName,EdgeMatrix,Edges,Vertices);
        end
    end
end
