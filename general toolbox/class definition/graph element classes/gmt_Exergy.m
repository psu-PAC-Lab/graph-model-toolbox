%% gmt_Exergy
% Defines an exergy equation object

classdef gmt_Exergy

properties
    ExergyEq
end

methods

        %% Constructor Method
        % Generates instance of gmt_Exergy object
        function obj = gmt_Exergy(ExergyEq)
            % add verification that syntax produces functional equation 
            obj.ExergyEq = ExergyEq;
        end
    
end

end