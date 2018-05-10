%{
 *
 * NEU Experiments - Data Augmentation script
 * 
 * Copyright (C) 2018, Vicomtech (http://www.vicomtech.es/),
 * (Spain) All rights reserved.
 * fsaiz@vicomtech.org
 */
%}

%% Set up

%Folder of the input images
NEUpath = ('./NEU_converted');

%CNN input size
inputResize = [200,200];
%Create image datastore
imds = imageDatastore(fullfile(NEUpath, {'1_crazing','2_inclusion',...
    '3_patches','4_pitted','5_rolled-in','6_scratches'}),...
'LabelSource', 'foldernames', 'FileExtensions', {'.jpg', '.png', '.tif'});

%% Augmentation

%Set parameters 
imageAugmenter = imageDataAugmenter(... 
    'RandYScale',[0.55 1.35],...
    'RandXScale',[0.55 1.35]);    
    
    %, ...
    %'RandXTranslation',[-3 3],
    %'RandRotation',[-360,360]...
    %'RandYTranslation',[-3 3])
    %'RandYReflection',true, ...
    %'RandXReflection',true)
    %'RandXShear', [-45, 45], ...
    %'RandYShear', [-45, 45], ...
 
augimdsTD = augmentedImageDatastore(inputResize,imds,'DataAugmentation',imageAugmenter);
miniBatch = augimdsTD.readall;

%% Save to a folder
for pp = 1:1:augimdsTD.NumObservations
    img =  imds.Files{pp};
    sp = strsplit(img,'\');
    
    % Data augmentation path
    outputPath = './dataAugmentation/';
    folderPos = length(sp)-1;
    dir = mkdir(char(strcat(outputPath,sp(folderPos),'/')));
    folder = char(strcat(outputPath,sp(folderPos),'/'));
    
    % Generate the new name of images
    newName = char(strrep(sp(length(sp)), '.', '_da.'));
    imwrite(miniBatch.input{pp}, fullfile(char(folder), newName))
end    

