%% gmt_Graph
% Superclass used to create any type of graph model (Component or System)

classdef gmt_Graph
    properties (SetAccess = public)
        % User Define Meta Data
        Name string % Name of the graph model
        EdgeMatrix double % An edge matrix defining connections between edges and vertices
        Edges gmt_Edge % A vector of edge objects
        Vertices gmt_Vertex % A vector of vertex objects
        Properties gmt_GraphProperties % Object containing overall graph properties
        DiGraph % MATLAB native directed graph object
        Inputs string = [] % String array of system input variable names
        InputData gmt_Input % Input objects to replace inputs in future
        States string % String array of system state variable names
        Outputs string = [] % String array of system output variable names
        %Disturbances string = [] % String array of system disturbance variable names
        ModelParameters gmt_Parameter % Model parameters object to manage model parameterization  
        SystemEquations = struct("FunctionInputs",[],"LHS",[],"RHS",[],"Expression",[])  % System of equations with parameterization 
        SystemEquationsSubs = struct("FunctionInputs",[],"LHS",[],"RHS",[],"Expression",[])  % System of equations with parameterization with variable substitution  
        InitialConditions double 
        ModelMetadata = struct("ModelType",[],"FunctionName",[],"MfileCode",[],"MassMatrix",[]) 
        Ports gmt_Port % Object containing graph model connection points
    end

    %% Public Methods 
    methods (Access = public)
        %% Constructor Graph 
        function obj = gmt_Graph(ObjectName,EdgeMatrix,EdgeArray,VertexArray,ParameterArray,InputArray,PortArray,varargin)
            
            % Assign Data
            obj.Name = ObjectName;
            obj.EdgeMatrix = EdgeMatrix;
            obj.Edges = EdgeArray;
            obj.Vertices = VertexArray;

            % Compute Basic Graph Properties (Nv, Ne, and M) 
            obj.Properties = gmt_GraphProperties(obj);

            % Variable Input Parsing 
            params = gmt_Graph.gmt_parseSuperclass(obj,varargin{:});
            componentMdl = ~params.SystemModel;

            % Assign Parameter Array
            if ~isempty(ParameterArray)
                % Update User Specified Data
                if ~isempty(params.ModelParameters)
                    default_vars = [ParameterArray.Variable]';
                    user_vars = [params.ModelParameters.Variable]';
                    vars_diff = setdiff(default_vars,user_vars);
                    assert(isempty(vars_diff),"user has not specified all variables for user defined parameterization")
                    obj.ModelParameters = params.ModelParameters;
                else
                    obj.ModelParameters = ParameterArray;
                end

                % Update Model Parameter Name
                if componentMdl 
                    for i = 1:length(obj.ModelParameters)
                        if ~obj.ModelParameters(i).Common
                            obj.ModelParameters(i) = obj.ModelParameters(i).gmt_ModelParameterParent(obj.Name);
                        else
                            obj.ModelParameters(i) = obj.ModelParameters(i).gmt_ModelParameterParent("System");
                        end
                    end
                end
            end
            
            % Assign Input Array 
            % Possibly set this up for varargin 
            if ~isempty(InputArray) 
                obj.InputData = InputArray;
                if ~params.SystemModel
                    for i = 1:length(obj.InputData)
                        obj.InputData(i) = obj.InputData(i).gmt_InputParent(obj);
                    end
                end
            end

            % Assign Port Array
            % Possibly set this up for varargin
            if ~isempty(PortArray)
                for i = 1:length(PortArray)
                obj.Ports(i) = PortArray(i).gmt_ParentPort(obj);
                end
            end

            % DiGraph Update
            obj = gmt_DiGraphUpdate(obj);

            % Build Model
            obj = gmt_ModelUpdate(obj,varargin{:});
        end

        %% Model Linearization
        % Generates linear model based on first order Taylor series approximation 
        function [A, B, Z] = gmt_ControlModel(obj,varargin)
            
            % Input Parsing 
            p = inputParser;
            p.KeepUnmatched = true;
            addParameter(p, 'Simplify',false, @(x) islogical(x) && isscalar(x));
            addParameter(p, 'NumSub',false, @(x) islogical(x) && isscalar(x));
            addParameter(p, 'Discrete',[], @(x) isnumeric(x) && isscalar(x));
            parse(p, varargin{:});

            % Create Symbolic System of Equations
            if p.Results.NumSub
                assert(obj.ModelMetadata.ModelType == gmt_ModelType.Analytical,"Numerical substition on available for analytical models")
                SysEqn = symfun(obj.SystemEquationsSubs.RHS,sym([obj.States,obj.Inputs]));
            else
                SysEqn = symfun(obj.SystemEquations.RHS,sym([obj.States,obj.Inputs]));
            end

            if p.Results.Simplify 
                A = simplify(jacobian(SysEqn,[sym([obj.States])]));
                B = simplify(jacobian(SysEqn,[sym([obj.Inputs])]));
            else
                A = jacobian(SysEqn,[sym([obj.States])]);
                B = jacobian(SysEqn,[sym([obj.Inputs])]);
            end

            if ~isempty([obj.Inputs])
                Z = SysEqn - A*sym([obj.States])' - B*sym([obj.Inputs])';
            else
                Z = SysEqn - A*sym([obj.States])';
            end

            if ~isempty(p.Results.Discrete)
                dt = p.Results.Discrete;
                A = exp(A*dt);
                syms tau
                B = int(exp(A*tau)*B,tau,0,dt);

            end       

        end

        %% Model Zero-Order Hold Discretization 
        
        %% Graph Report
        % Generates then displays vertex and edge report of entire model
        function gmt_ReportGraph(obj)
            % Vertex Table
            varNames_tmp = ["Vertex Name","Vertex Type","Vertex State Variable","State Variable Units","Capacitance Inputs","Capacitance","Capacitance Equation","Power Equation"];
            for idx_tmp = 1:length(varNames_tmp)
                varTypes_tmp(1,idx_tmp) = {'string'};
            end
            sz = [obj.Properties.Nv length(varNames_tmp)];
            table_tmp = table('Size',sz,'VariableTypes',varTypes_tmp,'VariableNames',varNames_tmp);
            % Assembly Table Data 
            for i = 1:obj.Properties.Nv
                table_tmp(i,1) = {obj.Vertices(i).VertexName};
                table_tmp(i,2) = {obj.Vertices(i).VertexType};
                if isempty(obj.Vertices(i).GraphStateVariables)
                    if isempty(obj.Vertices(i).GraphOutputVariables)
                        table_tmp(i,3) = {""};
                    else
                       table_tmp(i,3) = {obj.Vertices(i).GraphOutputVariables}; 
                    end
                else
                    table_tmp(i,3) = {obj.Vertices(i).GraphStateVariables};
                end

                if isempty(obj.Vertices(i).Units)
                    table_tmp(i,4) = {"Undefined"};
                else
                    table_tmp(i,4) = {obj.Vertices(i).Units};
                end

                if isempty(obj.Vertices(i).InputVariables)
                    table_tmp(i,5) = {""};
                else
                    table_tmp(i,5) = {join([obj.Vertices(i).InputVariables],", ")};
                end
                table_tmp(i,6) = {obj.Vertices(i).GraphCapacitance};
                table_tmp(i,7) = {str2sym(obj.Vertices(i).GraphCapacitanceEq)};
                table_tmp(i,8) = {str2sym(obj.Vertices(i).GraphPowerEq)};
            end

            fprintf('\n'); disp(table_tmp) 

            % Edge Table
            varNames2_tmp = ["Edge Name","Edge Type","Inputs","Edge Equation"];
            for idx2_tmp = 1:length(varNames2_tmp)
                varTypes2_tmp(1,idx2_tmp) = {'string'};
            end
            sz2 = [obj.Properties.Ne length(varNames2_tmp)];
            table2_tmp = table('Size',sz2,'VariableTypes',varTypes2_tmp,'VariableNames',varNames2_tmp);
            % Assembly Table Data 
            for i = 1:obj.Properties.Ne
                table2_tmp(i,1) = {obj.Edges(i).EdgeName};
                table2_tmp(i,2) = {obj.Edges(i).EdgeType};
                if isempty(obj.Edges(i).InputVariables)
                    table2_tmp(i,3) = {""};
                else
                    table2_tmp(i,3) = {join([obj.Edges(i).InputVariables],", ")};
                end

                table2_tmp(i,4) = {str2sym(obj.Edges(i).GraphEdgeEq)};   
            end

            fprintf('\n'); disp(table2_tmp) 

        end

        %% Initial Condition Report
        function gmt_ReportInitCon(obj)
            
            % Inital Condtion Table
            varNames_tmp = ["Vertex Name","Vertex State Variable","Initial Condition","State Variable Units",];
            for idx_tmp = 1:length(varNames_tmp)
                varTypes_tmp(1,idx_tmp) = {'string'};
            end

            sz = [obj.Properties.NvD  length(varNames_tmp)];
            table_tmp = table('Size',sz,'VariableTypes',varTypes_tmp,'VariableNames',varNames_tmp);

            % Assembly Table Data 
            for i = 1:obj.Properties.NvD
                table_tmp(i,1) = {obj.Vertices(obj.Properties.NvD_idx(i)).VertexName};
                table_tmp(i,2) = {obj.Vertices(obj.Properties.NvD_idx(i)).GraphStateVariables};
                if ~isempty(obj.InitialConditions) 
                    table_tmp(i,3) = {obj.InitialConditions(i)};
                else
                    table_tmp(i,3) = {"Unassigned"};
                end
                table_tmp(i,4) = {obj.Vertices(obj.Properties.NvD_idx(i)).Units};
            end

            fprintf('\n'); disp(table_tmp) 
        end
        %% Parameter Report
        % Generates then displays parameter report of all model parameterization 
        function gmt_ReportParameter(obj)
            num_params = length(obj.ModelParameters);
            varNames_tmp = ["Parent", "Parameter", "Description", "Units", "Parameter Type", "System Parameter", "Optimization Parameter"];
            for idx_tmp = 1:length(varNames_tmp)
                varTypes_tmp(1,idx_tmp) = {'string'};
            end
            sz = [num_params length(varNames_tmp)];
            table_tmp = table('Size',sz,'VariableTypes',varTypes_tmp,'VariableNames',varNames_tmp);
            for i = 1:num_params
                table_tmp(i,1) = {obj.ModelParameters(i).Parent};
                table_tmp(i,2) = {obj.ModelParameters(i).Variable};
                table_tmp(i,3) = {obj.ModelParameters(i).Description};
                if  ~isempty(obj.ModelParameters(i).Units)
                    table_tmp(i,4) = {obj.ModelParameters(i).Units};
                else
                    table_tmp(i,4) = {"Not Defined"};
                end
                table_tmp(i,5) = {obj.ModelParameters(i).ParameterType};
                table_tmp(i,6) = {obj.ModelParameters(i).Common};
                table_tmp(i,7) = {obj.ModelParameters(i).Optimization};
                
            end

            [~, sortIdx] = sort(lower([obj.ModelParameters.Variable]));

            fprintf('\n'); disp(table_tmp(sortIdx,:)) 

        end

        %% Connection Report  
        % Returns the port connection data in easy to read format
        function gmt_ReportConnection(obj)
            num_params = length(obj.Ports);
            varNames_tmp = ["Port Number","Parent","Description","PortType", "Element Number"];
            for idx_tmp = 1:length(varNames_tmp)
                varTypes_tmp(1,idx_tmp) = {'string'};
            end
            sz = [num_params length(varNames_tmp)];
            table_tmp = table('Size',sz,'VariableTypes',varTypes_tmp,'VariableNames',varNames_tmp);
            for i = 1:num_params
                table_tmp(i,1) = {i};
                table_tmp(i,2) = {obj.Ports(i).ParentName};
                table_tmp(i,3) = {obj.Ports(i).Description};
                table_tmp(i,4) = {obj.Ports(i).PortType};
                table_tmp(i,5) = {obj.Ports(i).ElementNumber};
            end

            fprintf('\n'); disp(table_tmp) 

        end

        %% Input Report  
        % Returns the port connection data in easy to read format
        function gmt_ReportInput(obj)
            num_params = length(obj.InputData);
            varNames_tmp = ["Variable","Parent","Description","Units"];
            for idx_tmp = 1:length(varNames_tmp)
                varTypes_tmp(1,idx_tmp) = {'string'};
            end
            sz = [num_params length(varNames_tmp)];
            table_tmp = table('Size',sz,'VariableTypes',varTypes_tmp,'VariableNames',varNames_tmp);
            for i = 1:num_params
                table_tmp(i,1) = {obj.InputData(i).VariableName};
                table_tmp(i,2) = {obj.InputData(i).Parent};
                table_tmp(i,3) = {obj.InputData(i).Description};
                if ~isempty(obj.InputData(i).Units)
                    table_tmp(i,4) = {obj.InputData(i).Units};
                else 
                    table_tmp(i,4) = {"Missing Units"};
                end
            end

            fprintf('\n'); disp(table_tmp) 

        end

        %% Full Report 
        % Generates all reports 
        function gmt_ReportFull(obj)

            fprintf('\n<strong>Graph Report</strong>\n');
            gmt_ReportGraph(obj)
            fprintf('<strong>Parameter Report</strong>\n');
            gmt_ReportParameter(obj)
            fprintf('<strong>Input Report</strong>\n');
            gmt_ReportInput(obj)
            fprintf('<strong>Connection Port Report</strong>\n');
            gmt_ReportConnection(obj)

        end

        %% DiGraphUpdate
        function obj = gmt_DiGraphUpdate(obj)

            % Vertex Color Coding
            for i = 1:obj.Properties.Nv
                Vertices_Names_tmp(i,1) = obj.Vertices(i).VertexName + " (V" + string(i) + ")";
                if obj.Vertices(i).VertexType == gmt_VertexType.External
                    color_tmp(i,:) = [1 0 0];
                else
                    color_tmp(i,:) = [0 0 1];
                end
            end

            % Edge Color Coding 
            for i =1:obj.Properties.Ne
                Edges_Names_tmp(i,1) = obj.Edges(i).EdgeName + " (E" + string(i) + ")";
                Edges_Names_celltmp{i,1} = obj.Edges(i).EdgeName;
                if obj.Edges(i).EdgeType  == gmt_EdgeType.External 
                    color_tmp2(i,:) = [1 0 0];
                else
                    color_tmp2(i,:) = [0 0 1];
                end
            end

            % Updates direct graph object propeties 
            obj.DiGraph = digraph(obj.EdgeMatrix(:,1),obj.EdgeMatrix(:,2));

            % Reorganize Edge Labels and Color Codes 
            Edges_Names_rotmp = Edges_Names_tmp;
            color_rotmp2 = color_tmp2;

            for i = 1:obj.Properties.Ne
                if ~isequal(table2array(obj.DiGraph.Edges(i,:)),obj.EdgeMatrix(i,:))
                    for j = 1:obj.Properties.Ne
                        if isequal(table2array(obj.DiGraph.Edges(i,:)),obj.EdgeMatrix(j,:))
                        Edges_Names_rotmp(i) = Edges_Names_tmp(j);
                        color_rotmp2(i) = color_tmp2(j);
                        break
                        end
                    end
                else 
                end
            end

            % Update Labels
            obj.DiGraph.Nodes.NodeLabel = Vertices_Names_tmp;
            obj.DiGraph.Edges.EdgeLabel = Edges_Names_rotmp;
            
            % Update Color
            obj.DiGraph.Nodes.NodeColor = color_tmp;
            obj.DiGraph.Edges.EdgeColor = color_rotmp2;     

        end

        %% Plot DiGraph
        % Function creates MATLAB native graph object and updates properties for plotting  
        function gmt_PlotGraph(obj)
            figure
            p = plot(obj.DiGraph,'LineWidth',5,"Layout","force");
            % Set Title
            sgtitle(obj.Name)
            % Set Edge Labels
            p.EdgeLabel = obj.DiGraph.Edges.EdgeLabel;
            % Set Node Labels
            p.NodeLabel = obj.DiGraph.Nodes.NodeLabel;
            % Set Edge Colors
            p.EdgeColor = obj.DiGraph.Edges.EdgeColor;
            % Set Node Colors
            p.NodeColor = obj.DiGraph.Nodes.NodeColor;
            % Arrow Size
            p.ArrowSize=15;
            % Position Arrow
            p.ArrowPosition = 0.80;
            % Font Size
            FontSize_tmp = 10;
            p.NodeFontSize = FontSize_tmp;
            p.EdgeFontSize = FontSize_tmp;
            text(p.XData+.01, p.YData+.01 ,p.NodeLabel, ...
            'VerticalAlignment','Bottom',...
            'HorizontalAlignment', 'left',...
            'FontSize', FontSize_tmp)
            p.NodeLabel = {}; 

        end
       
        %% Model Update 
        % Once all vertices, edges, and edge matrix has been defined a model can be generated 
        function obj = gmt_ModelUpdate(obj,varargin)

            % Varagin Input Argument Parsing 
            params = gmt_Graph.gmt_parseSuperclass(obj,varargin{:});
            makeFunc_mfile  = ~isempty(params.BuildSim);
            componentMdl = ~params.SystemModel;
            AddInitCons = ~isempty(params.InitCon);

            % Updates graph properties object and performs validation checks
            if all([obj.Properties.GraphValidity.IncidenceValid,obj.Properties.GraphValidity.VerticesValid,obj.Properties.GraphValidity.EdgesValid])
                % Compute Boundary Vertices
                obj.Properties.Ns = 0;
                for j = 1:obj.Properties.Nv
                    % Grab non-zero elements on each vertices 
                    tmp = obj.Properties.M(j,obj.Properties.M(j,:)~=0);
                    % Determine total number of edges
                    tmp_lgth = length(tmp);
                    % Take the max of all positive or all negative
                    tmp_sum = max(sum(abs(tmp(tmp==-1))),sum(tmp(tmp==1)));
                    % If all the elements match one direction, it is a boundary vertex
                    V_bv(j) = logical(tmp_sum == tmp_lgth);
                    % Update exogeny of each vertex 
                    % obj.Vertices(j) = obj.Vertices(j).gmt_VertexTypeUpdate(V_bv(j)); 
                    % if obj.Vertices(j).VertexType == gmt_VertexType.Internal
                    %     obj.Properties.Ns = obj.Properties.Ns + 1;
                    %     obj.Vertices(j) = obj.Vertices(j).gmt_VertexStateVariableUpdate(obj.Properties.Ns);
                    % end
                end
            elseif not(obj.Properties.GraphValidity.GraphValid)
                error('Error: Edge Matrix is not properly defined. Number of vertices must be greater than or equal to the number of edges')
            elseif not(obj.Properties.GraphValidity.VerticesValid)
                error('Error: Number of Vertices specified does not match dimensions of Edge Matrix')
            elseif not(obj.Properties.GraphValidity.EdgesValid)
                error('Error: Number of Edges specified does not match dimensions of Edge Matrix')
            end

            Tot_Ds_num = 0;
            Tot_As_num  = 0;
            Tot_y_num = 0;

            % Update Graph Specific State and State Derivative Variables 
            for i = 1:obj.Properties.Nv
                
                Ds_var_tmp = [];
                As_var_tmp = [];
                y_var_tmp = [];

                Ds_var = obj.Vertices(i).StateDerVariables; % Grab vertex specific dynamic state variables name
                Num_Ds = obj.Vertices(i).NvSd; % Grab total number of dynamic state varables 
                As_var = obj.Vertices(i).StateVariables; % Grab vertex specific dynamic state variables name
                Num_As = max(obj.Vertices(i).NvSa,obj.Vertices(i).NvS); % Grab total number of algebraic state varables
                V_var = obj.Vertices(i).OutputVariables; % Grab vertex specific output variables 
                Num_y = obj.Vertices(i).NvY; % Grab total number of output variables 

                if isa(Num_Ds,'double') && Num_Ds ~= 0
                    Tot_Ds_num = i;%(1:Num_Ds) + Tot_Ds_num(end); % Compute graph specific dynamic state variable numbering 
                    if Num_Ds == 1 && strlength(extractAfter(extractBefore(Ds_var,"_dot"),"x")) == 0
                        Ds_var_tmp = strcat("x",num2str(Tot_Ds_num),"_dot");
                    else
                        Ds_var_tmp = regexprep(Ds_var, '\d+', '${num2str(Tot_Ds_num(str2double($0)))}');
                    end
                end

                if isa(Num_As,'double') && Num_As ~= 0
                    Tot_As_num = i;%(1:Num_As) + Tot_As_num(end); % Compute graph specific algebraic state variable numbering
                    if Num_As == 1 && strlength(extractAfter(As_var,"x")) == 0
                        As_var_tmp = strcat("x",num2str(Tot_As_num));
                    else
                        As_var_tmp = regexprep(As_var, '\d+', '${num2str(Tot_As_num(str2double($0)))}');
                    end
                end

                if isa(Num_y,"double") && Num_y ~= 0
                    Tot_y_num = i;%(1:Num_y) + Tot_y_num(end);
                    if Num_y == 1 && strlength(extractAfter(V_var,"y")) == 0
                        y_var_tmp = strcat("y",num2str(Tot_y_num));
                    else
                        y_var_tmp = regexprep(As_var, '\d+', '${num2str(Tot_As_num(str2double($0)))}');
                    end
                end

                obj.Vertices(i) = obj.Vertices(i).gmt_GraphVertexUpdate(Ds_var_tmp,As_var_tmp,y_var_tmp);

                % Update Head and State Vertices Numbers
                for j = 1:obj.Properties.Ne 
                    % Prepare to update graph model 
                    obj.Edges(j) = obj.Edges(j).gmt_EdgeGraphModelUpdate();
                    
                    %if obj.Edges(j).NeHS > 0 && obj.Properties.M(i,j) == 1
                    if obj.Properties.M(i,j) == 1
                       obj.Edges(j) = obj.Edges(j).gmt_UpdateHeadVertexNum(i);
                       obj.Edges(j) = obj.Edges(j).gmt_UpdateGraphHeadStateVar(obj.Vertices(i).GraphStateVariables);
                       % if obj.Vertices(i).VertexType == gmt_VertexType.External
                       %  obj.Vertices(i) = obj.Vertices(i).gmt_VertexDisturanceType("Sink");
                       % end
                     
                    %elseif obj.Edges(j).NeTS > 0 && obj.Properties.M(i,j) == -1
                    elseif obj.Properties.M(i,j) == -1
                       obj.Edges(j) = obj.Edges(j).gmt_UpdateTailVertexNum(i);
                       obj.Edges(j) = obj.Edges(j).gmt_UpdateGraphTailStateVar(obj.Vertices(i).GraphStateVariables);
                       % if obj.Vertices(i).VertexType == gmt_VertexType.External
                       %  obj.Vertices(i) = obj.Vertices(i).gmt_VertexDisturanceType("Source");
                       % end
                    end
                end


            end
            
            % Internal State Variables 
            IntVertices_idx = find([obj.Vertices.VertexType] == gmt_VertexType.Internal); % Internal State Variables 

            % Update System State Variables
            state_vars_tmp = unique([obj.Vertices(IntVertices_idx).GraphStateVariables]);
            state_nums_tmp = str2double(extractAfter(state_vars_tmp, "x"));
            [~, idx] = sort(state_nums_tmp);
            state_vars_sorted_tmp = state_vars_tmp(idx);
            obj.States = state_vars_sorted_tmp;

            % Update System Input Variables
            if ~isempty([obj.Vertices.InputVariables]) || ~isempty([obj.Edges.InputVariables])
                input_vars_tmp = unique([[obj.Vertices.InputVariables],[obj.Edges.InputVariables]]);
                input_nums_tmp = str2double(extractAfter(input_vars_tmp, "u"));
                [~, idx] = sort(input_nums_tmp);
                input_vars_sorted_tmp = input_vars_tmp(idx);
                obj.Inputs = input_vars_sorted_tmp;
            end

            % Update System Output Variables 
            output_vars_tmp = unique([obj.Vertices.GraphOutputVariables]);
            output_nums_tmp = str2double(extractAfter(output_vars_tmp, "y"));
            [~, idx] = sort(output_nums_tmp);
            output_vars_sorted_tmp = output_vars_tmp(idx);
            obj.Outputs = output_vars_sorted_tmp;

            % Update System Disturbance Variables 

            % Update Power Equation for Each Edge
            for i = 1:obj.Properties.Nv 
                NvE_tmp = sum(abs(obj.Properties.M(i,:))==1);
                EdgeNum_tmp = find(abs(obj.Properties.M(i,:))==1);
                EdgeNumStr_tmp = string(obj.Properties.M(i,EdgeNum_tmp));
                
                % Define search terms (Longest/most specific first)
                oldVals = {'-1', '1'};

                % Define corresponding replacements
                newVals = {'-', '+'};
                
                % Perform the replacement across the whole cell array
                [oldVals_common, ia, ib] = intersect(EdgeNumStr_tmp, oldVals);
                newVals_common =  string(newVals(ib));
                Operator_tmp = replace(EdgeNumStr_tmp, oldVals_common, newVals_common);
                EdgeEq_tmp = "(" + [obj.Edges(EdgeNum_tmp).GraphEdgeEq] + ")";
                PowerEq_tmp = strjoin(Operator_tmp + EdgeEq_tmp,'');
                obj.Vertices(i) = obj.Vertices(i).gmt_GraphVertexEqUpdate(PowerEq_tmp,NvE_tmp);
            end

            % Determine Indices for Stacking 
            DynVertices_idx = find([obj.Vertices.StateType] == gmt_StateType.Dynamic); % Dynamic State Variables 
            AlgVertices_idx = find([obj.Vertices.StateType] == gmt_StateType.Algebraic); % Algebraic State Variables 
            IntVertices_idx = find([obj.Vertices.VertexType] == gmt_VertexType.Internal); % Internal State Variables 
            AlgIntVertices_idx = intersect(AlgVertices_idx,IntVertices_idx); %Algebraic and Internal State Variables

            % Dynamic State Variable Equations
            sys_dyneq_str_tmp = [obj.Vertices(DynVertices_idx).GraphStateDerVariables]' + " = " + [obj.Vertices(DynVertices_idx).GraphVertexEq]' + ";";

            % Algebraic State Variable Equations
            if ~isempty(AlgVertices_idx)
                sys_algeq_str_tmp = [obj.Vertices(AlgIntVertices_idx).GraphStateVariables]' + " = " + [obj.Vertices(AlgIntVertices_idx).GraphVertexEq]' + ";";
            else
                sys_algeq_str_tmp = [];
            end

            % Stack string expression on top of each other
            sys_eq_str_tmp = [sys_dyneq_str_tmp; sys_algeq_str_tmp];

            [~, idx] = sort(double(extractAfter(extractBefore(sys_eq_str_tmp,"_dot"),"x")));
            sys_eq_str_tmp = sys_eq_str_tmp(idx);

            % Create a MATLAB symbolic equation 
            sym_sys_tmp = str2sym(sys_eq_str_tmp);
            obj.SystemEquations.FunctionInputs = symvar(rhs(sym_sys_tmp));
            obj.SystemEquations.LHS = lhs(sym_sys_tmp);
            obj.SystemEquations.RHS = rhs(sym_sys_tmp);
            obj.SystemEquations.Expression = sym_sys_tmp; 

            %% Determine Model Type 
            if any([obj.ModelParameters.ParameterType] == gmt_ParameterType.Lookup) || any([obj.ModelParameters.ParameterType] == gmt_ParameterType.Neural_Network)
                obj.ModelMetadata.ModelType = gmt_ModelType.Numerical;
            else
                obj.ModelMetadata.ModelType = gmt_ModelType.Analytical;
            end

            %% Sub Parameter Values in System of Equations 
            if obj.ModelMetadata.ModelType == gmt_ModelType.Analytical
                
                % Determine Variables for Substitution 
                sub_idx = find([obj.ModelParameters.Optimization] == false);

                obj.SystemEquationsSubs.LHS = obj.SystemEquations.LHS;
                obj.SystemEquationsSubs.RHS = subs(rhs(sym_sys_tmp),str2sym([obj.ModelParameters(sub_idx).Variable]),[obj.ModelParameters(sub_idx).Data]);
                obj.SystemEquationsSubs.Expression = subs(sym_sys_tmp,str2sym([obj.ModelParameters(sub_idx).Variable]),[obj.ModelParameters(sub_idx).Data]);
                obj.SystemEquationsSubs.FunctionInputs = symvar(obj.SystemEquationsSubs.RHS);

            end

            %% If Component Model Append Edge and Vertex Names By Component Name
            if componentMdl
                
                for i = 1:length(obj.Edges)
                    obj.Edges(i).EdgeName = obj.Name + ": " + obj.Edges(i).EdgeName; 
                end
    
                for j = 1:length([obj.Vertices])
                    obj.Vertices(j).VertexName = obj.Name + ": " + obj.Vertices(j).VertexName; 
                end
            end

            %% If Inputs and InputData remove input data that is not in input parsing    
            if ~isempty(obj.Inputs) && ~isempty(obj.InputData)

                [Akeep, ia, ib] = intersect([obj.Inputs],[obj.InputData.VariableName], 'stable');
                InputData_Match_tmp = ismember([obj.InputData.VariableName],Akeep);
                obj.InputData = obj.InputData(InputData_Match_tmp);

            end


            %% If Requested, Add Initial Conditions
            if AddInitCons
                obj = gmt_InitCon(obj,params.InitCon);
            end

            %% If Requested, Build Simulation
            if makeFunc_mfile 
                obj = gmt_BuildSim(obj,params.BuildSim);
            end

        end
        
        %% Input Commonization 
        function obj = gmt_InputCommon(obj,InputMatching,varargin)

            % Append Varagin
            varargin = [varargin, {"SystemModel"}, {true}]; 
            CombineInputs = InputMatching;

            % Initalization 
            OldInputs = CombineInputs(:,1); % old input variables
            NewInputs = CombineInputs(:,2); % new input variables
            SysInputsVars = [obj.Inputs]; % all variables 
            
            % Update mapping for cases where one rows mapping impacts another
            NewInputs = replace(NewInputs, OldInputs, NewInputs);
            
            % Regular expression for variable parsing 
            OldInputsVars = regexp(OldInputs, '[a-zA-Z]\d+', 'match');
            NewInputsVars = regexp(NewInputs, '[a-zA-Z]\d+', 'match');
            OldInputsVars_vector = [OldInputsVars{:}];
            NewInputsVars_vector = [NewInputsVars{:}];

            % Validate variables are function of original system 
            OldInputsValid = all(ismember(OldInputsVars_vector, SysInputsVars));
            NewInputsValid = all(ismember(NewInputsVars_vector, SysInputsVars));
            assert(OldInputsValid,"Old inputs are not contained within system");
            assert(NewInputsValid,"New inputs are not contained within system");
    
            % Update Edge Equation
            for i = 1:length(obj.Edges)  
                EdgeEq_tmp = obj.Edges(i).EdgeEq;
                if contains(obj.Edges(i).InputVariables,OldInputs)
                    obj.Edges(i).EdgeEq = replace(EdgeEq_tmp,OldInputs,NewInputs);
                end

            end
    
            % Update Capacitance Equation
            for i = 1:length(obj.Vertices)  
                CapEq_tmp = obj.Vertices(i).CapacitanceEq;
                if matches(obj.Vertices(i).InputVariables,OldInputs)
                    obj.Vertices(i).CapacitanceEq = replace(CapEq_tmp,OldInputs,NewInputs);
                end
            end

            % Reconstruct Each Edge 
            for i = 1:length(obj.Edges)
                EdgeName_tmp = obj.Edges(i).EdgeName;
                EdgeEq_tmp = obj.Edges(i).EdgeEq;
                if obj.Edges(i).EdgeType == gmt_EdgeType.External
                    EdgeNew(i) = gmt_Edge(EdgeName_tmp,EdgeEq_tmp,"External");
                else
                    EdgeNew(i) = gmt_Edge(EdgeName_tmp,EdgeEq_tmp);
                end
            end

            % Reconstruct Each Vertex
            for i = 1:length(obj.Vertices)
                VertexName_tmp = obj.Vertices(i).VertexName;
                CapEq_tmp = obj.Vertices(i).CapacitanceEq;

                if ~isempty(obj.Vertices(i).Units)
                    varargin2 = [{"Units"}, {obj.Vertices(i).Units}]; 
                else
                    varargin2 = [];
                end

                if obj.Vertices(i).VertexType == gmt_VertexType.External && ~isempty(varargin2)
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp,"External",true,varargin2{:});
                elseif obj.Vertices(i).VertexType == gmt_VertexType.External
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp,"External",true);
                elseif ~isempty(varargin2)
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp,varargin2{:});
                else
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp);
                end
            end

            obj = gmt_Graph(obj.Name,obj.EdgeMatrix,EdgeNew,VertexNew,obj.ModelParameters,obj.InputData,obj.Ports,varargin{:});

        end

        %% Add Initial Conditions
        function obj = gmt_InitCon(obj,InitConVals)
                obj.InitialConditions = InitConVals;
        end

        %% Build Simulation
        function obj = gmt_BuildSim(obj,filepath)

                %% Determine Indicies  
                % Determine Indices for Stacking                 
                DynVertices_idx = find([obj.Vertices.StateType] == gmt_StateType.Dynamic); % Dynamic State Variables 
                AlgVertices_idx = find([obj.Vertices.StateType] == gmt_StateType.Algebraic); % Algebraic State Variables
                ExtVertices_idx = find([obj.Vertices.VertexType] == gmt_VertexType.External); % External State Variables 
                IntVertices_idx = find([obj.Vertices.VertexType] == gmt_VertexType.Internal); % Internal State Variables 
                AlgIntVertices_idx = intersect(AlgVertices_idx,IntVertices_idx); % Algebraic and Internal State Variables
                AlgExtVertices_idx = intersect(AlgVertices_idx,ExtVertices_idx); % Algebraic and External State Variables
               
                ScalarParams_idx = find([obj.ModelParameters.ParameterType] == gmt_ParameterType.Scalar);
                ExpressParams_idx = find([obj.ModelParameters.Expression] == true);
                LookupParams_idx = find([obj.ModelParameters.ParameterType] == gmt_ParameterType.Lookup);
                NNParams_idx = find([obj.ModelParameters.ParameterType] == gmt_ParameterType.Neural_Network);

                %% Create System Model in M File          
                % System Function Header
                if ispc
                    user = getenv('USERNAME');
                else
                    user = getenv('USER');
                end

                sysfun_mfile_preheader = "% Code-Auto Generated By " + user + " using gmt Toolbox on " + string(datetime);

                % Determine Boundary Conditions
                % Only include variables are a function of tODe
                state_tmp = [obj.Vertices(AlgExtVertices_idx).GraphStateVariables]';
                idx_len = length(state_tmp);

                for i = 1:idx_len
                    isFuncOfExtAlg(i) = contains(strjoin(string([obj.SystemEquations.RHS]')),state_tmp(i));
                end

                ExtAlgVars = [obj.Vertices(AlgExtVertices_idx(isFuncOfExtAlg)).GraphStateVariables];

                % Determine Control Inputs
                InputVars = [obj.InputData.VariableName]';

                % Function Arguments 
                sysFun_input_args = "(t,y";

                if ~isempty(obj.Inputs) 
                    sysFun_input_args = sysFun_input_args + "," + strjoin(InputVars,",");
                end

                if ~isempty(ExtAlgVars)
                    sysFun_input_args = sysFun_input_args + "," + strjoin(ExtAlgVars,",");
                end

                % Function Name 
                sysfun_FunctionName = "sysFun_" + obj.Name + sysFun_input_args + ")";
               
                % Function Header and Footer 
                sysfun_mfile_header = "function res = "+ sysfun_FunctionName;
                sysfun_mfile_footer = "end";
    
                % Initial Condition Parser 
                inputvar_list = [obj.Vertices(DynVertices_idx).GraphStateVariables]';
                unpackingCode = "";
                for i = 1:length(inputvar_list)
                    unpackingCode(i) = inputvar_list(i) + " = y(" + i + ");";
                end
                
                sysfun_mfile_prefix = unpackingCode';

                % System Model Parameters Parser 

                % Scalars 
                ScalarParams_idx_setdiff = setdiff(ScalarParams_idx,ExpressParams_idx);
                sysfun_mfile_scalars_data = [obj.ModelParameters(ScalarParams_idx_setdiff).Variable]' + " = " + [obj.ModelParameters(ScalarParams_idx_setdiff).Data]' + ";";
                sysfun_mfile_scalars_express = [obj.ModelParameters(ExpressParams_idx).Variable]' + ";";

                % Lookup
                if ~isempty(LookupParams_idx)

                    fields = fieldnames([obj.ModelParameters(LookupParams_idx).Data]);

                    y = 1;
                    for i = 1:length(LookupParams_idx)
                        idx = LookupParams_idx(i);
                        if ~isempty(obj.ModelParameters(idx).Data)
                            datadefined(y) = idx;
                            y = y + 1;
                        end

                    end
                    mFileLines = cell(length(fields), 1);
                    
                    % Loop through fields to create "LHS = RHS;" strings
                    y = 1;
                    for j = 1:length(datadefined)
                        idx = datadefined(j);
                        for i = 1:numel(fields)
                            fieldName = fields{i};
                            val = obj.ModelParameters(idx).Data.(fieldName); % Dynamic access
                        
                            if ischar(val) || isstring(val)
                                % Format: FieldName = 'StringData';
                                rhs = sprintf("'%s'", val);
                        
                            elseif isnumeric(val) || islogical(val)
                                % Format: FieldName = [1 0; 0 1]; or FieldName = 5;
                                % mat2str handles the brackets and semicolon for matrices
                                rhs = mat2str(val);
                        
                            else
                                % Fallback for empty or unsupported types
                                rhs = '[]';
                            end
                        
                            % Combine into the final assignment string
                            mFileLines{y} = sprintf('%s = %s;', fieldName, rhs);
                            y = y + 1;
                        end
                    end
    
                    sysfun_mfile_lookup_tmp = string(mFileLines);

                    % Find if user specified function lookup outside of edge equation 
                    sysfun_lookup_func_idx_tmp = find(contains([obj.ModelParameters(LookupParams_idx).Variable],"="));
                    sysfun_lookup_func_idx = LookupParams_idx(sysfun_lookup_func_idx_tmp);

                    if ~isempty(sysfun_lookup_func_idx)
                        sys_mfile_lookup2_tmp = [obj.ModelParameters(sysfun_lookup_func_idx).Variable]' + ";";
                    else
                        sys_mfile_lookup2_tmp = [];
                    end

                    sysfun_mfile_lookup = [sysfun_mfile_lookup_tmp;sys_mfile_lookup2_tmp];

                else 

                    sysfun_mfile_lookup = [];

                end

                % Neural Networks 

                % System Output Packager 
                outputvar_list = [obj.Vertices(DynVertices_idx).GraphStateDerVariables]';
                packingCode = "res = [" + strjoin(outputvar_list',";") + "];";
                sysfun_mfile_suffix = packingCode';
    
                % System Function Body 
                % Create string expression for each type
                sys_dyneq_str_tmp = [obj.Vertices(DynVertices_idx).GraphStateDerVariables]' + " = " + [obj.Vertices(DynVertices_idx).GraphVertexEq]' + ";";
                sys_algeq_str_tmp = [obj.Vertices(AlgVertices_idx).GraphStateVariables]'+ "_ = " + [obj.Vertices(AlgVertices_idx).GraphVertexEq]' + ";" ;
    
                % Stack string expression on top of each other
                sys_eq_str_tmp = [sys_dyneq_str_tmp;sys_algeq_str_tmp];
    
                sysfun_mfile_body = sys_eq_str_tmp;

                sysfun_mfile_combined = ...
                    [
                    sysfun_mfile_preheader; ...
                    sysfun_mfile_header;...
                    sysfun_mfile_prefix;...
                    sysfun_mfile_scalars_data;...
                    sysfun_mfile_lookup;...
                    sysfun_mfile_scalars_express;...
                    sysfun_mfile_body;...
                    sysfun_mfile_suffix;...
                    sysfun_mfile_footer];

                obj.ModelMetadata.MfileCode = sysfun_mfile_combined;
                obj.ModelMetadata.FunctionName = sysfun_FunctionName;

                sysfun_filename_tmp = "sysFun_" + obj.Name + ".m";
                sysobj_filename_tmp = "sysObj_" + obj.Name + ".mat";
                sysname_tmp = "sys_" + obj.Name;

                date_tmp = string(datetime('now','Format','MMDDyyy'));
                time_tmp = string(datetime('now','Format','HHmmss'));

                sys_bld_flder_tmp = sysname_tmp + "_" + date_tmp +  "_" + time_tmp;
                sys_bld_path_tmp = filepath + "\" + sys_bld_flder_tmp;

                mkdir(sys_bld_path_tmp)

                sysfun_file_save_path = sys_bld_path_tmp + "\" + sysfun_filename_tmp;
                syssim_file_save_path = extractBefore(sysfun_file_save_path,'.m') + "SimScript.m";
                sysobj_file_save_path = sys_bld_path_tmp + "\" + sysobj_filename_tmp;
    
                writelines(sysfun_mfile_combined, sysfun_file_save_path);

                %% Simulation Script Generator 
                if ~isempty([obj.InputData.VariableName])
                    inputstr_tmp = "% Inputs ";
                    inputstr_tmp = [inputstr_tmp ; [obj.InputData.VariableName]'+ " = 0; % " + [obj.InputData.Parent]'+ ": " + [obj.InputData.Description]'+ " (Units: " + string([obj.InputData.Units]')+ ")"];
                else 
                    inputstr_tmp = [];
                end

                if ~isempty(AlgExtVertices_idx)
                    extalgstr_tmp = "% Boundary Conditions";
                    extalgstr_tmp = [extalgstr_tmp; [obj.Vertices(AlgExtVertices_idx(isFuncOfExtAlg)).GraphStateVariables]' + " = 0; % " + [obj.Vertices(AlgExtVertices_idx(isFuncOfExtAlg)).VertexName]' + " (Units: " + string([obj.Vertices(AlgExtVertices_idx(isFuncOfExtAlg)).Units]')+ ")"];
                else 
                    extalgstr_tmp = [];
                end
                
                simtimstr_tmp = ["% Simulation Time";"SimTEnd = 2000;"];
                
                if isempty(obj.InitialConditions)
                    ic = string(1);
                else 
                    ic = string(obj.InitialConditions)';
                end
                icstr1_tmp = "% Initial Conditions";
                icstr1_tmp = [icstr1_tmp; [obj.Vertices(DynVertices_idx).GraphStateVariables]' + "_0 = "+ ic + ";  % " + [obj.Vertices(DynVertices_idx).VertexName]' + " (Units: " + string([obj.Vertices(DynVertices_idx).Units]')+ ")"];
                icstr2_tmp = "y0 = [" + strjoin([obj.Vertices(DynVertices_idx).GraphStateVariables]+"_0",",") + "];";
                icstr_tmp = [icstr1_tmp;icstr2_tmp];
                sysFuncName_tmp = obj.ModelMetadata.FunctionName; 
                simbody_tmp = "[t, y] = ode23s(@(t,y) " + sysFuncName_tmp + ", [0 SimTEnd], y0);";
                
                plotstr_tmp =[... 
                "% Plot Only Internal State Types";
                "InternalIdx = (["+obj.Name+".Vertices.VertexType] == gmt_VertexType.Internal);";
                "NumInternal = size(y,2);";
                "DimSubPlot = max(ceil(sqrt(NumInternal)),2);";
                
                "ylabels_tmp = ["+obj.Name+".Vertices(InternalIdx).VertexName];";
                "ylabelsnew_tmp = replace(ylabels_tmp, " + """:"""+ ", newline);";
                
                "figure";
                "for i = 1:NumInternal";
                "    subplot(DimSubPlot,DimSubPlot,i)";
                "    plot(t,y(:,i))";
                "    xlabel('Time')";
                "    ylabel(ylabelsnew_tmp(i))";
                "end"];
                
                SimScriptGen_mfilecode = ...
                    [sysfun_mfile_preheader; ...
                     inputstr_tmp; ...
                     extalgstr_tmp; ...
                     simtimstr_tmp; ...
                     icstr_tmp; ...
                     simbody_tmp; ...
                     plotstr_tmp];

                writelines(SimScriptGen_mfilecode, syssim_file_save_path);    

                save(sysobj_file_save_path, "obj")
    
                % Create DAE Mass Matrix 
                NsD_tmp = sum(([obj.Vertices.StateType]==gmt_StateType.Dynamic));
                NsA_tmp = sum(([obj.Vertices.StateType]==gmt_StateType.Algebraic));

                obj.ModelMetadata.MassMatrix = blkdiag(eye(NsD_tmp));

        end



    end
    %% Static Public Methods
    methods (Static)
        
          %% Combine Component Models
          function sys = gmt_Combine(CombineName, ObjectArray, PortArray, varargin)

            %% Append Varargin
            varargin = [varargin, {"SystemModel"}, {true}]; 

            % Input Parsing and Validation
            PrimaryObj = ObjectArray{1};
            SecondaryObj = ObjectArray{2};

            % Component Connection Information Processing
            NumCon = length(PrimaryObj);
            AllObj = {PrimaryObj{:},SecondaryObj{:}};
            AllObj_num = length(AllObj);

            for i = 1:AllObj_num
                AllObjName(i) = AllObj{i}.Name;
            end

            % Compute Number of Components
            [UniqueObjName, ia, ic] = unique(AllObjName);
            NumComp = length(UniqueObjName);
            UniqueObj = {AllObj{ia}};

            % Compute Combined Incidence Matrix Size
            objC_Nv = 1;
            objC_Ne = 1;
            objC_Nv_prev = 0;
            objC_Ne_prev = 0;
            EdgeTot = [];
            EdgeTot_comp_idx = [];
            VertexTot = [];
            VertexTot_comp_idx = [];
            ParamsTot = [];
            ParamsTot_comp_idx = [];
            InputTot = [];
            InputTot_comp_idx = [];
            PortsTot = [];
            PortsTot_comp_idx = [];
            Mc = [];
            PortsEdge_remove = [];
            NumInputs_prev = 0;
            objC_NumPorts_prev = 0;

            for i = 1:NumComp
                idx = i;
                idx_old = (max(i-1,1));

                objC_Nv_old{i} = 1:UniqueObj{idx}.Properties.Nv;
                objC_Nv = objC_Nv_prev + UniqueObj{idx}.Properties.Nv;
                objC_Nv_new{i} = (objC_Nv_prev+1:objC_Nv);
                objC_Nv_prev = objC_Nv;

                objC_Ne_old{i} = 1:UniqueObj{idx}.Properties.Ne;
                objC_Ne = objC_Ne_prev + UniqueObj{idx}.Properties.Ne;
                objC_Ne_new{i} = (objC_Ne_prev+1:objC_Ne);
                objC_Ne_prev = objC_Ne;

                Mc = blkdiag(Mc,UniqueObj{idx}.Properties.M);     

                EdgeTot = [EdgeTot,UniqueObj{idx}.Edges];
                NumEdge = length(UniqueObj{idx}.Edges);
                EdgeTot_comp_idx_new = ones(1,NumEdge).*i;
                EdgeTot_comp_idx = [EdgeTot_comp_idx, EdgeTot_comp_idx_new];

                VertexTot = [VertexTot,UniqueObj{idx}.Vertices];
                NumVertex = length(UniqueObj{idx}.Vertices);
                VertexTot_comp_idx_new = ones(1,NumVertex).*i;
                VertexTot_comp_idx = [VertexTot_comp_idx, VertexTot_comp_idx_new];

                ParamsTot = [ParamsTot, UniqueObj{idx}.ModelParameters];
                objC_NumParams = length(UniqueObj{idx}.ModelParameters);
                ParamsTot_comp_idx_new = ones(1,objC_NumParams).*i;
                ParamsTot_comp_idx = [ParamsTot_comp_idx, ParamsTot_comp_idx_new];
                objC_Params_old{i} = UniqueObj{idx}.ModelParameters;

                InputTot = [InputTot, UniqueObj{idx}.InputData];
                NumInputs = length(UniqueObj{idx}.InputData);
                InputTot_comp_idx_new = ones(1,NumInputs).*i;
                InputTot_comp_idx = [InputTot_comp_idx, InputTot_comp_idx_new];
                Inputs_old{i} = [UniqueObj{idx}.InputData.VariableName];
                InputNum_strt = (NumInputs_prev + 1);
                InputNum_end = InputNum_strt + NumInputs -1;
                NumInputs_prev = NumInputs_prev + NumInputs;
                Inputs_old{i} = "u" + string(1:NumInputs);
                Inputs_new{i} = "u" +  string(InputNum_strt:InputNum_end);

                NumPorts = length(UniqueObj{idx}.Ports);
                objC_PortNum_old{i} = 1:NumPorts;
                objC_NumPorts = objC_NumPorts_prev + NumPorts;
                objC_PortNum_new{i} = (objC_NumPorts_prev + 1:objC_NumPorts);
                objC_NumPorts_prev = objC_NumPorts;
                PortsTot = [PortsTot, UniqueObj{idx}.Ports];
                PortsTot_comp_idx_new = ones(1,NumPorts).*i;
                PortsTot_comp_idx = [PortsTot_comp_idx, PortsTot_comp_idx_new];
            end

            % Determine Unique Component Incidence Matrix
            Ports_cntr = 1;
            Ports_num_remove = [];
            for i = 1:NumCon 

                % Grab Port Numbers
                objA_PortNum = PortArray(i,1);
                objB_PortNum = PortArray(i,2);

                % Validate Connection Type
                connectionMatch = (PrimaryObj{i}.Ports(objA_PortNum).PortType == SecondaryObj{i}.Ports(objB_PortNum).PortType); 
                assert(connectionMatch,"Connection types do not match, please check connection port numbers and types")

                % Determine if edge or vertex connection
                is_edgecon = (PrimaryObj{i}.Ports(objA_PortNum).PortType == gmt_PortType.EdgeConnection);

                % Determine indices for each component
                PrimaryObjName{i} = PrimaryObj{i}.Name;
                SecondaryObjName{i} = SecondaryObj{i}.Name;
                objA_idx = find(UniqueObjName==PrimaryObjName{i});
                objB_idx = find(UniqueObjName==SecondaryObjName{i});

                table_tmp(i,:) = [string(PrimaryObjName{i}),string(objA_PortNum),PrimaryObj{i}.Ports(objA_PortNum).Description,string(SecondaryObjName{i}),string(objB_PortNum),SecondaryObj{i}.Ports(objB_PortNum).Description];

                % Initalize variables for each loop
                objA_EdgeNumM(i) = -1;
                objB_EdgeNumR(i) = -1;
                objA_VertexNumR(i) = -1;
                objB_VertexNumR(i) = -1;
                objA_VertexNumM(i) = -1;
                objB_VertexNumRvt(i) = -1;

                % Edge Connection Algorithm
                % asssign primary component edge for column concatentation 
                % assign secondary compoent edge for removal and concatentation 
                % assign primary component vertex number for removal
                % assign secondary component vertex number for removal
                if is_edgecon

                    Ports_num_remove{(2*Ports_cntr)-1} = objC_PortNum_new{objA_idx}(objC_PortNum_old{objA_idx}==objA_PortNum);
                    Ports_num_remove{(2*Ports_cntr)} = objC_PortNum_new{objB_idx}(objC_PortNum_old{objB_idx}==objB_PortNum);
                    Ports_cntr = Ports_cntr + 1;

                    objA_EdgeNum = PrimaryObj{i}.Ports(objA_PortNum).ElementNumber;
                    objB_EdgeNum = SecondaryObj{i}.Ports(objB_PortNum).ElementNumber;

                    objA_EdgeNumM(i) = objC_Ne_new{objA_idx}((objC_Ne_old{objA_idx}==objA_EdgeNum));
                    objB_EdgeNumR(i) = objC_Ne_new{objB_idx}((objC_Ne_old{objB_idx}==objB_EdgeNum));

                    % Compute Required Vertex Removal
                    % Edge A
                    objA_hVn = [PrimaryObj{i}.Edges(objA_EdgeNum).HeadVertexNum];
                    objA_tVn = [PrimaryObj{i}.Edges(objA_EdgeNum).TailVertexNum];
                    % Edge B
                    objB_hVn = [SecondaryObj{i}.Edges(objB_EdgeNum).HeadVertexNum];
                    objB_tVn = [SecondaryObj{i}.Edges(objB_EdgeNum).TailVertexNum];

                    % EdgeA HeadTail Vertex Assignment
                    if PrimaryObj{i}.Vertices(objA_hVn).GraphNvE == 1
                        objA_VertexNumR(i) = objC_Nv_new{objA_idx}((objC_Nv_old{objA_idx}==objA_hVn));
                    elseif PrimaryObj{i}.Vertices(objA_tVn).GraphNvE == 1
                        objA_VertexNumR(i) = objC_Nv_new{objA_idx}((objC_Nv_old{objA_idx}==objA_tVn));
                    else
                        error("New case identified, notify developer")
                    end
    
                    % EdgeB HeadTail Vertex Assignment
                    if SecondaryObj{i}.Vertices(objB_hVn).GraphNvE == 1
                        objB_VertexNumR(i) = objC_Nv_new{objB_idx}((objC_Nv_old{objB_idx}==objB_hVn));
                    elseif SecondaryObj{i}.Vertices(objB_tVn).GraphNvE == 1
                        objB_VertexNumR(i) = objC_Nv_new{objB_idx}((objC_Nv_old{objB_idx}==objB_tVn));
                    else
                        error("New case identified, notify developer")
                    end

                % Vertex Connection Algorithm 
                % assign primary component vertex number for row concatentation 
                % assign secondary component vertex number for removal and concatentation 
                else
                    objA_VertexNum = PrimaryObj{i}.Ports(objA_PortNum).ElementNumber;
                    objB_VertexNum = SecondaryObj{i}.Ports(objB_PortNum).ElementNumber;
                    objA_VertexNumM(i) = objC_Nv_new{objA_idx}((objC_Nv_old{objA_idx}==objA_VertexNum));
                    VertexTot(objA_VertexNumM(i)).VertexType = gmt_VertexType.Internal;
                    objB_VertexNumRvt(i) = objC_Nv_new{objB_idx}((objC_Nv_old{objB_idx}==objB_VertexNum));
                end

            end

            % Find Indices Requiring Updates
            objA_EdgeNumM_idx = find(objA_EdgeNumM>0);
            objB_EdgeNumR_idx = find(objB_EdgeNumR>0);
            objA_VertexNumR_idx = find(objA_VertexNumR>0);
            objB_VertexNumR_idx = find(objB_VertexNumR>0);
            objA_VertexNumM_idx = find(objA_VertexNumM>0);
            objB_VertexNumRvt_idx = find(objB_VertexNumRvt>0);

            % Update Arrays
            objA_EdgeNumM = objA_EdgeNumM(objA_EdgeNumM_idx);
            objB_EdgeNumR = objB_EdgeNumR(objB_EdgeNumR_idx);
            objA_VertexNumR = objA_VertexNumR(objA_VertexNumR_idx);
            objB_VertexNumR = objB_VertexNumR(objB_VertexNumR_idx);
            objA_VertexNumM =objA_VertexNumM(objA_VertexNumM_idx);
            objB_VertexNumRvt = objB_VertexNumRvt(objB_VertexNumRvt_idx);
            
            % Create Incidence Matrix 
            objC_VertexNumR = sort([objA_VertexNumR,objB_VertexNumR,objB_VertexNumRvt]); % order vertices to remove 
            Mc(:,objA_EdgeNumM) = Mc(:,objA_EdgeNumM) + Mc(:,objB_EdgeNumR); % concatenate common edge columns together 
            Mc(objA_VertexNumM,:) = Mc(objA_VertexNumM,:) + Mc(objB_VertexNumRvt,:); % concatenate common edge columns together 
            Mc(objC_VertexNumR,:) = []; % delete associated vertex rows 
            Mc(:,objB_EdgeNumR) = []; % delete associate edge columns

            % Update Final Dimensions 
            objC_Nv = size(Mc,1);
            objC_Ne = size(Mc,2);

            %% Construct New Edge Matrix from Incidence
            for i = 1:size(Mc,2)
                for j = 1:size(Mc,1)
                    idx_tmp = Mc(j,i);
                    if idx_tmp == 1
                        EdgeMatrixNew(i,2) = j;             
                    elseif idx_tmp == -1
                        EdgeMatrixNew(i,1) = j;
                    end
                end
            end 

            %% Update Parameterization Array
            ParamTot_name = [ParamsTot.Variable];
            ParamTot_comp_idx = ParamsTot_comp_idx;
            ParamTot_expression_idx = ([ParamsTot.Expression] == true);
            ParamTot_nonCommon_idx = ([ParamsTot.Common] == false);

            % Update non-common parameters for scalars and expressions containing non-common variables 
            ParamTot_name(ParamTot_expression_idx) = strtrim(extractBefore(ParamTot_name(ParamTot_expression_idx),"="));
            ParamTot_nonCommon_name = ParamTot_name(ParamTot_nonCommon_idx);
            ParamTot_nonCommon_comp = ParamsTot_comp_idx(ParamTot_nonCommon_idx);
            [ParamTot_nonCommon_name_unique, main_idx,repeat_idx] = unique(ParamTot_nonCommon_name);
            ParamTot_nonCommon_comp_unique = ParamTot_nonCommon_comp(main_idx);

            % Find repeating parameters
            ParamTot_nonCommon_repeat_cnts = accumarray(repeat_idx,1);
            ParamTot_nonCommon_repeat_name_idx = (ParamTot_nonCommon_repeat_cnts > 1);
            % Compute number of repeat values per parameter
            ParamTot_nonCommon_repeat_cnts = ParamTot_nonCommon_repeat_cnts(ParamTot_nonCommon_repeat_name_idx);
            % Compute repeat variable names
            ParamTot_nonCommon_repeat_name = ParamTot_nonCommon_name_unique(ParamTot_nonCommon_repeat_name_idx);
            % Compute indices that will require updates
            ParamTot_nonCommon_repeat_idx = find(ismember(ParamTot_name,ParamTot_nonCommon_repeat_name));
            % Compute component number 
            ParamTot_nonCommon_repeat_comp = ParamsTot_comp_idx(ParamTot_nonCommon_repeat_idx);
            % Compute variable names all 
            ParamTot_nonCommon_repeat_name_all = ParamTot_name(ParamTot_nonCommon_repeat_idx);
            % Number of variables to update
            ParamTot_num_vars_update = length(ParamTot_nonCommon_repeat_name);
            ParamTot_totnum_updates = sum(ParamTot_nonCommon_repeat_cnts);

            % For each variable that repeats, update the variable suffix 
            idx_tot = 1;
            for i = 1:ParamTot_num_vars_update
                suffix_tmp = 1; % initialize suffix numbering
                repeat_name_old = ParamTot_nonCommon_repeat_name(i); % temporary store of variable name 
                comp_tot_idx = ParamTot_nonCommon_repeat_comp(ismember(ParamTot_nonCommon_repeat_name_all,repeat_name_old));
                tot_updates = ParamTot_nonCommon_repeat_cnts(i);
                % For each time the variable repeats, update the suffix, verify new suffix is not contained within original variable list
                for j = 1:tot_updates
                    while true 
                    repeat_name_new = repeat_name_old + "_" + string(suffix_tmp);
                    suffix_tmp = suffix_tmp + 1;
                        if any(~ismember(ParamTot_name,repeat_name_new))
                            param_idx = ParamTot_nonCommon_repeat_idx(idx_tot);
                            param_old(idx_tot) = repeat_name_old;
                            param_new(idx_tot) = repeat_name_new;
                            comp_idx(idx_tot) = comp_tot_idx(j);
                            % If a scalar value update variable, else update LHS of expression
                            if ParamsTot(param_idx).Expression == false
                                ParamsTot(param_idx).Variable = repeat_name_new;
                            else
                                expression_tmp = ParamsTot(param_idx).Variable;
                                expression_lhs_old = extractBefore(expression_tmp,"=");
                                expression_rhs_tmp = extractAfter(expression_tmp,"=");
                                expression_lhs_new = replace(expression_lhs_old,repeat_name_old,repeat_name_new);
                                ParamsTot(param_idx).Variable = expression_lhs_new + "=" + expression_rhs_tmp;
                            end
                            idx_tot = idx_tot + 1;
                            break;
                        end
                    end
                end
            end

            for i = 1:ParamTot_totnum_updates
                CompNum_idx = comp_idx(i);
                ParametersVars_old_tmp = param_old(i);
                ParametersVars_new_tmp = param_new(i);
                EdgeNums = objC_Ne_new{CompNum_idx};
                VertexNums = objC_Nv_new{CompNum_idx};
                if ParametersVars_old_tmp ~= ParametersVars_new_tmp
                    for j = 1:length(EdgeNums)
                        EdgeIdx = EdgeNums(j);
                        EdgeEq_tmp = EdgeTot(EdgeIdx).EdgeEq;
                        if contains(EdgeEq_tmp,ParametersVars_old_tmp)
                            EdgeTot(EdgeIdx).EdgeEq = replace(EdgeEq_tmp,ParametersVars_old_tmp,ParametersVars_new_tmp);
                        end
                    end
        
                    for j = 1:length(VertexNums)
                        CapEq_tmp = VertexTot(VertexNums(j)).CapacitanceEq;
                        if contains(CapEq_tmp,ParametersVars_old_tmp)
                            VertexTot(VertexNums(j)).CapacitanceEq = replace(CapEq_tmp,ParametersVars_old_tmp,ParametersVars_new_tmp);
                        end
                    end
                end
            end

            [ParameterUnique, ia, ic] = unique([ParamsTot.Variable]);
            ParameterNew = ParamsTot(ia);

            %% Update Dependent Vertex State Variables
            VertexStateVar_old = [VertexTot.ComponentStateVariable];
            VertexStateVar_idx = find(VertexStateVar_old ~= "");

            for i = 1:length(VertexStateVar_idx)
                CompNum_idx = VertexTot_comp_idx(VertexStateVar_idx(i));
                OldStateNum(i) = double(extractAfter(VertexStateVar_old(VertexStateVar_idx(i)),"x"));
                NewStateNum(i) = objC_Nv_new{CompNum_idx}(objC_Nv_old{CompNum_idx} == OldStateNum(i));
                NumRemove = sum(objC_VertexNumR < NewStateNum(i));
                NewStateNum(i) = NewStateNum(i) - NumRemove;
                VertexUpdateArray = setdiff(objC_Nv_new{CompNum_idx},objC_VertexNumR);
                NumCapacitance = length(VertexUpdateArray);
                OldStateVar = "x" + string(OldStateNum(i));
                NewStateVar = "x" + string(NewStateNum(i));
                for j = 1:NumCapacitance
                    VertexIdx = VertexUpdateArray(j);
                    VertexTot(VertexIdx).CapacitanceEq = replace(VertexTot(VertexIdx).CapacitanceEq,OldStateVar,NewStateVar);
                end
            end

            %% Update Port Array 

            % Assign Temporary Port Array
            PortsTot_tmp = PortsTot;

            % Remove connected edge port connections 
            if ~isempty(Ports_num_remove)
                Ports_num_remove = [Ports_num_remove{:}];
                PortsTot_tmp(Ports_num_remove) = [];
                PortsTot_comp_idx(Ports_num_remove) = [];
            end

            % Determine edge and vertex connection port indices 
            Ports_edge_locIdx = find([PortsTot_tmp.PortType] == gmt_PortType.EdgeConnection);
            Ports_vertex_locIdx = find([PortsTot_tmp.PortType] == gmt_PortType.VertexConnection);

            % Renumber all edge connection element numbering
            for i = 1:length(Ports_edge_locIdx)
                PortNum_idx = Ports_edge_locIdx(i);
                CompNum_idx = PortsTot_comp_idx(PortNum_idx);
                OldElementNumber = PortsTot_tmp(PortNum_idx).ElementNumber;
                NewElementNumber = objC_Ne_new{CompNum_idx}(objC_Ne_old{CompNum_idx}==OldElementNumber);
                PortsTot_tmp(PortNum_idx).ElementNumber = NewElementNumber;
            end

            % Renumber all vertex connection element numbering
            for i = 1:length(Ports_vertex_locIdx)
                PortNum_idx = Ports_vertex_locIdx(i);
                CompNum_idx = PortsTot_comp_idx(PortNum_idx);
                OldElementNumber = PortsTot_tmp(PortNum_idx).ElementNumber;
                NewElementNumber = objC_Nv_new{CompNum_idx}(objC_Nv_old{CompNum_idx}==OldElementNumber);
                PortsTot_tmp(PortNum_idx).ElementNumber = NewElementNumber;
            end 

            % Create vectors for mapping old to new element numbers after combination
            objC_Nv_old_vec = [objC_Nv_new{:}];
            objC_Ne_old_vec = [objC_Ne_new{:}];
            objC_Nv_old_vec(objC_VertexNumR) = [];
            objC_Ne_old_vec(objB_EdgeNumR) = [];
            objC_Nv_new_vec = 1:length(objC_Nv_old_vec);
            objC_Ne_new_vec= 1:length(objC_Ne_old_vec);

            % Update edge element numbering 
            Ports_edge_elNum = [PortsTot_tmp(Ports_edge_locIdx).ElementNumber]; % old element numbers before reduced incidence matrix 
            [tf_edge, loc_edge] = ismember(Ports_edge_elNum,objC_Ne_old_vec); % mapping indicies from old to new 
            Ports_edge_elNum_new = objC_Ne_new_vec(loc_edge(tf_edge)); % new element numbers from mapping

            % Identify edge ports that need to be removed
            Ports_num_remove = Ports_edge_locIdx(~tf_edge); 
            Ports_edge_locIdx = Ports_edge_locIdx(tf_edge);

            % Map edge element numbering 
            Ports_vertex_elNum = [PortsTot_tmp(Ports_vertex_locIdx).ElementNumber];
            [tf_vertex, loc_vertex] = ismember(Ports_vertex_elNum,objC_Nv_old_vec);
            Ports_vertex_elNum_new = objC_Nv_new_vec(loc_vertex(tf_vertex));

            % Map vertex element numbering 
            Ports_num_remove = [Ports_num_remove, Ports_vertex_locIdx(~tf_vertex)];
            Ports_vertex_locIdx = Ports_vertex_locIdx(tf_vertex);

            % Update edge element numbering
            for i = 1:length(Ports_edge_locIdx)
                PortsTot_tmp(Ports_edge_locIdx(i)).ElementNumber = Ports_edge_elNum_new(i);
            end

            % Update vertex element numbering
            for i = 1:length(Ports_vertex_locIdx)
                PortsTot_tmp(Ports_vertex_locIdx(i)).ElementNumber = Ports_vertex_elNum_new(i);
            end

            % Remove ports 
            PortsTot_tmp(Ports_num_remove) = [];

            PortsNew = PortsTot_tmp;

            %% Update Input Array
            InputVars_new = [Inputs_new{:}]';
            NumInputVars = length(InputVars_new);

            % Update Input Objects
            for i = 1:NumInputVars
                NewInput(i) = InputTot(i);
                NewInput(i).VariableName = InputVars_new(i);
            end

            % Update Edge and Vertex Equations 
            for i = 1:NumComp
                EdgeNums = objC_Ne_new{i};
                VertexNums = objC_Nv_new{i};

                % Update Edge Objects
                for j = 1:length(EdgeNums)
                    EdgeTot(EdgeNums(j)).EdgeEq = replace(EdgeTot(EdgeNums(j)).EdgeEq,Inputs_old{i},Inputs_new{i});
                end

                % Update Vertex Objects
                for j = 1:length(VertexNums)
                    VertexTot(VertexNums(j)).CapacitanceEq = replace(VertexTot(VertexNums(j)).CapacitanceEq,Inputs_old{i},Inputs_new{i});
                end

            end

            %% Create New Edge and Vertex Arrays 
            EdgeTot(objB_EdgeNumR) = [];
            VertexTot(objC_VertexNumR) = [];

            %% Reconstruct Each Edge 
            for i = 1:length(EdgeTot)
                EdgeName_tmp = EdgeTot(i).EdgeName;
                EdgeEq_tmp = EdgeTot(i).EdgeEq;
                if EdgeTot(i).EdgeType == gmt_EdgeType.External
                    EdgeNew(i) = gmt_Edge(EdgeName_tmp,EdgeEq_tmp,"External");
                else
                    EdgeNew(i) = gmt_Edge(EdgeName_tmp,EdgeEq_tmp);
                end
            end

            %% Reconstruct Each Vertex
            for i = 1:length(VertexTot)
                VertexName_tmp = VertexTot(i).VertexName;
                CapEq_tmp = VertexTot(i).CapacitanceEq;

                if ~isempty(VertexTot(i).Units)
                    varargin2 = [{"Units"}, {VertexTot(i).Units}]; 
                else
                    varargin2 = [];
                end

                if VertexTot(i).VertexType == gmt_VertexType.External && ~isempty(varargin2)
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp,"External",true,varargin2{:});
                elseif VertexTot(i).VertexType == gmt_VertexType.External
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp,"External",true);
                elseif ~isempty(varargin2)
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp,varargin2{:});
                else
                    VertexNew(i) = gmt_Vertex(VertexName_tmp,CapEq_tmp);
                end
            end

            %% Build Graph Model 
            sys = gmt_Graph(CombineName,EdgeMatrixNew,EdgeNew,VertexNew,ParameterNew,NewInput,PortsNew,varargin{:});

          end

        %% Variable Input Argument Data Parsing 
        function params = gmt_parseSuperclass(obj,varargin)
            
            % Variable Input Parsing 
            p = inputParser;
            p.KeepUnmatched = true;
            addParameter(p, 'ModelParameters',[], @(x) isa(x,'gmt_Parameter'));
            addParameter(p, 'SystemModel',false, @(x) islogical(x) && isscalar(x));
            addParameter(p, 'InitCon', [], @(x) isnumeric(x) && size(x,2) == obj.Properties.NvD && size(x,1) == 1);
            addParameter(p, 'BuildSim', [], @(x) isstring(x));
            parse(p, varargin{:});
            params = p.Results;
            
        end

    end
end
