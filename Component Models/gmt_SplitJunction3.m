%% gmt_SplitJunction
% Defines a Split Junction

%% Class Defintion and Superclass Reference
classdef gmt_SplitJunction3 < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_SplitJunction3(ObjectName,varargin)

            Vertices(1) = gmt_Vertex("Junction Fluid Temperature","cp_f*V*Rho*x_dot");
            Vertices(2) = gmt_Vertex("Inlet 1","1","External");
            Vertices(3) = gmt_Vertex("Inlet 2","1","External");
            Vertices(4) = gmt_Vertex("Outlet 1","1","External");

            Edges(1) = gmt_Edge("Inlet Flow 1","u1*cp_f*xt");
            Edges(2) = gmt_Edge("Inlet Flow 2","u2*cp_f*xt");
            Edges(3) = gmt_Edge("Outlet Flow","(u1+u2)*cp_f*xt");

            % Define Edge Matrix
            EdgeMatrix = [2 1; ...
                          3 1; ...
                          1 4];

            % Define Default Model Parameterization 
            Param(1) = gmt_ModelParameter("Fluid Specific Heat","cp_f",3300,[]);
            Param(2) = gmt_ModelParameter("Volume","V",0.002,[]);
            Param(3) = gmt_ModelParameter("Fluid Density","Rho",1090,[]);

            % Creates an Motor Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edges,Vertices,Param,varargin{:})

            % Define Available Connection Ports
            for i = 1:length(Edges)
                obj.Ports(i) = gmt_ConnectionPort(obj,"EdgeConnection",i,"Thermal");
            end

        end
    end
end
