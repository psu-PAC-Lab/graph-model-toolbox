%% gmt_EnergyConversionSplit
% Defines a engine conversion split

%% Class Defintion and Superclass Reference
classdef gmt_EnergyConversionSplit < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_EnergyConversionSplit(ObjectName,varargin)

            % Define Model Vertices 
            Vertices(1) = gmt_Vertex("Junction Fluid Temperature","cp_f*V*Rho*x_dot","units","K");
            Vertices(2) = gmt_Vertex("Source Input 1","x","units","unitless","External",true);
            Vertices(3) = gmt_Vertex("Source Input 2","x","units","unitless","External",true);
            Vertices(4) = gmt_Vertex("Sink Output 1","x","units","unitless","External",true);
            Vertices(5) = gmt_Vertex("Sink Output 2","x","units","unitless","External",true);
          
            % Define Model Edges
            Edges(1)  = gmt_Edge("Chemical Energy Input","LHV*u1");
            Edges(2)  = gmt_Edge("Thermal Energy Input","cp_f*xt*u1");
            Edges(3)  = gmt_Edge("Chemical Energy Output","LHV*u1");
            Edges(4)  = gmt_Edge("Thermal Energy Output","cp_f*xt*u1");

            % Edge Matrix 
            EdgeMatrix = [2  1;...
                          3  1;...
                          1  4;...
                          1  5];
             
            % Define Default Model Parameterization 
            Parameters(1) = gmt_Parameter("Fluid Specific Heat","cp_f",3300,"Units","kJ/(kg*K)","Common",true);
            Parameters(2) = gmt_Parameter("Volume","V",0.002,"Units","m^3");
            Parameters(3) = gmt_Parameter("Fluid Density","Rho",1090,"Units","kg/(m^3)","Common",true);
            Parameters(4) = gmt_Parameter("Fuel Lower Heating Value","LHV",4.3e7,"Units","J/kg");

            % Model Input Array Tank Example
            Inputs(1) = gmt_Input("u1","Inlet Flow - 1","Units","unit/s");

            % Define Available Connection Ports
            Ports(1) = gmt_Port("EdgeConnection",1,"Chemical");
            Ports(2) = gmt_Port("EdgeConnection",2,"Thermal");
            Ports(3) = gmt_Port("EdgeConnection",3,"Chemical");
            Ports(4) = gmt_Port("EdgeConnection",4,"Thermal");

            % Creates Split Junction Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edges,Vertices,Parameters,Inputs,Ports,varargin{:});

        end
    end
end
