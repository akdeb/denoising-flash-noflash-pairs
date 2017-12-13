imflash = im2double(imread('./images/flash_data_JBF_Detail_transfer/cave01_00_flash.jpg'));
imambient = im2double(imread('./images/flash_data_JBF_Detail_transfer/cave01_01_noflash.jpg'));
Fr = imflash(:,:,1);
Fg = imflash(:,:,2);
Fb = imflash(:,:,3);
ambient_grd  = gradient(imambient);

%[Ajointr, Abaser, Fbaser] = bilateral(Fr, imambient(:,:,1));
%[Ajointg, Abaseg, Fbaseg] = bilateral(Fg, imambient(:,:,2));
%[Ajointb, Abaseb, Fbaseb] = bilateral(Fb, imambient(:,:,3));
[Ajointr, Abaser, Fbaser] = bfilter2(Fr, imambient(:,:,1));
[Ajointg, Abaseg, Fbaseg] = bfilter2(Fg, imambient(:,:,2));
[Ajointb, Abaseb, Fbaseb] = bfilter2(Fb, imambient(:,:,3));

Ajoint = cat(3,Ajointr,Ajointg,Ajointb);
Fbase = cat(3,Fbaser,Fbaseg,Fbaseb);
Abase = cat(3,Abaser,Abaseg,Abaseb);

eps = 0.02;
Fdetailr = (Fr+eps)./(Fbaser+eps);
Fdetailg = (Fg+eps)./(Fbaseg+eps);
Fdetailb = (Fb+eps)./(Fbaseb+eps);
Fdetail = cat(3,Fdetailr,Fdetailg,Fdetailb);

shadowMask = shadowRem(imflash, imambient);
Ffin = (cat(3,(1-shadowMask),(1-shadowMask),(1-shadowMask)).*Ajoint.*Fdetail) + (cat(3,shadowMask,shadowMask,shadowMask).*Abase);

figure, imshow(imambient);
figure, imshow(imflash);
figure, imshow(Ffin);