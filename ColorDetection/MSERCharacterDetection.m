% Curtis Wilson
% cswilson@brandeis.edu
% cosi177
% this function takes an rgb image in which a green sign has been isolated and returns an array of ocrTexts of
% words on the image
function [ocrtext] = MSERCharacterDetection( inimage )
% takes an image and tries to identify the text in the image using MSER and
% OCR. Returns an ocrText object and takes an rgb image.


image = rgb2gray(inimage);

% Detect the regions with MSER
regions = detectMSERFeatures(image, 'regionAreaRange', [1, 8000], 'thresholdDelta', 4);

sz = size(image);

% Get the properties of the regions
pixelIdxList = cellfun(@(xy)sub2ind(sz, xy(:,2), xy(:,1)), regions.PixelList, 'UniformOutput', false);

mserConnComp.Connectivity = 8;
mserConnComp.ImageSize = sz;
mserConnComp.NumObjects = regions.Count;
mserConnComp.PixelIdxList = pixelIdxList;

stats = regionprops(mserConnComp, 'BoundingBox', 'Eccentricity', ...
    'Solidity', 'Extent', 'Euler', 'Image');

bbox = vertcat(stats.BoundingBox);
w = bbox(:,3);
h = bbox(:,4);
aspectRatio = w./h;

% Create a filter with the properties of the regions to eliminate
% non-character regions
filter = aspectRatio' > 3;
filter = filter | [stats.Eccentricity] > 0.99;
filter = filter | [stats.Solidity] < 0.3;
filter = filter | [stats.Extent] < 0.25 | [stats.Extent] > 0.95;
filter = filter | [stats.EulerNumber] < -3;

stats(filter) = [];
regions(filter) = [];


% Eliminate more non-character regions based on stroke witdth
for j=1:numel(stats)
    regionImage = stats(j).Image;
    regionImage = padarray(regionImage, [1,1], 0);
    
    distanceImage = bwdist(~regionImage);
    skeletonImage = bwmorph(regionImage, 'thin', inf);
    
    strokeWidthValues = distanceImage(skeletonImage);
    
    strokeWidthThreshold = 0.4;
    
    strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);
    
    strokeWidthFilter(j) = strokeWidthMetric > strokeWidthThreshold;
    
end

regions(strokeWidthFilter) = [];
stats(strokeWidthFilter) = [];

% Create bounding boxes around the regions
bboxes = vertcat(stats.BoundingBox);


xmin = bboxes(:,1);
ymin = bboxes(:,2);
xmax = xmin + bboxes(:,3) - 1;
ymax = ymin + bboxes(:,4) - 1;

% Slightly expand the bounding boxes
expansionAmount = 0.02;
xmin = (1-expansionAmount)*xmin;
ymin = (1-expansionAmount)*ymin;
xmax = (1+expansionAmount)*xmax;
ymax = (1+expansionAmount)*ymax;

xmin = max(xmin, 1);
ymin = max(ymin, 1);
xmax = min(xmax, size(image,2));
ymax = min(ymax, size(image,1));

expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];

% Find overlapping bounding boxes and merge them
overlapRatio = bboxOverlapRatio(expandedBBoxes, expandedBBoxes);

n=size(overlapRatio, 1);
overlapRatio(1:n+1:n^2) = 0;

g = graph(overlapRatio);

componentIndices = conncomp(g);

xmin = accumarray(componentIndices', xmin, [], @min);
ymin = accumarray(componentIndices', ymin, [], @min);
xmax = accumarray(componentIndices', xmax, [], @max);
ymax = accumarray(componentIndices', ymax, [], @max);

textBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];


% Eliminate regions that did not merge (characters rarely come alone)
numRegionsInGroup = histcounts(componentIndices);
textBBoxes(numRegionsInGroup == 1, :) = [];

ITextRegion = insertShape(inimage, 'Rectangle', textBBoxes,'LineWidth',3);

figure
imshow(ITextRegion)
title('Detected Text')

% Perform OCR on each of the bounding boxes
ocrtext = ocr(image, textBBoxes);

% Show the regions on the image
% figure
% imshow(image)
% hold on
% plot(regions, 'showPixelList', true, 'showEllipses', false)
% hold off

end

