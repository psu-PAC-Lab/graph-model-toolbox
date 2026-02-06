%% gmt_SplitJunction
% Defines a Split Junction

%% Class Defintion and Superclass Reference
classdef gmt_SplitJunction2 < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_SplitJunction2(ObjectName,varargin)

            Vertices(1) = gmt_Vertex("Junction Fluid Temperature","cp_f*V*Rho*x_dot");
            Vertices(2) = gmt_Vertex("Inlet 1","cp_f*V*Rho*x_dot","External");
            Vertices(3) = gmt_Vertex("Outlet 1","cp_f*V*Rho*x_dot","External");
            Vertices(4) = gmt_Vertex("Outlet 2","cp_f*V*Rho*x_dot","External");

            Edges(1) = gmt_Edge("Inlet Flow","u1*cp_f*xt");
            Edges(2) = gmt_Edge("Outlet Flow 1","u2*cp_f*xt");
            Edges(3) = gmt_Edge("Outlet Flow 2","(u1-u2)*cp_f*xt");

            % Define Edge Matrix
            EdgeMatrix = [2 1; ...
                          1 3; ...
                          1 4];

            % Define Default Model Parameterization 
            Parameters(1) = gmt_ModelParameter("Fluid Specific Heat","cp_f",3300,"Units","kJ/(kg*K)","Common",true);
            Parameters(2) = gmt_ModelParameter("Volume","V",0.002);
            Parameters(3) = gmt_ModelParameter("Fluid Density","Rho",1090,"Units","kg/(m^3)","Common",true);

            % Define Input Labeling 
            Inputs(1) = gmt_Input("u1","Inlet Mass Flow 1","Units","kg/(m^3)");
            Inputs(2) = gmt_Input("u2","Outlet Mass Flow 1","Units","kg/(m^3)");

            % Creates an Motor Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edges,Vertices,Parameters,Inputs,varargin{:})

            % Define Available Connection Ports
            for i = 1:length(Edges)
                obj.Ports(i) = gmt_ConnectionPort(obj,"EdgeConnection",i,"Thermal");
            end

        end
    end
end
