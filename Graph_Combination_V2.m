clear all
close all

% Edge Combinations 
% Format System = EdgeCombine(Object A, Object B, [Edge_A(#),Edge_B(#)],'Priority',"First"]

% Vertex Combinations
% Format System = VertexCombine(Object A, Object B, [Vertex_A(#),Vertex_B(#)],'Priority',"First"]

% General Algorithm Structure 

% First Create Combined Incidence Matrices (A,B)
    % Edge Case Special 
        % Can only have one zero eigenvalue for eig(A,A') if more than one zero, indicates multiple components or subgraphs, we only want one subgraph
        % Other words need an algorithm that makes eig(A,A') only have one zero.
    % Vertex Case Straight Forward 
        % Create new matrix C = zeros(size(A,1)+size(B,1)-1,size(A,2)+size(B,2))
        % Map large of A and B onto C, if same size, pick first entry
        % Add small matrix columns entries from common row onto new matrix
        % Add remaining parts of small matrices onto new matrix
      
% What about creating to seperate matrices to append edge and vertex data?

% Second Combine Equations  
    % Edge Case 
        % Compare Equations 
        % Compare Conservation 
    % Vertex Case 
        % Compare Equations 
        % Compare Capacitance 
        % Compare Conservation 

% Create Final Model 
    % Make sure aligns with incidence matrix 

% Common Vertices Combination 

    M1 = [-1 -1; 0 1; 1 0];
    %M2 = [1 0 0 0; 0 1 0 0; 0 0 1 0 ; 0 0 0 1; -1 -1 -1 -1];
    M2 = [-1 -1; 0 1; 1 0];

    % Common Row Input
    cm_r = [1, 2];
    
    % Determine Bigger Matrix 
    if numel(M1) > numel(M2)
        A = M1;
        B = M2;
        
    else
        A = M2;
        B = M1;
        cm_r = [cm_r(2),cm_r(1)];
    end
    
    % Compute Each Matrix Sizes  
    sz_A_r = size(A,1);
    sz_A_c = size(A,2);
    sz_B_r = size(B,1);
    sz_B_c = size(B,2);
    sz_C_r = sz_A_r + sz_B_r - 1;
    sz_C_c = sz_A_c + sz_B_c;
    
    % Create New Matrix of Zeros 
    C = zeros(sz_C_r,sz_C_c);
    
    % Impose Large Matrix onto New Matrix (C)
    C(1:sz_A_r,1:sz_A_c) = A;
    
    % Add Common Row from B to New Matrix (C)
    C(cm_r(1),(sz_A_c+1):(sz_A_c+sz_B_c))= B(cm_r(2),:);
    
    % Append Remaining Data Points To End of New Matrix 
    B(cm_r(2),:) = []; 
    C((sz_A_r+1):end,(sz_A_c+1):(sz_A_c+sz_B_c))= B;

    % Need Method To Account of Vertex Data and Edge Data Changes 
    
    % Graph Properites 
    lap_det = det(C*C');
    lap_eig = eig(C*C');
    Nc = size(lap_eig(lap_eig<=eps("single")),1);
    
    % Create Graph Object
    [G, Nv, Ne] = gmtbGraph(C);
    
    % Plot for Comparison
    figure
    plot(G,'Layout','force')

% Common Edge Case 
% Organize s.t. the common edge is the last column in the first matrix, and first column in second matrix
% Stack Matrices 
% Perform Connectivity Analysis Using Repeated Zero Eigenvalues (i.e. we do not want repeating zero eigenvalues) 
% The problem is there can only be one positive or one negative value in the connect column column, all others have must have the same sign. 
clear all

M1 = [1	0	0	0	0	0	0;
0	1	0	0	-1	0	0;
0	0	1	0	0	-1	0;
0	0	0	1	1	1	-1;
0	0	0	0	0	0	1;
-1	-1	-1	-1	0	0	0];
[G, Nv, Ne] = gmtbGraph(M1);
figure
plot(G,'Layout','force')

M2 = [-1	0	-1	1;
1	-1	0	0;
0	1	1	0;
0	0	0	-1];
[G, Nv, Ne] = gmtbGraph(M2);
figure
plot(G,'Layout','force')

% M1 = [-1 -1; 0 1; 1 0];
% %M2 = [1 0 0 0; 0 1 0 0; 0 0 1 0 ; 0 0 0 1; -1 -1 -1 -1];
% M2 = [-1 -1; 0 1; 1 0];


%% Algorithm To Determine Possible Edge Connections 
% These are the number of combinations to connect these graphs 
% If a user does not define it this way, these are not valid graph combinations 

tic 
if numel(M1) > numel(M2)
    A = M1;
    B = M2;
else
    A = M2;
    B = M1;
end

% Compute Each Matrix Sizes  
sz_A_r = size(A,1);
sz_A_c = size(A,2);
sz_B_r = size(B,1);
sz_B_c = size(B,2);
sz_C_r = sz_A_r + sz_B_r;
sz_C_c = sz_A_c + sz_B_c - 1;

% Create New Matrix of Zeros 
D = zeros(sz_C_r,sz_C_c);

idx = 1;

close all
% Search Each Edge Combination in A and B 
for k = 1:sz_A_c
    for l = 1:sz_B_c

        % Creat Combination Vector
        cm_c = [k, l];

        % Rearrange Columns of A
        A_c_tmp = 1:1:sz_A_c;
        A_c_tmp(:,cm_c(1)) = [];
        A_tmp = [A(:,A_c_tmp),A(:,cm_c(1))];
        % 
        % [G, Nv, Ne] = gmtbGraph(A_tmp);
        % figure
        % plot(G,'Layout','force')
        % 
        % Rearrange Columns of B
        B_c_tmp = 1:1:sz_B_c;
        B_c_tmp(:,cm_c(2)) = [];
        B_tmp = [B(:,cm_c(2)), B(:,B_c_tmp)];

        % [G, Nv, Ne] = gmtbGraph(B_tmp);
        % figure
        % plot(G,'Layout','force')

        D(1:sz_A_r,1:sz_A_c) = A_tmp;
        D(sz_A_r+1:sz_C_r,sz_A_c:sz_C_c) = B_tmp;
        
        % Determine Non-Zero Rows at Edge Connection for Each Matrix
        % This limits the search space as these are the only possible vertices to remove
        % One vertice must be removed from A and one vertice must be removed from B 
        nz_v_a = find(A_tmp(:,sz_A_c)); % Number of Non-Zero Vertices at Edge Connection in Matrix A
        nz_v_b = find(B_tmp(:,1)); % Number of Non-Zero Vertices at Edge Connection in Matrix B

        % Search Non-Zero Vertices at Edge Connection in Matrix A
        for i = 1:length(nz_v_a)
            % Search Non-Zero Vertices at Edge Connection in Matrix B
            for j = 1:length(nz_v_b)
                % Compute rows to remove 
                va_r = nz_v_a(i); 
                vb_r = nz_v_b(j) + sz_A_r; % Offset based on matrix A position 
                % Assign temporary matrix 
                C_tmp = D;
                % Remove rows 
                C_tmp([va_r, vb_r],:) = [];
                % Compute Laplacian 
                Lap_tmp = C_tmp*C_tmp';
                % Compute Laplacian Eigenvalues
                Lap_eig_tmp = eig(Lap_tmp,"nobalance");
                % Compute Zero Eigenvalue Multiplicity 
                zero_eig_mult = sum(find(Lap_eig_tmp < eps('single')));
                % If a connected graph store the pairs 
                % if all([zero_eig_mult == 1, sum(sum(Lap_tmp, 1)) == 0, sum(sum(Lap_tmp,2)) == 0])
                    [G, Nv, Ne] = gmtbGraph(C_tmp);
                    valid_ec(idx,:) = [size(C_tmp,1), size(C_tmp,2), Nv, Ne, det(C_tmp*C_tmp'), zero_eig_mult, size(C_tmp*C_tmp',2)-rank(C_tmp*C_tmp'), k, l, va_r, vb_r, sum(sum(C_tmp, 1)), sum(sum(C_tmp,2)), sum(sum(C_tmp*C_tmp',1)), sum(sum(C_tmp*C_tmp',2)), max(sum(C_tmp*C_tmp',1)), max(sum(C_tmp*C_tmp',2)), min(sum(C_tmp*C_tmp',1)), min(sum(C_tmp*C_tmp',2)),Lap_eig_tmp'];
                    figure('Visible', 'off');
                    plot(G,'Layout','force')
                    fileName = strcat('GraphCombination_',string(datetime('today', 'Format', 'MMddyyyy')),'_Test_Num_',num2str(idx),'.png');
                    saveas(gcf,fileName)
                    close all
                    idx = idx + 1;
                % end
            end
        end
    end
end

table_header = {'M3 Nv','M3 Ne','G3 Nv','G3 Ne','Laplacian Determinant','Zero Eigenvalue Multiplicity','n - rank(Lap)','M1 Edge','M2 Edge','M1 Vertex','M2 Vertex','Incidence Matrix Row Sum','Incidence Matrix Column Sum','Laplacian Matrix Row Sum','Laplacian Matrix Column Sum','Max Laplacian Matrix Row Sum','Max Laplacian Matrix Column Sum','Min Laplacian Matrix Row Sum','Min Laplacian Matrix Column Sum',...
    'Laplacian Eigenvalue 1','Laplacian Eigenvalue 2','Laplacian Eigenvalue 3','Laplacian Eigenvalue 4','Laplacian Eigenvalue 5','Laplacian Eigenvalue 6','Laplacian Eigenvalue 7' ,'Laplacian Eigenvalue 8'};
valid_ec_tb = array2table(valid_ec,"VariableNames",table_header);
writetable(valid_ec_tb,'GraphCombination_Experiment_121912025.xlsx')    

sing_det_zero_rs = all([valid_ec(:,5)==0, valid_ec(:,14)==0, valid_ec(:,15)==0],2);
nonsing_det_zero_rs = all([valid_ec(:,5)~=0, valid_ec(:,14)==0, valid_ec(:,15)==0],2);
sing_det_nonzero_rs = all([valid_ec(:,5)==0, valid_ec(:,14)~=0, valid_ec(:,15)~=0],2);
nonsing_det_nonzero_rs = all([valid_ec(:,5)~=0, valid_ec(:,14)~=0, valid_ec(:,15)~=0],2);

nonsing_det_zeroeig_mult_1 = all([valid_ec(:,5)~=0, valid_ec(:,6)~=0],2);
nonsing_det_zeroeig_mult_0 = all([valid_ec(:,5)~=0, valid_ec(:,6)==0],2);
nonsing_det_zeroeig_mult_2 = all([valid_ec(:,5)~=0, valid_ec(:,6)>1],2);

sing_det_zeroeig_mult_1 = all([valid_ec(:,5)==0, valid_ec(:,6)~=0],2);
sing_det_zeroeig_mult_0 = all([valid_ec(:,5)==0, valid_ec(:,6)==0],2);
sing_det_zeroeig_mult_2 = all([valid_ec(:,5)==0, valid_ec(:,6)>1],2);

m3_nv_g3_nv_eq = all(valid_ec(:,1) == valid_ec(:,3),2);
m3_ne_g3_ne_eq = all(valid_ec(:,2) == valid_ec(:,4),2);
complete_g = all([m3_nv_g3_nv_eq == 1, m3_ne_g3_ne_eq == 1],2);

complete_vs_zero_rc_sum = all([complete_g ==1, valid_ec(:,14)==0, valid_ec(:,15)==0] ,2);

num_sing_det_zero_rs = sum(sing_det_zero_rs);
num_nonsing_det_zero_rs = sum(nonsing_det_zero_rs);
num_sing_det_nonzero_rs = sum(sing_det_nonzero_rs);
num_nonsing_det_nonzero_rs = sum(nonsing_det_nonzero_rs);

sum_data_1 = [num_sing_det_zero_rs, num_nonsing_det_zero_rs; num_sing_det_nonzero_rs, num_nonsing_det_nonzero_rs];

num_nonsing_det_zeroeig_mult_1 = sum(nonsing_det_zeroeig_mult_1);
num_nonsing_det_zeroeig_mult_0 = sum(nonsing_det_zeroeig_mult_0);
num_nonsing_det_zeroeig_mult_2 = sum(nonsing_det_zeroeig_mult_2);

num_sing_det_zeroeig_mult_1 = sum(sing_det_zeroeig_mult_1);
num_sing_det_zeroeig_mult_0 = sum(sing_det_zeroeig_mult_0);
num_sing_det_zeroeig_mult_2 = sum(sing_det_zeroeig_mult_2);

sum_data_2 = [num_nonsing_det_zeroeig_mult_1, num_nonsing_det_zeroeig_mult_0, num_nonsing_det_zeroeig_mult_2; num_sing_det_zeroeig_mult_1, num_sing_det_zeroeig_mult_0, num_sing_det_zeroeig_mult_2];


% Common Column Input
cm_c = [7, 4];

%Determine Bigger Matrix 
if numel(M1) > numel(M2)
    A = M1;
    B = M2;
else
    A = M2;
    B = M1;
    cm_c = [cm_c(2),cm_c(1)];
end

% Perform Check 
if any(res(:,1) == cm_c(1)) && any(res(:,2) == cm_c(2)) 
    res_r1 = res(:,1);
    res_r2 = res(:,2);
    idx_r1 = find(res_r1 == cm_c(1));
    idx_r2 = find(res_r2 == cm_c(2));
    idx_r3 = intersect(idx_r1, idx_r2);
    if size(idx_r3,1) > 1 
        error("Multiple Vertices Can Be Removed For Same Edge Connection")
    else
        v1 = res(idx_r3,4);
        v2 = res(idx_r3,5);
    end
else
    error("Specified Edge Connections Are Not Valid, Valid Edge Connections Are Stored In X Variable")
end

% Compute Each Matrix Sizes  
sz_A_r = size(A,1);
sz_A_c = size(A,2);
sz_B_r = size(B,1);
sz_B_c = size(B,2);
sz_C_r = sz_A_r + sz_B_r;
sz_C_c = sz_A_c + sz_B_c - 1;

% Create New Matrix of Zeros 
C = zeros(sz_C_r,sz_C_c);

% Rearrange Columns of A
A_c_tmp = 1:1:sz_A_c;
A_c_tmp(:,cm_c(1)) = [];
A_tmp = [A(:,A_c_tmp),A(:,cm_c(1))];

% Rearrange Columns of B
B_c_tmp = 1:1:sz_B_c;
B_c_tmp(:,cm_c(2)) = [];
B_tmp = [B(:,cm_c(2)), B(:,B_c_tmp)];

% Update C Matrix
C(1:sz_A_r,1:sz_A_c) = A_tmp;
C(sz_A_r+1:sz_C_r,sz_A_c:sz_C_c) = B_tmp;

C([v1,v2],:) = [];

% Graph Properites 
lap_det = det(C*C')
lap_eig = eig(C*C')
Nc = size(lap_eig(lap_eig<=eps("single")),1)

% Create Graph Object
[G, Nv, Ne] = gmtbGraph(C);

% Plot for Comparison 
figure
plot(G,'Layout','force')

indeg = indegree(G);
outdeg = outdegree(G)
adj = adjacency(G)
L = outdeg - adj
eig(L)

% Internal Functions
outdeg_ = outdegFun(C)
indeg_ = indegFun(C)
deg_ = degFun(C)
adj_ = adjMatrix(C)
% cadj_ = cadjMatrix(C)
L_ = deg_ - adj_
L__ = lapFun(C);
lap_eig_ = eig(L_)
lap_eig__ = eig(L__)

deg = degFun(abs(C))
adj = adjMatrix(abs(C))
L_undi = deg - adj;
lap_uni_eig = eig(L_undi);
lap_uni_eig_ = eig((abs(C))*abs(C)')

function adj = adjMatrix(M)

Nv = size(M,1);
Ne = size(M,2);
adj = zeros(Nv);

    for i = 1:Nv
        for j = 1:Nv
            for k = 1:Ne
                if i ~= j 
                    if (abs(M(j,k)) > 0) && (abs(M(i,k)) > 0)
                    adj(i,j) = 1;
                    end
                end
            end
        end
    end

end

function outdeg = outdegFun(M)

Nv = size(M,1);
outdeg = zeros(Nv);

    for i = 1:Nv
            outdeg(i,i) = sum(M(i,:) == -1);
    end

end

function indeg = indegFun(M)

Nv = size(M,1);
indeg = zeros(Nv);

    for i = 1:Nv
            indeg(i,i) = sum(M(i,:) == 1);
    end

end

function deg = degFun(M)

Nv = size(M,1);
deg = zeros(Nv);

    for i = 1:Nv
            deg(i,i) = sum(abs(M(i,:)) == 1);
    end

end

function lap = lapFun(M)

Nv = size(M,1);
lap = zeros(Nv);

    for i = 1:Nv
        for j = 1:Nv
            if i == j 
                lap(i,j) = sum(abs(M(i,:)) == 1);
            else
                log_tmp = all([(M(i,:) + M(j,:)) == 0  ; (abs(M(i,:)) > 0) ; (abs(M(j,:)) > 0)],1);
                if max(log_tmp) > 0 
                    lap(i,j)  = -1; 
                end
            end
        end
    end
end