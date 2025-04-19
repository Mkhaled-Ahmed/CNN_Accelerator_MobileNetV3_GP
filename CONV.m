function feature_map=CONV(photo)
    f=load('kernal.mat','conv_filter');
    f=f.conv_filter;
    
pad=1;
stride=2;




n=imread(photo);
X_in=(double((padding(n,pad)./127.5-1)));

[row,col,c]=size(X_in);



Maps=(zeros(112,112,16));



for k=1:16          
    for i=1:stride:row-stride
        for j=1:stride:col-stride
        
        data=(X_in(i:i+3-1,j:j+3-1,:));
        out=sum( sum( sum( data.*f(:,:,:,k) ) ) );
            Maps( (0.5*i+0.5) , (0.5*j+0.5) ,k)=out;
        end
    end
end

Maps=Batch_Norm(Maps,'_Conv1_',0);
Maps=h_swish(Maps);
feature_map=(Maps);



save('CONV_Kernal.mat', 'f');
%xlswrite( 'output.xlsx',f(_));
%c=(convn(X_in,f));
%csvwrite('feature_maps.csv',feature_map);  % Save the array to a CSV file

end
