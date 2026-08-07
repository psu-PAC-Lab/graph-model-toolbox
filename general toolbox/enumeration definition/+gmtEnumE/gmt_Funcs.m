%% gmt_Funcs
% Class used to define MATLAB function for intelligent analysis

classdef gmt_Funcs

    properties (SetAccess = private)
       Funcs string = ["sin","cos","tan","asin","acos","atan", ...
                        "sind","cosd","tand","asind","acosd","atand", ...
                        "sinh","cosh","tanh","asinh","acosh","atanh", ...
                        "exp","log","log10","log2","sqrt","nthroot", ...
                        "abs","sign","floor","ceil","round","mod","rem", ...
                        "min","max","mean","sum","prod","diff"];
    end
    
    methods
        %% Constructor Method
        function obj = gmt_Funcs()

        end
    end

end