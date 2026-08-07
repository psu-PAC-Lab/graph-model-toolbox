%% gmt_ElectricalBus
% class defines electrical bus model 
% model is dynamically created based on number of voltage inputs, and current outputs specified 

%% Class Definition and Superclass Reference
classdef gmt_ElectricalBus < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_ElectricalBus(ObjectName,v_in,i_out,varargin)

            % Input Validation 
            assert(v_in>=1,"Voltage input (v_in) must be greater than or equal to 1")
            assert(i_out>=1,"Current output (i_out) must be greater than or equal to 1")

            % Define Standard Vertices
            Vertex(1) = gmt_Vertex("Voltage", "C1*x*x_dot","units","V"); 
            Vertex(2) = gmt_Vertex("Sink Temperature", "x","units","K","external",true);

            % Define Standard Model Parameterization 
            Parameter(1) = gmt_Parameter("Capacitance","C1",0.01);
            Parameter(2) = gmt_Parameter("Bleed Resistance","R",0.01);

            % Define Ports 
            Ports(1) = gmt_Port("VertexConnection",2,"Thermal");

            % Define Empty Edge Matrix
            EdgeMatrix = [];
            portIdx = 2;

            % Dynamic Electrical Bus (Input) Edge, Vertex, Input, Parameter Construction
            for i = 1:v_in

                % Dynamic Inductance Description and Variable Naming
                InductanceName_tmp = "Inductance"+ string(i);
                InductanceVar_tmp  = "L" + string(i);

                % Dynamic Current State Description Naming
                CurrentStateName_tmp = "Current "  + string(i);

                % Dynamic Source State Description Naming
                SourceVoltageName_tmp  = "Source Voltage " + string(i);

                % Dynamic Input Variable Naming
                InputVar_tmp = "u" + string(i);

                % Vertex Definitions 
                Vertex(2*i+1) = gmt_Vertex(SourceVoltageName_tmp, "x","units","V","external",true);
                Vertex(2*i+2) = gmt_Vertex(CurrentStateName_tmp,  InductanceVar_tmp+"*x*x_dot","units","A");
                
                % Edge Definitions
                Edge(3*i-2) = gmt_Edge(SourceVoltageName_tmp + " to " + CurrentStateName_tmp,"xt*xh*"+InputVar_tmp);
                Edge(3*i-1) = gmt_Edge(CurrentStateName_tmp + " to Voltage","xt*xh*"+InputVar_tmp);
                Edge(3*i)   = gmt_Edge(CurrentStateName_tmp + " to Sink Temperature","R*xt*xt");

                % Parameter Definitions 
                Parameter(i+2) = gmt_Parameter(InductanceName_tmp,InductanceVar_tmp,0.01,"units","H");

                % Inputs 
                Input(i) = gmt_Input(InputVar_tmp,"Bus Input Switch "+ string(i));
                
                % Dynamically update edge matrix
                EdgeMatrix = [EdgeMatrix; ...
                              2*i+1, 2*i+2; ...
                              2*i+2, 1; ...
                              2*i+2, 2];  

                Ports(portIdx) = gmt_Port("EdgeConnection",3*i-2,"Electrical");
                portIdx = portIdx + 1;

            end

            % Dynamic Electrical Bus (Output) Edge, Vertex, Input, Parameter Construction
            for j = 1:i_out

                % Dynamic Sink State Description Naming
                SinkCurrentName_tmp    = "Sink Current "  + string(j);
                
                % Dynamic Input Variable Naming
                InputVar_tmp = "u"  + string(max(v_in)+j);

                % Inputs 
                Input(max(v_in)+j) = gmt_Input(InputVar_tmp,"Bus Output Switch "+ string(j));

                % Edge Definition 
                Edge(3*max(v_in)+j) = gmt_Edge("Voltage to " + SinkCurrentName_tmp, "xt*xh*" + InputVar_tmp);

                % Vertex Definition
                Vertex(2*max(v_in)+j+2) = gmt_Vertex(SinkCurrentName_tmp,  "x","units","A","external",true);

                % Dynamically update edge matrix
                EdgeMatrix = [EdgeMatrix; ...
                              1, 2*max(v_in)+j+2];

                Ports(portIdx) = gmt_Port("EdgeConnection",3*max(v_in)+j,"Electrical");
                portIdx = portIdx + 1;
                
            end

            % Creates Inverter Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,Input,Ports,varargin{:});

        end
    end
end
