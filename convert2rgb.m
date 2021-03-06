function imageRGB = convert2rgb(imageY, imageCr, imageCb, subimg)
%convert2rgb
%Inputs:
%imageY: A matrix that contains the luminance of the image.
%imageCb: A matrix that contains the (blue) chrominance of the image.
%imageCr: A matrix that contains the (red) chrominance of the image.
%subimg: A vector that defines the subsampling.               [1-by-3]
%return:
%imageRGB: The RGB image [uint-8 format].                     [M-by-N-by-3]
%
% At first for a valid subsampling vector compute the missing values of the
% matrixes. For the interpolation, the method of the nearest neighbor was
% used. Finally, For each 'pixel' [y cb cr], multiply it with the inverse of
% matrix T to find the [r g b] pixel values.
%
if ~isequal(size(subimg), [1 3]), error('Error. 4th argument {subimg} must be a 1x3 vector.'); end
%~ Initialize matrix T, used for the transformation ~%
T = [0.299   0.587       0.114;
    -0.1687  -0.3313     0.5;
     0.5     -0.4187    -0.0813];
invT = inv(T);
%~ Sub-sampling according to subimg ~%
[RowNumber, ColumnNumber] = size(imageY); imageRGB = zeros(RowNumber, ColumnNumber, 3, 'uint8');
imageCr_rec = zeros(RowNumber, ColumnNumber, 'uint8'); imageCb_rec = zeros(RowNumber, ColumnNumber, 'uint8');
if isequal(subimg, [4 4 4])
    imageCb_rec = imageCb;
    imageCr_rec = imageCr;
elseif isequal(subimg, [4 2 2])
    imageCb_rec(:,1:2:end) = imageCb;
    imageCr_rec(:,1:2:end) = imageCr;
%~ Interpolation with nearest neighbor ~% (Each row, the previous pixel value)
    imageCb_rec(:,2:2:end) = imageCb;
    imageCr_rec(:,2:2:end) = imageCr;
elseif isequal(subimg, [4 2 0])
    imageCb_rec(1:2:end,1:2:end) = imageCb;
    imageCr_rec(1:2:end,1:2:end) = imageCr;
    %~ Interpolation with nearest neighbor ~% (Moving window 2x2)
    imageCb_rec(1:2:end,2:2:end) = imageCb;     % Same row, next colum
    imageCb_rec(2:2:end,1:2:end) = imageCb;     % next row, same colum
    imageCb_rec(2:2:end,2:2:end) = imageCb;     % next row, next colum
    
    imageCr_rec(1:2:end,2:2:end) = imageCr;     % Same row, next colum
    imageCr_rec(2:2:end,1:2:end) = imageCr;     % next row, same colum
    imageCr_rec(2:2:end,2:2:end) = imageCr;     % next row, next colum
else
    error('Error. The provided subsampling rate doesnt exist.');
end
%~ From YCbCr transform to RGB ~%
Y  = imageY';      Y = reshape(Y,[],1); 
Cb = imageCb_rec'; Cb = reshape(Cb,[],1);
Cr = imageCr_rec'; Cr  = reshape(Cr,[],1);    
YCbCr = [Y Cb Cr];

itransformed = (double(YCbCr) - [0 128 128]) * invT';
red   = uint8(reshape(itransformed(:,1), ColumnNumber, RowNumber)'); %'
green = uint8(reshape(itransformed(:,2), ColumnNumber, RowNumber)'); %'
blue  = uint8(reshape(itransformed(:,3), ColumnNumber, RowNumber)'); %'

imageRGB(:,:,1) = red; imageRGB(:,:,2) = green; imageRGB(:,:,3) = blue;
end