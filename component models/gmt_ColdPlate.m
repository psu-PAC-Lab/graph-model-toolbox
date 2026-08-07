%% gmt_ColdPlate
% Defines a cold plate

%% Class Defintion and Superclass Reference
classdef gmt_ColdPlate < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_ColdPlate(ObjectName,varargin)

            % Define Vertex 
            Vertex(1) = gmt_Vertex("Fluid Temperature","cp_f*V*rho_f*x_dot","units","K");
            Vertex(2) = gmt_Vertex("Wall Temperature","cp_w*rho_w*l_w*a_w*x_dot","units","K");
            Vertex(3) = gmt_Vertex("Source Temperature","x","External",true,"units","K");
            Vertex(4) = gmt_Vertex("Sink Temperature","x","External",true,"units","K");
            Vertex(5) = gmt_Vertex("Energy Applied","x","External",true,"units","W");

            % Define Edge 
            Edge(1) = gmt_Edge("Advection In","cp_f*u1*xt");
            Edge(2) = gmt_Edge("Advection Out","cp_f*u1*xt");
            Edge(3) = gmt_Edge("Convection","h*a_w*(xt-xh)");
            Edge(4) = gmt_Edge("Power Applied","xt");

            % Define Edge Matrix
            EdgeMatrix = [3, 1; ...
                          1, 4; ...
                          2, 1; ...
                          5, 2];              

            % Define Default Model Parameterization 
            Parameter(1) = gmt_Parameter("Fluid Specific Heat","cp_f",3300,"Units","J/(kg*K)","Common",true);
            Parameter(2) = gmt_Parameter("Fluid Volume","V",0.002,"Units","m^3");
            Parameter(3) = gmt_Parameter("Fluid Density","rho_f",1090,"Units","kg/(m^3)","Common",true);
            Parameter(4) = gmt_Parameter("Wall Specific Heat","cp_w",897,"Units","J/(kg*K)");
            Parameter(5) = gmt_Parameter("Wall Density","rho_w",1090,"Units","kg/(m^3)","Common",true);
            Parameter(6) = gmt_Parameter("Wall Thickness","l_w",0.02,"Units","m");
            Parameter(7) = gmt_Parameter("Wall Area","a_w",1,"Units","m^2");
            Parameter(8) = gmt_Parameter("Heat Transfer Coefficient","h",100,"units","W/(m^2*K)");

            % Define Input Labeling 
            Input(1) = gmt_Input("u1","Inlet Mass Flow 1","Units","kg/s");

            % Define Available Connection Ports
            Port(1) = gmt_Port("EdgeConnection",1,"Thermal");
            Port(2) = gmt_Port("EdgeConnection",2,"Thermal");
            Port(3) = gmt_Port("EdgeConnection",3,"Thermal");
            Port(4) = gmt_Port("VertexConnection",1,"Thermal");

            % Creates Heat Load Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,Input,Port,varargin{:});

        end
    end
end
