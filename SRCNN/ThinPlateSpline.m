%Thin Plate Splines

%Image to be downscaled (strictly for 1000x1000x3)
image_for_downscaling = importdata('Data/LC08_033036_180929_LR.png');


for bands = 1:3
degraded_image = im2single(imresize(image_for_downscaling(:,:,bands), 1/8, 'nearest'));
degraded_image_unit8 = uint8(255 * mat2gray(degraded_image));
im = padarray(degraded_image_unit8, [1 1], 'replicate');
[imh,imw,imc] = size(im);

%define landmarks
ps = [1,1;imw-0,1;imw-0,imh-0;1,imh-0;
    0.4*imw,imh*3/8;
    0.6*imw,imh*3/8;
    0.4*imw,imh*5/8;
    0.6*imw,imh*5/8];
%move points based on scale
pd = 8*ps;

%TPS
[imo1,mask1] = tpsInterpolation( im, ps, pd,'thin');





downscaled_image = imo1(17:1016, 17:1016, :);
downscaled_image= mat2gray(downscaled_image);
downscaled_image = im2single(imadjust(downscaled_image,[],[min(degraded_image(:)) max(degraded_image(:))]));
imwrite(downscaled_image, strcat('TPS_result_Band', num2str(bands), '.png'), 'png');
end