classdef gmt_GraphValidity

    properties
        GraphValid logical % Logical to determine graph validality 
        EdgesValid logical % Logical to determine edge validality 
        VerticesValid logical % Logical to determine vertex validality
    end

    methods

        %% Constructor Method 
        function obj = gmt_GraphValidity(obj_in,obj_in2)
            obj.GraphValid = logical(obj_in2.Nv + 1 >= obj_in2.Ne);
            obj.VerticesValid = logical(obj_in2.Nv == length(obj_in.Vertices));
            obj.EdgesValid = logical(obj_in2.Ne == length(obj_in.Edges));
        end

    end

end