%% gmt_BuckBooster
% Defines buck booster model 

%% Class Defintion and Superclass Reference
classdef gmt_BuckBooster < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_BuckBooster(ObjectName,varargin)

            % Define Vertex 
            Vertex(1) = gmt_Vertex("Current","","units","A");
            Vertex(2) = gmt_Vertex("Voltage","","units","V");
            Vertex(3) = gmt_Vertex("Temperature","","units","K");
            Vertex(4) = gmt_Vertex("Source Voltage","","units","V","external",true);
            Vertex(5) = gmt_Vertex("Sink Current","","units","A","external",true);
            Vertex(6) = gmt_Vertex("Sink Voltage","","units","V","external",true);
            Vertex(7) = gmt_Vertex("Sink Temperature","","units","K","external",true);

            % Define Edge 
            Edge(1) = gmt_Edge("Input Voltage to Current Conversion","u1*sqrt(3/2)*xt*xh");


            % Define Edge Matrix
            EdgeMatrix = [4, 2; ...
                          2, 1; ...
                          1, 5; ...
                          2, 3; ...
                          3, 6];

            % Define Default Model Parameterization 
            Parameter(1) = gmt_Parameter("Thermal Losses","Ri",0.0808);

            % Define Model Input  
            Input(1) = gmt_Input("u1","Buck Booster Duty Cycle");

            % Define Available Connection Ports 
            Port(1) = gmt_Port();

            % Creates Inverter Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,Input,Port,varargin{:});

        end
    end
end
