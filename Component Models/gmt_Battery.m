%% gmt_Battery
% Defines a Battery Model 

%% Class Defintion and Superclass Reference
classdef gmt_Battery < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_Battery(ObjectName)

            % Define Hardcoded Coefficients

            % Define User Define Values 

            % If User Defines UserDefined Populated Grab Values
            % Pick Battery Type and Grab
           
            % Else Use Default Parmeters 

            % C2 = interp2(x,y,z,Tbatt(o),Soc(o))

            % Define Vertices 
            Vertices(1) = gmt_Vertex("SOC","Q*Vocv*x_dot");
            Vertices(2) = gmt_Vertex("Battery Voltage 1","C1*x*x_dot");
            Vertices(3) = gmt_Vertex("Battery Voltage 2","C2*x*x_dot");
            Vertices(4) = gmt_Vertex("Battery Cell Temperature","Cc*x_dot");
            Vertices(5) = gmt_Vertex("Battery Surface Temperature","Cs*x_dot","External");
            Vertices(6) = gmt_Vertex("Battery Current","Vocv*x_dot","External");

            % Define Edges 
            Edges(1) = gmt_Edge("Battery Cell 1 Thermal Transfer","(xt^2)/R1");
            Edges(2) = gmt_Edge("Battery Cell 2 Thermal Transfer","(xt^2)/R2");
            Edges(3) = gmt_Edge("Current Load Heater Transfer","(xt^2)/Rs");
            Edges(4) = gmt_Edge("Battery Cell to Surface Thermal Transfer","(xt-xh)/Rc");
            Edges(5) = gmt_Edge("Battery Charge Rate","Vocv*xt");
            Edges(6) = gmt_Edge("Battery Cell 1 Power Rate","xt*xh");
            Edges(7) = gmt_Edge("Battery Cell 2 Power Rate","xt*xh");
            
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
            Param(1) = gmt_ModelParameter("Cell 1 Capacitance","C1",1.538844236133056e+03,[]);
            Param(2) = gmt_ModelParameter("Cell 2 Capacitance","C2",1.538844236133056e+03,[]);
            Param(3) = gmt_ModelParameter("Cell 1 Resistance","R1",0.033078975870769,[]);
            Param(4) = gmt_ModelParameter("Cell 2 Resistance","R2",0.033078975870769,[]);
            Param(5) = gmt_ModelParameter("Open Circuit Voltage","Vocv",500,[]);
            Param(6) = gmt_ModelParameter("Cell Thermal Capacitance","Cc",10,[]);
            Param(7) = gmt_ModelParameter("Surface Thermal Capacitance","Cs",10,[]);
            Param(8) = gmt_ModelParameter("Battery Capacity","Q",100,[]);
            Param(9) = gmt_ModelParameter("Internal Series Resistance","Rs",0.033078975870769,[]);
            Param(10) = gmt_ModelParameter("Theraml Conductivity","Rc",0.033078975870769,[]);

            % Creates an Battery Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edges,Vertices,Param,"CombineNames");

            % Define Available Connection Ports 
            % obj.ConnectionPorts(1) = gmt_ConnectionPort(obj,"EdgeConnection",4,"Electrical");


        end
    end
end
