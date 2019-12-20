%% load images and define qTable for Y and Cb/Cr %%
clear all; clc
load('img1_down.mat')
%~ Make the image to be exactly for blocks 8x8, whithout leftovers ~%
[N, M] = size(img1_down);
N = mod(N, 8); M = mod(M, 8);
img1_down = img1_down(1:end-N, 1:end-M, :);

%~ Create the blocks and apply the DCT transformation ~%
clear imageY imageCb imageCr
clear imageY_rec imageCr_rec imageCb_rec
subimg = [4 2 0]; qScale = 0.6;
tic
JPEGenc = JPEGencode(img1_down, subimg, qScale);
toc
tic
imgRec = JPEGdecode(JPEGenc, subimg, qScale);
toc
%%
figure; 
subplot(1,2,1)
imshow(img1_down)
title('Original Image', 'Interpreter', 'latex')
subplot(1,2,2)
imshow(imgRec);
title_str = ['Reconstructed Image - Subsampling ',num2str(subimg(1)),':',num2str(subimg(2)), ...
             ':', num2str(subimg(3)), ' , qScale = ', num2str(qScale)];
title(title_str, 'Interpreter', 'latex')
figure(); image(img1_down - imgRec);
title('Quantization error', 'Interpreter', 'latex')
