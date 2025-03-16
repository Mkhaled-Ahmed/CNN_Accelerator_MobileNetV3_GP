classdef CustommultiplicationLayer < nnet.layer.Layer & nnet.internal.cnn.layer.Traceable ...
        & nnet.internal.cnn.layer.CPUFusableLayer ...
        & nnet.internal.cnn.layer.BackwardOptional ...   
        & nnet.layer.Formattable
   %#codegen
    properties
 InputFormats
 OutputFormats
   end
    methods
        function layer = CustommultiplicationLayer(numInputs, name)
            layer.Name = name;
            layer.NumInputs = numInputs;
            layer.Description = iGetMessageString('nnet_cnn:layer:MultiplicationLayer:oneLineDisplay', numInputs);
            layer.Type = iGetMessageString('nnet_cnn:layer:MultiplicationLayer:Type');
            
            % Define the input and output formats as 'SSCB'
            layer.InputFormats = repmat({"SSCB"}, 1, numInputs);  % All inputs must have 'SSCB' format
            layer.OutputFormats = {"SSCB"};  % The output must also be 'SSCB' format
        end
        
        function Z = predict(layer, varargin)
            if isempty(varargin)
                error('MATLAB:narginchk:notEnoughInputs',"Not enough input arguments");
            end
          
            
            % Perform the multiplication of inputs
            idx = 1:layer.NumInputs;
            Z = iMultiplyInputs(varargin, idx);
        end
        
        function varargout = backward(layer, varargin)
           
            
            % Backward propagate the derivative of the loss function
            varargout = cell(1,layer.NumInputs);
            X = varargin(1:layer.NumInputs);
            k = layer.NumInputs + layer.NumOutputs + 1;
            dLdZ = varargin{k};
            
            for i = 1:layer.NumInputs
                idx = [1:i-1, i+1:layer.NumInputs];
                val = iMultiplyInputs(X, idx) .* dLdZ;
                
                % Finding singleton dimensions of input
                singletonDim = size(X{i}) == 1;
                f = find(singletonDim);
                if f
                    % Sum up all the derivative values along those singleton dimensions
                    varargout{i} = sum(val, f);        
                else
                    varargout{i} = val;
                end
            end            
        end
    end
    
    methods(Static = true, Hidden = true)
        function name = matlabCodegenRedirect(~)
            name = 'nnet.internal.cnn.coder.MultiplicationLayer';
        end
    end
    
    methods (Hidden)
        function layerArgs = getFusedArguments(layer)
            % Get the arguments needed to call the layer in a fused network
            layerArgs = { 'multiplication', layer.NumInputs };
        end

        function tf = isFusable(~, ~, ~)
            % Indicate if the layer is fusable in a given network
            tf = true;
        end
    end
end

% Helper function to multiply inputs
function Z = iMultiplyInputs(X, ind)
    Z = X{ind(1)};
    for i = ind(2:end)
        Z = Z .* X{i};
    end
end

% Helper function to retrieve the message string
function messageString = iGetMessageString(varargin)
    messageString = getString(message(varargin{:}));
end
