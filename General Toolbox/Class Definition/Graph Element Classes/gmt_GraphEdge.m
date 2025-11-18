%% gmt_GraphEdge
% Class used to define edge properties in graph model
classdef gmt_GraphEdge

properties
    Name string % User specified name to define an edge object
    Eq string % User specified formula defining the edge equation 

end

properties (SetAccess = protected)
    EdgeType string = gmt_EdgeType.Unassigned % Internally specified enumeration to determine exogeny of edge
end

methods

    %% Constructor Method
    function obj = gmt_GraphEdge(Name,Equation)
        % Generates instance of gmt_GraphEdge object
        Name_data_valid = isa(Name,'string');
        Equation_data_valid = isa(Equation,'string');

        % Determine if name input is empty
        if Name_data_valid
            Name_blank = logical(strlength(Name)==0);
            if Name_blank 
                error("Name field is empty")
            end
        else
            error("Name field data type is not a string")
        end

        % Determine if CapEquation input is empty
        if Equation_data_valid
            Equation_blank = logical(strlength(Equation)==0);
            if Equation_blank
                error("Equation field is empty")
            end
        else 
            error("Equation field data type is not a string")
        end

        obj.Name = Name; % Assigns input variable Name to Edge_Name property 
        obj.Eq = Equation; % Assigns input variable Equation to Edge_Eq property 

        if (contains(Equation,"xt") == true || contains(Equation,"xh") == true)
            obj.EdgeType = gmt_EdgeType.Internal;
        else
            obj.EdgeType = gmt_EdgeType.External;
        end

    end

end

end