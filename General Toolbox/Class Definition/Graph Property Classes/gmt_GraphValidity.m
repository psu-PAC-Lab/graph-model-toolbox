classdef gmt_GraphValidity

    properties
        EdgesValid logical % Logical to determine edge validality 
        VerticesValid logical % Logical to determine vertex validality
        IncidenceValid logical % Logical to determine incidence matrix validality 
    end

    methods

        %% Constructor Method 
        function obj = gmt_GraphValidity(obj_in,obj_in2)
            obj.VerticesValid = logical(obj_in2.Nv == length(obj_in.Vertices));
            obj.EdgesValid = logical(obj_in2.Ne == length(obj_in.Edges));
            obj.IncidenceValid = all(logical(obj_in2.Ne == size(obj_in2.M,2)),logical(obj_in2.Nv == size(obj_in2.M,1)));
        end

    end

end