clear all; close all; clc
%% load images and define Huffman Tables%%
load('img1_down.mat')
%~ Make the image to be exactly for blocks 8x8, whithout leftovers ~%
[N, M, ~] = size(img1_down); N = mod(N, 16); M = mod(M, 16);
img1_down = img1_down(1:end-N, 1:end-M, :);

load('img2_down.mat')
%~ Make the image to be exactly for blocks 8x8, whithout leftovers ~%
[N, M, ~] = size(img2_down); N = mod(N, 16); M = mod(M, 16);
img2_down = img2_down(1:end-N, 1:end-M, :);

global qTableL qTableC;
[qTableL, qTableC] = changedTables(0);
ISO_Tables
num = [20 40 50 60 63];
%% Image 1 ~ Changed Quantize Tables %%
tStart = tic;
subimg = [4 4 4]; qScale = 1;
for i = 1:length(num)       % At each loop, zero the last num(i) High Frequency Coefficients
    [qTableL, qTableC] = changedTables(num(i));
    JPEGenc = JPEGencode(img1_down, subimg, qScale);
    imgRec = JPEGdecode(JPEGenc);
    figure();
    subplot(1,2,1)
    imshow(img1_down)
    title('Original Image', 'Interpreter', 'latex')
    subplot(1,2,2)
    imshow(imgRec);
    title_str = ['Reconstructed Image - Zeroing the last ', num2str(num(i)), ' High Frequency Coefficients.'];
    title(title_str, 'Interpreter', 'latex')
    fprintf('[First Image] - Done zeroing the last %d High Frequency Coefficients.\n', num(i));
end
%% Image 2 ~ Changed Quantize Tables %%
subimg = [4 4 4]; qScale = 1;
for i = 1:length(num)       % At each loop, zero the last num(i) High Frequency Coefficients
    [qTableL, qTableC] = changedTables(num(i));
    JPEGenc = JPEGencode(img2_down, subimg, qScale);
    imgRec = JPEGdecode(JPEGenc);
    figure();
    subplot(1,2,1)
    imshow(img2_down)
    title('Original Image', 'Interpreter', 'latex')
    subplot(1,2,2)
    imshow(imgRec);
    title_str = ['Reconstructed Image - Zeroing the last ', num2str(num(i)), ' High Frequency Coefficients.'];
    title(title_str, 'Interpreter', 'latex')
    fprintf('[Second Image] - Done zeroing the last %d High Frequency Coefficients.\n', num(i));
end
%% Image 1 ~ Statistics (MSE, Number of bits) %%
[qTableL, qTableC] = changedTables(0);
subimg = [4 2 2];
qScale = [0.1 0.3 0.6 1 2 5 10]; 
MSE = zeros(length(qScale),1);
bitNumber = zeros(length(qScale),1);
compressRatio = zeros(length(qScale),1);
for i = 1:length(qScale)
    JPEGenc = JPEGencode(img1_down, subimg, qScale(i));
    imgRec = JPEGdecode(JPEGenc);
    MSE(i) = sum((img1_down(:) - imgRec(:)) .^2) / numel(img1_down);
    for j = 2:length(JPEGenc)
       currStruct =  JPEGenc{j};
       % HuffStream, is ByteStream. So *8, to get the bit number
       bitNumber(i) = bitNumber(i) + (length(currStruct.huffStream) * 8);
    end
    % Compression rate
    compressRatio(i) = (numel(img1_down) * 8) / bitNumber(i);
    figure();
    subplot(1,3,1)
    imshow(img1_down)
    title('Original Image', 'Interpreter', 'latex')
    subplot(1,3,2)
    imshow(imgRec);
    title_str = ['Reconstructed Image - Subsampling ',num2str(subimg(1)),':',num2str(subimg(2)), ...
                 ':', num2str(subimg(3)), ' , qScale = ', num2str(qScale(i))];
    title(title_str, 'Interpreter', 'latex')
    subplot(1,3,3)
    imshow(img1_down - imgRec);
    title('Error on reconstruction', 'Interpreter', 'latex')
    fprintf('[First Image] - Done computing results for qScale = %.1f.\n', qScale(i));
end
figure();
plot(qScale, MSE, '-o')
title('First Image - Mean Square Error', 'Interpreter', 'latex')
xticks(qScale(:))
xlabel('qScale', 'Interpreter', 'latex'); ylabel('MSE', 'Interpreter', 'latex')
grid on

figure();
plot(qScale, compressRatio, '-o')
title('First Image - Compression Ratio', 'Interpreter', 'latex')
xticks(qScale(:))
xlabel('qScale', 'Interpreter', 'latex'); ylabel('Compression Ratio', 'Interpreter', 'latex')
grid on

figure();
plot(qScale, bitNumber, '-o')
title('First Image - Number of bits [Encoded Image]', 'Interpreter', 'latex')
xticks(qScale(:))
xlabel('qScale', 'Interpreter', 'latex'); ylabel('Number of bits', 'Interpreter', 'latex')
grid on

figure();
plot(bitNumber, MSE, '-o')
title('First Image - Mean Square Error and Number of bits', 'Interpreter', 'latex')
xlabel('Number of bits', 'Interpreter', 'latex'); ylabel('MSE', 'Interpreter', 'latex');
grid on

%% Image 2 ~ Statistics (MSE, Number of bits) %%
[qTableL, qTableC] = changedTables(0);
subimg = [4 4 4];
qScale = [0.1 0.3 0.6 1 2 5 10];  
MSE = zeros(length(qScale),1);
bitNumber = zeros(length(qScale),1);
compressRatio = zeros(length(qScale),1);
for i = 1:length(qScale)
    JPEGenc = JPEGencode(img2_down, subimg, qScale(i));
    imgRec = JPEGdecode(JPEGenc);
    MSE(i) = sum((img2_down(:) - imgRec(:)) .^2) / numel(img2_down);
    for j = 2:length(JPEGenc)
       currStruct =  JPEGenc{j};
       %HuffStream, is ByteStream. So *8, to get the bit number
       bitNumber(i) = bitNumber(i) + (length(currStruct.huffStream) * 8);
    end
    compressRatio(i) = (numel(img2_down) * 8) / bitNumber(i);
    figure();
    subplot(1,3,1)
    imshow(img2_down)
    title('Original Image', 'Interpreter', 'latex')
    subplot(1,3,2)
    imshow(imgRec);
    title_str = ['Reconstructed Image - Subsampling ',num2str(subimg(1)),':',num2str(subimg(2)), ...
                 ':', num2str(subimg(3)), ' , qScale = ', num2str(qScale(i))];
    title(title_str, 'Interpreter', 'latex')
    subplot(1,3,3)
    imshow(img2_down - imgRec);
    title('Error on reconstruction', 'Interpreter', 'latex')
    fprintf('[Second Image] - Done computing results for qScale = %.1f.\n', qScale(i));
end
figure();
plot(qScale, MSE, '-o')
title('Second Image - Mean Square Error', 'Interpreter', 'latex')
xticks(qScale(:))
xlabel('qScale', 'Interpreter', 'latex'); ylabel('MSE', 'Interpreter', 'latex')
grid on

figure();
plot(qScale, compressRatio, '-o')
title('Second Image - Compression Ratio', 'Interpreter', 'latex')
xticks(qScale(:))
xlabel('qScale', 'Interpreter', 'latex'); ylabel('Compression Ratio', 'Interpreter', 'latex')
grid on

figure();
plot(qScale, bitNumber, '-o')
title('Second Image - Number of bits [Encoded Image]', 'Interpreter', 'latex')
xticks(qScale(:))
xlabel('qScale', 'Interpreter', 'latex'); ylabel('Number of bits', 'Interpreter', 'latex')
grid on

figure();
plot(bitNumber, MSE, '-o')
title('Second Image - Mean Square Error and Number of bits', 'Interpreter', 'latex')
xlabel('Number of bits', 'Interpreter', 'latex'); ylabel('MSE', 'Interpreter', 'latex');
grid on
tEnd = toc(tStart)
% Elapsed time: tEnd = 619.2475 sec 