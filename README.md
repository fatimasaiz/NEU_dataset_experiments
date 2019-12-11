# NEU_dataset_experiments
Source code used on "A robust and fast deep learning-based method for defect classification in steel surfaces" paper.

*
 * NEU Experiments - ReadMe
 * 
 * Copyright (C) 2018, Vicomtech (http://www.vicomtech.es/),
 * (Spain) All rights reserved.
 * fsaiz@vicomtech.org
 *
 
 1. DESCRIPTION

This directory contains the source code used on "A robust and fast deep learning-based method
for defect classification in steel surfaces" paper.

It contains the following scripts:

 - preProcess: apply filters to highlight the defects. 
		(i) imadjustn: Adjust image intensity values (achieves the best classification accuracy)
		(ii) histeq: Enhance contrast using histogram equalization
		(iii) localcotnrast: Edge-aware local contrast manipulation of images
 - dataAugmentation: apply transformations 
 - generateOcclusion: generate a percentage of occlusions
 - increaseBrightness: augment the brightness
 - NEU_CNN_[train|test] with different architectures
		(1) AlexNet
		(2) GoogleNet
		(3) ResNet50

 2. SETTINGS
 
 - NEUpath: 				folder of the input images 
 - architecture_net:        1 = AlexNet v2                  
                            2 = pretrained GoogLeNet (224x224x3)                          
                            3 = pretrained ResNet50 (224x224x3) 
							
 - k: 						k-fold cross validation
 
 - trainingOptions parameters

 
 

Please if you use the code, reference our work:
 
Saiz, F.A. , Serrano, I., Barandiran. I., Sanchez, J.R. A robust and fast deep learning-based method
for defect classification in steel surfaces. IEE-IS18. pp. 455-460 (2018)

https://ieeexplore.ieee.org/abstract/document/8710501
 
 
