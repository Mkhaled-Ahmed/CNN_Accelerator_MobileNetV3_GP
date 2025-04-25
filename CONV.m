function feature_map=CONV(photo)
    parameters=load('new_param.mat');
    parameters=parameters.parameters;
    f=parameters.weights;
    bias=parameters.Bias;
    
pad=1;
stride=2;




X_in=double(imread(photo));
whos X_in
data=(X_in(1:3,1:3,:))
meanR = mean(mean(X_in(:,:,1))) % Red channel
meanG = mean(mean(X_in(:,:,2))) % Green channel
meanB = mean(mean(X_in(:,:,3))) % Blue channel
X_in(:,:,1)=double(X_in(:,:,1)-meanR);
data=(X_in(:,:,1));
X_in(:,:,2)=double(X_in(:,:,2)-meanG);
X_in(:,:,3)=double(X_in(:,:,3)-meanB);
data=(X_in(1:3,1:3,:))
X_in=double(padding(X_in,pad));
data=(X_in(1:3,1:3,:))
[row,col,c]=size(X_in);



Maps=(zeros(112,112,16));



for k=1:16          
    for i=1:stride:row-stride
        for j=1:stride:col-stride
        
        data=(X_in(i:i+3-1,j:j+3-1,:));
        out=sum( sum( sum( data.*f(:,:,:,k) ) ) )+bias(k);
            Maps( (0.5*i+0.5) , (0.5*j+0.5) ,k)=out;
        end
    end
end

%Maps=Batch_Norm(Maps,'_Conv1_',0);
Maps=h_swish(Maps);
feature_map=(Maps);



save('CONV_Kernal.mat', 'f');
%xlswrite( 'output.xlsx',f(_));
%c=(convn(X_in,f));
%csvwrite('feature_maps.csv',feature_map);  % Save the array to a CSV file

end
