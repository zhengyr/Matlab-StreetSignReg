%This script produces 10 images decreasing in resolution by 10%
%The input image must be in the same directory.
%Assumes image has a 4 character length extension (ex: '.jpg')
%Output name format: originalname + X percent scale + image extension

filename = input('Enter image filename: ', 's') %prompt user for desired template image
OGIm = imread(filename);
filenameLength = numel(filename); 
rawname = filename(1:filenameLength-4); %Removes extension from filename. 'dog.jpg' -> 'dog'
fileType = filename(filenameLength-3:filenameLength); %Takes extension, necessary for imwrite
foldername = input('Enter output foldername: ', 's')
append = 'percent_scale';
mkdir(foldername); %creates directory with templates
cd(foldername); %access the new directory

%each iteration outputs a 10% downscaled image into a folder
for i = 1:10
    outputname = strcat(rawname,num2str(i*10),append,fileType); %filename creation
    outputIm = imresize(OGIm, i*0.1); %rescale the image
    imwrite(outputIm, outputname); %saves all the templates into the folder
end

cd ..