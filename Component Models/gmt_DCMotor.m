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
            Vertex(1) = gmt_Vertex("Current","L*x*x_dot","units","A");
            Vertex(2) = gmt_Vertex("Angular Velocity","J*x*x_dot","units","w");
            Vertex(3) = gmt_Vertex("Temperature","Cp*x_dot","units","K");
            Vertex(4) = gmt_Vertex("Source Voltage","x","External",true,"units","V");
            Vertex(5) = gmt_Vertex("Sink Temperature","x","External",true,"units","K");

            % Define Edge 
            Edge(1) = gmt_Edge("Electrical to Mechanical Conversion","Kt*xt*xh");
            Edge(2) = gmt_Edge("Mechanical Losses","b*xt^2+c*xt");
            Edge(3) = gmt_Edge("Electrical Losses","Ra*xt^2");
            Edge(4) = gmt_Edge("Electrical Input","xh*xt");
            Edge(5) = gmt_Edge("Sink Heat Transfer","(xt-xh)/Ru");

            % Define Edge Matrix
            EdgeMatrix = [1, 2; ...
                          2, 3; ...
                          1, 3; ...
                          4, 1; ...
                          3, 5];

            % Define Default Model Parameterization 
            Parameter(1) = gmt_Parameter("Rotational Inertia","J",1.09*10^-4);
            Parameter(2) = gmt_Parameter("DC Motor Specific Heat","Cp",60);
            Parameter(3) = gmt_Parameter("Motor Inductance","L",1.252192537082724e-05);
            Parameter(4) = gmt_Parameter("Friction Coefficient b","b",1.89435163576232e-05);
            Parameter(5) = gmt_Parameter("Friction Coefficient b","c",0.000234355495215172);
            Parameter(6) = gmt_Parameter("Motor Armature Resistance","Ra",0.013461960749493);
            Parameter(7) = gmt_Parameter("Motor Torque Constant","Kt",0.009688163543703);
            Parameter(8) = gmt_Parameter("Thermal Convection Resistance","Ru",0.009688163543703);

            % Define Input

            % Define Connection Port Object Array 
            Port(1) = gmt_Port("EdgeConnection",4,"Electrical");
            Port(2) = gmt_Port("EdgeConnection",5,"Thermal");
            Port(3) = gmt_Port("VertexConnection",1,"Electrical");
            Port(4) = gmt_Port("VertexConnection",2,"Thermal");
            Port(5) = gmt_Port("VertexConnection",4,"Electrical");
            Port(6) = gmt_Port("VertexConnection",5,"Thermal");

            % Creates DC Motor Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,[],Port,varargin{:});

        end
    end
end
