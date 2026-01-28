%% gmt_RecipEngineModel
% Defines a recipocating engine graph model 


%% Class Defintion and Superclass Reference
classdef gmt_RecipEngineModel < gmt_Graph

    %% Properties
    properties
    end

    methods

        %% Constructor Method
        function obj = gmt_RecipEngineModel(ObjectName,varargin)

            % Define Vertices (% Divided by zero)
            Vertices(1) = gmt_Vertex("Tank Mass","Qhv*x_dot");
            Vertices(2) = gmt_Vertex("Angular Velocity","J*x*x_dot");
            Vertices(3) = gmt_Vertex("Cooling Heat Sink", "1","External");
            Vertices(4) = gmt_Vertex("Ambient Heat Sink", "1","External");

            % Define Edges 
            Edges(1) = gmt_Edge("Chemical Power","Qhv*xh*u1");
            Edges(2) = gmt_Edge("Cooling Heat Rejection", "interp1(xd,yd,xt)*Qhv*xt*u1");
            Edges(3) = gmt_Edge("Ambient Heat Rejection", "Nth_a*Qhv*xt*u1");

            % Define Energy Edge Matrix 
            EdgeMatrix = [1 2;...
                          2 3;...
                          2 4];

            % Define Model Parameterization 
            % Scalar Example 
            % Param(1) = gmt_ModelParameter("Heating Value","Qhv",46e6,[]);
            % Variable Qhv is heating value with value 46e6, there are no lookup table or neural network options 
            % Lookup Table Example 
            % Param(4) = gmt_ModelParameter("Theraml Efficency","interp2(x1d,x2d,x2d,x1,x2)",Data,[]);
            % Data.xd = [];
            % Data.yd = [];
            % Data.zd = [];
            % State x1 and x2 
            Param(1) = gmt_ModelParameter("Heating Value","Qhv",46e6,[]);
            Param(2) = gmt_ModelParameter("Rotational Inertia","J",25,[]);
            Param(3) = gmt_ModelParameter("Efficiency Loss to Ambient","Nth_a",0.25,[]);
            
            Data.xd = linspace(1,1000,10);
            Data.yd = rand(1,10);
            Param(4) = gmt_ModelParameter("Theraml Efficency","interp1(xd,yd,xt)",Data,[]);

            % Creates an unparameterized componentn object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edges,Vertices,Param,varargin{:});

            % Define Connection Ports 
            obj.Ports(1) = gmt_ConnectionPort(obj,"VertexConnection",2,"Mechanical");
            obj.Ports(2) = gmt_ConnectionPort(obj,"EdgeConnection",3,"Thermal");
        end
    end
end
