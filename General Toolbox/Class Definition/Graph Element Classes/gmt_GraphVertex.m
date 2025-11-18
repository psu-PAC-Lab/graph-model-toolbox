%% gmt_GraphVertex
% Class used to define vertex properties in graph model

classdef gmt_GraphVertex
    
    properties
        Name string % User specified name to define an vertex object
        CapEq string % User specified name formula defining the vertex capacitance equation
    end

    properties (SetAccess = protected)
        StateType string % Internally specified state type based on user define capitance equation formulation
        VertexType string = gmt_VertexType.Unassigned % Internally specified vertex type assigned during graph model generation
        GenStateVariable string = "Unassigned" % Internally specified state variable x1, x2, x3, etc. assigned during graph model generation
        UserStateVariable string = "Unassigned" % User specified state variable name for human readability assigned during graph model generation
        Capacitance string % Internally computed capacitance based on user defined capacitance equation 
        Power_Eq string % Internally specified vertex total power equation after post processing edge equations, and edge matrix
        X_Dot_Eq string % Internall computed state derivative equation
    end

    methods
    
        %% Constructor Method
        function obj = gmt_GraphVertex(Name,CapEquation)
            % Generates instance of gmt_GraphVertex object
            Name_data_valid = isa(Name,'string');
            CapEquation_data_valid = isa(CapEquation,'string');
    
            % Determine if name input is empty
            if Name_data_valid
                Name_blank = logical(strlength(Name)==0);
                if Name_blank 
                    error("Name field is empty")
                end
            else
                error("Name field data type is not a string")
            end
    
            % Determine if CapEquation input is empty
            if CapEquation_data_valid
                CapEquation_blank = logical(strlength(CapEquation)==0);
                if CapEquation_blank
                    error("CapEquation field is empty")
                end
            else 
                error("CapEquation field data type is not a string")
            end
    
            obj.Name = Name; % Assigns input variable Name to Edge_Name property 
            obj.CapEq = CapEquation; % Assigns input variable Equation to Edge_Eq property 
    
            if contains(CapEquation,"x_dot") == true
                obj.StateType = gmt_StateType.Dynamic;
            else
                obj.StateType = gmt_StateType.Algebraic;
            end
            
            obj = gmt_ComputeCapacitance(obj);
    
        end
    
        %% Function to Update Vertex Type
        function obj = gmt_VertexTypeUpdate(obj,BoundaryVertex_Status)
            % Updates vertex type based on edge matrix analysis
            if BoundaryVertex_Status == true && obj.StateType == gmt_StateType.Dynamic
                obj.VertexType = gmt_VertexType.Internal;
            elseif BoundaryVertex_Status == true && obj.StateType == gmt_StateType.Algebraic 
                obj.VertexType = gmt_VertexType.External;
            else 
                obj.VertexType = gmt_VertexType.Internal;
            end
    
        end
    
        %% Function to Update State Variable 
        function obj = gmt_VertexStateVariableUpdate(obj,number)
            % Updates state variable name based on edge matrix analysis
            obj.GenStateVariable = strcat("x",num2str(number,0));
        end 
    
        %% Function to Update Power Equations 
        function obj = gmt_PowerEqUpdate(obj,final_tmp)
            % Updates vertex power flow based on edge matrix analysis, and edge equations
            obj.Power_Eq = final_tmp;
        end

        %% Compute Capacitance 
        function obj = gmt_ComputeCapacitance(obj)
            % Determine Capitance by removing states, operators, and symbols intelligently 
            % Remove state derivative "x_dot" from string.
            % NOTE: MUST HAPPEN BEFORE REMOVING "x" FROM STRING, REMOVING "x" BEFORE "x_dot" COULD RESULT IN "_dot" IF "x_dot" PRESENT
            cap_tmp = erase(obj.CapEq,"x_dot");
            % Remove state variable "x" from string 
            cap_tmp = erase(cap_tmp,"x"); %
            % Convert reduce string to character array for operator search 
            cap_char_tmp = char(cap_tmp);
            % Compute character array length and store for future use 
            cap_char_len = length(cap_char_tmp);
            % Search through character array for operator or other symbols {+, -, *, /}
            sym_idx_tmp = [];
            idx_tmp = 1;
            for j = 1:cap_char_len
                % If the character is a symbol, indication in an array. 
                if contains(cap_char_tmp(j),gmt_Symbols().Symbols) == false
                    sym_idx_tmp(idx_tmp) = j;
                    idx_tmp = idx_tmp + 1;
                end
            end
            % Remove indexes with symbols
            obj.Capacitance = string(cap_char_tmp(sym_idx_tmp));
        end

        %% Compute State Derivative Equation 
        function obj = gmt_XDotEq(obj)
            % Determine if parathesis are required 
            if contains(obj.Power_Eq,gmt_Symbols().Symbols) == true 
                % Add parathesis to end 
                pwr_eq_tmp = strcat("(",obj.Power_Eq,")");
                obj.X_Dot_Eq = strcat(pwr_eq_tmp,"/",obj.Capacitance);
            else
                obj.X_Dot_Eq = strcat(obj.Power_Eq,"/",obj.Capacitance);
            end
        end
    end
end

