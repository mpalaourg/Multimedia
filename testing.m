clear all; clc
load('img1_down.mat')
%~ Make the image to be exactly for blocks 8x8, whithout leftovers ~%
[N, M] = size(img1_down);
N = mod(N, 8); M = mod(M, 8);
img1_down = img1_down(1:end-N, 1:end-M, :);
imshow(img1_down)
%~ Subsampling 4 4 4 ~%
subimg = [4 4 4];
[imageY, imageCb, imageCr] = convert2ycbcr(img1_down, subimg);
%figure; imshow(imageY); figure; imshow(imageCb); figure; imshow(imageCr); 
imageRGB = convert2rgb(imageY, imageCr, imageCb, subimg);
figure; image(imageRGB); figure; imshow(img1_down - imageRGB);
%%
%~ Subsampling 4 2 2 ~%
subimg = [4 2 2];
[imageY, imageCb, imageCr] = convert2ycbcr(img1_down, subimg);
imageRGB = convert2rgb(imageY, imageCr, imageCb, subimg);
figure; imshow(imageRGB); figure; imshow(img1_down - imageRGB);
%~ Subsampling 4 2 0 ~%
subimg = [4 2 0];
[imageY, imageCb, imageCr] = convert2ycbcr(img1_down, subimg);
imageRGB = convert2rgb(imageY, imageCr, imageCb, subimg);
figure; imshow(imageRGB); figure; imshow(img1_down - imageRGB);
