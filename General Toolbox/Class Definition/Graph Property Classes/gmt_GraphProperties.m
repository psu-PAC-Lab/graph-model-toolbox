classdef gmt_GraphProperties 

    properties
        M double % Incident Matrix 
        L double % Oriented Laplacian Matrix 
        Lev double % Oriented Laplacian Eigenvalues
        Nc double % Number of independent graphs 
        Nv double % Number of vertices 
        Ne double % Number of edges
        Ns double % Number of States
        NvD double % Number of dynamic states
        NvD_idx double % Vertex indicies cooresponding to dynamic states 
        NsA double % Number of algebraic states
        NumComponents double % Number of unconnected graphs 
        GraphValidity % object of graph validity logical statements 
    end

    methods

        %% Constructor Method 
        function [obj] = gmt_GraphProperties(obj_in)

            % Compute Graph Size
            obj.Ne = length(obj_in.EdgeMatrix); 
            obj.Nv = max(obj_in.EdgeMatrix(:));
            vertexInt_idx = find([obj_in.Vertices.VertexType] == gmt_VertexType.Internal);
            vertexDyn_idx = find([obj_in.Vertices.StateType] == gmt_StateType.Dynamic);
            vertexIntDyn_idx = intersect(vertexInt_idx,vertexDyn_idx);
            obj.NvD_idx = vertexIntDyn_idx;
            obj.NvD = length(vertexIntDyn_idx);

            % Compute Incident Matrix 
            tmp = zeros(obj.Nv,obj.Ne);
            for i = 1:obj.Ne
                for j = 1:obj.Nv
                    if obj_in.EdgeMatrix(i,1) == j
                        tmp(j,i) = -1;
                    elseif obj_in.EdgeMatrix(i,2) == j
                        tmp(j,i) = 1;
                    end
                end
    
            end

            % Update Incidence Matrix 
            obj.M = tmp;

            % Update Laplacian Matrix
            obj.L = tmp*tmp';

            % Update Independent Graph Count
            obj.Nc = size(obj.L,1) - rank(obj.L);

            % Laplacian Eigenvalues 
            obj.Lev = eig(obj.L);

            % Number Components
            obj.NumComponents =rank(obj.L) - obj.Nv;

            % Compute Graph Validity 
            obj.GraphValidity = gmt_GraphValidity(obj_in,obj);

        end

    end

end
