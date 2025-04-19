function Maps_out=CONV2d(Maps)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here



[row,col,C]=size(Maps);

Maps_out=zeros(7,7,576);
channel_out=576;


flag=1;
if flag==0
    
f=randn(1,1,C,channel_out);
save('CONV2d_Filters.mat','f');

else
    f=load('CONV2d_Filters.mat', 'f');
    f=f.f;
    
end



for K=1:channel_out

    for i=1:row
    
        for j=1:col
        
            out=f(:,:,:,K).*Maps(i,j,:);
            out=sum(out);
            
            Maps_out(i,j,K)=out;
            
            
        end
    end
end

Maps_out=Batch_Norm(Maps_out,'_CONV2d_',12);
Maps_out=h_swish(Maps_out);

Maps_out=mean(mean(Maps_out));

end

