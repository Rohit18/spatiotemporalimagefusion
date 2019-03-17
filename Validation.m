%Validation Metrices for Chile

%Variables
t1 = histeq(im2uint16(importdata('tucson/tucson_t1_subset.png')));
t2 = histeq(im2uint16(importdata('tucson/tucson_t2_subset.png')));
hybrid = im2uint16(importdata('tucson/tucson_hybrid.png'));
fsdaf = histeq(im2uint16(importdata('tucson/tucson_FSDAF.png')));
srcnn = histeq(im2uint16(importdata('tucson/tucson_SRCNN.png')));

%ssim
t1_t2_ssim = ssim(t1, t2);
hybrid_ssim = ssim(hybrid, t2);
fsdaf_ssim = ssim(fsdaf, t2);
srcnn_ssim = ssim(srcnn, t2);


%psnr
t1_t2_psnr = psnr(t1, t2);
hybrid_psnr = psnr(hybrid, t2);
fsdaf_psnr = psnr(fsdaf, t2);
srcnn_psnr = psnr(srcnn, t2);


%rsme
t1_t2_rmse = sqrt(immse(t1, t2));
hybrid_rmse = sqrt(immse(hybrid, t2));
fsdaf_rmse = sqrt(immse(fsdaf, t2));
srcnn_rmse = sqrt(immse(srcnn, t2));


%corrcoef
t1_t2_cc = corrcoef(im2double(t1), im2double(t2));
hybrid_cc = corrcoef(im2double(hybrid), im2double(t2));
fsdaf_cc = corrcoef(im2double(fsdaf), im2double(t2));
srcnn_cc = corrcoef(im2double(srcnn), im2double(t2));
