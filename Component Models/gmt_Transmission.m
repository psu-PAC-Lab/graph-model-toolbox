%% gmt_Transmission
% Defines a Fluid Tank

%% Class Defintion and Superclass Reference
classdef gmt_Transmission < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_Transmission(ObjectName,varargin)

            % Define Vertices 
            % We want to be able to specify vertex equation with any other state if required
            % Curreng algorithm does allow this to be achieved, see below
            Vertices(1) = gmt_Vertex("Input Shaft Angular Velocity","J1*x*x_dot");
            Vertices(2) = gmt_Vertex("Output Shaft Angular Velocity","J2*x*x_dot");
            Vertices(3) = gmt_Vertex("Transmission Fluid Temperature","Ct*x_dot");

            % Define Edges 
            Edges(1) = gmt_Edge("Input Shaft Friction","b*xt+c");
            Edges(2) = gmt_Edge("Output Shaft Friction","b*xt+c");
            Edges(3) = gmt_Edge("Internal Power Transfer","-(u1*(xh - xt/u2))/xt");
            Edges(4) = gmt_Edge("Intput Shaft Power","u1","External");

            % Define Edge Matrix
            EdgeMatrix = [1 3; ...
                          2 3; ...
                          1 2];

            % Define Default Model Parameterization 
            Parameters(1) = gmt_ModelParameter("Input Shaft Inertia","J1",25,"Units","kg/m^2");
            Parameters(2) = gmt_ModelParameter("Output Shaft Inertia","J2",25,"Units","kg/m^2");
            Parameters(3) = gmt_ModelParameter("Shaft Friction Coefficient (b)","b",0.002);
            Parameters(4) = gmt_ModelParameter("Shaft Friction Coefficient (c)","c",0.0000000002);
            Parameters(5) = gmt_ModelParameter("Transmission Thermal Capacitance","Ct",15000);

            % Define Input Labeling 
            Inputs(1) = gmt_Input("u1","Input Shaft Power");
            Inputs(1) = gmt_Input("u2","Gear Ratio");

            % Creates an Motor Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edges,Vertices,Parameters,Inputs,varargin{:});

            % Define Available Connection Ports
            obj.Ports(1) = gmt_ConnectionPort(obj,"EdgeConnection",1,"Mechanical");
            obj.Ports(2) = gmt_ConnectionPort(obj,"EdgeConnection",2,"Mechanical");

        end
    end
end
