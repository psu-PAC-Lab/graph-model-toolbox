%% gmt_DCMotor
% Defines a DC electric motor model 

%% Class Defintion and Superclass Reference
classdef gmt_DCMotor < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_DCMotor(ObjectName,varargin)

            % Define Vertex 
            Vertex(1) = gmt_Vertex("Motor Current","L*x*x_dot");
            Vertex(2) = gmt_Vertex("Angular Velocity","J*x*x_dot");
            Vertex(3) = gmt_Vertex("Motor Temperature","Cp*x_dot");

            % Define Edge 
            Edge(1) = gmt_Edge("Electrical to Mechanical Conversion","Kt*xt*xh");
            Edge(2) = gmt_Edge("Mechanical Losses","b*xt^2+c*xt");
            Edge(3) = gmt_Edge("Electrical Losses","R*xt^2");
            % Edge(5) = gmt_Edge("Electrical Input","1*xt*xh");
            % Edge(6) = gmt_Edge("Mechanical Output","1*xt*xh");

            % Define Edge Matrix
            EdgeMatrix = [1  2; ...
                          2  3; ...
                          1  3; ...
                          ];

            % Define Default Model Parameterization 
            Parameter(1) = gmt_Parameter("Rotational Inertia","J",1);
            Parameter(2) = gmt_Parameter("DC Motor Specific Heat","Cp",1);
            Parameter(3) = gmt_Parameter("Motor Inductance","L",1);
            Parameter(4) = gmt_Parameter("Friction Coefficient b","b",1);
            Parameter(5) = gmt_Parameter("Friction Coefficient b","c",1);
            Parameter(6) = gmt_Parameter("Motor Armature Resistance","R",1);
            Parameter(7) = gmt_Parameter("Motor Torque Constant","Kt",1);

            % Define Connection Port Object Array 
            Port(1) = gmt_Port("VertexConnection",2,"Mechanical");

            % Creates DC Motor Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,[],Port,varargin{:});

        end
    end
end
