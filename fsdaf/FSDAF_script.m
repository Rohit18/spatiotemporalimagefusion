%%Loading Images

%Loading the two Sentinel data

%%!Change Name of the image files
%Available Sentinel image (FT1)
file_t1 = 'Data/LC08_045028/LC08_045028_180704_LR.png';
file_t2 = 'Data/LC08_045028/LC08_045028_180731_LR.png';
[~, name1, ~] = fileparts(file_t1);
[~, name2, ~] = fileparts(file_t2);
sentinelt1 = importdata(file_t1);
%Sentinel Image to be predicted through FSDAF - Ground Truth Image (FT2)
sentinelt2 = importdata(file_t2);
%Downsampled image
sentinel_srcnn = importdata('Data/LC08_045028/LC08_045028_180731_LR_TPS.png');


%Checking if image dimensions match
image_measurements_t1 = size(sentinelt1);
image_measurements_t2 = size(sentinelt2);
if (image_measurements_t1(1) ~= image_measurements_t2(1) || image_measurements_t1(2) ~= image_measurements_t2(2) || image_measurements_t1(3) ~= image_measurements_t2(3))
    msgbox("Image Dimensions do not match!")
    return
else
    rows = image_measurements_t1(1);
    columns = image_measurements_t1(2);
    channels = image_measurements_t1(3);
    clear image_measurements_t1 image_measurements_t2 
end

%Unsupervised classification using K-means (4 classes)
classdata = imsegkmeans(sentinelt1, 4, 'NumAttempts', 3);

%This variable will store the resolved bands per iteration of the following
%loop
result = zeros(rows, columns, channels);
prediction_direct = zeros(rows, columns, channels);


%Looping through the Sentinel bands for performing FSDAF (assuming only
%3 bands are used)
for bands = 1:channels %channels 
    
FT1 = im2single(sentinelt1(:,:,bands));

%Upsampling to MODIS from FT1 (CT1) 
%Upscales bands to the 1/8 of the orginal resolution
CT1 = imresize(sentinelt1(:,:, bands), 1/8, 'nearest');
%Upsampling the available MODIS from FT2 (CT2)
CT2 = imresize(sentinelt2(:,:,bands), 1/8, 'nearest');

%Converting to single from double
CT1 = im2single(CT1);
CT2 = im2single(CT2);

%STEP ONE
classifiedImage = classdata;
cdata = classdata;
%Retrieving the specifications of the Coarse Image
[rowsC, colsC] = size(CT1);

%Initializing the classified image matrix
classM = zeros(rowsC, colsC, channels);

%Counters for no of fine pixels belonging to each class per coarse pixel
classCounter1=0;
classCounter2=0;
classCounter3=0;
classCounter4=0;


%Traversing the Coarse Image 

%%!Modify moving window size (default moving window size 8*8)
movingwindow = 8;


for colsC = 1:columns/8
    for rowsC = 1:rows/8
        
        %Traversing the Fine Image
        for colsF = (colsC*movingwindow)-(movingwindow-1):colsC*movingwindow
            for rowsF = (rowsC*movingwindow)-(movingwindow-1):rowsC*movingwindow
                
                %Finding out the no of fine pixels belonging to each class per coarse pixel
                if classifiedImage(rowsF, colsF) == 1
                    classCounter1 = classCounter1 + 1;
                elseif classifiedImage(rowsF, colsF) == 2
                    classCounter2 = classCounter2 + 1;
                elseif classifiedImage(rowsF, colsF) == 3
                    classCounter3 = classCounter3 + 1;
                elseif classifiedImage(rowsF, colsF) == 4
                    classCounter4 = classCounter4 + 1;
                end
                
            end
        end
        
        %Assigning Counts for each class (please keep this fixed)
        classM(rowsC, colsC, 1) = classCounter1;
        classM(rowsC, colsC, 2) = classCounter2;
        classM(rowsC, colsC, 3) = classCounter3;
        classM(rowsC, colsC, 4) = classCounter4;
        
        %Resetting the Counters
        classCounter1=0;
        classCounter2=0;
        classCounter3=0;
        classCounter4=0;
        
        
    end
end

%clear classCounter1 classCounter2 classCounter3 classCounter4 colsC rowsC colsF rowsF classifiedImage

%STEP TWO
ChosenPixels_Class1 = zeros(rows/8,columns/8);
ChosenPixels_Class2 = zeros(rows/8,columns/8);
ChosenPixels_Class3 = zeros(rows/8,columns/8);
ChosenPixels_Class4 = zeros(rows/8,columns/8);


class1_m1 = classM(:,:,1);
class2_m1 = classM(:,:,2);
class3_m1 = classM(:,:,3);
class4_m1 = classM(:,:,4);

%Find the pixel values for each class, sort them to find the minimum values
sortPixelValues1 = sort(class1_m1(:), 'descend');
choosePixelValues1 = sortPixelValues1(1:20);
minimumPixelValue1 = choosePixelValues1(20);

sortPixelValues2 = sort(class2_m1(:), 'descend');
choosePixelValues2 = sortPixelValues2(1:20);
minimumPixelValue2 = choosePixelValues2(20);

sortPixelValues3 = sort(class3_m1(:), 'descend');
choosePixelValues3 = sortPixelValues3(1:20);
minimumPixelValue3 = choosePixelValues3(20);

sortPixelValues4 = sort(class4_m1(:), 'descend');
choosePixelValues4 = sortPixelValues4(1:20);
minimumPixelValue4 = choosePixelValues4(20);


%choose all the purer class pixels
for colsT = 1 : columns/8
    for rowsT = 1 : rows/8
        
        if all(class1_m1(rowsT, colsT) >= minimumPixelValue1)
            ChosenPixels_Class1(rowsT,colsT) = 1;
        end
        
        if all(class2_m1(rowsT, colsT) >= minimumPixelValue2)
            ChosenPixels_Class2(rowsT,colsT) = 1;
        end
        if all(class3_m1(rowsT, colsT) >= minimumPixelValue3)
            ChosenPixels_Class3(rowsT,colsT) = 1;
        end
        if all(class4_m1(rowsT, colsT) >= minimumPixelValue4)
            ChosenPixels_Class4(rowsT,colsT) = 1;       
        end
    end
end

%Only choose the pixels which are less than purest ones and more than
%impurest ones so that only the pixels which have more chances of
%transitioning are chosen
ChosenPixels = ChosenPixels_Class1 + ChosenPixels_Class2 + ChosenPixels_Class3 + ChosenPixels_Class4;
ChosenPixels = ChosenPixels > 0;
ChangeModis = CT2 - CT1;
ChangeTemp = ChangeModis .* ChosenPixels;
ChangeModisArray = zeros(1, nnz(ChangeTemp));
quantiles1 = quantile(ChangeModis(:), 50);

% TempChosenPixels1 = ChangeModis > quantiles1(2);
% TempChosenPixels2 = ChangeModis < quantiles1(8);

%Find the pixels for the chosen locations
ChosenPixelsBand1 = ChangeModis > quantiles1(1) & ChangeModis < quantiles1(50);
SelectedPixelsBand1 = ChosenPixelsBand1 & ChosenPixels;
pixelLocations1 = zeros(2, nnz(SelectedPixelsBand1));
rowsP1 = 1;
colsP1 = 1;

for colsT = 1 : columns/8
    for rowsT = 1 : rows/8
        
        if SelectedPixelsBand1(rowsT, colsT) == 1
            pixelLocations1(rowsP1, colsP1) = rowsT;
            rowsP1= rowsP1 + 1;
            pixelLocations1(rowsP1, colsP1) = colsT;
            rowsP1 = 1;
            colsP1 = colsP1 + 1;
        end
    end
end

ChangeModisMat1 = zeros(nnz(SelectedPixelsBand1), 1);
ClassFractionMat1 = zeros(nnz(SelectedPixelsBand1), 4);

for rowsT = 1 : nnz(SelectedPixelsBand1)
    ChangeModisMat1 (rowsT, 1) = ChangeModis(pixelLocations1(1, rowsT), pixelLocations1(2, rowsT));
    
    ClassFractionMat1 (rowsT, 1) = class1_m1(pixelLocations1(1, rowsT), pixelLocations1(2, rowsT))/(movingwindow*movingwindow);
    ClassFractionMat1 (rowsT, 2) = class2_m1(pixelLocations1(1, rowsT), pixelLocations1(2, rowsT))/(movingwindow*movingwindow);
    ClassFractionMat1 (rowsT, 3) = class3_m1(pixelLocations1(1, rowsT), pixelLocations1(2, rowsT))/(movingwindow*movingwindow);
    ClassFractionMat1 (rowsT, 4) = class4_m1(pixelLocations1(1, rowsT), pixelLocations1(2, rowsT))/(movingwindow*movingwindow);

end

%Modulus
deltaF_Band1 = ClassFractionMat1\ChangeModisMat1; 

landsat1_afterChange = FT1; %the pixel values are turning negative; must set to [0,1] after the loop

for colsT = 1:columns
    for rowsT = 1:rows
        
        if cdata(rowsT, colsT) == 1
            
            landsat1_afterChange(rowsT, colsT) = landsat1_afterChange(rowsT, colsT) + deltaF_Band1(1);
            
        end
        if cdata(rowsT, colsT) == 2
            
            landsat1_afterChange(rowsT, colsT) = landsat1_afterChange(rowsT, colsT, 1) + deltaF_Band1(2);
            
        end
        if cdata(rowsT, colsT) == 3
            
            landsat1_afterChange(rowsT, colsT) = landsat1_afterChange(rowsT, colsT, 1) + deltaF_Band1(3);
            
        end
        if cdata(rowsT, colsT) == 4
            
            landsat1_afterChange(rowsT, colsT) = landsat1_afterChange(rowsT, colsT, 1) + deltaF_Band1(4);
            
        end
        
    end
end

landsat1_afterChange = rescale(landsat1_afterChange);


temporalChange_Landsat = landsat1_afterChange - FT1;
temporalChange_Landsat_resized = imresize(temporalChange_Landsat, 1/8, 'nearest');
Residual_eq9 = ChangeModis - temporalChange_Landsat_resized;
landsat_temporal = im2single(sentinel_srcnn(:,:,bands));
E_HO_eq14 = landsat1_afterChange - landsat_temporal; %min of -0.0184
E_HE_eq14 = imresize(Residual_eq9, 8, 'nearest');

%Eq. 16
padded_cdata = padarray(cdata, [100 100], 'replicate');
HI = nlfilter(padded_cdata,[movingwindow movingwindow],'histest');
HI_T = HI(101:rows+100, 101:columns+100);
HI = im2single(mat2gray(HI_T));
inv_het_index = 1 - HI;

cw = (E_HO_eq14 .* HI) + (E_HE_eq14 .* inv_het_index);

weights = gradientweight(cw);
r = (E_HE_eq14.* weights);
change_modis = imresize(ChangeModis, 8);
r = rescale(r, min(change_modis(:)), max(change_modis(:)));



%Creating DeltaF matrix for each class
%deltaF_Band1 has values for changes in each class
%deltaF_changeMatrix is a matrix where each pixel has the change value from
%T1 to T2 per class dependent on the class the pixels of T1 belongs to
%Required in Equation 20

[rows, cols] = size(classdata);
deltaF_changeMatrix = zeros(rows, cols);

for col = 1 : cols
    for row = 1 : rows

        if classdata(row, col) == 1
            deltaF_changeMatrix(row, col) = deltaF_Band1(1);
        elseif classdata(row, col) == 2
            deltaF_changeMatrix(row, col) = deltaF_Band1(2);
        elseif classdata(row, col) == 3
            deltaF_changeMatrix(row, col) = deltaF_Band1(3);    
        elseif classdata(row, col) == 4
            deltaF_changeMatrix(row, col) = deltaF_Band1(4);
        end
        
    end
end


e20 = r + deltaF_changeMatrix;

% Code for redistributing pixels
FinalRunTrial

result1 = rescale(predictedImage, min(landsat_temporal(:)), max(landsat_temporal(:)));
result2 = imhistmatch(result1, landsat_temporal);
result(:,:,bands) = result2;


end

imwrite(result, strcat(name2,'_FSDAF.png'), 'png');

Evaluate_FSDAF

clear A ans bands C cdata change change_R changeMatrix ChangeModis 
clear ChangeModisArray ChangeModisMat1 changenew ChangeTemp channels
clear check choosePixelValues1 choosePixelValues2 choosePixelValues3 
clear choosePixelValues4 ChosenPixels ChosenPixels_Class1 ChosenPixels_Class2
clear ChosenPixels_Class3 ChosenPixels_Class4 ChosenPixelsBand1
clear class1_m1 class2_m1 class3_m1 class4_m1 classCounter1 classCounter2
clear classCounter3 classCounter4 classdata ClassFractionMat1 classifiedImage
clear classM coarse_c1 coarse_c2_p colsB colsN colsP1 colsS colsT columns 
clear col cols colsC colsF current_min currentMatrix cw cw_resized
clear counter_afterChange_Band1 current_max deltaF_Band1 deltaF_changeMatrix
clear counter_landsatt1_Band1 deltaF_eq20 deltaF_eq20_test diff_change
clear CT1 downsampled_bands_result1 downsampled_bands_result2 HO
clear CT2 dist distanceMatrix diststep1 diststep2 FT1
clear downsampled_bands_result3 downsampled_bands_result4 E_HE E_HE_eq14
clear E_HE_test E_HO E_HO_eq14 E_HO_eq14_check file final final_test
clear final_test_rescale HI_T inv_het_index landsatDiff_Temp 
clear first HI I4 landsatt1_double maxval minimumPixelValue1
clear FT2 I3 minimumPixelValue2 movingwindow
clear l_tps landsat1_afterChange minimumPixelValue3 minval
clear landsat_tps minimumPixelValue4 minimumspectradiffvalue
clear name new_max new_min padded_cdata pixelLocations1 predict_change_c
clear quantiles1 r r_test real_change_c realChange
clear reciprocalDist reciprocalMatrix reciprocalsum Residual_eq9 Residuals
clear result1 result2 result3 result4 result_test row rows rowsB
clear rowsC rowsF rowsN rowsP1 rowsS rowsT sentinel_srcnn 
clear SelectedPixelsBand1 sentinelt1 sentinelt2 sorted sortPixelValues1
clear sortPixelValues2 sortPixelValues3 sortPixelValues4 spectralDiff
clear spectralMatrix spectralMatrixSelected ssim_check t temp
clear temporalChange_Landsat temporalChange_Landsat_resize 
clear temporalChange_Landsat_resized test testing threshold w W
clear w_change_tps W_test w_uniform file_t1 file_t2 name1 name2
clear predictedImage  landsat_temporal result





























