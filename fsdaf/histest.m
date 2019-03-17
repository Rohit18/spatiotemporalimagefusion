function pixval = histest(x)
[rowsN, colsN] = size(x);
y = zeros(rowsN, colsN);
for j = 1 : colsN
    for i = 1 :rowsN
        
        if x(i, j) == x(rowsN/8,colsN/8)
            y(i, j) = 1;
        else
            y(i, j) = 0;
        end
        
        
    end
end

temp = sum(y(:));
pixval = temp/rowsN*colsN;

end
