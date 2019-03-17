%This is the final step in FSDAF
change = padarray(e20, [100 100], 'replicate');
first = padarray(FT1, [100 100], 'replicate');
predictedImage = zeros(rows+200, columns+200);

w = 17;

spectralMatrix = zeros(w,w);
distanceMatrix = zeros(w,w);
reciprocalMatrix = zeros(w,w);
spectralMatrixSelected = zeros(w,w);

for colsT = 101: columns+100
    for rowsT = 101: rows+100
        
        %define neighborhood
        colsB = colsT - movingwindow;
        colsS = colsT + movingwindow;
        rowsB = rowsT - movingwindow;
        rowsS = rowsT + movingwindow;
        
        currentMatrix = first(rowsB:rowsS, colsB:colsS);
        changeMatrix = change(rowsB:rowsS, colsB:colsS);
        
        for colsN = 1:w
            for rowsN = 1:w
                
                spectralDiff = abs(currentMatrix(rowsN, colsN) - currentMatrix(9, 9))/currentMatrix(9, 9);
                spectralMatrix(rowsN,colsN) = spectralDiff;
                
            end
        end
        
        %find the top 20 pixels
        sorted = sort(spectralMatrix, 'descend');
        minimumspectradiffvalue = sorted(25);
        threshold = spectralMatrix > minimumspectradiffvalue;
        spectralMatrixSelected = threshold .* spectralMatrix;
        
        %find the euclidean distance between the pixels
        for colsN = 1:w
            for rowsN = 1:w
                
                if spectralMatrixSelected(rowsN, colsN) > 0
                    
                    diststep1 = sqrt((rowsN-9)^2 + (colsN-9)^2);
                    diststep2 = diststep1/(w*w/2);
                    dist = 1 + diststep2;
                    distanceMatrix(rowsN, colsN) = dist;
                end
                
                
            end
        end
        
        %calculate the weights of each similar pixel
        for colsN = 1:w
            for rowsN = 1:w
                
                
                if distanceMatrix(rowsN, colsN) > 0
                    
                    reciprocalDist = 1/distanceMatrix(rowsN, colsN);
                    reciprocalsum = 1./distanceMatrix;
                    reciprocalsum(~isfinite(reciprocalsum))=0;
                    reciprocalsum = sum(reciprocalsum(:));
                    reciprocalDist = reciprocalDist./reciprocalsum;
                    reciprocalMatrix(rowsN,colsN) = reciprocalDist;
                end
                
            end
        end
        
        %find out the change value for each pixel
        realChange = changeMatrix .* reciprocalMatrix;
        realChange = sum(realChange(:));
        predictedImage(rowsT, colsT) = first(rowsT, colsT) + realChange;
    end
end

predictedImage = predictedImage(101:rows+100, 101:columns+100);