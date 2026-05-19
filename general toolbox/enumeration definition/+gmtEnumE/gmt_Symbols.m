%% gmt_Symbols
% Class used to define symbol parameters for intelligent analysis

classdef gmt_Symbols

    properties (SetAccess = private)
       Symbols string = ["+", "-", "*", "/" ,"^"] 
    end
    
    methods
        %% Constructor Method
        function obj = gmt_Symbols()

        end
    end

end