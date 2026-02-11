%% gmt_HeadLoad
% Defines a heat load

%% Class Defintion and Superclass Reference
classdef gmt_HeatLoad < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_HeatLoad(ObjectName,varargin)

            % Define Vertex 
            Vertex(1) = gmt_Vertex("Load Temperature","cp_f*V*Rho*x_dot");
            Vertex(2) = gmt_Vertex("Inlet","cp_f*Rho*V*x_dot","External",true);
            Vertex(3) = gmt_Vertex("Outlet","cp_f*Rho*V*x_dot","External",true);
            Vertex(4) = gmt_Vertex("Energy Applied","x_dot","External",true);

            % Define Edge 
            Edge(1) = gmt_Edge("Advection In","cp_f*u1*xt");
            Edge(2) = gmt_Edge("Advection Out","cp_f*u1*xt");
            Edge(3) = gmt_Edge("Power Applied","u2","External");

            % Define Edge Matrix
            EdgeMatrix = [2 1; ...
                          1 3; ...
                          4 1];

            % Define Default Model Parameterization 
            Parameter(1) = gmt_Parameter("Fluid Specific Heat","cp_f",3300,"Units","kJ/(kg*K)","Common",true);
            Parameter(2) = gmt_Parameter("Volume","V",0.002,"Units","m^3");
            Parameter(3) = gmt_Parameter("Fluid Density","Rho",1090,"Units","kg/(m^3)","Common",true);

            % Define Input Labeling 
            Input(1) = gmt_Input("u1","Inlet Mass Flow 1","Units","kg/s");
            Input(2) = gmt_Input("u2","Energy Applied","Units","W");

            % Define Available Connection Ports
            Port(1) = gmt_Port("EdgeConnection",1,"Thermal");
            Port(2) = gmt_Port("EdgeConnection",2,"Thermal");
            Port(3) = gmt_Port("VertexConnection",1,"Thermal");

            % Creates Heat Load Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,Input,Port,varargin{:});

        end
    end
end
