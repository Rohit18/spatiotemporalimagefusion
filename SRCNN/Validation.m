%Validation Metrices

%Variables
t1 = im2uint16(importdata('LC08_045028/LC08_045028_180704_LR.png'));
t2 = im2uint16(importdata('LC08_045028/LC08_045028_180731_LR.png'));
tps = im2uint16(importdata('LC08_045028/LC08_045028_180731_LR_TPS.png'));
fsdaf = im2uint16(importdata('LC08_045028/LC08_045028_180731_LR_FSDAF.png'));
srcnn = im2uint16(importdata('LC08_045028/LC08_045028_180731_SRCNN.png'));
bi = im2uint16(importdata('LC08_045028/LC08_045028_180731_BI.png'));

%ssim
t1_ssim = ssim(t1, t2); %for determining the change percentage
tps_ssim = ssim(tps, t2);
fsdaf_ssim = ssim(fsdaf, t2);
srcnn_ssim = ssim(srcnn, t2);
bi_ssim = ssim(bi, t2);

%psnr
t1_psnr = psnr(t1, t2);
tps_psnr = psnr(tps, t2);
fsdaf_psnr = psnr(fsdaf, t2);
srcnn_psnr = psnr(srcnn, t2);
bi_psnr = psnr(bi, t2);

%rsme
t1_rmse = sqrt(MSE(t1(:), t2(:)));
%t1_rmse = sqrt(immse(t1, t2));
tps_rmse = sqrt(MSE(tps(:), t2(:)));
%tps_rmse = sqrt(immse(tps, t2));
fsdaf_rmse = sqrt(MSE(fsdaf(:), t2(:)));
%fsdaf_rmse = sqrt(immse(fsdaf, t2));
srcnn_rmse = sqrt(MSE(srcnn(:), t2(:)));
%srcnn_rmse = sqrt(immse(srcnn, t2));
bi_rmse = sqrt(MSE(bi(:), t2(:)));
%bi_rmse = sqrt(immse(bi, t2));

%corrcoef
t1_cc = corrcoef(im2double(t1), im2double(t2));
tps_cc = corrcoef(im2double(tps), im2double(t2));
fsdaf_cc = corrcoef(im2double(fsdaf), im2double(t2));
srcnn_cc = corrcoef(im2double(srcnn), im2double(t2));
bi_cc = corrcoef(im2double(bi), im2double(t2));