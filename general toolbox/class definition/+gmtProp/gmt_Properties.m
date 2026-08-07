classdef gmt_Properties 

    properties 
        M  double % Incident Matrix 
        Nv double % Number of vertices 
        Ne double % Number of edges
        Ns double % Number of states
        Ns_idx double % State indicies
        Nu double % Number of inputs
        Nd double % Number of disturbances
        Nd_idx double % Disturbance indicies
        Ny double % Number of outputs
        L double % Oriented Laplacian Matrix 
        Lev double % Oriented Laplacian Eigenvalues
        %NvD double % Number of dynamic states
        %NsA double % Number of algebraic states
        Nc double % Number of independent graphs
        NumComponents double % Number of unconnected graphs 
        GraphValidity % object of graph validity logical statements 
    end

    methods (Hidden)

        %% Constructor Method 
        function [obj] = gmt_Properties(obj_in)

            % Compute Graph Size
            obj.Ne = size(obj_in.EdgeMatrix,1); 
            obj.Nv = max(obj_in.EdgeMatrix(:));

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
            obj.GraphValidity = gmtProp.gmt_GraphValidity(obj_in,obj);
        end

        %% Number of Inputs
        function [obj] = gmt_PropertiesNu(obj,Nu)
            obj.Nu = Nu;
        end

        %% Number of States
        function [obj] = gmt_PropertiesNs(obj,Ns,Ns_idx)
            obj.Ns = Ns;
            obj.Ns_idx = Ns_idx;
        end

        %% Number of Disturbances
        function [obj] = gmt_PropertiesNd(obj,Nd,Nd_idx)
            obj.Nd = Nd;
            obj.Nd_idx = Nd_idx;
        end
    end
end
