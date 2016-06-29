function [result, xoffSet, yoffSet, width, height] = tem_match_rgb(temp, input)
    %display the original image
    %figure, imshowpair(input,temp,'montage')
    orig = input;
    %convert the image to grayscale
    temp = rgb2gray(temp);
    input = rgb2gray(input);
    %Read images into the workspace and display them side-by-side.
    %figure, imshowpair(input,temp,'montage')
    c = normxcorr2(temp,input);
    %Perform cross-correlation and display result as surface.
    %figure, surf(c), shading flat
    %Find peak in cross-correlation.
    result = max(c(:));
    [ypeak, xpeak] = find(c== result);
    %Account for the padding that normxcorr2 adds.
    yoffSet = ypeak-size(temp,1)+1;
    xoffSet = xpeak-size(temp,2)+1;
    %Display matched area.
    %figure, imshow(orig);
    width = size(temp,2);
    height = size(temp,1);
    %rectangle('position',[xoffSet, yoffSet, size(temp,2), size(temp,1)],'edgecolor','r','LineWidth',4); 
end
