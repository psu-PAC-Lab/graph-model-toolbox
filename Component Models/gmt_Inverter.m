%% gmt_Inverter
% Defines a inverter model 

%% Class Defintion and Superclass Reference
classdef gmt_Inverter < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_Inverter(ObjectName)

            % Define Hardcoded Coefficients

            % Define User Define Values 

            % If User Defines UserDefined Populated Grab Values
            % Pick Battery Type and Grab
           
            % Else Use Default Parmeters 

            % C2 = interp2(x,y,z,Tbatt(o),Soc(o))

            % Define Vertices 
            Vertices(1) = gmt_Vertex("Input Voltage","x","External");
            Vertices(2) = gmt_Vertex("Output Voltage","x");
            Vertices(3) = gmt_Vertex("Input Current","x","External");
            Vertices(4) = gmt_Vertex("Output Current","x");
            Vertices(5) = gmt_Vertex("Inverter Temperature","Cp*x_dot");

            % Define Edges 
            Edges(1) = gmt_Edge("Voltage Input to Voltage Output","sqrt(3/2)*xt*u1");
            Edges(2) = gmt_Edge("Current Input to Voltage Output","Rm*xh*u1");
            Edges(3) = gmt_Edge("Current Input to Current Output","sqrt(3/2)*xt*u1");
            Edges(4) = gmt_Edge("Electrical to Thermal","xt*xt");

            % Define Edge Matrix
            EdgeMatrix = [1  2; ...
                          3  2; ...
                          3  4; ...
                          4  5];

            % Creates an Battery Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edges,Vertices);

            % Define Available Connection Ports 
            % obj.ConnectionPorts(1) = gmt_ConnectionPort(obj,"VertexConnection",1,"Electrical");
            % obj.ConnectionPorts(2) = gmt_ConnectionPort(obj,"VertexConnection",2,"Electrical");

        end
    end
end
