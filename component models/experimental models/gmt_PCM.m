%% gmt_PCM
% Defines a phase change heat exchanger

%% Class Defintion and Superclass Reference
classdef gmt_PCM < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_PCM(ObjectName,varargin)

            % Define Vertex Object Array
            Vertex(1) = gmt_Vertex("Fluid Temperature","cp_f*V1*rho_f*x_dot","units","K");
            Vertex(2) = gmt_Vertex("Wall 1 Temperature","cp_w1*rho_w1*l_w1*a_w1*x_dot","units","K");
            Vertex(3) = gmt_Vertex("Wax Temperature","cp_wax*V2*rho_wax*x_dot","units","K");
            Vertex(4) = gmt_Vertex("Wall 2 Temperature","cp_w2*rho_w2*l_w2*a_w2*x_dot","units","K");
            Vertex(5) = gmt_Vertex("Source Temperature","x","External",true,"Units","K");
            Vertex(6) = gmt_Vertex("Sink Temperature","x","External",true,"Units","K");
            Vertex(7) = gmt_Vertex("Air Temperature","x","External",true,"Units","K");  

            % Define Edge Object Array
            Edge(1) = gmt_Edge("Advection In","cp_f*u1*xt");
            Edge(2) = gmt_Edge("Advection Out","cp_f*u1*xt");
            Edge(3) = gmt_Edge("Convection: Fluid to Wall 1","hf1*a_w1*(xt-xh)");
            Edge(4) = gmt_Edge("Conduction: Wall 1 to Wax"  ,"*a_w1w*(xt-xh)");
            Edge(5) = gmt_Edge("Conduction: Wax to Wall 2"  ,"*a_w2w*(xt-xh)");
            Edge(6) = gmt_Edge("Convection: Wall 2 to Air"  ,"h2a*a_w2*(xt-xh)");

            % Define Edge Matrix
            EdgeMatrix = [5, 1; ...
                          1, 6; ...
                          1, 2; ...
                          2, 3; ...
                          3, 4; ...
                          4, 7];

           % Define Parameter Object Array
            Parameter(1)  = gmt_Parameter("Fluid Specific Heat","cp_f",3300,"Units","J/(kg*K)","Common",true);
            Parameter(2)  = gmt_Parameter("Fluid Density","rho_f",1090,"Units","kg/(m^3)","Common",true);
            Parameter(3)  = gmt_Parameter("Fluid Volume","V1",0.002,"Units","m^3");
            Parameter(4)  = gmt_Parameter("Wax Specific Heat","cp_wax",3300,"Units","J/(kg*K)");
            Parameter(5)  = gmt_Parameter("Wax Density","rho_wax",1090,"Units","kg/(m^3)");
            Parameter(6)  = gmt_Parameter("Wax Volume","V2",0.002,"Units","m^3");
            Parameter(7)  = gmt_Parameter("Wall 1 Area","a_w1",0.002,"Units","m^2");
            Parameter(8)  = gmt_Parameter("Wall 2 Area","a_w2",0.002,"Units","m^2");
            Parameter(9)  = gmt_Parameter("Wall 1 Length","l_w1",0.002,"Units","m^2");
            Parameter(10) = gmt_Parameter("Wall 2 Length","l_w2",0.002,"Units","m^2");
            Parameter(11) = gmt_Parameter("Wall 1 Density","rho_w1",0.002,"Units","kg/(m^3)");
            Parameter(12) = gmt_Parameter("Wall 2 Density","rho_w2",0.002,"Units","kg/(m^3)");
            Parameter(13) = gmt_Parameter("HTC: Fluid to Wall 1","hf1",0.002,"Units","W/(m^2*K)");
            Parameter(14) = gmt_Parameter("HTC: Wall 1 to Wax","h1w",0.002,"Units","W/(m^2*K)");
            Parameter(15) = gmt_Parameter("HTC: Wax to Wall 2","hw2",0.002,"Units","W/(m^2*K)");
            Parameter(16) = gmt_Parameter("HTC: Wall 2 to Air","h2a",0.002,"Units","W/(m^2*K)");
            Parameter(17) = gmt_Parameter("Wall 1 Specific Heat","cp_w1",0.002,"Units","J/(kg*K)");
            Parameter(18) = gmt_Parameter("Wall 2 Specific Heat","cp_w2",0.002,"Units","J/(kg*K)");

            % Define Input Object Array 
            Input(1) = gmt_Input("u1","Inlet Mass Flow 1","Units","kg/s");

            % Define Connection Port Object Array 
            Port(1) = gmt_Port("EdgeConnection",1,"Thermal");
            Port(2) = gmt_Port("EdgeConnection",2,"Thermal");

            % Creates Tank Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,Input,Port,varargin{:});

        end
    end
end
