function [mask] = remSpecShad(flash, ambient)
    flash_lin = 0.299*flash(:,:,1) + 0.587*flash(:,:,2) + 0.114*flash(:,:,3);
    ambient_lin = 0.299*ambient(:,:,1) + 0.587*ambient(:,:,2) + 0.114*ambient(:,:,3);
    mask = flash_lin - ambient_lin;
    flag = zeros(size(mask));
    flag(mask < -0.05 & mask > -0.2) = 1;
    flag(mask > 0.65 & mask < 0.7) = 1;
    spec = 0.95 * (max(flash_lin(:)) - min(flash_lin(:)));
    flag(flash_lin > spec) = 1;

    %this part is required to get a better reading
    %idea from: https://github.com/agarwal-shubham/Digital-Photography-with-Flash-and-No-flash-Image-Pairs-/blob/master/codes/shadowRem.m
    restruct1 = strel('disk',2);
    restruct2 = strel('disk',6);
    restruct3 = strel('disk',4);
    
    flag = imerode(flag,restruct1);
    flag = imfill(flag,'holes');
    flag = imdilate(flag,restruct2);
    flag = imerode(flag,restruct3);
   
    %apply a gaussian filter
    mask = imgaussfilt(flag,3);
end
