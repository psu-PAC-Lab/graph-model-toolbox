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