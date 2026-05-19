%% gmt_HeatExchanger
% Defines a heat exchanger model 
% Two plates, no wall

%% Class Defintion and Superclass Reference
classdef gmt_HeatExchanger < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_HeatExchanger(ObjectName,varargin)

            % Define Vertex 
            Vertex(1) = gmt_Vertex("Temperature - Fluid A","cpf_a*V_a*Rho_a*x_dot","units","K");
            Vertex(2) = gmt_Vertex("Temperature - Fluid B","cpf_b*V_b*Rho_b*x_dot","units","K");
            Vertex(3) = gmt_Vertex("Wall Temperature","cp_w*(rho_w*l_w*((A_a+A_b)/2))*x_dot","units","K");
            Vertex(4) = gmt_Vertex("Source Temperature - Fluid A","x","External",true,"units","K");
            Vertex(5) = gmt_Vertex("Source Temperature - Fluid B","x","External",true,"units","K");
            Vertex(6) = gmt_Vertex("Sink Temperature - Fluid A","x","External",true,"units","K");
            Vertex(7) = gmt_Vertex("Sink Temperature - Fluid B","x","External",true,"units","K");

            % Define Edge 
            Edge(1) = gmt_Edge("Inlet Heat Advection - Fluid A","cpf_a*u1*xt");
            Edge(2) = gmt_Edge("Inlet Heat Advection - Fluid B","cpf_b*u2*xt");
            Edge(3) = gmt_Edge("Outlet Heat Advection - Fluid A","cpf_a*u1*xt");
            Edge(4) = gmt_Edge("Outlet Heat Advection - Fluid B","cpf_b*u2*xt");
            Edge(5) = gmt_Edge("Wall Conduction - Fluid A","h_a*A_a*(xt-xh)");
            Edge(6) = gmt_Edge("Wall Conduction - Fluid B","h_b*A_b*(xt-xh)");

            % Define Edge Matrix
            EdgeMatrix = [4, 1; ...
                          5, 2; ...
                          1, 6; ...
                          2, 7; ...
                          3, 1; ...
                          2, 3];

            % Define Default Model Parameterization 
            Parameter(1) = gmt_Parameter("Specific Heat - Fluid A","cpf_a",2250,"units","J/(kg*K)","Common",true);
            Parameter(2) = gmt_Parameter("Specific Heat - Fluid B","cpf_b",1005,"units","J/(kg*K)","Common",true);
            Parameter(3) = gmt_Parameter("Wall Area - Fluid A","A_a",1,"units","m^2");
            Parameter(4) = gmt_Parameter("Wall Area - Fluid B","A_b",1,"units","m^2)");
            Parameter(5) = gmt_Parameter("Heat Transfer Coefficient - Fluid A","h_a",1,"units","W/(m^2*K)");
            Parameter(6) = gmt_Parameter("Heat Transfer Coefficient - Fluid B","h_b",1,"units","W/(m^2*K)");
            Parameter(7) = gmt_Parameter("Density - Fluid A","Rho_a",840,"Units","kg/(m^3)","Common",true);
            Parameter(8) = gmt_Parameter("Density - Fluid B","Rho_b",1090,"Units","kg/(m^3)","Common",true);
            Parameter(9) = gmt_Parameter("Volume - Fluid A","V_a",0.01,"Units","m^3");
            Parameter(10) = gmt_Parameter("Volume - Fluid B","V_b",0.01,"Units","m^3");
            Parameter(11) = gmt_Parameter("Wall Heat Capacity","cp_w",900,"Units","J/(kg*K)");
            Parameter(12) = gmt_Parameter("Wall Thickness","l_w",0.02,"Units","m");
            Parameter(13) = gmt_Parameter("Wall Density","rho_w",2700,"Units","kg/m^3");
            
            % Define Input Object Array 
            Input(1) = gmt_Input("u1","Mass Flow Rate - Fluid A","Units","kg/s");
            Input(2) = gmt_Input("u2","Mass Flow Rate - Fluid B","Units","kg/s");

            % Define Connection Ports 
            Port(1) = gmt_Port("EdgeConnection",1,"Thermal");
            Port(2) = gmt_Port("EdgeConnection",2,"Thermal");
            Port(3) = gmt_Port("EdgeConnection",3,"Thermal");
            Port(4) = gmt_Port("EdgeConnection",4,"Thermal");

            % Creates Heat Exchanger Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,Input,Port,varargin{:});

        end
    end
end
