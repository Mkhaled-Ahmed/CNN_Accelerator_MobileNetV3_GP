function x_in=padding(photo,bit)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
[row,col,C]=size(photo);

rows=zeros(bit,col,C);
cols=zeros(row+2*bit,bit,C);


% add rows
photo=[rows; photo; rows];

%add columns 
photo=[cols photo cols];


x_in=photo;
end

