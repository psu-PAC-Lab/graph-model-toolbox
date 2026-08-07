%% gmt_WyeToDelta
% Defines wye to delta conversion model

%% Class Defintion and Superclass Reference
classdef gmt_WyeToDelta < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_WyeToDelta(ObjectName,varargin)

            % Define Vertex 
            Vertex(1) = gmt_Vertex("Voltage","C*x*x_dot","units","V");
            Vertex(2) = gmt_Vertex("Current","L*x*x_dot","units","A");
            Vertex(3) = gmt_Vertex("Source Voltage","x","External",true,"units","V");
            Vertex(4) = gmt_Vertex("Source Current","x","External",true,"units","A");

            % Define Edge 
            Edge(1) = gmt_Edge("Current to Voltage","xt*xh");
            Edge(2) = gmt_Edge("Source Voltage to Current","xt*xh");
            Edge(3) = gmt_Edge("Sink Current from Voltage","xt*xh");

            % Define Edge Matrix
            EdgeMatrix = [2, 1; ...
                          3, 2; ...
                          1, 4];

            % Define Default Model Parameterization 
            Parameter(1) = gmt_Parameter("Capacitance","C",0.1,"units","F");
            Parameter(2) = gmt_Parameter("Inductance","L",0.01,"units","H");

            % Define Model Input  
            Input = [];

            % Define Available Connection Ports 
            Port(1) = gmt_Port("EdgeConnection",2,"Electrical");
            Port(2) = gmt_Port("EdgeConnection",3,"Electrical");

            % Creates Inverter Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,Input,Port,varargin{:});

        end
    end
end
