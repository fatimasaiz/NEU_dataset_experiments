%{
 *
 * NEU Experiments - Occlusion generator script
 * 
 * Copyright (C) 2018, Vicomtech (http://www.vicomtech.es/),
 * (Spain) All rights reserved.
 * fsaiz@vicomtech.org
 */
%}

%% Set up

%Folder of the input images
NEUpath = '.\dataAugmentation';
nClasses = 6;
imagesFormat               = 'tif';
classes = {'1_crazing','2_inclusion',...
    '3_patches','4_pitted','5_rolled-in','6_scratches'}

imds = imageDatastore(fullfile(NEUpath, {'1_crazing','2_inclusion',...
    '3_patches','4_pitted','5_rolled-in','6_scratches'}),...
'LabelSource', 'foldernames', 'FileExtensions', {'.jpg', '.png', '.tif'});

%Set the occlusion percentage (0 - 100)
ocPercen = 40;
%Set the size of the input images
imSize = 200;
dim = uint8(((imSize*imSize)*(ocPercen/100))^(1/2));
%Set the output path 
dirO = '.\oc40\';

%% Generate the occlusion

for pp=1:1:size(imds.Files)
    %Generate random number of column and row
    randC = randi((imSize-dim),1);
    randR = randi((imSize-dim),1);
    
    img =  imds.Files{pp};
    sp = strsplit(img,'\');
    
    % Occlusion path
    outputPath = './occlusionImages/';
    folderPos = length(sp)-1;
    dir = mkdir(char(strcat(outputPath,sp(folderPos),'/')));
    folder = char(strcat(outputPath,sp(folderPos),'/'));
    
    % Generate the new name of images
    nameExt = strcat('_', string(ocPercen) ,'.');
    newName = char(strrep(sp(length(sp)), '.', nameExt));
            
    imdspp = rgb2gray(imread(imds.Files{pp}));
    for rc=randC:1:(randC+dim)
       for rf=randR:1:(randR+dim)
            imdspp(rf,rc) = 0;
       end 
    end
    imdspp=cat(3,imdspp,imdspp,imdspp);
    imwrite(imdspp, fullfile(char(folder), newName))
    imdspp = [];
      
end