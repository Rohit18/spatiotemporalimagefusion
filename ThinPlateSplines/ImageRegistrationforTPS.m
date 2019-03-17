%Automatic Registration of Already Cropped Images
%Cropping each image to 512*512

fix = im2single(image_for_downscaling(:,:,bands));
[row, col] = size(fix);
move = imo1;

A  = fix;
B  = move;

c = normxcorr2(A,B);
[ypeak, xpeak] = find(c==max(c(:)));
yoffSet = ypeak-size(A,1);
xoffSet = xpeak-size(A,2);

downscaled_image = move((0+yoffSet):(row-1+yoffSet), (0+xoffSet):(col-1+xoffSet), :);

imshowpair(im2double(downscaled_image), fix, 'montage')

imwrite(im2double(downscaled_image), 'D1.png', 'png');
