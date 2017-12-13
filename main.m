%% Bilateral filtered image of ambient image (A_Base)
input = './sol_images/carpet_noflash.tif';
output = './sol_images/carpet_ambient_bilateral.tif';
%input = './my_input/bottle4_ambient.tif';
%output = './my_input/bottle4_ambient_bilateral.tif';
A = im2double(imread(input));
A_base = bfilter2(A, 11, [27 0.1]);
imwrite(A_base, output);

%% Bilateral filtered image of flash image (F_Base)
input = './sol_images/carpet_flash.tif';
output = './sol_images/carpet_flash_bilateral.tif';
F = im2double(imread(input));
F_base = bfilter2(F, 11, [5 0.1]);
imwrite(F_base, output);

%% Joint Bilateral filtered image of ambient image (A_NR)
A =  im2double(imread('./sol_images/carpet_noflash.tif'));
F = im2double(imread('./sol_images/carpet_flash.tif'));
A_NR = jbfilter2(A, F, 5, 3, 0.1);
imwrite(A_NR, './sol_images/carpet_joint_bilateral2.tif');

%% Calculate F_detail to obtain a detail layer
epsilon = 0.02;
F_base = im2double(imread('./sol_images/carpet_flash_bilateral.tif'));
F = im2double(imread('./sol_images/carpet_flash.tif'));
F_detail = (F+epsilon) ./ (F_base+epsilon);
imwrite(F_detail, './sol_images/carpet_flash_detail.tif');

%% Call function to create flag to remove shadows and specularities from image
A = im2double(imread('./sol_images/carpet_noflash.tif'));
F = im2double(imread('./sol_images/carpet_flash.tif'));
flag = remSpecShad(A, F);
imwrite(flag, './sol_images/carpet_mask_good.tif');

%% Final function to produce detail transfer/noise-removed image
M = im2double(imread('./sol_images/carpet_mask_good.tif'));
A_NR = im2double(imread('./sol_images/carpet_joint_bilateral.tif'));
A_Base = im2double(imread('./sol_images/carpet_ambient_bilateral.tif'));
F_Detail = im2double(imread('./sol_images/carpet_flash_detail.tif'));
allM = zeros([size(M), 3]);
for i=1:3
    allM(:,:,i) = M;
end
A_Final = (1-allM) .* A_NR .* F_Detail + allM .* A_Base;
imwrite(A_Final, './sol_images/carpet_final.tif');







