classdef CustomhSigmoidLayer < nnet.layer.Layer & nnet.layer.Formattable
%#codegen
    methods
        function layer = CustomhSigmoidLayer(name)
            % Constructor
            layer.Name = name;
            layer.Description = 'Hard-Sigmoid activation layer';
        end

        function Z = predict(layer, X)
            if isa(X, 'dlarray')
                data = extractdata(X); % Extract numeric data
                Z = max(0, min(1, 0.2 * data + 0.5));
                Z = dlarray(Z, dims(X)); % Preserve dlarray format
            else
                Z = max(0, min(1, 0.2 * X + 0.5));
            end
        end

        function [dLdX] = backward(layer, X, ~, dLdZ, ~)
            if isa(X, 'dlarray')
                data = extractdata(X); % Extract numeric data
                dZ_dX = 0.2 .* (data > -2.5 & data < 2.5);
                dZ_dX = dlarray(dZ_dX, dims(X)); % Preserve dlarray format
            else
                dZ_dX = 0.2 .* (X > -2.5 & X < 2.5);
            end
            dLdX = dLdZ .* dZ_dX;
        end
    end
end
