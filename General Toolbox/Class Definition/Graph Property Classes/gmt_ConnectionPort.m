%% gmt_ConnectionPort
% Class used for user defined graph model connections points. Simplifies component connections 
% 01/05/2025 add intelligence to avoid duplicate connection ports 

%% Class Defintion
classdef gmt_ConnectionPort
    
    properties (SetAccess = protected)
        PortType (1,1) gmt_PortType = gmt_PortType.EdgeConnection % Interconnection Types: Type 1 for edge connections and Type 2 for vertex connections
        ElementNumber (:,1) % Stores the edge or vertex number for connection 
        EnergyDomain (1,1) gmt_EnergyDomain = gmt_EnergyDomain.Unassigned % Port Energy Domain
    end

    properties
        Description (1,1) string  % User defined description of connection type 
    end

    methods
        
        %% Constructor Method
        function obj = gmt_ConnectionPort(ParentObj,PortType,ElementNumber,EnergyDomain,varagin)
            
            % Check Parent Object is Graph Class
            superclass_tmp = superclasses(ParentObj);
            if strcmp(superclass_tmp,'gmt_Graph') == false
                error("Parent object is not graph class object")
            end

            % Input Validity Checks
            if ElementNumber <= 0 
                error("Element number must be positive number")
            end

            % Matches PortType Enumerations 
            if strcmpi(PortType,gmt_PortType.EdgeConnection)
                obj.PortType = gmt_PortType.EdgeConnection;
            elseif strcmpi(PortType,gmt_PortType.VertexConnection)
                obj.PortType = gmt_PortType.VertexConnection;
            else
                error("Specified PortType does not enumerations of gmt_PortType, check spelling, note case-insenstitive.")
            end

            % Matches EnergyDomain Enumerations 
            enum_tmp = enumeration('gmt_EnergyDomain');
            match_tmp = strcmpi(enum_tmp,EnergyDomain);
            if sum(match_tmp) == 0 
                error("Specified EnergyDomain does not match enumerations of gmt_EnergyDomain, check spelling, note case-insenstitive.")
            elseif sum(match_tmp) == 1
                obj.EnergyDomain = enum_tmp(match_tmp == 1);
            else 
                error("More than one EnergyDomain specified, check number of EnergyDomains specified")
            end

            if obj.PortType == gmt_PortType.EdgeConnection && ElementNumber <= ParentObj.Properties.Ne 
                obj.ElementNumber = ElementNumber;
            elseif obj.PortType == gmt_PortType.VertexConnection && ElementNumber <= ParentObj.Properties.Nv 
                obj.ElementNumber = ElementNumber;
            else
                error("Specified ElementNumber not within upper range of Ne or Nv, check connection type and coorsesponding parent Nv or Ne value.")
            end
               
           % If varagin input argument assigned, add as description if more than one assigned return error  
           if nargin == 5 && isa(varagin{5},'string')
               obj.Description = varagin{5};
           elseif nargin == 5
               error("Optional description input argument data is not string, check specified data type")
           elseif nargin > 5
               error("Number of variable input arguments exceed allowable length of one. Check number of variable input arguments.")
           end
        end
    end
end


