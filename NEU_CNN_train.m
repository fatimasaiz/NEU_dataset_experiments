%{
 *
 * NEU Experiments - CNN train script
 * 
 * Copyright (C) 2018, Vicomtech (http://www.vicomtech.es/),
 * (Spain) All rights reserved.
 * fsaiz@vicomtech.org
 */
%}
%% CNN FOR NEU DATASET (ACIVS2018)


%% Input parameters
% Folder of the input images
NEUpath = ('./NEU_converted');

% Define the CNN architectures
architecture_net    = 2     % 1 = AlexNet v2                  
                            % 2 = pretrained GoogLeNet (224x224x3)                          
                            % 3 = pretrained ResNet50 (224x224x3)  

% K-folds cross-validation
k=4;



rng('default');
% CNN architectures
addpath('./CNN_architectures/');

%% Load data
nClasses = 6;
images_format               = 'tif';
classes = {'1_crazing','2_inclusion',...
    '3_patches','4_pitted','5_rolled-in','6_scratches'}

	
% Load the data as ImageDataStore object
imds = imageDatastore(fullfile(NEUpath, {'1_crazing','2_inclusion',...
    '3_patches','4_pitted','5_rolled-in','6_scratches'}),...
'LabelSource', 'foldernames', 'FileExtensions', {'.jpg', '.png', '.tif'});

% Data augmentation folder path
AUGpath = './dataAugmentation';

augimdsLoad = imageDatastore(fullfile(AUGpath, {'1_crazing','2_inclusion',...
    '3_patches','4_pitted','5_rolled-in','6_scratches'}),...
'LabelSource', 'foldernames', 'FileExtensions', {'.jpg', '.png', '.tif'});

augimdTDT = imageDatastore(cat(1,augimdsLoad.Files,imds.Files));
augimdTDT.Labels = cat(1,augimdsLoad.Labels,imds.Labels);

%Copy original imds for test
imdso = imds;

imds = augimdTDT;

                      

                        
% Define the CNN architecture
switch(architecture_net)
    case 1    
        % Arquitectura 1: alexnet v2 (original)
        %Resize the images of datastore
        resize = [150,150];
        imds.ReadSize = numpartitions(imds);
        imds.ReadFcn = @(loc)imresize(imread(loc),resize);
        layers =  AlexNetV2(resize(1,1), resize(1,2), 3, nClasses);     
    case 2
        % Architecture 2: Pretrained GoogLeNet, just for (224x224x3)
        resize = [224,224];
        imds.ReadSize = numpartitions(imds);
        imds.ReadFcn = @(loc)imresize(imread(loc),resize);
        layers = preTrainedGoogLeNet(resize(1,1), resize(1,2), 3, nClasses);
    case 3
        % Architecture 3: Pretrained RestNet50 (224x224x3)
        resize = [224,224];
        imds.ReadSize = numpartitions(imds);
        imds.ReadFcn = @(loc)imresize(imread(loc),resize);
        layers = preTrainingResNet50(resize(1,1), resize(1,2), 3, nClasses);
end

%% Divide the datastore (training, validation and test sets)

%Divide the datastore so that each category in the training set
%has 75 images and the testing set has the remaining images from each label.


imdoSize = size(imdso.Files);
imdSize = size(imds.Files);

if (k<3) || (k> (imdSize(1)/nClasses))
    disp('Error. K value not valid')
    pause
end 

%Cross validation index for each label
cvIndex=[]
cvoIndex=[];
for i=1:1:nClasses
   cvoIndex(:,i) = crossvalind('KFold', (imdoSize(1)/nClasses), k);
   cvIndex(:,i) = crossvalind('KFold', (imdSize(1)/nClasses), k);
end    

%Set the number of folds to train, test and vlaidation
nFoldTrain = 2;
nFoldTest = 1;
nFoldValid = 1;

if (nFoldTrain+nFoldTest+nFoldValid > k)
    disp ('Error. Incorrect number of folds.');
    pause
end 

posTr = []
matFolds = [];
matFolds = string(matFolds);

posTro = []
matFoldso = [];
matFoldso = string(matFoldso);

%Divide data into folds
for fo=1:1:k
   pos=find(cvIndex()==fo);
   posTr = [pos];
   matFolds(:,fo) = [imds.Files(posTr)];
   pos = [];
end

for foo=1:1:k
   poso=find(cvoIndex()==foo);
   posTro = [poso];
   matFoldso(:,foo) = [imdso.Files(posTro)];
   poso = [];
end

% Train folds
for tr=1:1:nFoldTrain
   pos=find(cvIndex()==tr);
   posTr = [posTr; pos];
end   

%% Training and metrics

rng(1);
% Variables
totalNet = [];
infoTotalNet = [];
totalAcc = [];
crossValidationTrainData = [];
crossValidationTestData = [];
crossValidationValidationData = []; 
crossValidationTestDataTotal = [];
    
for j = 1:1:k
    
    % Train data
    for td = 1:1:nFoldTrain
        td = td + j;
        if td >k
            td = td - k;
        end    
       crossValidationTrainData = [crossValidationTrainData; matFolds(:,td)];
    end   
    % Test data
    for ted = (nFoldTrain+1):1:(nFoldTest+nFoldTrain)
        ted = ted + j;
        if ted >k
            ted = ted - k;
        end 
       crossValidationTestData = [crossValidationTestData; matFoldso(:,ted)];
    end 
    % Validation data
    for vd = (nFoldTest+nFoldTrain+1):1:(nFoldValid+nFoldTest+nFoldTrain)
        vd = vd + j;
        if vd >k
            vd = vd - k;
        end 
       crossValidationValidationData = [crossValidationValidationData(); matFolds(:,vd)];
    end
      
    crossValidationTrainDataID = imageDatastore(cellstr(crossValidationTrainData),'LabelSource', 'foldernames');
    crossValidationTestDataID = imageDatastore(cellstr(crossValidationTestData) ,'LabelSource', 'foldernames');
    crossValidationValidDataID = imageDatastore(cellstr(crossValidationValidationData) ,'LabelSource', 'foldernames');
 
    
 %% Training setup

  %Training options
	options = trainingOptions(...
	    'sgdm', ...
		'Plots','training-progress', ... 
		'InitialLearnRate', 0.001, ...
		'LearnRateSchedule', 'piecewise', ...
		'LearnRateDropFactor', 0.5, ...
		'LearnRateDropPeriod', 3, ...
		'L2Regularization', 0.004, ...
		'MaxEpochs', 20, ...
		'MiniBatchSize',32,...
		'Momentum', 0.9, ...
		'Shuffle', 'every-epoch', ...
		'ExecutionEnvironment', 'auto', ...     % 'auto' | 'cpu' | 'gpu' | 'multi-gpu' | 'parallel'
		'OutputFcn', [], ...  % 3 times that the accuracy on the validation set can be smaller than or equal to the previously highest accuracy before network training stops
		'Verbose', true, ...
		'ValidationData', crossValidationValidDataID, ...
		'ValidationFrequency', 100);

   %Resize the images of datastore

    crossValidationTrainDataID.ReadSize = numpartitions(crossValidationTrainDataID);

    crossValidationTrainDataID.ReadFcn = @(loc)imresize(imread(loc),resize);

    crossValidationTestDataID.ReadSize = numpartitions(crossValidationTestDataID);

    crossValidationTestDataID.ReadFcn = @(loc)imresize(imread(loc),resize);

    crossValidationValidDataID.ReadSize = numpartitions(crossValidationValidDataID);

    crossValidationValidDataID.ReadFcn = @(loc)imresize(imread(loc),resize);

    %Train the network.
    tic;
    [net, infoNet] = trainNetwork( crossValidationTrainDataID,layers,options);
    trainTime= toc;
    
        
    %Run the trained network on the test set
    tic;
    YPred = classify(net,crossValidationTestDataID);
    testTime=toc;
    YTest = crossValidationTestDataID.Labels;

    %Accuracy
    accuracy = sum(YPred == YTest)/numel(YTest)

    % Confusion matrix and plot
    plotConf = plotconfusion(YTest,YPred)
    confMatrix = confusionmat(YTest, YPred)
         
    % Save obtained data
    totalNet = [totalNet ; net];
    infoTotalNet = [infoTotalNet ; infoNet];
    totalAcc = [totalAcc ; accuracy];
    crossValidationTestDataTotal = [crossValidationTestDataTotal ; crossValidationTestData];
   
    
         
    crossValidationTrainData = [];
    crossValidationTestData = [];
    crossValidationValidationData = []; 
   

end

%Save model and variables for test
 save('trainingData','totalNet','totalAcc','imdso','resize','crossValidationTestDataTotal');
