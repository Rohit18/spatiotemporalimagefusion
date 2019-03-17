function MSE = MSE(lena, image_new)
[M, N] = size(lena);
error = lena - (image_new);
MSE = sum(sum(error .* error)) / (M * N);
disp(MSE);
end