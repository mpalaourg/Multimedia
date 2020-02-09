%% load images and define qTable for Y and Cb/Cr %%
clear all; close all; clc
load('img1_down.mat')
%~ Make the image to be exactly for blocks 8x8, whithout leftovers ~%
[N, M, ~] = size(img1_down); N = mod(N, 16); M = mod(M, 16);
img1_down = img1_down(1:end-N, 1:end-M, :);

load('img2_down.mat')
%~ Make the image to be exactly for blocks 8x8, whithout leftovers ~%
[N, M, ~] = size(img2_down); N = mod(N, 16); M = mod(M, 16);
img2_down = img2_down(1:end-N, 1:end-M, :);

%~ Define qTable for Y and Cb/Cr ~%
global qTableL qTableC;
[qTableL, qTableC] = changedTables(0);
%% First image for 4:2:2 subsampling. %%
subimg = [4 2 2];
[imageY, imageCb, imageCr] = convert2ycbcr(img1_down, subimg);
imageRGB = convert2rgb(imageY, imageCr, imageCb, subimg);
figure; 
subplot(1,3,1)
imshow(img1_down)
title('Original Image', 'Interpreter', 'latex')
subplot(1,3,2)
imshow(imageRGB);
title('Reconstructed Image - Subsampling 4:2:2', 'Interpreter', 'latex')
subplot(1,3,3)
imshow(img1_down - imageRGB);
title('Error on reconstruction', 'Interpreter', 'latex')

%% Second image for 4:4:4 subsampling. %%
subimg = [4 4 4];
[imageY, imageCb, imageCr] = convert2ycbcr(img2_down, subimg);
imageRGB = convert2rgb(imageY, imageCr, imageCb, subimg);
figure; 
subplot(1,3,1)
imshow(img2_down)
title('Original Image', 'Interpreter', 'latex')
subplot(1,3,2)
imshow(imageRGB);
title('Reconstructed Image - Subsampling 4:4:4', 'Interpreter', 'latex')
subplot(1,3,3)
imshow(img2_down - imageRGB);
title('Error on reconstruction', 'Interpreter', 'latex')

%% First image for 4:2:2 subsampling and qScale = 0.6%%
clear imageY imageCb imageCr
clear imageY_rec imageCr_rec imageCb_rec
subimg = [4 2 2]; qScale = 0.6;
[imageY, imageCb, imageCr] = convert2ycbcr(img1_down, subimg);
%~ For all the blocks compute DCT and quantize them.~%
[RowNumber, ColumnNumber] = size(imageY);
%~ For the Y component ~%
for row = 1:8:RowNumber
    for column = 1:8:ColumnNumber
        blockY  = imageY(row:row+7, column:column+7);
        dctblockY  = blockDCT(blockY);
        quantblockY  = quantizeJPEG(dctblockY, qTableL, qScale);
%~ For all the quantized blocks compute idCT. ~%
        de_quantblockY  = dequantizeJPEG(quantblockY, qTableL, qScale);
        idctblockY  = iBlockDCT(de_quantblockY);
        imageY_rec(row:row+7, column:column+7) = idctblockY;
    end
end

[RowNumber, ColumnNumber] = size(imageCb);
%~ For the Cb, Cr components ~%
for row = 1:8:RowNumber
    for column = 1:8:ColumnNumber
        blockCr = imageCr(row:row+7, column:column+7);
        blockCb = imageCb(row:row+7, column:column+7);
        
        dctblockCr = blockDCT(blockCr);
        dctblockCb = blockDCT(blockCb);
        
        quantblockCr = quantizeJPEG(dctblockCr, qTableC, qScale);
        quantblockCb = quantizeJPEG(dctblockCb, qTableC, qScale);
%~ For all the quantized blocks compute idCT. ~%
        de_quantblockCr  = dequantizeJPEG(quantblockCr, qTableC, qScale);
        de_quantblockCb  = dequantizeJPEG(quantblockCb, qTableC, qScale);
        
        idctblockCr  = iBlockDCT(de_quantblockCr);
        idctblockCb  = iBlockDCT(de_quantblockCb);
        
        imageCr_rec(row:row+7, column:column+7) = idctblockCr;
        imageCb_rec(row:row+7, column:column+7) = idctblockCb;
    end
end

%~ Reconstruct RGB image. ~%
imageRGB = convert2rgb(imageY_rec, imageCr_rec, imageCb_rec, subimg);
figure; 
subplot(1,3,1)
imshow(img1_down)
title('Original Image', 'Interpreter', 'latex')
subplot(1,3,2)
imshow(imageRGB);
title('Reconstructed Image - Subsampling 4:2:2 , qScale = 0.6', 'Interpreter', 'latex')
subplot(1,3,3)
imshow(img1_down - imageRGB);
title('Quantization and SubSampling error', 'Interpreter', 'latex')
MSE = sum((img1_down(:) - imageRGB(:)) .^2) / numel(img1_down);
fprintf('Mean Square Error for the 1st image is: %f. [qScale = 0.6, Subsampling 4:2:2]\n', MSE);

%% Second image for 4:4:4 subsampling and qScale = 5%%
clear imageY imageCb imageCr
clear imageY_rec imageCr_rec imageCb_rec
subimg = [4 4 4]; qScale = 5;
[imageY, imageCb, imageCr] = convert2ycbcr(img2_down, subimg);
%~ For all the blocks compute DCT and quantize them.~%
[RowNumber, ColumnNumber] = size(imageY);
%~ For the Y component ~%
for row = 1:8:RowNumber
    for column = 1:8:ColumnNumber
        blockY  = imageY(row:row+7, column:column+7);
        dctblockY  = blockDCT(blockY);
        quantblockY  = quantizeJPEG(dctblockY, qTableL, qScale);
%~ For all the quantized blocks compute idCT. ~%
        de_quantblockY  = dequantizeJPEG(quantblockY, qTableL, qScale);
        idctblockY  = iBlockDCT(de_quantblockY);
        imageY_rec(row:row+7, column:column+7) = idctblockY;
    end
end

[RowNumber, ColumnNumber] = size(imageCb);
%~ For the Cb, Cr components ~%
for row = 1:8:RowNumber
    for column = 1:8:ColumnNumber
        blockCr = imageCr(row:row+7, column:column+7);
        blockCb = imageCb(row:row+7, column:column+7);
        
        dctblockCr = blockDCT(blockCr);
        dctblockCb = blockDCT(blockCb);
        
        quantblockCr = quantizeJPEG(dctblockCr, qTableC, qScale);
        quantblockCb = quantizeJPEG(dctblockCb, qTableC, qScale);
%~ For all the quantized blocks compute idCT. ~%
        de_quantblockCr  = dequantizeJPEG(quantblockCr, qTableC, qScale);
        de_quantblockCb  = dequantizeJPEG(quantblockCb, qTableC, qScale);
        
        idctblockCr  = iBlockDCT(de_quantblockCr);
        idctblockCb  = iBlockDCT(de_quantblockCb);
        
        imageCr_rec(row:row+7, column:column+7) = idctblockCr;
        imageCb_rec(row:row+7, column:column+7) = idctblockCb;
    end
end

%~ Reconstruct RGB image. ~%
imageRGB = convert2rgb(imageY_rec, imageCr_rec, imageCb_rec, subimg);
figure; 
subplot(1,3,1)
imshow(img2_down)
title('Original Image', 'Interpreter', 'latex')
subplot(1,3,2)
imshow(imageRGB);
title('Reconstructed Image - Subsampling 4:4:4 , qScale = 5', 'Interpreter', 'latex')
subplot(1,3,3)
imshow(img2_down - imageRGB);
title('Quantization error', 'Interpreter', 'latex')
MSE = sum((img2_down(:) - imageRGB(:)) .^2) / numel(img2_down);
fprintf('Mean Square Error for the 2nd image is: %f. [qScale = 5, Subsampling 4:4:4]\n', MSE);
