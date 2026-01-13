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
        States string % String array of system state variable names
        Outputs string = [] % String array of system output variable names
        %Disturbances string = [] % String array of system disturbance variable names
        ModelParameters gmt_ModelParameter % Model parameters object to manage model parameterization  
        EdgeTable table % Human readable summary of edge data
        VertexTable table % Human readable summary of vertex data
        SystemEquations string % Symbolic system of equations for system
        MassMatrix % Mass Matrix for ODE Solver 
        Ports gmt_Port % Object containing graph model connection points
        MfileCode 
        ModelType gmt_ModelType % Determines model type for post analysis
    end

    %% Public Methods 
    methods (Access = public)
        %% Constructor Graph 
        function obj = gmt_Graph(Name,EdgeMatrix,Edges,Vertices,Parameters)
            % Generates instance of gmt_Graph object
            % Assign Data
            obj.Name = Name;
            obj.EdgeMatrix = EdgeMatrix;
            obj.Edges = Edges;
            obj.Vertices = Vertices;
            obj.ModelParameters = Parameters;

            % Compute Basic Graph Properties (Nv, Ne, and M) 
            obj.Properties = gmt_GraphProperties(obj);

            % Graph Update
            obj = gmt_GraphUpdate(obj);

            % Model Update  
            obj = gmt_ModelUpdate(obj);

            % Compute and Update Edge and Vertex Table Data 
            %obj = gmt_EdgeVertexTable(obj);

           
        end

        %% Edge and Vertex Table Assembly
        % Assembles Vertex Table for readability 
        function obj = gmt_TableUpdate(obj)
            % Vertex Table
            varNames_tmp = ["Vertex Name","Vertex Type","Vertex State Variable","Capacitance Equation","Power Equation"];
            for idx_tmp = 1:length(varNames_tmp)
                varTypes_tmp(1,idx_tmp) = {'string'};
            end
            sz = [obj.Properties.Nv length(varNames_tmp)];
            table_tmp = table('Size',sz,'VariableTypes',varTypes_tmp,'VariableNames',varNames_tmp);
            % Assembly Table Data 
            for i = 1:obj.Properties.Nv
                table_tmp(i,1) = {obj.Vertices(i).VertexName};
                table_tmp(i,2) = {obj.Vertices(i).VertexType};
                table_tmp(i,3) = {obj.Vertices(i).GenStateVariable};
                table_tmp(i,4) = {obj.Vertices(i).CapacitanceEq};
                table_tmp(i,5) = {obj.Vertices(i).Power_Eq};
            end
            obj.VertexTable = table_tmp;

            % Edge Table
            varNames_tmp = ["Edge Name","Edge Type","Edge Equation"];
            for idx_tmp = 1:length(varNames_tmp)
                varTypes_tmp(1,idx_tmp) = {'string'};
            end
            sz = [obj.Properties.Ne length(varNames_tmp)];
            table_tmp = table('Size',sz,'VariableTypes',varTypes_tmp,'VariableNames',varNames_tmp);
            % Assembly Table Data 
            for i = 1:obj.Properties.Ne
                table_tmp(i,1) = {obj.Edges(i).EdgeName};
                table_tmp(i,2) = {obj.Edges(i).EdgeType};
                table_tmp(i,3) = {obj.Edges(i).EdgeEq};
            end
            obj.EdgeTable = table_tmp;
        end

        %% Graph Update
        % Function creates MATLAB native graph object and updates properties for plotting  
        function obj = gmt_GraphUpdate(obj)
         
            % Note need to update naming and graph object information 

            % Vertex Color Coding
            for i = 1:obj.Properties.Nv
                Vertices_Names_tmp(i,1) = obj.Vertices(i).VertexName;
                if obj.Vertices(i).VertexType == gmt_VertexType.External
                    color_tmp(i,:) = [1 0 0];
                else
                    color_tmp(i,:) = [0 0 1];
                end
            end

            % Edge Color Coding 
            for i =1:obj.Properties.Ne
                Edges_Names_tmp(i,1) = obj.Edges(i).EdgeName;
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
        
            p = plot(obj.DiGraph,'LineWidth',1,'Layout','subspace');
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
            p.NodeFontSize = 7;
            p.EdgeFontSize = 7;
            text(p.XData+.01, p.YData+.01 ,p.NodeLabel, ...
            'VerticalAlignment','Bottom',...
            'HorizontalAlignment', 'left',...
            'FontSize', 7)
            p.NodeLabel = {}; 
        end

        function out = gmt_ModelParameters(obj)

            out = obj.ModelParameters;

        end

        %% Model Update 
        % Once all vertices, edges, and edge matrix has been defined a model can be generated 
        function obj = gmt_ModelUpdate(obj)

            % Updates graph properties object and performs validation checks
            if obj.Properties.GraphValidity.GraphValid && obj.Properties.GraphValidity.VerticesValid && obj.Properties.GraphValidity.EdgesValid
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
                    Tot_Ds_num = (1:Num_Ds) + Tot_Ds_num(end); % Compute graph specific dynamic state variable numbering 
                    if Num_Ds == 1 && strlength(extractAfter(extractBefore(Ds_var,"_dot"),"x")) == 0
                        Ds_var_tmp = strcat("x",num2str(Tot_Ds_num),"_dot");
                    else
                        Ds_var_tmp = regexprep(Ds_var, '\d+', '${num2str(Tot_Ds_num(str2double($0)))}');
                    end
                end

                if isa(Num_As,'double') && Num_As ~= 0
                    Tot_As_num = (1:Num_As) + Tot_As_num(end); % Compute graph specific algebraic state variable numbering
                    if Num_As == 1 && strlength(extractAfter(As_var,"x")) == 0
                        As_var_tmp = strcat("x",num2str(Tot_As_num));
                    else
                        As_var_tmp = regexprep(As_var, '\d+', '${num2str(Tot_As_num(str2double($0)))}');
                    end
                end

                if isa(Num_y,"double") && Num_y ~= 0
                    Tot_y_num = (1:Num_y) + Tot_y_num(end);
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
                    
                    if obj.Edges(j).NeHS > 0 && obj.Properties.M(i,j) == 1
                       obj.Edges(j) = obj.Edges(j).gmt_UpdateHeadVertexNum(i);
                       obj.Edges(j) = obj.Edges(j).gmt_UpdateGraphHeadStateVar(obj.Vertices(i).GraphStateVariables);
                     
                    elseif obj.Edges(j).NeTS > 0 && obj.Properties.M(i,j) == -1
                       obj.Edges(j) = obj.Edges(j).gmt_UpdateTailVertexNum(i);
                       obj.Edges(j) = obj.Edges(j).gmt_UpdateGraphTailStateVar(obj.Vertices(i).GraphStateVariables);
                    end
                end


            end

            % Update System Variables

            % Update System State Variables 
            obj.States = unique([obj.Vertices.GraphStateVariables]);

            % Update System Input Variables
            if ~isempty([obj.Vertices.InputVariables]) || ~isempty([obj.Edges.InputVariables])
                obj.Inputs = unique([[obj.Vertices.InputVariables],[obj.Edges.InputVariables]]);
            end

            % Update System Output Variables 
            obj.Outputs = unique([obj.Vertices.GraphOutputVariables]);

            % Update System Disturbance Variables 

            % Update Power Equation for Each Edge
            for i = 1:obj.Properties.Nv 
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
                obj.Vertices(i) = obj.Vertices(i).gmt_GraphVertexEqUpdate(PowerEq_tmp);
            end

            % Determine Equations for Stacking 
            IntVertices_idx = find([obj.Vertices.StateType] == gmt_StateType.Dynamic);
            ScalarParams_idx = find([obj.ModelParameters.ParameterType] == gmt_ParameterType.Scalar);
            LookupParams_idx = find([obj.ModelParameters.ParameterType] == gmt_ParameterType.Lookup);
            NNParams_idx = find([obj.ModelParameters.ParameterType] == gmt_ParameterType.Neural_Network);
            OutVertices_idx = find([obj.Vertices.StateType] == gmt_StateType.Algebraic);

            % Create string expression for each type
            sys_dyneq_str_tmp = [obj.Vertices(IntVertices_idx).GraphStateDerVariables]' + " = " + [obj.Vertices(IntVertices_idx).GraphVertexEq]' + ";";
            sys_algeq_str_tmp = [obj.Vertices(OutVertices_idx).GraphOutputVariables]' + " = " + [obj.Vertices(OutVertices_idx).GraphVertexEq]' + ";";

            % Stack string expression on top of each other
            sys_eq_str_tmp = [sys_dyneq_str_tmp;sys_algeq_str_tmp];

            % Create a MATLAB symbolic equation 
            obj.SystemEquations = sys_eq_str_tmp; %str2sym(sys_eq_str_tmp);
            % obj.MassMatrix = 
            % obj.SysEqnType = 

            % Determine Model Type 
            if any([obj.ModelParameters.ParameterType] == gmt_ParameterType.Lookup) || any([obj.ModelParameters.ParameterType] == gmt_ParameterType.Neural_Network)
                obj.ModelType = gmt_ModelType.Numerical;
            else
                obj.ModelType = gmt_ModelType.Analytical;
            end

            %% Create System M File
            % TASK: Make user defined input to generated this function 
            makeFunc_mfile = 1;
            if makeFunc_mfile 

                % System Function Header
                if ispc
                    user = getenv('USERNAME');
                else
                    user = getenv('USER');
                end

                sysfun_mfile_preheader = "% Code-Auto Generated By " + user + " using gmt Toolbox on " + string(datetime);

                if ~isempty(obj.Inputs)
                    sysfun_mfile_header = "function res = sysFun_" + obj.Name + "(t,y," + strjoin([obj.Inputs],",") + ")";
                else
                    sysfun_mfile_header = "function res = sysFun_" + obj.Name + "(t,y)";
                end
                sysfun_mfile_footer = "end";
    
                % System Function Input Parser 
                inputvar_list = [[obj.Vertices(IntVertices_idx).GraphStateVariables]';[obj.Vertices(OutVertices_idx).GraphOutputVariables]'];
                unpackingCode = "";
                for i = 1:length(inputvar_list)
                    unpackingCode(i) = inputvar_list(i) + " = y(" + i + ");";
                end
                
                sysfun_mfile_prefix = unpackingCode';

                % System Model Parameters Parser 

                % Scalars 
                sysfun_mfile_scalars = [obj.ModelParameters(ScalarParams_idx).Variable]' + " = " + [obj.ModelParameters(ScalarParams_idx).Data]' + ";";

                % Lookup
                if ~isempty(LookupParams_idx)

                    fields = fieldnames(obj.ModelParameters(LookupParams_idx).Data);
                    mFileLines = cell(length(fields), 1);
                    
                    % 3. Loop through fields to create "LHS = RHS;" strings
                    for i = 1:numel(fields)
                        fieldName = fields{i};
                        val = obj.ModelParameters(LookupParams_idx).Data.(fieldName); % Dynamic access
                    
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
                        mFileLines{i} = sprintf('%s = %s;', fieldName, rhs);
                    end
    
                    sysfun_mfile_lookup = string(mFileLines);

                else 

                    sysfun_mfile_lookup = [];

                end

                % Neural Networks 

                % System Output Packager 
                outputvar_list = [[obj.Vertices(IntVertices_idx).GraphStateDerVariables]';[obj.Vertices(OutVertices_idx).GraphOutputVariables]' + "_"];
                packingCode = "res = [" + strjoin(outputvar_list',";") + "];";
                sysfun_mfile_suffix = packingCode';
    
                % System Function Body 
                % Create string expression for each type
                sys_dyneq_str_tmp = [obj.Vertices(IntVertices_idx).GraphStateDerVariables]' + " = " + [obj.Vertices(IntVertices_idx).GraphVertexEq]' + ";";
                sys_algeq_str_tmp = [obj.Vertices(OutVertices_idx).GraphOutputVariables]'+ "_ = " + [obj.Vertices(OutVertices_idx).GraphVertexEq]' + "-" + [obj.Vertices(OutVertices_idx).GraphOutputVariables]' + ";";
    
                % Stack string expression on top of each other
                sys_eq_str_tmp = [sys_dyneq_str_tmp;sys_algeq_str_tmp];
    
                sysfun_mfile_body = sys_eq_str_tmp;
    
                sysfun_mfile_combined = ...
                    [
                    sysfun_mfile_preheader; ...
                    sysfun_mfile_header;...
                    sysfun_mfile_scalars;...
                    sysfun_mfile_lookup;...
                    sysfun_mfile_prefix;...
                    sysfun_mfile_body;...
                    sysfun_mfile_suffix;...
                    sysfun_mfile_footer];

                obj.MfileCode = sysfun_mfile_combined;
    
                writelines(sysfun_mfile_combined, "sysFun_" + obj.Name + ".m");
    
                % Create DAE Mass Matrix 
                obj.MassMatrix = double(diag(([obj.Vertices.StateType]==gmt_StateType.Dynamic)));

            end

        end
        
    end
    %% Graph Combination Function 
    % methods (Static)
    % 
    %     function objC = gmt_Combine(CompM_Edge,EdgeC,CompM_Vertex,VertexC)
    %         % Joe Pisani 12/19/2025 GraphTools uses concept of Ports which are user defined model connection points 
    %         % The algorithm C. Aksland uses requires specification of common vertices and edges together. 
    %         % Recommend using graph theory to combine graphs, but laplacians are not unique they can only tell us if the combined graph is correct or not. ... 
    %         % They are not invertible, meaning they are linear dependent, meaning there are multiplie solutions. 
    %         % More details on GraphTools algorithm, an incidence matrix is computed based on head and tail state defintions. 
    %         % Chris tells use we must specify the vertex pair to be removed when an edge is removed 
    %         % Do we want to use the port concept or be more generic? 
    % 
    %         % Need to update internal and external vertex and edge definition areas 
    % 
    %         % CompM is dimension {:,2}, meaning two components 
    %         CompM_Edge_len = size(CompM_Edge,1);
    %         CompM_Edge_width = size(CompM_Edge,2);
    %         EdgeC_len = size(EdgeC,1);
    % 
    %         CompM_Vertex_len = size(CompM_Vertex,1);
    %         CompM_Vertex_width = size(CompM_Vertex,1);
    %         VertexC_len = size(VertexC,1);
    % 
    %         if all([~isempty(CompM_Edge),~isempty(EdgeC),CompM_Edge_width == 2,CompM_Edge_len==EdgeC_len])
    %             % Valid Edge Connection 
    %             % Verify Class Types
    %             for i = 1:CompM_Edge_len
    %                 for j = 1:2
    %                     if isa(CompM_Edge(i,j),"gmt_Graph")
    %                         error("Not all components being combined are of class gmt_Graph")
    %                         break;
    %                     end   
    %                 end
    %             end
    % 
    %         elseif all([~isempty(CompM_Vertex),~isempty(VertexC),CompM_Vertex_width == 2,CompM_Vertex_len==VertexC_len])
    %             % Valid Vertex Connection 
    %             % Verify Class Types
    %             for i = 1:CompM_Vertex_len
    %                 for j = 1:2
    %                     if isa(CompM_Vertex(i,j),"gmt_Graph")
    %                         error("Not all components being combined are of class gmt_Graph")
    %                         break;
    %                     end
    % 
    %                 end
    %             end
    %         end
    % 
    % 
    %         % Verify The Inputs Are gmt_Graph
    % 
    %         % Compute Each Matrix Sizes  
    %         A = CompM_Edge(i,1).Properties.M;
    %         B = CompM_Edge(j,1).Properties.M;
    % 
    %         sz_A_r = size(A,1);
    %         sz_A_c = size(A,2);
    %         sz_B_r = size(B,1);
    %         sz_B_c = size(B,2);
    %         sz_C_r = sz_A_r + sz_B_r;
    %         sz_C_c = sz_A_c + sz_B_c - 1;
    % 
    %         % Create New Matrix of Zeros 
    %         C = zeros(sz_C_r,sz_C_c);
    % 
    %         idx = 1;
    % 
    %         close all
    %         % Search Each Edge Combination in A and B 
    %         for k = 1:sz_A_c
    %             for l = 1:sz_B_c
    % 
    %                 % Creat Combination Vector
    %                 cm_c = [k, l];
    % 
    %                 % Rearrange Columns of A
    %                 A_c_tmp = 1:1:sz_A_c;
    %                 A_c_tmp(:,cm_c(1)) = [];
    %                 A_tmp = [A(:,A_c_tmp),A(:,cm_c(1))];
    %                 % 
    %                 % [G, Nv, Ne] = gmtbGraph(A_tmp);
    %                 % figure
    %                 % plot(G,'Layout','force')
    %                 % 
    %                 % Rearrange Columns of B
    %                 B_c_tmp = 1:1:sz_B_c;
    %                 B_c_tmp(:,cm_c(2)) = [];
    %                 B_tmp = [B(:,cm_c(2)), B(:,B_c_tmp)];
    % 
    %                 % [G, Nv, Ne] = gmtbGraph(B_tmp);
    %                 % figure
    %                 % plot(G,'Layout','force')
    % 
    %                 D(1:sz_A_r,1:sz_A_c) = A_tmp;
    %                 D(sz_A_r+1:sz_C_r,sz_A_c:sz_C_c) = B_tmp;
    % 
    %                 % Determine Non-Zero Rows at Edge Connection for Each Matrix
    %                 % This limits the search space as these are the only possible vertices to remove
    %                 % One vertice must be removed from A and one vertice must be removed from B 
    %                 nz_v_a = find(A_tmp(:,sz_A_c)); % Number of Non-Zero Vertices at Edge Connection in Matrix A
    %                 nz_v_b = find(B_tmp(:,1)); % Number of Non-Zero Vertices at Edge Connection in Matrix B
    % 
    %                 % Search Non-Zero Vertices at Edge Connection in Matrix A
    %                 for i = 1:length(nz_v_a)
    %                     % Search Non-Zero Vertices at Edge Connection in Matrix B
    %                     for j = 1:length(nz_v_b)
    %                         % Compute rows to remove 
    %                         va_r = nz_v_a(i); 
    %                         vb_r = nz_v_b(j) + sz_A_r; % Offset based on matrix A position 
    %                         % Assign temporary matrix 
    %                         C_tmp = D;
    %                         % Remove rows 
    %                         % C_tmp([va_r, vb_r],:) = [];
    %                         % Compute Laplacian 
    %                         Lap_tmp = C_tmp*C_tmp';
    %                         % Compute Laplacian Eigenvalues
    %                         Lap_eig_tmp = eig(Lap_tmp,"nobalance");
    %                         % Compute Zero Eigenvalue Multiplicity 
    %                         zero_eig_mult = sum(find(Lap_eig_tmp < eps('single')));
    %                         % If a connected graph store the pairs 
    %                         % if all([zero_eig_mult == 1, sum(sum(Lap_tmp, 1)) == 0, sum(sum(Lap_tmp,2)) == 0])
    %                             [G, Nv, Ne] = gmtbGraph(C_tmp);
    %                             valid_ec(idx,:) = [size(C_tmp,1), size(C_tmp,2), Nv, Ne, det(C_tmp*C_tmp'), zero_eig_mult, size(C_tmp*C_tmp',2)-rank(C_tmp*C_tmp'), k, l, va_r, vb_r, sum(sum(C_tmp, 1)), sum(sum(C_tmp,2)), sum(sum(C_tmp*C_tmp',1)), sum(sum(C_tmp*C_tmp',2)), max(sum(C_tmp*C_tmp',1)), max(sum(C_tmp*C_tmp',2)), min(sum(C_tmp*C_tmp',1)), min(sum(C_tmp*C_tmp',2)),Lap_eig_tmp'];
    %                             figure('Visible', 'off');
    %                             plot(G,'Layout','force')
    %                             fileName = strcat('GraphCombination_',string(datetime('today', 'Format', 'MMddyyyy')),'_Test_Num_',num2str(idx),'.png');
    %                             saveas(gcf,fileName)
    %                             close all
    %                             idx = idx + 1;
    %                         % end
    %                     end
    %                 end
    %             end
    %         end
    %     end
    % end
end
