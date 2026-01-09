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

for k = 1:sz_A_c
    for l = 1:sz_B_c

        % Creat Combination Vector
        cm_c = [k, l];

        % Rearrange Columns of A
        A_c_tmp = 1:1:sz_A_c;
        A_c_tmp(:,cm_c(1)) = [];
        A_tmp = [A(:,A_c_tmp),A(:,cm_c(1))];
        
        % Rearrange Columns of B
        B_c_tmp = 1:1:sz_B_c;
        B_c_tmp(:,cm_c(2)) = [];
        B_tmp = [B(:,cm_c(2)), B(:,B_c_tmp)];

        D(1:sz_A_r,1:sz_A_c) = A_tmp;
        D(sz_A_r+1:sz_C_r,sz_A_c:sz_C_c) = B_tmp;
        
        % Determine Non-Zero Rows. 
        nz_v = find(D(:,sz_A_c));

        % A graph with one connection has one repeating zero eigenvalue. 
        % Only one zero eigenvalue implies one reachable set 
        lap_eig_c = zeros(length(nz_v));
        for i = 1:length(nz_v)
            for j = 1:length(nz_v)
                if nz_v(i) <= sz_A_r && nz_v(j) >= sz_A_r+1
                    if sum(abs(D(nz_v(i),:))) == 1 && sum(abs(D(nz_v(j),:))) == 1
                        C_tmp = D;
                        C_tmp([nz_v(i), nz_v(j)],:) = [];
                        C_tmp_c = C_tmp(:,sz_A_c);
                        lap_eig_tmp = eig(C_tmp*C_tmp');
                        lap_eig_c(i,j) = size(lap_eig_tmp(lap_eig_tmp<=eps("single")),1);
                    end
                end
            end
        end

        [X, Y] = find(lap_eig_c);

        if sum(sum(lap_eig_c)) > 0 

            res(idx,:) = [k, l, sum(sum(lap_eig_c)), nz_v(X)', nz_v(Y)'];
    
            idx = idx + 1;

        end

    end
end
    
toc

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