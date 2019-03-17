%Evaluate Results

%Variables

t1 = importdata('Data/LC08_045028/LC08_045028_180704_LR.png');

t2 = importdata('Data/LC08_045028/LC08_045028_180731_LR.png');

fsdaf = im2uint16(importdata('LC08_045028_180731_LR_FSDAF.png'));


%ssim
t1_t2_ssim = ssim(t1, t2);
fsdaf_t1_ssim = ssim(t1, fsdaf);
fsdaf_ssim = ssim(fsdaf, t2);



%psnr
t1_t2_psnr = psnr(t1, t2);
fsdaf_t1_psnr = psnr(t1, fsdaf);
fsdaf_psnr = psnr(fsdaf, t2);



%rsme
t1_t2_rmse = sqrt(immse(t1, t2));
fsdaf_t1_rmse = sqrt(immse(t1, fsdaf));
fsdaf_rmse = sqrt(immse(fsdaf, t2));



%corrcoef
t1_t2_cc = corrcoef(im2double(t1), im2double(t2));
fsdaf_t1_cc = corrcoef(im2double(t1), im2double(fsdaf));
fsdaf_cc = corrcoef(im2double(fsdaf), im2double(t2));

