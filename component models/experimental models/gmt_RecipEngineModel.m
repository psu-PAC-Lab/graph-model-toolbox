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

            % Define Vertex (% Divided by zero)
            Vertex(1) = gmt_Vertex("Tank Mass","Qhv*x_dot");
            Vertex(2) = gmt_Vertex("Angular Velocity","J*x*x_dot");
            Vertex(3) = gmt_Vertex("Cooling Heat Sink Temperature", "x_dot","External",true);
            Vertex(4) = gmt_Vertex("Ambient Heat Sink Temperature", "x_dot","External",true);

            % Define Edge 
            Edge(1) = gmt_Edge("Chemical Power","Qhv*xh*u1");
            Edge(2) = gmt_Edge("Cooling Heat Rejection", "interp1(xd,yd,xt)*Qhv*xt*u1");
            Edge(3) = gmt_Edge("Ambient Heat Rejection", "Nth_a*Qhv*xt*u1");

            % Define Energy Edge Matrix 
            EdgeMatrix = [1 2;...
                          2 3;...
                          2 4];

            % Define Model Parameterization 
            % Scalar Example 
            % Param(1) = gmt_Parameter("Heating Value","Qhv",46e6,[]);
            % Variable Qhv is heating value with value 46e6, there are no lookup table or neural network options 
            % Lookup Table Example 
            % Param(4) = gmt_Parameter("Theraml Efficency","interp2(x1d,x2d,x2d,x1,x2)",Data,[]);
            % Data.xd = [];
            % Data.yd = [];
            % Data.zd = [];
            % State x1 and x2 
            Parameter(1) = gmt_Parameter("Heating Value","Qhv",46e6);
            Parameter(2) = gmt_Parameter("Rotational Inertia","J",25);
            Parameter(3) = gmt_Parameter("Efficiency Loss to Ambient","Nth_a",0.25);
            
            Data.xd = linspace(1,1000,10);
            Data.yd = rand(1,10);
            Parameter(4) = gmt_Parameter("Theraml Efficency","interp1(xd,yd,xt)",Data);

            % Define Model Input
            Input(1) = gmt_Input("u1","Engine Fuel Mass");

            % Define Connection Ports 
            Port(1) = gmt_Port("VertexConnection",2,"Mechanical");
            Port(2) = gmt_Port("EdgeConnection",3,"Thermal");

            % Creates Inverter Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,Input,Port,varargin{:});

        end
    end
end
