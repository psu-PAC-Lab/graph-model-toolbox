%% gmt_Inverter
% Defines a inverter model 

%% Class Defintion and Superclass Reference
classdef gmt_Inverter < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_Inverter(ObjectName,varargin)

            % Define Vertex 
            Vertex(1) = gmt_Vertex("Input Voltage","x","External",true);
            Vertex(2) = gmt_Vertex("Output Voltage","x");
            Vertex(3) = gmt_Vertex("Input Current","x","External",true);
            Vertex(4) = gmt_Vertex("Output Current","x");
            Vertex(5) = gmt_Vertex("Inverter Temperature","Cp*x_dot");

            % Define Edge 
            Edge(1) = gmt_Edge("Voltage Input to Voltage Output","sqrt(3/2)*xt*u1");
            Edge(2) = gmt_Edge("Current Input to Voltage Output","Rm*xh*u1");
            Edge(3) = gmt_Edge("Current Input to Current Output","sqrt(3/2)*xt*u1");
            Edge(4) = gmt_Edge("Electrical to Thermal","xt*xt");

            % Define Edge Matrix
            EdgeMatrix = [1  2; ...
                          3  2; ...
                          3  4; ...
                          4  5];

            % Define Default Model Parameterization 
            Parameter(1) = gmt_Parameter("Inverter Losses","Rm",0.0008);

            % Define Model Input  
            Input(1) = gmt_Input("u1","Inverter Duty Cycle");


            % Define Available Connection Ports 
            Port(1) = gmt_Port("VertexConnection",1,"Electrical");
            Port(2) = gmt_Port("VertexConnection",2,"Electrical");

            % Creates Inverter Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,Input,Port,varargin{:});

        end
    end
end
