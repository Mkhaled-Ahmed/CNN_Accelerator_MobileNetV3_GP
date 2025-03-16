% Load the trained network
net = load('QUANTIZE.mat');
net = net.quantizedNet;

% Step 2: Extract the parameters (weights, biases, batch normalization stats)
parameters = struct();
for i = 1:numel(net.Layers)
    layer = net.Layers(i);
    parameters(i).Name = layer.Name; % Store the layer name
    
    % Check if the layer has weights and biases
    if isprop(layer, 'Weights') && ~isempty(layer.Weights)
        parameters(i).Weights = layer.Weights;
    end
    if isprop(layer, 'Bias') && ~isempty(layer.Bias)
        parameters(i).Bias = layer.Bias;
    end
    
    % Check if the layer is a batch normalization layer
    if isa(layer, 'nnet.cnn.layer.BatchNormalizationLayer')
        parameters(i).TrainedMean = layer.TrainedMean; % Extract TrainedMean
        parameters(i).TrainedVariance = layer.TrainedVariance; % Extract TrainedVariance
        parameters(i).Scale = layer.Scale; % Extract Scale (gamma)
        parameters(i).Offset = layer.Offset; % Extract Offset (beta)
    end
end

% Step 3: Save the extracted parameters to a .mat file
save('mobilenetv3_parameters.mat', 'parameters');
