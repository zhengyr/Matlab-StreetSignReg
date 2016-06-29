%This function asks the user for folder name containing the templates.
%The function then parses through every image in the folder, determining
%which template image has the highest correlation to the input. It then
%displays the region in the input image with the highest correlation.

inputName = input('Input image name: ', 's')
foldername = input('Input folder name: ', 's')
d = dir(foldername); 
%gets number of files in the template folder
[r c] = size(d); 
%preallocates a matrix storing the result of the template match test for each template
temp = zeros(r-2,5); 
append = 'percent_scale'; 

%loop runs for each template image in the folder
for i = 3:r
   %pulls name of the template image
   templateName = d(i).name;
   %enter the folder, read the image, exit the folder
   cd ..
   cd(foldername) 
   templateIm = imread(templateName); 
   %read input
   inputIm = imread(inputName); 
   %store the result of template matching algorithm
   [temp(i-2,1),temp(i-2,2),temp(i-2,3),temp(i-2,4),temp(i-2,5)] = tem_match_rgb(templateIm, inputIm); 
end

%determine highest correlation
maxCorr = max(temp(:,1));

%corresponding index of highest correlation
ind = find(maxCorr == temp);
%display result
figure,imshow(inputName)
rectangle('position',[temp(ind,2), temp(ind,3), temp(ind,4), temp(ind,5)],'edgecolor','r','LineWidth',4); 