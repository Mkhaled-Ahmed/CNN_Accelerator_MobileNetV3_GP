function pixel_ex(photo,file_name)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% Step 1: Read the image
img = photo;  % Load the image

% Step 2: Extract pixel values
% If it's an RGB image, convert to grayscale for simplicity (optional)
if size(img, 3) == 3
    img = rgb2gray(img);  % Convert to grayscale
end

% Step 3: Write pixel values to a text file
fileID = fopen(file_name, 'w');  % Open a file for writing

% Step 4: Loop through each pixel and write to file
for row = 1:size(img, 1)
    for col = 1:size(img, 2)
        fprintf(fileID, '%d ', img(row, col));  % Write pixel value
    end
    fprintf(fileID, '\n');  % New line for each row
end

% Step 5: Close the file
fclose(fileID);



end

