P = ["a" "b"; "c" "d"];
myFunc(1, 2, 'Params', P)

function myFunc(x, y, varargin)

    p = inputParser;

    addParameter(p, ...
        'Params', strings(0,0), ...
        @(s) isstring(s) && ismatrix(s));

    parse(p, varargin{:});

    params = p.Results.Params;

    disp(params)
end