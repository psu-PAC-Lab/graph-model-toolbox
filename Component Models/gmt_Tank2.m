%% gmt_Tank
% Defines a Fluid Tank

%% Class Defintion and Superclass Reference
classdef gmt_Tank2 < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_Tank2(ObjectName,varargin)

            % Define Vertices 
            % We want to be able to specify vertex equation with any other state if required
            % Curreng algorithm does not allow this to be achieved 
            Vertices(1) = gmt_Vertex("Liquid Temperature","cp_f*x2*x_dot");
            Vertices(2) = gmt_Vertex("Tank Mass","x_dot");
            Vertices(3) = gmt_Vertex("Tank Fill Inlet","1");
            Vertices(4) = gmt_Vertex("Inlet Temperature","cp_f*V*Rho*x_dot","External");
            Vertices(5) = gmt_Vertex("Outlet Temperature","cp_f*V*Rho*x_dot","External");

            % Define Edges 
            Edges(1) = gmt_Edge("Advection In","cp_f*u1*xh");
            Edges(2) = gmt_Edge("Advection Out","cp_f*u1*xt");
            Edges(3) = gmt_Edge("Tank Fill Rate","(-u1)");

            % Define Edge Matrix
            EdgeMatrix = [4 1; ...
                          1 5; ...
                          3 2];

            % Define Default Model Parameterization 
            Param(1) = gmt_ModelParameter("Fluid Specific Heat","cp_f",3300,[]);
            Param(2) = gmt_ModelParameter("Volume","V",0.002,[]);
            Param(3) = gmt_ModelParameter("Fluid Density","Rho",1090,[]);

            % Creates an Motor Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edges,Vertices,Param,varargin{:});

            % Define Available Connection Ports
            obj.Ports(1) = gmt_ConnectionPort(obj,"EdgeConnection",1,"Thermal");
            obj.Ports(2) = gmt_ConnectionPort(obj,"EdgeConnection",2,"Thermal");
            obj.Ports(3) = gmt_ConnectionPort(obj,"VertexConnection",4,"Thermal");
            obj.Ports(4) = gmt_ConnectionPort(obj,"VertexConnection",5,"Thermal");

        end
    end
end
