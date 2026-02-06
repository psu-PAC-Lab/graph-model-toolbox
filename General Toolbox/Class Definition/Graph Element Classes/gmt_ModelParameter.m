%% gmt_ModelParameter
% Class used to define model parameters within toolbox 

classdef gmt_ModelParameter
    
    properties
        Description string
        Variable string
        Common logical = false
        Optimization logical = false
        Units string
        Data 
    end

    properties (SetAccess = protected) 
        ParameterType gmt_ParameterType
        Parent string
        lookupVars string
        lookupDim 
        TableOpts 
        NetOpts 
    end

    methods
    
        %% Constructor Method (User Defined and Internal Meta Data Update) 
        function obj = gmt_ModelParameter(Description,Variable,Data,varargin)

            % Input Parsing
            p = inputParser;
            addParameter(p, 'Optimization',false, @(x) islogical(x) && isscalar(x));
            addParameter(p, 'Common',false, @(x) islogical(x) && isscalar(x));
            addParameter(p, 'Units',[], @(x) isstring(x));
            parse(p, varargin{:});

            % Required User Properties 
            obj.Description = Description;
            obj.Variable = Variable;

            % Optional User Properties
            if ~isempty(p.Results.Units)
                obj.Units = p.Results.Units;
            end

            if ~isempty(p.Results.Common)
                obj.Common = p.Results.Common;
            end

            if ~isempty(p.Results.Optimization)
                obj.Optimization = p.Results.Optimization;
            end

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

        %% Update Model Parameter Parent Name
        function obj = gmt_ModelParameterParent(obj,GraphName)
            obj.Parent = GraphName;    
        end

    end

end

