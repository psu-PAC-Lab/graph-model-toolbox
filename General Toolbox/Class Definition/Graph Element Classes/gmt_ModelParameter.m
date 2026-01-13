%% gmt_ModelParameter
% Class used to define model parameters within toolbox 

classdef gmt_ModelParameter
    
    properties
        Description string
        Variable string
        Data 
    end

    properties (SetAccess = protected) 
        ParameterType gmt_ParameterType
        lookupVars string
        lookupDim 
        TableOpts 
        NetOpts 
    end

    methods
    
        %% Constructor Method (User Defined and Internal Meta Data Update) 
        function obj = gmt_ModelParameter(Description,Variable,Data,Opts)

            % Validate Inputs 

            % Determine Parameter Type 
            obj.Description = Description;
            
            obj.Variable = Variable;

            % Determine Parameter Type
            switch true 

                % Lookup Function Case 
                case contains(Variable, 'interp')
                    obj.ParameterType = gmt_ParameterType.Lookup;
                    lookupDim_tmp = extractBefore(extractAfter(Variable,"interp"),"(");
                    is_digit_array = isstrprop(lookupDim_tmp, 'digit');

                    if is_digit_array
                        obj.lookupDim = str2double(lookupDim_tmp);
                    else
                        obj.lookupDim = lookupDim_tmp;
                    end
                       
                    obj.Data = Data;

                    obj.lookupVars = string(fieldnames(obj.Data));

                    if ~isempty(Opts)
                        obj.TableOpts = Opts;
                    end
                % Neural Network Case     
                case contains(Variable, 'net')
                    obj.ParameterType = gmt_ParameterType.Neural_Network;
                    obj.Data = Data;
                    if ~isempty(Opts)
                        obj.NetOpts = Opts;
                    end

                % All others assume scalars     
                otherwise
                    obj.ParameterType = gmt_ParameterType.Scalar;
                    obj.Data = Data;

            end
                          
        end

    end

end

