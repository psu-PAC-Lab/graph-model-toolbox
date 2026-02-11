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

            % Define Vertex Object Array
            Vertex(1) = gmt_Vertex("Tank Fluid Temperature","cp_f*x2*x_dot","Units","K");
            Vertex(2) = gmt_Vertex("Tank Mass","x_dot","Units","kg");
            Vertex(3) = gmt_Vertex("Delta Tank Mass","x_dot","External",true,"Units","kg");
            Vertex(4) = gmt_Vertex("Inlet Temperature","cp_f*Rho*V*x_dot","External",true,"Units","K");
            Vertex(5) = gmt_Vertex("Outlet Temperature","cp_f*Rho*V*x_dot","External",true,"Units","K");
            Vertex(6) = gmt_Vertex("Tank Energy Temperature","cp_f*Rho*V*x_dot","External",true,"Units","K");

            % Define Edge Object Array
            Edge(1) = gmt_Edge("Advection In","cp_f*u1*xt");
            Edge(2) = gmt_Edge("Advection Out","cp_f*u2*xt");
            Edge(3) = gmt_Edge("Tank Fill Rate","(u1-u2)");
            Edge(4) = gmt_Edge("Advection Tank Fluid","cp_f*(u1-u2)*xt");

            % Define Edge Matrix
            EdgeMatrix = [4 1; ...
                          1 5; ...
                          3 2; ...
                          1 6];

           % Define Parameter Object Array
            Parameter(1) = gmt_Parameter("Fluid Specific Heat","cp_f",3300,"Units","kJ/(kg*K)","Common",true);
            Parameter(2) = gmt_Parameter("Fluid Density","Rho",1090,"Units","kg/(m^3)","Common",true);
            Parameter(3) = gmt_Parameter("Volume","V",0.002,"Units","m^3");

            % Define Input Object Array 
            Input(1) = gmt_Input("u1","Inlet Mass Flow 1","Units","kg/s");
            Input(2) = gmt_Input("u2","Outlet Mass Flow 1","Units","kg/s");

            % Define Connection Port Object Array 
            Port(1) = gmt_Port("EdgeConnection",1,"Thermal");
            Port(2) = gmt_Port("EdgeConnection",2,"Thermal");
            Port(3) = gmt_Port("VertexConnection",4,"Thermal");
            Port(4) = gmt_Port("VertexConnection",5,"Thermal");

            % Creates Tank Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,Input,Port,varargin{:});

        end
    end
end
