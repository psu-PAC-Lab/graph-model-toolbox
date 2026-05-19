%% gmt_Port
% gmt_Port  Class used to define graph-model connection ports.
%
% Documentation authored with assistance from OpenAI ChatGPT.
%
%   OBJ = gmt_Port(PortType, ElementNumber, EnergyDomain)
%   creates a graph connection-port object used to define component
%   interconnection locations within the gmt Toolbox framework.
%
%   gmt_Port objects define valid connection points between graph-based
%   components and systems. Ports may represent either edge-based or
%   vertex-based connections and are used during graph-model combination
%   and validation operations.
%
% Port Types
%   Ports may be configured as either:
%
%       gmt_PortType.EdgeConnection
%       gmt_PortType.VertexConnection
%
% Energy Domains
%   Energy-domain classifications must match the enumerations defined in:
%
%       gmt_EnergyDomain
%
%   Example domains may include:
%
%       Hydraulic
%       Electrical
%       Mechanical
%       Thermal
%
% Element Number Definition
%   ElementNumber corresponds to either:
%
%       - Edge number within a graph model
%       - Vertex number within a graph model
%
%   depending on the selected PortType.
%
% Constructor Inputs
%   PortType
%       String or enumeration specifying the port connection type.
%
%   ElementNumber
%       Numeric index corresponding to an edge or vertex within the parent
%       graph model.
%
%   EnergyDomain
%       String or enumeration specifying the port energy domain.
%
% User-Defined Properties
%   PortType
%       Connection classification:
%
%           gmt_PortType.EdgeConnection
%           gmt_PortType.VertexConnection
%
%   ElementNumber
%       Edge or vertex index associated with the connection port.
%
%   EnergyDomain
%       Energy-domain classification associated with the port.
%
% Auto-Generated Properties
%   ParentName
%       Name of the parent graph object associated with the port.
%
%   Description
%       Description of the associated edge or vertex object.
%
% Public Methods
%   gmt_ParentPort
%       Associates the port with a parent graph object and validates the
%       specified element number against the graph dimensions.
%
%       obj = obj.gmt_ParentPort(ParentObj)
%
%       This method:
%           - Assigns the parent-object name
%           - Validates edge or vertex indices
%           - Updates the port description using the associated edge or
%             vertex name
%
% Notes
%   - EdgeConnection ports reference graph edges.
%
%   - VertexConnection ports reference graph vertices.
%
%   - Port energy domains must match when combining graph models using
%     gmt_Graph.gmt_Combine.
%
%   - Port validation occurs automatically during parent-object assignment.
%
% Example
%   % Edge connection port
%   P1 = gmt_Port( ...
%       "EdgeConnection", ...
%       1, ...
%       "Hydraulic");
%
%   % Vertex connection port
%   P2 = gmt_Port( ...
%       "VertexConnection", ...
%       2, ...
%       "Electrical");
%
% See also gmt_Graph, gmt_Edge, gmt_Vertex, gmt_PortType,
%          gmt_EnergyDomain

%% Class Defintion
classdef gmt_Port
    
    properties
        PortType (1,1) gmtEnumE.gmt_PortType = gmtEnumE.gmt_PortType.EdgeConnection % Interconnection Types: Type 1 for edge connections and Type 2 for vertex connections
        ElementNumber (:,1) % Edge or Vertex Number
        EnergyDomain (1,1) gmtEnumA.gmt_EnergyDomain = gmtEnumA.gmt_EnergyDomain.Unassigned % Port Energy Domain
    end

    properties
        ParentName string  % Parent Object Name
        Description string  % Edge or Vertex Description
    end

    methods
        
        %% Constructor Method
        function obj = gmt_Port(PortType,ElementNumber,EnergyDomain)
            
            % Input Data Validation
            valid_PortType = any(strcmp(PortType,string(enumeration('gmtEnumE.gmt_PortType'))));
            valid_EnergyDomain = any(strcmp(EnergyDomain,string(enumeration('gmtEnumA.gmt_EnergyDomain'))));
            assert(valid_PortType,"Invalid Port Type Specified")
            assert(valid_EnergyDomain,"Invalid Energy Domain Specified")

            % Assign Properties 
            obj.PortType = gmtEnumE.gmt_PortType(PortType);
            obj.ElementNumber = ElementNumber;
            obj.EnergyDomain = gmtEnumA.gmt_EnergyDomain(EnergyDomain);

        end

        %% Parent Object Update and Validation
        function obj = gmt_ParentPort(obj,ParentObj)
           
            obj.ParentName = ParentObj.Name;
            
            if obj.PortType == gmtEnumE.gmt_PortType.EdgeConnection
                assert(obj.ElementNumber <= ParentObj.Properties.Ne, "Invalid element number specified")
            else
                assert(obj.ElementNumber <= ParentObj.Properties.Nv, "Invalid element number specified")
            end
            
            if obj.PortType == gmtEnumE.gmt_PortType.EdgeConnection
                obj.Description = ParentObj.Edges(obj.ElementNumber).EdgeName;
            else
                obj.Description = ParentObj.Vertices(obj.ElementNumber).VertexName;
            end

        end

    end
end


