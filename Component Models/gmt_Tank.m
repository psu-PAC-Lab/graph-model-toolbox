%% gmt_Tank
% Defines a Fluid Tank

%% Class Defintion and Superclass Reference
classdef gmt_Tank < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_Tank(ObjectName,varargin)

            % Define Vertices 
            % We want to be able to specify vertex equation with any other state if required
            % Curreng algorithm does allow this to be achieved, see below
            Vertices(1) = gmt_Vertex("Tank Fluid Temperature","cp_f*x2*x_dot");
            Vertices(2) = gmt_Vertex("Tank Mass","x_dot");
            Vertices(3) = gmt_Vertex("Delta Tank Mass","x_dot","External");
            Vertices(4) = gmt_Vertex("Inlet Temperature","cp_f*Rho*V*x_dot","External");
            Vertices(5) = gmt_Vertex("Outlet Temperature","cp_f*Rho*V*x_dot","External");
            Vertices(6) = gmt_Vertex("Tank Energy Temperature","cp_f*Rho*V*x_dot","External");

            % Define Edges 
            Edges(1) = gmt_Edge("Advection In","cp_f*u1*xt");
            Edges(2) = gmt_Edge("Advection Out","cp_f*u2*xt");
            Edges(3) = gmt_Edge("Tank Fill Rate","(u1-u2)");
            Edges(4) = gmt_Edge("Advection Tank Fluid","cp_f*(u1-u2)*xt");

            % Define Edge Matrix
            EdgeMatrix = [4 1; ...
                          1 5; ...
                          3 2; ...
                          1 6];

            % Define Default Model Parameterization 
            Parameters(1) = gmt_ModelParameter("Fluid Specific Heat","cp_f",3300,"Units","kJ/(kg*K)","Common",true);
            Parameters(2) = gmt_ModelParameter("Fluid Density","Rho",1090,"Units","kg/(m^3)","Common",true);
            Parameters(3) = gmt_ModelParameter("Volume","V",0.002,"Units","m^3");

            % Define Input Labeling 
            Inputs(1) = gmt_Input("u1","Inlet Mass Flow 1","Units","kg/s");
            Inputs(2) = gmt_Input("u2","Outlet Mass Flow 1","Units","kg/s");

            % Creates an Motor Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edges,Vertices,Parameters,Inputs,varargin{:});

            % Define Available Connection Ports 
            obj.Ports(1) = gmt_ConnectionPort(obj,"EdgeConnection",1,"Thermal");
            obj.Ports(2) = gmt_ConnectionPort(obj,"EdgeConnection",2,"Thermal");
            obj.Ports(3) = gmt_ConnectionPort(obj,"VertexConnection",4,"Thermal");
            obj.Ports(4) = gmt_ConnectionPort(obj,"VertexConnection",5,"Thermal");

        end
    end
end
