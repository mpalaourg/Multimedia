%% Image 1 %%
%~ load images and define qTable for Y and Cb/Cr ~%
clear all; clc
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
load('img1_down.mat')
%~ Make the image to be exactly for blocks 8x8, whithout leftovers ~%
[N, M] = size(img1_down);
N = mod(N, 8); M = mod(M, 8);
img1_down = img1_down(1:end-N, 1:end-M, :);
    %~ For the Y component ~%
subimg = [4 2 2]; qScale = 0.6;
[imageY, imageCb, imageCr] = convert2ycbcr(img1_down, subimg);
[RowNumber, ColumnNumber] = size(imageY);
allQuantY = []; allRunlengthY = [];
DC_PredY = 0;
for row = 1:8:RowNumber
    for column = 1:8:ColumnNumber
        blockY  = imageY(row:row+7, column:column+7);
        dctblockY  = blockDCT(blockY);
        quantblockY = quantizeJPEG(dctblockY, qTableL, qScale);
        runSymbolsY = runLength(quantblockY, DC_PredY);

        DC_PredY = quantblockY(1,1);            % For the next iteration
        allRunlengthY = [allRunlengthY; runSymbolsY];
        allQuantY     = [allQuantY quantblockY];
    end
end
    %~ For the Cb, Cr components ~%
[RowNumber, ColumnNumber] = size(imageCb);
allQuantCb = []; allQuantCr = [];
allRunlengthCb = []; allRunlengthCr = [];
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
        
        DC_PredCr = quantblockCr(1,1);            % For the next iteration
        DC_PredCb = quantblockCb(1,1);            % For the next iteration

        allRunlengthCb = [allRunlengthCb; runSymbolsCb]; allRunlengthCr = [allRunlengthCr; runSymbolsCr]; 
        allQuantCb     = [allQuantCb quantblockCb];      allQuantCr     = [allQuantCr quantblockCr];
    end
end
%%
red = img1_down(:,:,1); green = img1_down(:,:,2); blue = img1_down(:,:,3);
%~ Compute entropy of Spatial Domain ~%
[uniqueRed, ~, icRed] = unique(red, 'stable');
[uniqueGreen, ~, icGreen] = unique(green, 'stable');
[uniqueBlue, ~, icBlue] = unique(blue, 'stable');
%~ Count the freq of the quantized values ~%
freqRed = accumarray(icRed, 1) / numel(red);
freqGreen = accumarray(icGreen, 1) / numel(green);
freqBlue = accumarray(icBlue, 1) / numel(blue);
%~ Entropy is -freq*log(freq) ~%
entropySpatialAll = sum(-freqRed .* log2(freqRed)) + sum(-freqGreen .* log2(freqGreen)) + ...
                      sum(-freqBlue .* log2(freqBlue));
fprintf('The entropy for the Spatial Domain is: %f.\n', entropySpatialAll);

%~ Compute entropy for the quantized values ~%
[uniqueQuantY, ~, icQuantY] = unique(allQuantY, 'stable');
[uniqueQuantCb, ~, icQuantCb] = unique(allQuantCb, 'stable');
[uniqueQuantCr, ~, icQuantCr] = unique(allQuantCr, 'stable');
%~ Count the freq of the quantized values ~%
freqQuantY = accumarray(icQuantY, 1) / numel(allQuantY);
freqQuantCb = accumarray(icQuantCb, 1) / numel(allQuantCb);
freqQuantCr = accumarray(icQuantCr, 1) / numel(allQuantCr);
%~ Entropy is -freq*log(freq) ~%
entropyQuantAll = sum(-freqQuantY .* log2(freqQuantY)) + sum(-freqQuantCb .* log2(freqQuantCb)) ...
                  +sum(-freqQuantCr .* log2(freqQuantCr));
fprintf('\nThe entropy for the Quantize DCT Coefficients is: %f.\n', entropyQuantAll);

allQuants = [allQuantY allQuantCb allQuantCr];
[uniqueQuants, ~, icQuants] = unique(allQuants, 'stable');
freqQuant = accumarray(icQuants, 1) / numel(allQuants);
entropyQuants = sum(-freqQuant .* log2(freqQuant));
fprintf('The other entropy for the Quant is: %f.\n', entropyQuants);

%~ Compute entropy for runlegth ~%
%~ Find the unique rows ~%
[uniqueY, ~, icY] = unique(allRunlengthY(:,1:2),'rows', 'stable');
[uniqueCb, ~, icCb] = unique(allRunlengthCb(:,1:2),'rows', 'stable');
[uniqueCr, ~, icCr] = unique(allRunlengthCr(:,1:2),'rows', 'stable');
%~ Count the freq of those rows in the runlengths ~%
freqY = accumarray(icY, 1) / length(allRunlengthY);
freqCb = accumarray(icCb, 1) / length(allRunlengthCb);
freqCr = accumarray(icCr, 1) / length(allRunlengthCr);
%~ Entropy is -freq*log(freq) ~%
entropyRunlengthAll = sum(-freqY .* log2(freqY)) + sum(-freqCb .* log2(freqCb)) + sum(-freqCr .* log2(freqCr));
fprintf('\nThe entropy for the Runlength is: %f.\n', entropyRunlengthAll);

allRunlengths = [allRunlengthY; allRunlengthCb; allRunlengthCr];
[uniqueRuns, ~, icRuns] = unique(allRunlengths(:,1:2),'rows', 'stable');
freqRun = accumarray(icRuns, 1) / length(allRunlengths);
entropyRuns = sum(-freqRun .* log2(freqRun));
fprintf('The other entropy for the Runlength is: %f.\n', entropyRuns);
