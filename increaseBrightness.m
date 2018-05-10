%{
 *
 * NEU Experiments - Brightness increasment script
 * 
 * Copyright (C) 2018, Vicomtech (http://www.vicomtech.es/),
 * (Spain) All rights reserved.
 * fsaiz@vicomtech.org
 */
%}

%% Set up

%Folder of the input images
NEUpath = './NEU_converted';
n_classes = 6;
images_format               = 'tif';
classes = {'1_crazing','2_inclusion',...
    '3_patches','4_pitted','5_rolled-in','6_scratches'}

imds = imageDatastore(fullfile(NEUpath, {'1_crazing','2_inclusion',...
    '3_patches','4_pitted','5_rolled-in','6_scratches'}),...
'LabelSource', 'foldernames', 'FileExtensions', {'.jpg', '.png', '.tif'});

%Set the brightness increasement (0 - 256)
brIncr = 100;

%% Increase brightness

for pp=1:1:size(imds.Files)
    
    img =  imds.Files{pp};
    sp = strsplit(img,'\');
    
    % Occlusion path
    outputPath = './brightnessImages/';
    folderPos = length(sp)-1;
    dir = mkdir(char(strcat(outputPath,sp(folderPos),'/')));
    folder = char(strcat(outputPath,sp(folderPos),'/'));
    
    % Generate the new name of images
    nameExt = strcat('_', string(brIncr) ,'.');
    newName = char(strrep(sp(length(sp)), '.', nameExt));
    
    imdspp= (imread(imds.Files{pp}))+ brIncr;
    imwrite(imdspp, fullfile(char(folder), newName))
  
    imdspp = [];
    
end