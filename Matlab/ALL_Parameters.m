

%counter=0;
% Load the trained network
net = load('QUANTIZE.mat');
net = net.quantizedNet;%.net;

% Step 2: Extract the parameters (weights, biases, batch normalization stats)
parameters = struct();
layer=net.Layers(2);
parameters.weights=layer.Weights;
parameters.Bias=layer.Bias;
save('new_param.mat', 'parameters');
%{
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
     [~,~,C]=size(layer.TrainedVariance);
       for mm=1:C
        if(layer.TrainedVariance(:,:,mm)<0)
             counter=counter+1;
        end
       end
        parameters(i).Scale = layer.Scale; % Extract Scale (gamma)
        parameters(i).Offset = layer.Offset; % Extract Offset (beta)
    end
end
%}
% Step 3: Save the extracted parameters to a .mat file

