%% load images and define qTable for Y and Cb/Cr %%
clear all; clc
ISO_Tables
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
%% Image 1 %%
    %~ For the Y component ~%
subimg = [4 2 2]; qScale = 0.6;
[imageY, imageCb, imageCr] = convert2ycbcr(img1_down, subimg);
[RowNumberY, ColumnNumberY] = size(imageY);
allQuantY = []; allRunlengthY = [];
DC_PredY = 0;
for row = 1:8:RowNumberY
    for column = 1:8:ColumnNumberY
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
[RowNumberCbCr, ColumnNumberCbCr] = size(imageCb);
allQuantCb = []; allQuantCr = [];
allRunlengthCb = []; allRunlengthCr = [];
DC_PredCr = 0; DC_PredCb = 0;
for row = 1:8:RowNumberCbCr
    for column = 1:8:ColumnNumberCbCr
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
red = img1_down(:,:,1); green = img1_down(:,:,2); blue = img1_down(:,:,3);
%~ Compute entropy of Spatial Domain ~%
[~, ~, icRed]   = unique(red, 'stable');
[~, ~, icGreen] = unique(green, 'stable');
[~, ~, icBlue]  = unique(blue, 'stable');
%~ Count the freq of the quantized values ~%
freqRed = accumarray(icRed, 1) / numel(red);
freqGreen = accumarray(icGreen, 1) / numel(green);
freqBlue = accumarray(icBlue, 1) / numel(blue);
%~ Entropy is -freq*log(freq) ~%
entropySpatialAll = sum(-freqRed .* log2(freqRed)) + sum(-freqGreen .* log2(freqGreen)) + ...
                      sum(-freqBlue .* log2(freqBlue));
fprintf('[First Image] ~ The entropy for the Spatial Domain is: %f [per symbol].\n', entropySpatialAll);
fprintf('[First Image] ~ The entropy for the Spatial Domain is: %e.\n', entropySpatialAll * length(img1_down)^2);

%~ Compute entropy for the quantized values ~%
[~,  ~, icQuantY] = unique(allQuantY, 'stable');
[~, ~, icQuantCb] = unique(allQuantCb, 'stable');
[~, ~, icQuantCr] = unique(allQuantCr, 'stable');
%~ Count the freq of the quantized values ~%
freqQuantY = accumarray(icQuantY, 1) / numel(allQuantY);
freqQuantCb = accumarray(icQuantCb, 1) / numel(allQuantCb);
freqQuantCr = accumarray(icQuantCr, 1) / numel(allQuantCr);
%~ Entropy is -freq*log(freq) ~%
entropyQuantAll_perSymbol = sum(-freqQuantY .* log2(freqQuantY)) + sum(-freqQuantCb .* log2(freqQuantCb)) ...
                  +sum(-freqQuantCr .* log2(freqQuantCr));
fprintf('\n[First Image] ~ The entropy for the Quantize DCT Coefficients is: %f [per symbol].\n', entropyQuantAll_perSymbol);
entropyQuantAll = sum(-freqQuantY .* log2(freqQuantY))   * (RowNumberY    * ColumnNumberY)...
                + sum(-freqQuantCb .* log2(freqQuantCb)) * (RowNumberCbCr * ColumnNumberCbCr)...
                + sum(-freqQuantCr .* log2(freqQuantCr)) * (RowNumberCbCr * ColumnNumberCbCr);
fprintf('[First Image] ~ The entropy for the Quantize DCT Coefficients is: %e.\n', entropyQuantAll);

%~ Compute entropy for runlegth ~%
allRunlengths = [allRunlengthY; allRunlengthCb; allRunlengthCr];
%~ Find the unique rows ~%
[~, ~, icRuns] = unique(allRunlengths(:,1:2),'rows', 'stable');
%~ Count the freq of those rows in the runlengths ~%
freqRun = accumarray(icRuns, 1) / length(allRunlengths);
%~ Entropy is -freq*log(freq) ~%
entropyRunlength_perSymbol = sum(-freqRun .* log2(freqRun));
fprintf('\n[First Image] ~ The entropy for the Runlength is: %f. [per Symbol]\n', entropyRunlength_perSymbol);
fprintf('[First Image] ~ The entropy for the Runlength is: %e.\n', entropyRunlength_perSymbol*length(allRunlengths));
%% Image 2 %%
    %~ For the Y component ~%
subimg = [4 4 4]; qScale = 5;
[imageY, imageCb, imageCr] = convert2ycbcr(img2_down, subimg);
[RowNumberY, ColumnNumberY] = size(imageY);
allQuantY = []; allRunlengthY = [];
DC_PredY = 0;
for row = 1:8:RowNumberY
    for column = 1:8:ColumnNumberY
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
[RowNumberCbCr, ColumnNumberCbCr] = size(imageCb);
allQuantCb = []; allQuantCr = [];
allRunlengthCb = []; allRunlengthCr = [];
DC_PredCr = 0; DC_PredCb = 0;
for row = 1:8:RowNumberCbCr
    for column = 1:8:ColumnNumberCbCr
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
red = img2_down(:,:,1); green = img2_down(:,:,2); blue = img2_down(:,:,3);
%~ Compute entropy of Spatial Domain ~%
[~, ~, icRed]   = unique(red, 'stable');
[~, ~, icGreen] = unique(green, 'stable');
[~, ~, icBlue]  = unique(blue, 'stable');
%~ Count the freq of the quantized values ~%
freqRed = accumarray(icRed, 1) / numel(red);
freqGreen = accumarray(icGreen, 1) / numel(green);
freqBlue = accumarray(icBlue, 1) / numel(blue);
%~ Entropy is -freq*log(freq) ~%
entropySpatialAll = sum(-freqRed .* log2(freqRed)) + sum(-freqGreen .* log2(freqGreen)) + ...
                      sum(-freqBlue .* log2(freqBlue));
fprintf('\n[Second Image] ~ The entropy for the Spatial Domain is: %f [per symbol].\n', entropySpatialAll);
fprintf('[Second Image] ~ The entropy for the Spatial Domain is: %e.\n', entropySpatialAll * length(img2_down)^2);

%~ Compute entropy for the quantized values ~%
[~, ~, icQuantY]  = unique(allQuantY, 'stable');
[~, ~, icQuantCb] = unique(allQuantCb, 'stable');
[~, ~, icQuantCr] = unique(allQuantCr, 'stable');
%~ Count the freq of the quantized values ~%
freqQuantY = accumarray(icQuantY, 1) / numel(allQuantY);
freqQuantCb = accumarray(icQuantCb, 1) / numel(allQuantCb);
freqQuantCr = accumarray(icQuantCr, 1) / numel(allQuantCr);
%~ Entropy is -freq*log(freq) ~%
entropyQuantAll_perSymbol = sum(-freqQuantY .* log2(freqQuantY)) + sum(-freqQuantCb .* log2(freqQuantCb)) ...
                  +sum(-freqQuantCr .* log2(freqQuantCr));
fprintf('\n[Second Image] ~ The entropy for the Quantize DCT Coefficients is: %f [per symbol].\n', entropyQuantAll_perSymbol);
entropyQuantAll = sum(-freqQuantY .* log2(freqQuantY))   * (RowNumberY    * ColumnNumberY)...
                + sum(-freqQuantCb .* log2(freqQuantCb)) * (RowNumberCbCr * ColumnNumberCbCr)...
                + sum(-freqQuantCr .* log2(freqQuantCr)) * (RowNumberCbCr * ColumnNumberCbCr);
fprintf('[Second Image] ~ The entropy for the Quantize DCT Coefficients is: %e.\n', entropyQuantAll);
%~ Compute entropy for runlegth ~%
allRunlengths = [allRunlengthY; allRunlengthCb; allRunlengthCr];
%~ Find the unique rows ~%
[~, ~, icRuns] = unique(allRunlengths(:,1:2),'rows', 'stable');
%~ Count the freq of those rows in the runlengths ~%
freqRun = accumarray(icRuns, 1) / length(allRunlengths);
%~ Entropy is -freq*log(freq) ~%
entropyRunlength_perSymbol = sum(-freqRun .* log2(freqRun));
fprintf('\n[Second Image] ~ The entropy for the Runlength is: %f. [per Symbol]\n', entropyRunlength_perSymbol);
fprintf('[Second Image] ~ The entropy for the Runlength is: %e.\n', entropyRunlength_perSymbol*length(allRunlengths));
