function out= h_swish(data)


[row,col,C]=size(data);

for K=1:C
    for i=1:row
        for j=1:col
            
temp = data(i,j,K) + 3;  % Shift input by 3
temp = min(max(temp, 0), 6);  % Apply ReLU6 to (data + 3)
temp = temp / 6;  % Divide by 6

out(i,j,K) = data(i,j,K) .* temp;  % Element-wise multiplication

            
        end
    end
end



end
 

