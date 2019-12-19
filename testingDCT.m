%%%
%%% WRONG, I HAVE TO COMPUTE THE RIGHT DC VALUE 
%%%
%% load images and define qTable for Y and Cb/Cr %%
clear all; clc
load('img1_down.mat')
%~ Make the image to be exactly for blocks 8x8, whithout leftovers ~%
[N, M] = size(img1_down);
N = mod(N, 8); M = mod(M, 8);
img1_down = img1_down(1:end-N, 1:end-M, :);

%~ Define qTable for Y and Cb/Cr ~%
ISO_Tables;
qTableL = [16 11 10 16 24 40 51 61;     12 12 14 19 26 58 60 55;
           14 13 16 24 40 57 69 56;     14 17 22 29 51 87 80 62;
           18 22 37 56 68 109 103 77;   24 35 55 64 81 104 113 92;
           49 64 78 87 103 121 120 101; 72 92 95 98 112 100 103 99];
qTableC = [17 18 24 47 99 99 99 99; 
           18 21 26 66 99 99 99 99;
           24 26 56 99 99 99 99 99;
           47 66 99 99 99 99 99 99;
           99 99 99 99 99 99 99 99;
           99 99 99 99 99 99 99 99;
           99 99 99 99 99 99 99 99;
           99 99 99 99 99 99 99 99];
%~ Create the blocks and apply the DCT transformation ~%
clear imageY imageCb imageCr
clear imageY_rec imageCr_rec imageCb_rec
subimg = [4 2 2]; qScale = 0.6;
[imageY, imageCb, imageCr] = convert2ycbcr(img1_down, subimg);
%~ For all the blocks compute DCT and quantize them.~%
[RowNumber, ColumnNumber] = size(imageY);
tic
%~ For the Y component ~%
DC_Pred = 0;
for row = 1:8:RowNumber
    for column = 1:8:ColumnNumber
        blockY  = imageY(row:row+7, column:column+7);
        dctblockY  = blockDCT(blockY);
        quantblockY  = quantizeJPEG(dctblockY, qTableL, qScale);
        runSymbolsY = runLength(quantblockY, DC_Pred);
        huffStreamY = huffEnc(runSymbolsY,  1); % isLuminance = 1 FOR Y
%~ For all the quantized blocks compute idCT. ~%
        myrunSymbols = huffDec(huffStreamY,1);  % isLuminance = 1 FOR Y
        quantblockY = irunLength(myrunSymbols, DC_Pred);
        de_quantblockY  = dequantizeJPEG(quantblockY, qTableL, qScale);
        idctblockY  = iBlockDCT(de_quantblockY);
        imageY_rec(row:row+7, column:column+7) = idctblockY;
        
     %DC_Pred = .. ;
        %max(runSymbols - double(myrunSymbols))
        %qBlock_run = irunLength(runSymbols, 60);
        %max(max(qBlock - qBlock_run))
        %de_dctBlock = dequantizeJPEG(qBlock, qTableL, qScale);
        %fprintf('Quantize Error: %d\n', norm(dctBlock - de_dctBlock));
    end
end
disp("All good with Y")
toc
tic
[RowNumber, ColumnNumber] = size(imageCb);
%~ For the Cb, Cr components ~%
DC_PredCr = 0; DC_PredCb = 0;
for row = 1:8:RowNumber
    for column = 1:8:ColumnNumber
        blockCr = imageCr(row:row+7, column:column+7);
        blockCb = imageCb(row:row+7, column:column+7);
        
        dctblockCr = blockDCT(blockCr);
        dctblockCb = blockDCT(blockCb);
        
        quantblockCr = quantizeJPEG(dctblockCr, qTableC, qScale);
        quantblockCb = quantizeJPEG(dctblockCb, qTableC, qScale);
        
        runSymbolsCr = runLength(quantblockCr, DC_PredCr);
        runSymbolsCb = runLength(quantblockCb, DC_PredCb);
        
        huffStreamCr = huffEnc(runSymbolsCr,  0); % isLuminance = 0 FOR Cr
        huffStreamCb = huffEnc(runSymbolsCb,  0); % isLuminance = 0 FOR Cb
%~ For all the quantized blocks compute idCT. ~%
        myrunSymbolsCr = huffDec(huffStreamCr, 0);  % isLuminance = 0 FOR Cb
        myrunSymbolsCb = huffDec(huffStreamCb, 0);  % isLuminance = 0 FOR Cb
        
        quantblockCr = irunLength(myrunSymbolsCr, DC_PredCr);
        quantblockCb = irunLength(myrunSymbolsCb, DC_PredCb);
        
        de_quantblockCr  = dequantizeJPEG(quantblockCr, qTableC, qScale);
        de_quantblockCb  = dequantizeJPEG(quantblockCb, qTableC, qScale);
        
        idctblockCr  = iBlockDCT(de_quantblockCr);
        idctblockCb  = iBlockDCT(de_quantblockCb);
        
        imageCr_rec(row:row+7, column:column+7) = idctblockCr;
        imageCb_rec(row:row+7, column:column+7) = idctblockCb;
    end
end
disp("All good with Cb, Cr")
toc
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
