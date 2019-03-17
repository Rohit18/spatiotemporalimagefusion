%Thin Plate Splines


file = 'Data/LC08_045028/LC08_045028_180731_LR.png';
image_for_downscaling = importdata(file);
[~, name, ~] = fileparts(file);
[r, c, b] = size(image_for_downscaling);
temp = zeros(r, c, b);

for bands = 1:3

    degraded_image = im2single(imresize(image_for_downscaling(:,:,bands), 1/8, 'nearest'));
    %degraded_image = imresize(image_for_downscaling(:,:,bands), 1/8, 'nearest');
    degraded_image_unit8 = uint8(255 * mat2gray(degraded_image));

    im = padarray(degraded_image_unit8, [1 1], 'replicate');
    [imh,imw,~] = size(im);

    %define landmarks
    ps = [1,1;
        imw-0,1;
        imw-0,imh-0;
        1,imh-0;
        0.4*imw,imh*3/8;
        0.6*imw,imh*3/8;
        0.4*imw,imh*5/8;
        0.6*imw,imh*5/8];
    %move points based on scale
    pd = 8*ps;

    %TPS; there are two variables: scale and padding
    [imo1] = tpsInterpolation( im, ps, pd,'thin');
    
    %ImageRegistrationforTPS %Automatically registers original and resultant image

    %downscaled_image = im2single(imadjust(imo1,[],[min(degraded_image(:)) max(degraded_image(:))]));
    %downscaled_image = imadjust(downscaled_image,[],[min(degraded_image(:)) max(degraded_image(:))]);
    
    %Automatic Registration of Already Cropped Images
    %Cropping each image to 512*512

    fix = im2single(image_for_downscaling(:,:,bands));
    [row, col] = size(fix);
    move = im2single(imo1);

    A  = fix;
    B  = move;

    c = normxcorr2(A,B);
    [ypeak, xpeak] = find(c==max(c(:)));
    yoffSet = ypeak-size(A,1);
    xoffSet = xpeak-size(A,2);

    downscaled_image = move((0+yoffSet):(row-1+yoffSet), (0+xoffSet):(col-1+xoffSet), :);

    temp(:,:,bands) = uint8(downscaled_image);
    
    
end
imwrite(uint8(temp), strcat(name, '_TPS', '.png'), 'png');

clear A b B c Bands c col degraded_image degraded_image_unit8 downscaled_image 
clear ext file filepath fix im image_for_downscaling imc imh imo1 imw mask1 move
clear name pd ps r row temp test1 xoffSet xpeak yoffSet ypeak bands