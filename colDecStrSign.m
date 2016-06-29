%Yiran Zheng
%zhengyr@brandeis.edu
%cosi177
%this is function that find the where the street sign is using the color
%detection of hue
function result = colDecStrSign(filename)
    [rgbImage, ~] = imread(filename); 

    % Convert RGB image to HSV
    hsvImage = rgb2hsv(rgbImage);
    % Extract out the H, S, and V images individually
    hImage = hsvImage(:,:,1);
    sImage = hsvImage(:,:,2);
    vImage = hsvImage(:,:,3);
    % Use values that I know work for my sample
    hueThresholdLow = 0.15;
    hueThresholdHigh = 0.60;
    saturationThresholdLow = 0.36;
    saturationThresholdHigh = 1;
    valueThresholdLow = 0;
    valueThresholdHigh = 0.8;

    % Now apply each color band's particular thresholds to the color band
    hueMask = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
    saturationMask = (sImage >= saturationThresholdLow) & (sImage <= saturationThresholdHigh);
    valueMask = (vImage >= valueThresholdLow) & (vImage <= valueThresholdHigh);
    % Combine the masks to find where all 3 are "true."
    coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);

    % Keep areas only if they're bigger than this.
    smallestAcceptableArea = 200;
    coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));

    % Smooth the border using a morphological closing operation, imclose().
    structuringElement = strel('disk', 4);
    coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
    % Fill in any holes in the regions
    coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');
    % We need to convert the type of coloredObjectsMask to the same data type as hImage.
    coloredObjectsMask = cast(coloredObjectsMask, 'like', rgbImage); 
    % Use the colored object mask to mask out the colored-only portions of the rgb image.
    maskedImageR = coloredObjectsMask .* rgbImage(:,:,1);
    maskedImageG = coloredObjectsMask .* rgbImage(:,:,2);
    maskedImageB = coloredObjectsMask .* rgbImage(:,:,3);
    % Concatenate the masked color bands to form the rgb image.
    maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);
    result = maskedRGBImage;
end