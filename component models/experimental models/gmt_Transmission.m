%% gmt_Transmission
% Defines a variable speed transmission model

%% Class Defintion and Superclass Reference
classdef gmt_Transmission < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_Transmission(ObjectName,varargin)

            % Define Vertex 
            % We want to be able to specify vertex equation with any other state if required
            % Curreng algorithm does allow this to be achieved, see below
            Vertex(1) = gmt_Vertex("Input Shaft Angular Velocity","J1*x*x_dot","Units","rad/s");
            Vertex(2) = gmt_Vertex("Output Shaft Angular Velocity","J2*x*x_dot","Units","rad/s");
            Vertex(3) = gmt_Vertex("Transmission Fluid Temperature","Ct*x_dot","Units","K");

            % Define Edge 
            Edge(1) = gmt_Edge("Input Shaft Friction","b*xt+c");
            Edge(2) = gmt_Edge("Output Shaft Friction","b*xt+c");
            Edge(3) = gmt_Edge("Internal Power Transfer","-(u1*(xh - xt/u2))/xt");

            % Define Edge Matrix
            EdgeMatrix = [1 3; ...
                          2 3; ...
                          1 2];

            % Input Parsing
            n = size(Vertex,2);
            p = inputParser;
            p.KeepUnmatched = true;
            addParameter(p, 'Parameter', [], @(s) isa(s,'gmt_Parameter'))
            parse(p, varargin{:});

            % Define Default Model Parameterization 
            Parameter(1) = gmt_Parameter("Input Shaft Inertia","J1",25,"Units","kg/m^2");
            Parameter(2) = gmt_Parameter("Output Shaft Inertia","J2",25,"Units","kg/m^2");
            Parameter(3) = gmt_Parameter("Shaft Friction Coefficient (b)","b",0.002);
            Parameter(4) = gmt_Parameter("Shaft Friction Coefficient (c)","c",0.0000000002);
            Parameter(5) = gmt_Parameter("Transmission Thermal Capacitance","Ct",15000);

            % Update Parameterization 
            if ~isempty(p.Results.Parameter)
                for i = 1:length(p.Results.Parameter)
                    for j = 1:length(Parameter)
                        if Parameter(j).Variable == p.Results.Parameter(i).Variable 
                            Parameter(j) = p.Results.Parameter(i);
                            break
                        end
                    end
                end
            end

            % Define Input Labeling 
            Input(1) = gmt_Input("u1","Input Shaft Power");
            Input(2) = gmt_Input("u2","Gear Ratio");

            % Define Available Connection Ports
            Port(1) = gmt_Port("VertexConnection",1,"Mechanical");
            Port(2) = gmt_Port("VertexConnection",2,"Mechanical");

            % Creates Transmission Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,Input,Port,varargin{:});

        end
    end
end
