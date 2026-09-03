%% gmt_Tank
% Defines a Fluid Tank

%% Class Defintion and Superclass Reference
classdef gmt_Tank < gmt_Graph

    %% Properties 
    properties
    end

    methods
        %% Constructor Method
        function obj = gmt_Tank(ObjectName,varargin)

            % class superclass parsing function 
            params = gmt_Battery.gmt_parseClass(varargin{:});

            % Define Vertex Object Array
            Vertex(1) = gmt_Vertex("Temperature","cp_f*x2*x_dot","Units","K");
            Vertex(2) = gmt_Vertex("Mass","x_dot","Units","kg");
            Vertex(3) = gmt_Vertex("Mass Conservation","x","External",true,"Units","kg");
            Vertex(4) = gmt_Vertex("Source Temperature","x","External",true,"Units","K");
            Vertex(5) = gmt_Vertex("Sink Temperature","x","External",true,"Units","K");
            Vertex(6) = gmt_Vertex("Internal Sink Temperature","x","External",true,"Units","K");

            % Define Edge Object Array
            Edge(1) = gmt_Edge("Advection In","cp_f*u1*xt");
            Edge(2) = gmt_Edge("Advection Out","cp_f*u2*xt");
            Edge(3) = gmt_Edge("Tank Fill Rate","(u1-u2)");
            Edge(4) = gmt_Edge("Advection Tank Fluid","cp_f*(u1-u2)*xt");

            % Define Edge Matrix
            EdgeMatrix = [4, 1; ...
                          1, 5; ...
                          3, 2; ...
                          1, 6];

           % Define Parameter Object Array
            Parameter(1) = gmt_Parameter("Fluid Specific Heat","cp_f",3300,"Units","J/(kg*K)","Common",true);

            % Define Input Object Array 
            Input(1) = gmt_Input("u1","Inlet Mass Flow 1","Units","kg/s");
            Input(2) = gmt_Input("u2","Outlet Mass Flow 1","Units","kg/s");

            % Define Connection Port Object Array 
            Port(1) = gmt_Port("EdgeConnection",1,"Thermal");
            Port(2) = gmt_Port("EdgeConnection",2,"Thermal");

            % Define Exergy Class
            % add variable input arguments 
            % if output.ExergyFlg 
            %     Exergy = gmt_Exergy("x1");
            %     Parameter(2) = gmt_Parameter("Exergy Reference Temperature","T0",300,"Units","K","Common",true,"Optimization",true);
            % else 
            %     % Exergy = [];
            % end

            % concatcente varagin with exergy 

            % Creates Tank Object 
            obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,Input,Port,varargin{:});

        end
    end

    methods (Static)

        %% Variable Input Argument Data Parsing 
        function output = gmt_parseClass(varargin)

            % Variable Input Parsing 
            p = inputParser;
            p.KeepUnmatched = true;
            addParameter(p, 'ExergyFlg',false, @(x) islogical(x));
            parse(p, varargin{:});
            output = p.Results;

        end
    end
end
