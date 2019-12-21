clear all; clc
%% load images and define qTable for Y and Cb/Cr %%
load('img1_down.mat')
%~ Make the image to be exactly for blocks 8x8, whithout leftovers ~%
[N, M] = size(img1_down);
N = mod(N, 8); M = mod(M, 8);
img1_down = img1_down(1:end-N, 1:end-M, :);
%%
subimg = [4 4 4];
%qScale = [1 2 5 10]; 
qScale = [0.1 0.3 0.6 1 2 5 10];
MSE = zeros(length(qScale),1);
bitNumber = zeros(length(qScale),1);
for i = 1:length(qScale)
    tic
    JPEGenc = JPEGencode(img1_down, subimg, qScale(i));
    imgRec = JPEGdecode(JPEGenc, subimg, qScale(i));
    toc
    MSE(i) = sum((img1_down(:) - imgRec(:)) .^2) / numel(img1_down);
    for j = 2:length(JPEGenc)
       currStruct =  JPEGenc{j};
       %HuffStream, is ByteStream. So *8, to get the bit number
       bitNumber(i) = bitNumber(i) + (length(currStruct.huffStream) * 8); 
    end
    figure();
    subplot(1,2,1)
    imshow(img1_down)
    title('Original Image', 'Interpreter', 'latex')
    subplot(1,2,2)
    imshow(imgRec);
    title_str = ['Reconstructed Image - Subsampling ',num2str(subimg(1)),':',num2str(subimg(2)), ...
                 ':', num2str(subimg(3)), ' , qScale = ', num2str(qScale(i))];
    title(title_str, 'Interpreter', 'latex')
end
%% Plot MSE versus qScale %%
figure();
plot(qScale, MSE, '-o')
title('Mean Square Error', 'Interpreter', 'latex')
xticks(qScale(:))
xlabel('qScale', 'Interpreter', 'latex'); ylabel('MSE', 'Interpreter', 'latex')
grid on

figure();
plot(qScale, bitNumber, '-o')
title('Number of bits [Encoded Image]', 'Interpreter', 'latex')
xticks(qScale(:))
xlabel('qScale', 'Interpreter', 'latex'); ylabel('Number of bits', 'Interpreter', 'latex')
grid on
%%
figure();
plot(bitNumber, MSE, '-o')
title('Mean Square Error and Number of bits', 'Interpreter', 'latex')
xlabel('Number of bits', 'Interpreter', 'latex'); ylabel('MSE', 'Interpreter', 'latex');
grid on
%% Change qTableL, qTableC %% UNCOMMENT FOR THE DESIRED PHOTO
% qTableL = [16 11 10 16 24 40 51 61;     12 12 14 19 26 58 60 55;
%            14 13 16 24 40 57 69 56;     14 17 22 29 51 87 80 62;
%            18 22 37 56 68 109 103 77;   24 35 55 64 81 104 113 92;
%            49 64 78 87 103 121 120 101; 72 92 95 98 112 100 103 99];
% qTableC = [17 18 24 47 99 99 99 99; 
%            18 21 26 66 99 99 99 99;
%            24 26 56 99 99 99 99 99;
%            47 66 99 99 99 99 99 99;
%            99 99 99 99 99 99 99 99;
%            99 99 99 99 99 99 99 99;
%            99 99 99 99 99 99 99 99;
%            99 99 99 99 99 99 99 99];
% %~ For zeroing, change 99 to 1000 ~%
% qTableL = qTableL'; qTableC = qTableC';
% qTableL = [qTableL(1:end-20) 1000*ones(1,20)];% 20 high frequency 
% qTableC = [qTableC(1:end-20) 1000*ones(1,20)];% 20 high frequency 
% qTableL = reshape(qTableL, [8 8]); qTableL = qTableL';
% qTableC = reshape(qTableC, [8 8]); qTableC = qTableC';
% plotDiffTables(img1_down, qTableL, qTableC, [4 2 0], 1, 20)
% 
% qTableL = qTableL'; qTableC = qTableC';
% qTableL = [qTableL(1:end-40) 1000*ones(1,40)];% 40 high frequency 
% qTableC = [qTableC(1:end-40) 1000*ones(1,40)];% 40 high frequency 
% qTableL = reshape(qTableL, [8 8]); qTableL = qTableL';
% qTableC = reshape(qTableC, [8 8]); qTableC = qTableC';
% plotDiffTables(img1_down, qTableL, qTableC, [4 2 0], 1, 40)
% 
% qTableL = qTableL'; qTableC = qTableC';
% qTableL = [qTableL(1:end-50) 1000*ones(1,50)];% 50 high frequency 
% qTableC = [qTableC(1:end-50) 1000*ones(1,50)];% 50 high frequency 
% qTableL = reshape(qTableL, [8 8]); qTableL = qTableL';
% qTableC = reshape(qTableC, [8 8]); qTableC = qTableC';
% plotDiffTables(img1_down, qTableL, qTableC, [4 2 0], 1, 50)
% 
% qTableL = qTableL'; qTableC = qTableC';
% qTableL = [qTableL(1:end-60) 1000*ones(1,60)];% 60 high frequency 
% qTableC = [qTableC(1:end-60) 1000*ones(1,60)];% 60 high frequency 
% qTableL = reshape(qTableL, [8 8]); qTableL = qTableL';
% qTableC = reshape(qTableC, [8 8]); qTableC = qTableC';
% plotDiffTables(img1_down, qTableL, qTableC, [4 2 0], 1, 60)
% 
% qTableL = qTableL'; qTableC = qTableC';
% qTableL = [qTableL(1:end-63) 1000*ones(1,63)];% 63 high frequency 
% qTableC = [qTableC(1:end-63) 1000*ones(1,63)];% 63 high frequency 
% qTableL = reshape(qTableL, [8 8]); qTableL = qTableL';
% qTableC = reshape(qTableC, [8 8]); qTableC = qTableC';
% plotDiffTables(img1_down, qTableL, qTableC, [4 2 0], 1, 63)
% 
% function plotDiffTables(img, qTableL, qTableC, subimg, qScale, num)
%     JPEGenc = JPEGencode(img, subimg, qScale, qTableL, qTableC);
%     imgRec = JPEGdecode(JPEGenc, subimg, qScale);
%     figure();
%     subplot(1,2,1)
%     imshow(img)
%     title('Original Image', 'Interpreter', 'latex')
%     subplot(1,2,2)
%     imshow(imgRec);
%     title_str = ['Reconstructed Image - Zeroing the last ', num2str(num), ' High Frequency Coefficients.'];
%     title(title_str, 'Interpreter', 'latex')
% end