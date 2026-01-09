M1 = [1	0	0	0	0	0	0;
0	1	0	0	-1	0	0;
0	0	1	0	0	-1	0;
0	0	0	1	1	1	-1;
0	0	0	0	0	0	1;
-1	-1	-1	-1	0	0	0];

M2 = [-1	0	-1	1;
1	-1	0	0;
0	1	1	0;
0	0	0	-1];



%% Graph Connections 
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
                % if sum(sum(C_tmp, 1)) == 0 && sum(sum(C_tmp,2)) == 0 
                    [G, Nv, Ne] = gmtbGraph(C_tmp);
                    valid_ec(idx,:) = [size(C_tmp,1), size(C_tmp,2), Nv, Ne, det(C_tmp*C_tmp'), zero_eig_mult, size(C_tmp*C_tmp',2)-rank(C_tmp*C_tmp'), k, l, va_r, vb_r, sum(sum(C_tmp, 1)), sum(sum(C_tmp,2)), sum(sum(C_tmp*C_tmp',1)), sum(sum(C_tmp*C_tmp',2)), Lap_eig_tmp'];
                    % figure('Visible', 'off');
                    % plot(G,'Layout','force')
                    % fileName = strcat('GraphCombination_',string(datetime('today', 'Format', 'MMddyyyy')),'_Test_Num_',num2str(idx),'.png');
                    % saveas(gcf,fileName)
                    % close all
                    idx = idx + 1;
                % end
            end
        end
    end
end