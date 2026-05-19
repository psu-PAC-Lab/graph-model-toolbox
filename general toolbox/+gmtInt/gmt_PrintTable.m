function gmt_PrintTable(T, centerCols)
% gmt_PrintTable Prints a MATLAB table without quotes or braces.
%
% Inputs:
%   T          - MATLAB table object
%   centerCols - logical array, true = center that column

    headers = T.Properties.VariableNames;
    nCols   = numel(headers);
    nRows   = height(T);

    if nargin < 2 || isempty(centerCols)
        centerCols = [false, true(1, nCols - 1)];
    end

    assert(istable(T), 'Input T must be a MATLAB table.');
    assert(numel(centerCols) == nCols, ...
        'centerCols must have one entry per table column.');

    cols = cell(1, nCols);

    for c = 1:nCols
        val = T.(headers{c});

        if isnumeric(val)
            cols{c} = string(arrayfun(@num2str, val, ...
                'UniformOutput', false));
        else
            cols{c} = string(val);
        end
    end

    colWidth = zeros(1, nCols);

    for c = 1:nCols
        dataWidth      = max(strlength(cols{c})) + 2;
        dataWidth      = max(dataWidth, 4);
        headerWords    = strsplit(headers{c}, ' ');
        minHeaderWidth = max(cellfun(@numel, headerWords)) + 2;
        colWidth(c)    = max(dataWidth, minHeaderWidth);
    end

    wrappedHeaders = cell(1, nCols);
    maxHeaderLines = 1;

    for c = 1:nCols
        wrappedHeaders{c} = wrapHeader(headers{c}, colWidth(c) - 1);
        maxHeaderLines = max(maxHeaderLines, numel(wrappedHeaders{c}));
    end

    for c = 1:nCols
        while numel(wrappedHeaders{c}) < maxHeaderLines
            wrappedHeaders{c}{end+1} = '';
        end
    end

    fprintf('\n');

    for row = 1:maxHeaderLines
        for c = 1:nCols
            line = wrappedHeaders{c}{row};

            if centerCols(c)
                fprintf('%s', centerStr(line, colWidth(c)));
            else
                fprintf('%-*s', colWidth(c), line);
            end
        end
        fprintf('\n');
    end

    for c = 1:nCols
        fprintf('%s ', repmat('_', 1, colWidth(c) - 1));
    end

    fprintf('\n');

    for i = 1:nRows
        for c = 1:nCols
            if centerCols(c)
                fprintf('%s', centerStr(cols{c}(i), colWidth(c)));
            else
                fprintf('%-*s', colWidth(c), cols{c}(i));
            end
        end
        fprintf('\n');
    end

    fprintf('\n');

end


function lines = wrapHeader(str, maxWidth)

    words   = strsplit(str, ' ');
    lines   = {};
    current = '';

    for w = 1:numel(words)
        word = words{w};

        if isempty(current)
            current = word;
        elseif numel(current) + 1 + numel(word) <= maxWidth
            current = [current, ' ', word]; %#ok<AGROW>
        else
            lines{end+1} = current; %#ok<AGROW>
            current = word;
        end
    end

    if ~isempty(current)
        lines{end+1} = current;
    end

end


function str = centerStr(str, width)

    str      = char(str);
    strLen   = numel(str);
    padTotal = max(0, width - strLen);
    padLeft  = floor(padTotal / 2);
    padRight = padTotal - padLeft;

    str = [repmat(' ', 1, padLeft), ...
           str, ...
           repmat(' ', 1, padRight)];

end