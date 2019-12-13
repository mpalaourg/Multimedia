function [imageY, imageCb, imageCr] = convert2ycbcr(imageRGB, subimg)
if ndims(imageRGB) ~=3, error('Error. 1st argument {imageRGB} must be a 3d matrix.'); end
if ~isequal(size(subimg), [1 3]), error('Error. 2nd argument {subimg} must be a 1x3 vector.'); end
%~ Make the image to be exactly for blocks 8x8, whithout leftovers ~%
[N, M] = size(imageRGB);
N = mod(N, 8); M = mod(M, 8);
imageRGB = imageRGB(1:end-N, 1:end-M, :);
%~ Initialize matrix T, used for the transformation ~%
T = [0.299   0.587       0.114;
    -0.168736 -0.331264  0.5;
     0.5      -0.418688 -0.081312];
%~ Get the individuals colors from the RGB image and transform to YCbCr ~%
[RowNumber, ColumnNumber, ~] = size(imageRGB); imageY = zeros(RowNumber, ColumnNumber, 'uint8'); 
imageCr = zeros(RowNumber, ColumnNumber, 'uint8'); imageCb = zeros(RowNumber, ColumnNumber, 'uint8');
for i = 1:RowNumber
    for j = 1:ColumnNumber
        transformed = double([imageRGB(i,j,1) imageRGB(i,j,2) imageRGB(i,j,3)]) * T'  + [0 128 128];
        imageY(i,j) = uint8(transformed(1,1));
        imageCb(i,j) = uint8(transformed(1,2));
        imageCr(i,j) = uint8(transformed(1,3)); 
    end
end
%~ Sub-sampling according to subimg ~%
if isequal(subimg, [4 4 4])
    return;
elseif isequal(subimg, [4 2 2])
    imageCb = imageCb(:,1:2:end);
    imageCr = imageCr(:,1:2:end);
    return;
elseif isequal(subimg, [4 2 0])
    imageCb = imageCb(1:2:end,1:2:end);
    imageCr = imageCr(1:2:end,1:2:end);
    return;
else
    error('Error. The provided subsampling rate doesnt exist.');
end
end