%% load images and define qTable for Y and Cb/Cr %%
load('img1_down.mat')
%~ Make the image to be exactly for blocks 8x8, whithout leftovers ~%
[N, M] = size(img1_down);
N = mod(N, 8); M = mod(M, 8);
img1_down = img1_down(1:end-N, 1:end-M, :);

load('img2_down.mat')
%~ Make the image to be exactly for blocks 8x8, whithout leftovers ~%
[N, M] = size(img2_down);
N = mod(N, 8); M = mod(M, 8);
img2_down = img2_down(1:end-N, 1:end-M, :);

%~ Define qTable for Y and Cb/Cr ~%
qTableL = [16 11 10 16 24 40 51 61;     12 12 14 19 26 58 60 55;
           14 13 16 24 40 57 69 56;     14 17 22 29 51 87 80 62;
           18 22 37 56 68 109 103 77;   24 35 55 64 81 104 113 92;
           49 64 78 87 103 121 120 101; 72 92 95 98 112 100 103 99];
gTableC = [17 18 24 47 99 99 99 99; 
           18 21 26 66 99 99 99 99;
           24 26 56 99 99 99 99 99;
           47 66 99 99 99 99 99 99;
           99 99 99 99 99 99 99 99;
           99 99 99 99 99 99 99 99;
           99 99 99 99 99 99 99 99;
           99 99 99 99 99 99 99 99];
%% First image for 4:2:2 subsampling. %%
subimg = [4 2 2];
[imageY, imageCb, imageCr] = convert2ycbcr(img1_down, subimg);
imageRGB = convert2rgb(imageY, imageCr, imageCb, subimg);
figure; 
subplot(1,2,1)
imshow(img1_down)
title('Original Image', 'Interpreter', 'latex')
subplot(1,2,2)
imshow(imageRGB);
title('Reconstructed Image - Subsampling 4:2:2', 'Interpreter', 'latex')

%% Second image for 4:4:4 subsampling. %%
subimg = [4 4 4];
[imageY, imageCb, imageCr] = convert2ycbcr(img2_down, subimg);
imageRGB = convert2rgb(imageY, imageCr, imageCb, subimg);
figure; 
subplot(1,2,1)
imshow(img2_down)
title('Original Image', 'Interpreter', 'latex')
subplot(1,2,2)
imshow(imageRGB);
title('Reconstructed Image - Subsampling 4:4:4', 'Interpreter', 'latex')

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
        
        quantblockCr = quantizeJPEG(dctblockCr, gTableC, qScale);
        quantblockCb = quantizeJPEG(dctblockCb, gTableC, qScale);
%~ For all the quantized blocks compute idCT. ~%
        de_quantblockCr  = dequantizeJPEG(quantblockCr, gTableC, qScale);
        de_quantblockCb  = dequantizeJPEG(quantblockCb, gTableC, qScale);
        
        idctblockCr  = iBlockDCT(de_quantblockCr);
        idctblockCb  = iBlockDCT(de_quantblockCb);
        
        imageCr_rec(row:row+7, column:column+7) = idctblockCr;
        imageCb_rec(row:row+7, column:column+7) = idctblockCb;
    end
end

%~ Reconstruct RGB image. ~%
imageRGB = convert2rgb(imageY_rec, imageCr_rec, imageCb_rec, subimg);
figure; 
subplot(1,2,1)
imshow(img1_down)
title('Original Image', 'Interpreter', 'latex')
subplot(1,2,2)
imshow(imageRGB);
title('Reconstructed Image - Subsampling 4:2:2 , qScale = 0.6', 'Interpreter', 'latex')
figure(); image(img1_down - imageRGB);
title('Quantization error', 'Interpreter', 'latex')
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
        
        quantblockCr = quantizeJPEG(dctblockCr, gTableC, qScale);
        quantblockCb = quantizeJPEG(dctblockCb, gTableC, qScale);
%~ For all the quantized blocks compute idCT. ~%
        de_quantblockCr  = dequantizeJPEG(quantblockCr, gTableC, qScale);
        de_quantblockCb  = dequantizeJPEG(quantblockCb, gTableC, qScale);
        
        idctblockCr  = iBlockDCT(de_quantblockCr);
        idctblockCb  = iBlockDCT(de_quantblockCb);
        
        imageCr_rec(row:row+7, column:column+7) = idctblockCr;
        imageCb_rec(row:row+7, column:column+7) = idctblockCb;
    end
end

%~ Reconstruct RGB image. ~%
imageRGB = convert2rgb(imageY_rec, imageCr_rec, imageCb_rec, subimg);
figure; 
subplot(1,2,1)
imshow(img2_down)
title('Original Image', 'Interpreter', 'latex')
subplot(1,2,2)
imshow(imageRGB);
title('Reconstructed Image - Subsampling 4:4:4 , qScale = 5', 'Interpreter', 'latex')
figure(); image(img2_down - imageRGB);
title('Quantization error', 'Interpreter', 'latex')
