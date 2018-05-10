%{
 *
 * NEU Experiments - CNN test script
 * 
 * Copyright (C) 2018, Vicomtech (http://www.vicomtech.es/),
 * (Spain) All rights reserved.
 * fsaiz@vicomtech.org
 */
%}

%Load the generated model
load('trainingData','totalNet','totalAcc','imdso','resize','crossValidationTestDataTotal');

%Select the best net
[maxAcc, maxAccI] = max(totalAcc);

% Input parameters for testing
net = totalNet(maxAccI);
testDataSize = size(crossValidationTestDataTotal);
numberImTest = testDataSize(1)/4;
posT=1;
for i=1:1:4
% Create a new imageDatastore for test
testData = imageDatastore(cellstr(crossValidationTestDataTotal(posT:posT+(numberImTest-1),:)),'LabelSource', 'foldernames');

%Resize the images
testData.ReadSize = numpartitions(testData);

testData.ReadFcn = @(loc)imresize(imread(loc),resize);


tic;
YPred = classify(net,testData);
testTime=toc;
YTest = testData.Labels;

%Accuracy
accuracy = sum(YPred == YTest)/numel(YTest)

% Confusion matrix and plot
plotConf = plotconfusion(YTest,YPred)
confMatrix = confusionmat(YTest, YPred)
posT = posT + numberImTest;
end