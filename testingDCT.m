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
load('img1_down.mat')
qScale = 0.6;
%~ Make the image to be exactly for blocks 8x8, whithout leftovers ~%
[N, M] = size(img1_down);
N = mod(N, 8); M = mod(M, 8);
img1_down = img1_down(1:end-N, 1:end-M, :); subimg = [4 4 4];
[imageY, imageCb, imageCr] = convert2ycbcr(img1_down, subimg);
%~ Create the blocks and apply the DCT transformation ~%
[RowNumber, ColumnNumber] = size(img1_down);
for row = 1:8:RowNumber
    for column = 1:8:ColumnNumber
        block = imageY(row:row+7, column:column+7);
        dctBlock = blockDCT(block);
        qBlock = quantizeJPEG(dctBlock, qTableL, qScale);
        
        runSymbols = runLength(qBlock, 60);
        qBlock_run = irunLength(runSymbols, 60);
        de_dctBlock = dequantizeJPEG(qBlock, qTableL, qScale);
        fprintf('Quantize Error: %d\n', norm(dctBlock - de_dctBlock));
    end
end