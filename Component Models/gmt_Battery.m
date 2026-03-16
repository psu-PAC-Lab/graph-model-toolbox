%% gmt_Battery
% Defines a battery model 
% Default model has numerical lookup tables for battery properties 
% Battery properties are available for the following batteries
% - 3.3V LiFePO4 2.3 Ah
% - 3.3V LiFePO4 Graph 2.3 Ah
% - 4.2V LiPo 5.1 Ah
% - 4.2V LiPo Graph 5.1 Ah
% - 57.6 Testbed 21.33 Ah'
% - 57.6 Testbed Graph 21.33 Ah
% Any of these batteries can be selected for modeling using optional input 
% optional syntax "Battery","Battery Name"
% Battery name must match list from above 
% Number of cells in series Ns is an optional input default is 1
% optional syntax "Ns",<numeric_value>
% Number of cells in parallel Np is an optional input default is 1
% optional syntax "Np",<numeric_value>

%% Class Defintion and Superclass Reference
classdef gmt_Battery < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_Battery(ObjectName,varargin)
            
            % Component Specific Input Parsing 
            params = gmt_Battery.gmt_parseClass(varargin{:});

            % Define Vertex 
            Vertex(1) = gmt_Vertex("SOC","3600*Bcap*Np*x_dot","units","%");
            Vertex(2) = gmt_Vertex("Voltage 1","C1*x*x_dot","units","V");
            Vertex(3) = gmt_Vertex("Voltage 2","C2*x*x_dot","units","V");
            Vertex(4) = gmt_Vertex("Cell Temperature","Np*Ns*Cc*x_dot","units","K");
            Vertex(5) = gmt_Vertex("Surface Temperature","Np*Ns*Cs*x_dot","units","K");
            Vertex(6) = gmt_Vertex("Sink Temperature","x","External",true,"units","K");
            Vertex(7) = gmt_Vertex("Source Current","x","External",true,"units","A");

            % Define Edge 
            Edge(1) = gmt_Edge("Cell 1 Thermal Transfer","(xt^2)/R1"); 
            Edge(2) = gmt_Edge("Cell 2 Thermal Transfer","(xt^2)/R2"); 
            Edge(3) = gmt_Edge("Current Load Heat Transfer","Rs*(xt^2)");
            Edge(4) = gmt_Edge("Cell to Surface Heat Transfer","(xt-xh)/Rc");
            Edge(5) = gmt_Edge("Charge Rate","Vocv_*xh");
            Edge(6) = gmt_Edge("Cell 1 Power Rate","xt*xh");
            Edge(7) = gmt_Edge("Cell 2 Power Rate","xt*xh");
            Edge(8) = gmt_Edge("Sink Heat Transfer","(xt-xh)/Ru");
            
            % Define Edge Matrix
            EdgeMatrix = [2, 4; ...
                          3, 4; ...
                          7, 4; ...
                          4, 5; ...
                          1, 7; ...
                          7, 2; ...
                          7, 3; ...
                          5, 6];

            %% Battery Lookup Table Data 
            load('BattProp.mat');

            if strcmp(params.Battery,'3.3V LiFePO4 2.3 Ah')
                cell = BattProp.LiFePO_33V;
                t = 1;
           
            elseif strcmp(params.Battery,'3.3V LiFePO4 Graph 2.3 Ah')
                cell = BattProp.LiFePO_33V_G;
                t = 2;
            
            elseif strcmp(params.Battery,'4.2V LiPo 5.1 Ah')
                cell = BattProp.LiPo_42V;
                t = 1;
            
            elseif strcmp(params.Battery,'4.2V LiPo Graph 5.1 Ah')
                cell = BattProp.LiPo_42V_G;
                t = 2;
            
            elseif strcmp(params.Battery,'57.6 Testbed 21.33 Ah')
                cell = BattProp.Testbed4Pack;
                t = 1;
            
            elseif strcmp(params.Battery,'57.6 Testbed Graph 21.33 Ah')
                cell = BattProp.Testbed4Pack_G;
                t = 2;
            else
                error("No Battery Model Matches Found")
            end

            %% Define Model Parameterization 
            
            % Number of Cells in Series and Parallel 
            Parameter(1) = gmt_Parameter("Number of Parallel Cells","Np",params.Np);
            Parameter(2) = gmt_Parameter("Number of Series Cells","Ns",params.Ns);

            % Battery Property Temperature Profile 
            if t > 1.5 
                tm_tmp = "x4-273";
            else 
                tm_tmp = "((x4+x5)/2)-273";
            end

            % Capacitance Cell 1
            Parameter(3) = gmt_Parameter("Cell 1 Capacitance - d","C1d = interp2(Temp,RC_SOC_d,C1_d,"+tm_tmp+",x1,'linear')",cell);
            Parameter(4) = gmt_Parameter("Cell 1 Capacitance - c","C1c = interp2(Temp,RC_SOC_c,C1_c,"+tm_tmp+",x1,'linear')",[]);
            Parameter(5) = gmt_Parameter("Cell 1 Capacitance","C1 = ((C1d-C1c)/(1+exp(-50*x7)))+C1c",[]);
            
            % Capacitance Cell 2
            Parameter(6) = gmt_Parameter("Cell 2 Capacitance - d","C2d = interp2(Temp,RC_SOC_d,C2_d,"+tm_tmp+",x1,'linear')",[]);
            Parameter(7) = gmt_Parameter("Cell 2 Capacitance - c","C2c = interp2(Temp,RC_SOC_c,C2_c,"+tm_tmp+",x1,'linear')",[]);
            Parameter(8) = gmt_Parameter("Cell 2 Capacitance","C2 = ((C2d-C2c)/(1+exp(-50*x7)))+C2c",[]);
            
            % Resistance Cell 1
            Parameter(9) = gmt_Parameter("Cell 1 Resistance","R1d = interp2(Temp,RC_SOC_d,R1_d,"+tm_tmp+",x1,'linear')",[]);
            Parameter(10) = gmt_Parameter("Cell 1 Resistance","R1c = interp2(Temp,RC_SOC_c,R1_c,"+tm_tmp+",x1,'linear')",[]);
            Parameter(11) = gmt_Parameter("Cell 1 Resistance","R1 = ((R1d-R1c)/(1+exp(-50*x7)))+R1c",[]);

            % Resistance Cell 2
            Parameter(12) = gmt_Parameter("Cell 1 Resistance","R2d = interp2(Temp,RC_SOC_d,R2_d,"+tm_tmp+",x1,'linear')",[]);
            Parameter(13) = gmt_Parameter("Cell 1 Resistance","R2c = interp2(Temp,RC_SOC_c,R2_c,"+tm_tmp+",x1,'linear')",[]);
            Parameter(14) = gmt_Parameter("Cell 1 Resistance","R2 = ((R2d-R2c)/(1+exp(-50*x7)))+R2c",[]);

            % Resistance Cell Series
            Parameter(15) = gmt_Parameter("Internal Series Resistance","Rsd = interp2(Temp,RC_SOC_d,Rs_d,"+tm_tmp+",x1,'linear')",[]);
            Parameter(16) = gmt_Parameter("Internal Series Resistance","Rsc = interp2(Temp,RC_SOC_c,Rs_c,"+tm_tmp+",x1,'linear')",[]);
            Parameter(17) = gmt_Parameter("Internal Series Resistance","Rs = ((Rsd-Rsc)/(1+exp(-50*x7)))+Rsc",[]);

            % Open Circuit Voltage
            Parameter(18) = gmt_Parameter("Open Circuit Voltage","Vocv_ = Ns*interp1(V_SOC,Vocv,x1)",[]);

            % Thermal Capacitance 
            Parameter(19) = gmt_Parameter("Cell Thermal Capacitance","Cc",62.7);
            Parameter(20) = gmt_Parameter("Surface Thermal Capacitance","Cs",4.5);

            % Battery Capacity 
            Parameter(21) = gmt_Parameter("Battery Capacity","Bcap",21.3);

            % Conduction Resistance 
            Parameter(22) = gmt_Parameter("Theraml Conductivity","Rc",1.94);

            % Thermal Convection Resistance
            Parameter(23) = gmt_Parameter("Thermal Convection Resistance","Ru",0.01);

            %% Define Available Connection Ports 
            Port(1) = gmt_Port("EdgeConnection",8,"Thermal");
            Port(2) = gmt_Port("VertexConnection",6,"Thermal");
            Port(3) = gmt_Port("VertexConnection",7,"Electrical");

            %% Creates Battery Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,[],Port,varargin{:});

        end
    end

    methods (Static)

        %% Variable Input Argument Data Parsing 
        function params = gmt_parseClass(varargin)

            % Variable Input Parsing 
            p = inputParser;
            p.KeepUnmatched = true;
            addParameter(p, 'Battery',"3.3V LiFePO4 2.3 Ah", @(x) istring(x));
            addParameter(p, 'Ns',1, @(x) isnumeric(x));
            addParameter(p, 'Np',1, @(x) isnumeric(x));
            parse(p, varargin{:});
            params = p.Results;

        end
    end
end
