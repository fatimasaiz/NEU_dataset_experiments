function net = AlexNetV2(height, width, n_channels, n_classes)
    net = [
        imageInputLayer([height width n_channels])
        
        convolution2dLayer(11,96,'Stride',4,'Padding',0,'BiasL2Factor',1)
        reluLayer()
%         crossChannelNormalizationLayer(5,'Alpha',0.0001,'Beta',0.75,'K',1)
       batchNormalizationLayer()

        maxPooling2dLayer(3,'Stride',2,'Padding',0)
        
        convolution2dLayer(5,256,'Stride',1,'Padding',2,'BiasL2Factor',1)
        reluLayer()
%         crossChannelNormalizationLayer(5,'Alpha',0.0001,'Beta',0.75,'K',1)
        batchNormalizationLayer()

        maxPooling2dLayer(3,'Stride',2,'Padding',0)
        
        convolution2dLayer(3,384,'Stride',1,'Padding',1,'BiasL2Factor',1)
        reluLayer()
        batchNormalizationLayer()
        
        convolution2dLayer(3,384,'Stride',1,'Padding',1,'BiasL2Factor',1)
        reluLayer()
        batchNormalizationLayer()
        
        convolution2dLayer(3,256,'Stride',1,'Padding',1,'BiasL2Factor',1)
        reluLayer()
        batchNormalizationLayer()
        
        maxPooling2dLayer(3,'Stride',2,'Padding',0)
        
        fullyConnectedLayer(4096)
        reluLayer()
        dropoutLayer(0.8)
        
        fullyConnectedLayer(4096)
        reluLayer()
        dropoutLayer(0.8)
        
        fullyConnectedLayer(n_classes)
        softmaxLayer()
        classificationLayer()
    ];
end