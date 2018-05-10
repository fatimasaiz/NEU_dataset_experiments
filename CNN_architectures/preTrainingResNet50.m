function net = preTrainingResNet50(height, width, n_channels, n_classes)
    
    if(height==224 && width==224 && n_channels==3)
        net = resnet50;
        net = layerGraph(net);
        
        net = removeLayers(net, {'fc1000','fc1000_softmax','ClassificationLayer_fc1000'});

        newLayers = [
            fullyConnectedLayer(n_classes,'Name','fc','WeightLearnRateFactor',20,'BiasLearnRateFactor', 20)
            softmaxLayer('Name','softmax')
            classificationLayer('Name','classoutput')];
        
        net = addLayers(net,newLayers);
        net = connectLayers(net,'avg_pool','fc');

%         net = net.Layers;
        
        else
            error('The input size is not proper');
    end

end