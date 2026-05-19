%% gmt_Component
% Template
% All component model classes must be prefixed with gbm_ followed by descriptive name

%% Class Defintion and Superclass Reference
classdef gmt_Component < gmt_Graph
    % Component subclasses must reference gmt_Graph superclass 

    %% Properties 
    % No properties are defined for component subclasses
    properties
    end

    methods
        %% Constructor Method
        % Create a constructor for component with the same name as the component subclass
        function obj = gmt_Component(ObjectName,varargin)

            % Define Vertex Object Array
            % Syntax gmt_Vertex("Enter Vertex Description (string)","Enter Capacitance Equation (string)")
            % Assign each vertex object to vertex array
            % Optional Input Arguments 
            % Defining External Vertex: Append gmt_Vertex with the following statement,"External",true) 
            % Adding State Variable Units: Append gmt_Vertex with the following statement ,"Units","Specify Units") 

            % Vertex Array Tank Example 
            %Vertex(1) = gmt_Vertex("Tank Fluid Temperature","cp_f*x2*x_dot","Units","K");
            %Vertex(2) = gmt_Vertex("Tank Mass","x_dot","Units","kg");
            %Vertex(3) = gmt_Vertex("Delta Tank Mass","x_dot","External",true,"Units","kg");
            %Vertex(4) = gmt_Vertex("Inlet Temperature","cp_f*Rho*V*x_dot","External",true,"Units","K");
            %Vertex(5) = gmt_Vertex("Outlet Temperature","cp_f*Rho*V*x_dot","External",true,"Units","K");
            %Vertex(6) = gmt_Vertex("Tank Energy Temperature","cp_f*Rho*V*x_dot","External",true,"Units","K");

            % Define Edge Object Array
            % Syntax gmt_Edge("Enter Edge Description (string)","Enter Edge Equation (string)")
            % Assign each edge object to edge array
            % Optional Input Arguments 
            % Defining External Edge: Append gmt_Edge with the following statement,"External",true) 

            % Edge Array Tank Example 
            %Edge(1) = gmt_Edge("Advection In","cp_f*u1*xt");
            %Edge(2) = gmt_Edge("Advection Out","cp_f*u2*xt");
            %Edge(3) = gmt_Edge("Tank Fill Rate","(u1-u2)");
            %Edge(4) = gmt_Edge("Advection Tank Fluid","cp_f*(u1-u2)*xt");

            % Define Edge Matrix
            % Syntax EdgeMatrix(Ne,2) = [(Tail Vertex Number) (Head Vertex Number); ...]
            % Ne is number of Edge 

            % Edge Matrix Tank Example
            %EdgeMatrix = [4 1; ...
            %              1 5; ...
            %              3 2; ...
            %              1 6];

            % Define Model Parameterization Array
            % Syntax gmt_Parameter("Enter Parameter Description (string)","Enter Parameter Variable (string)","Enter Parameter Data (numeric)")
            % Assign each parameter object to parameter array
            % Optional Input Arguments 
            % Defining External Vertex: Append gmt_Parameter with the following statement,"External",true) 
            % Adding Parmeter Variable Units: Append gmt_Parameter with the following statement ,"Units","Specify Units") 
            % Defining Parameter Common at System Level: Append gmt_Parameter with the following statement ,"Common",true)

            % Model Parameterization Array Tank Example
            % Parameter(1) = gmt_Parameter("Fluid Specific Heat","cp_f",3300,"Units","kJ/(kg*K)","Common",true);
            % Parameter(2) = gmt_Parameter("Fluid Density","Rho",1090,"Units","kg/(m^3)","Common",true);
            % Parameter(3) = gmt_Parameter("Volume","V",0.002,"Units","m^3");

            % Define Model Input Array
            % Syntax gmt_Input("Enter Input Variable (string)","Enter Input Description (string)")
            % Assign each input object to input array
            % Optional Input Arguments 
            % Adding Parmeter Variable Units: Append gmt_Input with the following statement ,"Units","Specify Units") 

            % Model Input Array Tank Example
            % Input(1) = gmt_Input("u1","Inlet Mass Flow 1","Units","kg/s");
            % Input(2) = gmt_Input("u2","Outlet Mass Flow 1","Units","kg/s");

            % Creates an Graph Object 
            % No need to change this part
            % obj@gmt_Graph(ObjectName,EdgeMatrix,Edge,Vertex,Parameter,Input,varargin{:});

            % Define Connection Port Array

            % Connection Port Array Tanke Example
            %obj.Ports(1) = gmt_Port(obj,"EdgeConnection",1,"Thermal");
            %obj.Ports(2) = gmt_Port(obj,"EdgeConnection",2,"Thermal");
            %obj.Ports(3) = gmt_Port(obj,"VertexConnection",4,"Thermal");
            %obj.Ports(4) = gmt_Port(obj,"VertexConnection",5,"Thermal");

        end
    end
end
