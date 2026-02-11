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
            Vertex(1) = gmt_Vertex("Temperature S1","x_dot");
            Vertex(2) = gmt_Vertex("Temperature S2","x_dot"); 
            Vertex(3) = gmt_Vertex("Inlet S1","x_dot","External",true); 
            Vertex(4) = gmt_Vertex("Inlet S2","x_dot","External",true); 
            Vertex(5) = gmt_Vertex("Outlet S1","x_dot","External",true); 
            Vertex(6) = gmt_Vertex("Outlet S2","x_dot","External",true); 

            % Define Edge 
            Edge(1) = gmt_Edge("Heat Transfer 1 In","cp_f1*u1*xt");
            Edge(2) = gmt_Edge("Heat Transfer 1 Out","cp_f1*u1*xt");
            Edge(3) = gmt_Edge("Heat Transfer 2 In","cp_f2*u2*xt");
            Edge(4) = gmt_Edge("Heat Transfer 2 Out","cp_f2*u2*xt");
            Edge(5) = gmt_Edge("Fluid Heat Transfer","HTC*(xt-xh)");

            % Define Edge Matrix
            EdgeMatrix = [3 1; ...
                          1 5; ...
                          4 2; ...
                          2 6; ...
                          1 2];

            % Define Default Model Parameterization 
            Parameter(1) = gmt_Parameter("Specific Heat Fluid 1","cp_f1",1);
            Parameter(2) = gmt_Parameter("Specific Heat Fluid 2","cp_f2",1);
            Parameter(3) = gmt_Parameter("Heat Transfer Coefficient","HTC",1);

            % Define Input Object Array 
            Input(1) = gmt_Input("u1","Inlet Mass Flow 1","Units","kg/s");
            Input(2) = gmt_Input("u2","Inlet Mass Flow 2","Units","kg/s");

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
