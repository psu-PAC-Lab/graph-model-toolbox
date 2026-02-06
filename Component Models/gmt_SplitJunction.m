%% gmt_SplitJunction
% Defines a Split Junction

%% Class Defintion and Superclass Reference
classdef gmt_SplitJunction < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_SplitJunction(ObjectName,n_in,n_out,varargin)

            Vertices(1) = gmt_Vertex("Junction Fluid Temperature","cp_f*V*Rho*x_dot");
            
            % Define Vertices 
            for i = 1:n_in
                VertexName_tmp = 'Inlet_' + string(i);
                Vertices(i+1) = gmt_Vertex(VertexName_tmp,"cp_f*V*Rho*x_dot","External");
            end

            for i = n_in+1:n_in+n_out
                VertexName_tmp = 'Outlet_' + string(i);
                Vertices(i+1) = gmt_Vertex(VertexName_tmp,"cp_f*V*Rho*x_dot","External");
            end

            % Define Edges and Inputs
            for i = 1:(n_in+n_out)
                if i <= n_in
                    EdgeName_tmp = 'Inflow_' + string(i);
                    InputName_tmp = "Inlet Mass Flow " + string(i);
                else
                    EdgeName_tmp = 'Outflow_' + string(i-n_in);
                    InputName_tmp = "Outlet Mass Flow " + string(i-n_in);
                end
                Input_tmp = "u" + string(i);
                EdgeEq_tmp = "u" + string(i) + "*cp_f*xt";
                Edges(i) = gmt_Edge(EdgeName_tmp,EdgeEq_tmp);
                Inputs(i) = gmt_Input(Input_tmp,InputName_tmp,"Units","kg/s");
            end
     
            % Define Edge Matrix
            EdgeMatrix = [[(2:n_in+1)',ones(n_in,1)]; ...
                                [ones(n_out,1),(n_in+2:n_in+n_out+1)']];
             
            % Define Default Model Parameterization 
            Parameters(1) = gmt_ModelParameter("Fluid Specific Heat","cp_f",3300,"Units","kJ/(kg*K)","Common",true);
            Parameters(2) = gmt_ModelParameter("Volume","V",0.002,"Units","m^3");
            Parameters(3) = gmt_ModelParameter("Fluid Density","Rho",1090,"Units","kg/(m^3)","Common",true);

            % Creates an Motor Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edges,Vertices,Parameters,Inputs,varargin{:})

            % Define Available Connection Ports
            for i = 1:length(Edges)
                obj.Ports(i) = gmt_ConnectionPort(obj,"EdgeConnection",i,"Thermal");
            end

        end
    end
end
