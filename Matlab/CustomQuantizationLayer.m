 
classdef CustomQuantizationLayer < nnet.layer.Layer
     %#codegen
    properties
        NumericType
        MinValue
        MaxValue
        Scale
    end
    
    methods
        function layer = CustomQuantizationLayer(numericType, name)
            if nargin < 2
                name = 'Quantization_1';
            end
            
            layer.Name = name;
            layer.NumericType = numericType;
            layer.Description = 'Quantization layer for fixed-point arithmetic';
            
            % Calculate quantization parameters
            layer.Scale = 2^numericType.FractionLength;
            layer.MinValue = -2^(numericType.WordLength-1) / layer.Scale;
            layer.MaxValue = (2^(numericType.WordLength-1) - 1) / layer.Scale;
        end
        
        function Z = predict(layer, X)
            % Quantization steps:
            % 1. Scale to fixed-point range
      
           
            X_scaled = X * layer.Scale;
            
            % 2. Round to nearest integer
            X_rounded = round(X_scaled);
            
            % 3. Clip to valid range
            X_clipped = max(min(X_rounded, ...
                2^(layer.NumericType.WordLength-1)-1), ...
                -2^(layer.NumericType.WordLength-1));
            
            % 4. Scale back to floating point
            Z = X_clipped / layer.Scale;

          
            % 5. Ensure output is in valid range
            Z = max(min(Z, layer.MaxValue), layer.MinValue);

             %writeLayerStatisticsToExcel(layer, X, 'LayerStatistics.xlsx');
        end
        end
    end

 



 