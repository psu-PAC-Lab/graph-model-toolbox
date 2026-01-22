%% gmt_SplitJunction
% Defines a Split Junction

%% Class Defintion and Superclass Reference
classdef gmt_SplitJunction < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_SplitJunction(ObjectName,n_in,n_out)

            Vertices(1) = gmt_Vertex("Junction Fluid Temperature","cp_f*x_dot");
            
            % Define Vertices 
            for i = 1:n_in
                VertexName_tmp = 'Inlet_' + string(i);
                Vertices(i+1) = gmt_Vertex(VertexName_tmp,"1","External");
            end

            for i = n_in+1:n_in+n_out
                VertexName_tmp = 'Outlet_' + string(i);
                Vertices(i+1) = gmt_Vertex(VertexName_tmp,"1","External");
            end

            % Define Edges
            for i = 1:(n_in+n_out)
                if i <= n_in
                    EdgeName_tmp = 'Inflow_' + string(i);
                else
                    EdgeName_tmp = 'Outflow_' + string(i);
                end
                EdgeEq_tmp = "u" + string(i) + "*xt";
                Edges(i) = gmt_Edge(EdgeName_tmp,EdgeEq_tmp);
            end
     
            % Define Edge Matrix
            EdgeMatrix = [[(2:n_in+1)',ones(n_in,1)]; ...
                                [ones(n_out,1),(n_in+2:n_in+n_out+1)']];
             
            % Define Default Model Parameterization 
            Param(1) = gmt_ModelParameter("Fluid Specific Heat","cp_f",1,[]);

            % Creates an Motor Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edges,Vertices,Param,"Component");

            % Define Available Connection Ports
            for i = 1:length(Edges)
                obj.Ports(i) = gmt_ConnectionPort(obj,"EdgeConnection",i,"Thermal");
            end

        end
    end
end
