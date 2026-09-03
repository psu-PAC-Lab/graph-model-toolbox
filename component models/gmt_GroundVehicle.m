%% gmt_GroundVehicle
% defines ground vehicle using EPA road load calculation

%% Class Defintion and Superclass Reference
classdef gmt_GroundVehicle < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_GroundVehicle(ObjectName,varargin)

            % Define Vertex 
            Vertex(1) = gmt_Vertex("Vehicle Velocity","x","units","m/s");
            Vertex(2) = gmt_Vertex("Source Angular Velocity","x","External",true,"units","rad/s");

            % Define Edge 
            Edge(1) = gmt_Edge("Vehicle Road Load Power","xt*(D/2)");

            % Define Edge Matrix
            EdgeMatrix = [2, 1];

            % Define Default Model Parameterization 
            %Parameter(1) = gmt_Parameter("Road Load Coefficient A","A",0.38,"units","N/(m/s)^2");
            %Parameter(2) = gmt_Parameter("Road Load Coefficient B","B",0.60,"units","N/(m/s)");
            %Parameter(3) = gmt_Parameter("Road Load Coefficient C","C",140,"units","N");

            
            Parameter(1) = gmt_Parameter("Tire Diameter","D",0.64,"units","m");
            %Parameter(5) = gmt_Parameter("Vehicle Mass","m",1800,"units","kg");

            % Define Model Input  
            Input = [];

            % Define Available Connection Ports
            Port(1) = gmt_Port("VertexConnection",2,"Rotational");

            % Creates Inverter Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,Input,Port,varargin{:});

        end
    end
end