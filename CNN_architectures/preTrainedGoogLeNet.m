function net = preTrainedGoogLeNet(height, width, n_channels, n_classes)
    
    if(height==224 && width==224 && n_channels==3)
        net = googlenet;
        net = layerGraph(net);
        
        net = removeLayers(net, {'loss3-classifier','prob','output'});

        newLayers = [
            fullyConnectedLayer(n_classes,'Name','fc','WeightLearnRateFactor',20,'BiasLearnRateFactor', 20)
            softmaxLayer('Name','softmax')
            classificationLayer('Name','classoutput')];
        
        net = addLayers(net,newLayers);
        net = connectLayers(net,'pool5-drop_7x7_s1','fc');

%         net = net.Layers;
        
        else
            error('The input size is not proper');
    end

end