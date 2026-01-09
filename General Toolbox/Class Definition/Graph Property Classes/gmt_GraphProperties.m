classdef gmt_GraphProperties 

    properties
        M double % Incident Matrix 
        Nv double % Number of vertices 
        Ne double % Number of edges
        % NvB double % Number of Boundary Vertices, Obsolete 
        Ns double % Number of States
        NsD double % Number of dynamic states
        NsA double % Number of algebraic states
        GraphValidity % object of graph validity logical statements 
    end

    methods

        %% Constructor Method 
        function [obj] = gmt_GraphProperties(obj_in)

            % Compute Graph Size
            obj.Ne = length(obj_in.EdgeMatrix); 
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

            % Compute Graph Validity 
            obj.GraphValidity = gmt_GraphValidity(obj_in,obj);

        end

    end

end
