%% load images and define qTable for Y and Cb/Cr %%
clear all; close all; clc
subimg = cell(1,3);
subimg{1} = [4 4 4]; subimg{2} = [4 2 2]; subimg{3} = [4 2 0];
qScale = [0.1 0.3 0.6 1 2 5 10];
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
tic
    %~ For the Y component ~%
for i = 1:length(subimg)        % for each resolution
    curr_subimg = subimg{i};
    for j = 1:length(qScale)
    [imageY, imageCb, imageCr] = convert2ycbcr(img1_down, curr_subimg);
    [RowNumberY, ColumnNumberY] = size(imageY);
    allQuantY = []; allRunlengthY = [];
    DC_PredY = 0;
    for row = 1:8:RowNumberY
        for column = 1:8:ColumnNumberY
            blockY  = imageY(row:row+7, column:column+7);
            dctblockY  = blockDCT(blockY);
            quantblockY = quantizeJPEG(dctblockY, qTableL, qScale(j));
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

            quantblockCr = quantizeJPEG(dctblockCr, qTableC, qScale(j));
            quantblockCb = quantizeJPEG(dctblockCb, qTableC, qScale(j));

            runSymbolsCr = runLength(quantblockCr, DC_PredCr);
            runSymbolsCb = runLength(quantblockCb, DC_PredCb);

            DC_PredCr = quantblockCr(1,1);            % For the next iteration
            DC_PredCb = quantblockCb(1,1);            % For the next iteration

            allRunlengthCb = [allRunlengthCb; runSymbolsCb]; allRunlengthCr = [allRunlengthCr; runSymbolsCr]; 
            allQuantCb     = [allQuantCb quantblockCb];      allQuantCr     = [allQuantCr quantblockCr];
        end
    end
    %~ Compute entropy for runlegth ~%
    allRunlengths = [allRunlengthY; allRunlengthCb; allRunlengthCr];
    %~ Find the unique rows ~%
    [~, ~, icRuns] = unique(allRunlengths(:,1:2),'rows', 'stable');
    %~ Count the freq of those rows in the runlengths ~%
    freqRun = accumarray(icRuns, 1) / length(allRunlengths);
    %~ Entropy is -freq*log(freq) ~%
    entropyRunlength(i,j) = sum(-freqRun .* log2(freqRun)) * length(allRunlengths);
    fprintf(['[First Image] ~ The entropy for the Runlength is: %e. [SubSampling %d:%d:%d], '...
             '[qScale = %.2f].\n'], entropyRunlength(i,j), curr_subimg(1), curr_subimg(2), curr_subimg(3), qScale(j));
    end
    figure();
    plot(qScale(:), entropyRunlength(i,:), '-o')
    title_str = ['Entropy of Runlegths [SubSampling ', num2str(curr_subimg(1)), ':', num2str(curr_subimg(2)), ...
                 ':', num2str(curr_subimg(3)), '] [First Image]'];
    title(title_str, 'Interpreter', 'latex')
    xticks(qScale(:))
    xlabel('qScale', 'Interpreter', 'latex'); ylabel('Entropy', 'Interpreter', 'latex')
    grid on
end
toc
%% Image 2 %%
    %~ For the Y component ~%
tic
for i = 1:length(subimg)        % for each resolution
    curr_subimg = subimg{i};
    for j = 1:length(qScale)
    [imageY, imageCb, imageCr] = convert2ycbcr(img2_down, curr_subimg);
    [RowNumberY, ColumnNumberY] = size(imageY);
    allQuantY = []; allRunlengthY = [];
    DC_PredY = 0;
    for row = 1:8:RowNumberY
        for column = 1:8:ColumnNumberY
            blockY  = imageY(row:row+7, column:column+7);
            dctblockY  = blockDCT(blockY);
            quantblockY = quantizeJPEG(dctblockY, qTableL, qScale(j));
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

            quantblockCr = quantizeJPEG(dctblockCr, qTableC, qScale(j));
            quantblockCb = quantizeJPEG(dctblockCb, qTableC, qScale(j));

            runSymbolsCr = runLength(quantblockCr, DC_PredCr);
            runSymbolsCb = runLength(quantblockCb, DC_PredCb);

            DC_PredCr = quantblockCr(1,1);            % For the next iteration
            DC_PredCb = quantblockCb(1,1);            % For the next iteration

            allRunlengthCb = [allRunlengthCb; runSymbolsCb]; allRunlengthCr = [allRunlengthCr; runSymbolsCr]; 
            allQuantCb     = [allQuantCb quantblockCb];      allQuantCr     = [allQuantCr quantblockCr];
        end
    end
    %~ Compute entropy for runlegth ~%
    allRunlengths = [allRunlengthY; allRunlengthCb; allRunlengthCr];
    %~ Find the unique rows ~%
    [~, ~, icRuns] = unique(allRunlengths(:,1:2),'rows', 'stable');
    %~ Count the freq of those rows in the runlengths ~%
    freqRun = accumarray(icRuns, 1) / length(allRunlengths);
    %~ Entropy is -freq*log(freq) ~%
    entropyRunlength(i,j) = sum(-freqRun .* log2(freqRun)) * length(allRunlengths);
    fprintf(['[Second Image] ~ The entropy for the Runlength is: %e. [SubSampling %d:%d:%d], '...
             '[qScale = %.2f].\n'], entropyRunlength(i,j), curr_subimg(1), curr_subimg(2), curr_subimg(3), qScale(j));
    end
    figure();
    plot(qScale(:), entropyRunlength(i,:), '-o')
    title_str = ['Entropy of Runlegths [SubSampling ', num2str(curr_subimg(1)), ':', num2str(curr_subimg(2)), ...
                 ':', num2str(curr_subimg(3)), '] [Second Image]'];
    title(title_str, 'Interpreter', 'latex')
    xticks(qScale(:))
    xlabel('qScale', 'Interpreter', 'latex'); ylabel('Entropy', 'Interpreter', 'latex')
    grid on
end
toc