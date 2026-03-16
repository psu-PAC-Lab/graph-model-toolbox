%% gmt_Inverter
% Defines inverter model 

%% Class Defintion and Superclass Reference
classdef gmt_Inverter < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_Inverter(ObjectName,varargin)

            % Define Vertex 
            Vertex(1) = gmt_Vertex("Voltage","C*x*x_dot","units","V");
            Vertex(2) = gmt_Vertex("Current","L*x*x_dot","units","A");
            Vertex(3) = gmt_Vertex("Temperature","Cp*x_dot","units","K");
            Vertex(4) = gmt_Vertex("Source Voltage","x","External",true,"units","V");
            Vertex(5) = gmt_Vertex("Sink Current","x","External",true,"units","A");
            Vertex(6) = gmt_Vertex("Sink Temperature","x","External",true,"units","K");

            % Define Edge 
            Edge(1) = gmt_Edge("Input Voltage to Current Conversion","u1*sqrt(3/2)*xt*xh");
            Edge(2) = gmt_Edge("Source Current to Voltage","xt*xh");
            Edge(3) = gmt_Edge("Sink Voltage to Current","xt*xh");
            Edge(4) = gmt_Edge("Electrical Losses","u1*Ri*xt^2");
            Edge(5) = gmt_Edge("Sink Heat Transfer","(1/Ru)*(xt-xh)");

            % Define Edge Matrix
            EdgeMatrix = [4, 2; ...
                          2, 1; ...
                          1, 5; ...
                          2, 3; ...
                          3, 6];

            % Define Default Model Parameterization 
            Parameter(1) = gmt_Parameter("Thermal Losses","Ri",0.0808);
            Parameter(2) = gmt_Parameter("Thermal Capacity","Cp",10000);
            Parameter(3) = gmt_Parameter("Capacitance","C1",0.1);
            Parameter(4) = gmt_Parameter("Inductance","L",0.01);
            Parameter(5) = gmt_Parameter("Convection Resistance","Ru",0.0808);

            % Define Model Input  
            Input(1) = gmt_Input("u1","Inverter Duty Cycle");

            % Define Available Connection Ports 
            Port(1) = gmt_Port("EdgeConnection",2,"Electrical");
            Port(2) = gmt_Port("EdgeConnection",3,"Electrical");
            Port(3) = gmt_Port("EdgeConnection",5,"Thermal");
            Port(4) = gmt_Port("VertexConnection",1,"Electrical");
            Port(5) = gmt_Port("VertexConnection",2,"Electrical");
            Port(6) = gmt_Port("VertexConnection",4,"Electrical");
            Port(7) = gmt_Port("VertexConnection",5,"Electrical");
            Port(8) = gmt_Port("VertexConnection",6,"Thermal");

            % Creates Inverter Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,Input,Port,varargin{:});

        end
    end
end
