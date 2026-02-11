%% gmt_Battery
% Defines a Battery Model 

%% Class Defintion and Superclass Reference
classdef gmt_Battery < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_Battery(ObjectName,varargin)

            % Define Vertex 
            Vertex(1) = gmt_Vertex("SOC","Q*Vocv*x_dot");
            Vertex(2) = gmt_Vertex("Battery Voltage 1","C1*x*x_dot");
            Vertex(3) = gmt_Vertex("Battery Voltage 2","C2*x*x_dot");
            Vertex(4) = gmt_Vertex("Battery Cell Temperature","Cc*x_dot");
            Vertex(5) = gmt_Vertex("Battery Surface Temperature","Cs*x_dot","External",true);
            Vertex(6) = gmt_Vertex("Battery Current","Vocv*x_dot","External",true);

            % Define Edge 
            Edge(1) = gmt_Edge("Battery Cell 1 Thermal Transfer","(xt^2)/R1");
            Edge(2) = gmt_Edge("Battery Cell 2 Thermal Transfer","(xt^2)/R2");
            Edge(3) = gmt_Edge("Current Load Heater Transfer","(xt^2)/Rs");
            Edge(4) = gmt_Edge("Battery Cell to Surface Thermal Transfer","(xt-xh)/Rc");
            Edge(5) = gmt_Edge("Battery Charge Rate","Vocv*xt");
            Edge(6) = gmt_Edge("Battery Cell 1 Power Rate","xt*xh");
            Edge(7) = gmt_Edge("Battery Cell 2 Power Rate","xt*xh");
            
            % Define Edge Matrix
            EdgeMatrix = [2  4; ...
                          3  4; ...
                          6  4; ...
                          4  5; ...
                          1  6; ...
                          6  2; ...
                          6  3; ...
                          ];

            % Define Model Parameterization 
            Parameter(1) = gmt_Parameter("Cell 1 Capacitance","C1",1.538844236133056e+03);
            Parameter(2) = gmt_Parameter("Cell 2 Capacitance","C2",1.538844236133056e+03);
            Parameter(3) = gmt_Parameter("Cell 1 Resistance","R1",0.033078975870769);
            Parameter(4) = gmt_Parameter("Cell 2 Resistance","R2",0.033078975870769);
            Parameter(5) = gmt_Parameter("Open Circuit Voltage","Vocv",500);
            Parameter(6) = gmt_Parameter("Cell Thermal Capacitance","Cc",10);
            Parameter(7) = gmt_Parameter("Surface Thermal Capacitance","Cs",10);
            Parameter(8) = gmt_Parameter("Battery Capacity","Q",100);
            Parameter(9) = gmt_Parameter("Internal Series Resistance","Rs",0.033078975870769);
            Parameter(10) = gmt_Parameter("Theraml Conductivity","Rc",0.033078975870769);

            % Define Available Connection Ports 
            Port(1) = gmt_Port("EdgeConnection",4,"Electrical");

            % Creates Battery Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,[],Port,varargin{:});

        end
    end
end
