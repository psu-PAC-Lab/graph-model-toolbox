function [G, Nv, Ne] = gmtbGraph(M)

% Edge Calculations 
edges = [];
for j = 1:size(M, 2) % Iterate through each edge (column of I)
    % Find the indices of the two non-zero entries in the column
    node_indices = find(M(:, j));
    if numel(node_indices) == 2
        if M(node_indices(1),j) == -1 
        s = node_indices(1);
        t = node_indices(2);
        else
        s = node_indices(2);
        t = node_indices(1);
        end
        edges = [edges; s, t]; % Add the edge to the list
    end
end



G = digraph(edges(:,1), edges(:,2));

% Calculate Incidence Matrix Characteristics 
Ne = length(edges);
Nv = max(max(edges));

end
