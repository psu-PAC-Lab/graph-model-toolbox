%% gmt_DCMotor
% Defines a DC electric motor model 

%% Class Defintion and Superclass Reference
classdef gmt_DCMotor < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_DCMotor(ObjectName)

            % Define Vertices 
            Vertices(1) = gmt_Vertex("Motor Current","L*x*x_dot");
            Vertices(2) = gmt_Vertex("Angular Velocity","J*x*x_dot");
            Vertices(3) = gmt_Vertex("Motor Temperature","Cp*x_dot");

            % Define Edges 
            Edges(1) = gmt_Edge("Electrical to Mechanical Conversion","Kt*xt*xh");
            Edges(2) = gmt_Edge("Mechanical Losses","b*xt^2+c*xt");
            Edges(3) = gmt_Edge("Electrical Losses","R*xt^2");
            % Edges(5) = gmt_Edge("Electrical Input","1*xt*xh");
            % Edges(6) = gmt_Edge("Mechanical Output","1*xt*xh");

            % Define Edge Matrix
            EdgeMatrix = [1  2; ...
                          2  3; ...
                          1  3; ...
                          ];

            % Define Default Model Parameterization 
            Param(1) = gmt_ModelParameter("Rotational Inertia","J",1,[]);
            Param(2) = gmt_ModelParameter("DC Motor Specific Heat","Cp",1,[]);
            Param(3) = gmt_ModelParameter("Motor Inductance","L",1,[]);
            Param(4) = gmt_ModelParameter("Friction Coefficient b","b",1,[]);
            Param(5) = gmt_ModelParameter("Friction Coefficient b","c",1,[]);
            Param(6) = gmt_ModelParameter("Motor Armature Resistance","R",1,[]);
            Param(7) = gmt_ModelParameter("Motor Torque Constant","Kt",1,[]);

            % Creates an Motor Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edges,Vertices,Param,"CombineNames");

            % Define Available Connection Ports 
            % Define Connection Ports 
            obj.Ports(1) = gmt_ConnectionPort(obj,"VertexConnection",2,"Mechanical");

        end
    end
end
