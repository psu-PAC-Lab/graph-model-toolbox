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

            Vertex(1) = gmt_Vertex("Junction Fluid Temperature","cp_f*V*Rho*x_dot");
            
            % Define Vertices 
            for i = 1:n_in
                VertexName_tmp = 'Inlet_' + string(i);
                Vertex(i+1) = gmt_Vertex(VertexName_tmp,"cp_f*V*Rho*x_dot","External",true);
            end

            for i = n_in+1:n_in+n_out
                VertexName_tmp = 'Outlet_' + string(i);
                Vertex(i+1) = gmt_Vertex(VertexName_tmp,"cp_f*V*Rho*x_dot","External",true);
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
                Edge(i) = gmt_Edge(EdgeName_tmp,EdgeEq_tmp);
                Input(i) = gmt_Input(Input_tmp,InputName_tmp,"Units","kg/s");
            end
     
            % Define Edge Matrix
            EdgeMatrix = [[(2:n_in+1)',ones(n_in,1)]; ...
                                [ones(n_out,1),(n_in+2:n_in+n_out+1)']];
             
            % Define Default Model Parameterization 
            Parameter(1) = gmt_Parameter("Fluid Specific Heat","cp_f",3300,"Units","kJ/(kg*K)","Common",true);
            Parameter(2) = gmt_Parameter("Volume","V",0.002,"Units","m^3");
            Parameter(3) = gmt_Parameter("Fluid Density","Rho",1090,"Units","kg/(m^3)","Common",true);

            % Define Available Connection Ports
            for i = 1:length(Edge)
                Port(i) = gmt_Port("EdgeConnection",i,"Thermal");
            end

            % Creates Split Junction Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,Input,Port,varargin{:});

        end
    end
end
