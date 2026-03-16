%% gmt_Port
% Class used for user defined graph model connections points.

%% Class Defintion
classdef gmt_Port
    
    properties
        PortType (1,1) gmt_PortType = gmt_PortType.EdgeConnection % Interconnection Types: Type 1 for edge connections and Type 2 for vertex connections
        ElementNumber (:,1) % Edge or Vertex Number
        EnergyDomain (1,1) gmt_EnergyDomain = gmt_EnergyDomain.Unassigned % Port Energy Domain
    end

    properties
        ParentName string  % Parent Object Name
        Description string  % Edge or Vertex Description
    end

    methods
        
        %% Constructor Method
        function obj = gmt_Port(PortType,ElementNumber,EnergyDomain)
            
            % Input Data Validation
            valid_PortType = any(strcmp(PortType,string(enumeration('gmt_PortType'))));
            valid_EnergyDomain = any(strcmp(EnergyDomain,string(enumeration('gmt_EnergyDomain'))));
            assert(valid_PortType,"Invalid Port Type Specified")
            assert(valid_EnergyDomain,"Invalid Energy Domain Specified")

            % Assign Properties 
            obj.PortType = gmt_PortType(PortType);
            obj.ElementNumber = ElementNumber;
            obj.EnergyDomain = gmt_EnergyDomain(EnergyDomain);

        end

        %% Parent Object Update and Validation
        function obj = gmt_ParentPort(obj,ParentObj)
           
            obj.ParentName = ParentObj.Name;
            
            if obj.PortType == gmt_PortType.EdgeConnection
                assert(obj.ElementNumber <= ParentObj.Properties.Ne, "Invalid element number specified")
            else
                assert(obj.ElementNumber <= ParentObj.Properties.Nv, "Invalid element number specified")
            end
            
            if obj.PortType == gmt_PortType.EdgeConnection
                obj.Description = ParentObj.Edges(obj.ElementNumber).EdgeName;
            else
                obj.Description = ParentObj.Vertices(obj.ElementNumber).VertexName;
            end

        end

    end
end


