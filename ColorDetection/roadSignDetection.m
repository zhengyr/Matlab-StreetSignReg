% Curtis Wilson, Yiran Zheng
% cswilson@brandeis.edu, zhengyr@brandeis.edu
% cosi177
% This function is a composition of colDecStrSign and
% MSERCharacterDetection. It takes the file name of an rgb image of a
% street sign and returns the image with the sign isolated, and an array of
% ocrTexts, one for each word on the sign. It also displays the original
% image with the words that have been detected over the original words.

function [outputImage, ocrArray] = roadSignDetection(imageFilename)

image = imread(imageFilename);

% Isolates the sign
outputImage = colDecStrSign(imageFilename);

% detects the words
ocrArray = MSERCharacterDetection(outputImage);


s = size(ocrArray);
% Show the text on the image
imshow(image)
for i=1:s
    word = ocrArray(i).Text;
    box = ocrArray(i).WordBoundingBoxes;
    if(size(word) ~= 0)
        x = box(1,1);
        y = box(1,2);
        text(x, y, word, 'FontSize', 20);
    end
end


end

