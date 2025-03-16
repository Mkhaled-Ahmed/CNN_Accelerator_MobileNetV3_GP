classdef CustomhswishLayer < nnet.layer.Layer & nnet.layer.Formattable
  %#codegen
    methods
        function layer = CustomhswishLayer(name)
            % Constructor
            layer.Name = name;
            layer.Description = 'Hard-Swish activation layer';
        end

        function Z = predict(layer, X)
            if isa(X, 'dlarray')
                data = extractdata(X); % Extract numeric data
                result = data .* (min(max(data + 3, 0), 6) / 6);
                Z = dlarray(result, dims(X)); % Preserve dlarray format
            else
                Z = X .* (min(max(X + 3, 0), 6) / 6);
            end
        end

        function dLdX = backward(layer, X, ~, dLdZ, ~)
            % Gradient computation for backward pass
            if isa(X, 'dlarray')
                data = extractdata(X); % Extract numeric data
                grad = computeGradient(data);
                grad = dlarray(grad, dims(X)); % Preserve dlarray format
                dLdX = dLdZ .* grad; % Apply chain rule
            else
                grad = computeGradient(X);
                dLdX = dLdZ .* grad; % Apply chain rule
            end
        end
    end
end

% Helper function for gradient computation
function grad = computeGradient(X)
    grad = zeros(size(X), 'like', X); % Initialize gradient
    mask1 = (X > -3) & (X < 3);
    mask2 = X >= 3;
    grad(mask1) = (min(max(X(mask1) + 3, 0), 6) / 6) + (X(mask1) .* (1 / 6));
    grad(mask2) = 1;
    % For X <= -3, gradient remains 0 (handled by initialization)
end
