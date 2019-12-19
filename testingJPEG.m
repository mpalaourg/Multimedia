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
subimg = [4 2 2]; qScale = 0.6;
JPEGenc = JPEGencode(img1_down, subimg, qScale);
