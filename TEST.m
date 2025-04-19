%entering the image address
n=imread('blue-grape-hyacinths.jpg'); 
I=padding(n,1);
figure
%subplot to add on more than one result on same output for better comparison
subplot(2,2,1); 
imshow(I); 
%for labelling the image
xlabel('original image')
grid on;

%represents the Red colour plane of the RGB image
 R=I(:,:,1); 
 subplot(2,2,2); 
 imshow(R); 
 xlabel('RED component is extracted')
 grid on; %
 pixel_ex(R,'pixel_values_R.txt');

% represents the Green colour plane of the RGB image 
G=I(:,:,2); 
subplot(2,2,3); 
imshow(G); 
xlabel('GREEN component is extracted')
grid on;
pixel_ex(G,'pixel_values_G.txt');

%represents the Blue colour plane of the RGB image
B=I(:,:,3); 
subplot(2,2,4); 
imshow(B);
xlabel('BLUE component is extracted')
grid on;
pixel_ex(B,'pixel_values_B.txt');
