function extract(name1,name2)
% Define input and output folders
inputFolder = name1;  % Replace with your folder path
outputFolder = name2; % Replace with your folder path

% Create output folder if it doesn't exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Get list of image files in the folder (adjust extension if needed)
imageFiles = dir(fullfile(inputFolder, '*.png')); % Use *.png, *.jpeg for other formats

% Loop through all images in the folder
for i = 1:length(imageFiles)
    % Construct the full path of the current image
    imagePath = fullfile(inputFolder, imageFiles(i).name);
    img = imread(imagePath);
    
    % Step 1: Super-Resolution (Upscaling the Image)
    % Resize the image by a factor of 2 using bicubic interpolation
    scaledImg = imresize(img, 2, 'bicubic');
    
    % Step 2: Contrast Adjustment (Optional for dull images)
    % Apply adaptive histogram equalization if the image is grayscale
    if size(scaledImg, 3) == 1
        scaledImg = adapthisteq(scaledImg, 'ClipLimit', 0.01);
    end
    
    % Step 3: Sharpening to enhance edges
    sharpenedImg = imsharpen(scaledImg, 'Amount', 1.2, 'Radius', 1, 'Threshold', 0.05);
    
    % Step 4: Noise Reduction using Median Filtering
    if size(sharpenedImg, 3) == 3
        % If the image is RGB, apply median filtering to each channel
        rChannel = medfilt2(sharpenedImg(:,:,1), [3 3]);
        gChannel = medfilt2(sharpenedImg(:,:,2), [3 3]);
        bChannel = medfilt2(sharpenedImg(:,:,3), [3 3]);
        % Combine the channels back into an RGB image
        denoisedImg = cat(3, rChannel, gChannel, bChannel);
    else
        % If the image is grayscale, apply median filtering directly
        denoisedImg = medfilt2(sharpenedImg, [3 3]);
    end
    
    % Step 5: Resize the final image to 224x224
    resizedImg = imresize(denoisedImg, [224 224]);

    % Step 6: Save the enhanced image
    outputFilePath = fullfile(outputFolder, imageFiles(i).name);
    imwrite(resizedImg, outputFilePath);
    
    
end

disp('All images have been processed and saved!');
