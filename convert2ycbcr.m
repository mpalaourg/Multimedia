function [imageY, imageCb, imageCr] = convert2ycbcr(imageRGB, subimg)
%convert2ycbcr
%Inputs:
%imageRGB: The RGB image [uint-8 format].                     [M-by-N-by-3]
%subimg: A vector that defines the subsampling.               [1-by-3]
%return:
%imageY: A matrix that contains the luminance of the image.
%imageCb: A matrix that contains the (blue) chrominance of the image.
%imageCr: A matrix that contains the (red) chrominance of the image.
%
% At first, check the validity of the inputs. Then, make sure that the
% image is multiple of 16, so the 8x8 blocks can be perfect defined. For
% each pixel [r g b], multiply it with matrix T to find the new elements of
% Y, Cb, Cr. Finally, for a valid subsampling vector compute the appropriate matrixes.
%
if ndims(imageRGB) ~=3, error('Error. 1st argument {imageRGB} must be a 3d matrix.'); end
if ~isequal(size(subimg), [1 3]), error('Error. 2nd argument {subimg} must be a 1x3 vector.'); end
%~ Make the image to be exactly for blocks 8x8, whithout leftovers ~%
[N, M] = size(imageRGB);
N = mod(N, 16); M = mod(M, 16);
imageRGB = imageRGB(1:end-N, 1:end-M, :);
%~ Initialize matrix T, used for the transformation ~%
T = [0.299   0.587       0.114;
    -0.1687  -0.3313     0.5;
     0.5     -0.4187    -0.0813];
%~ Get the individuals colors from the RGB image and transform to YCbCr ~%
[RowNumber, ColumnNumber, ~] = size(imageRGB); 
red   = imageRGB(:,:,1); red   = red';   red = reshape(red,[],1); 
green = imageRGB(:,:,2); green = green'; green = reshape(green,[],1);
blue  = imageRGB(:,:,3); blue  = blue';  blue  = reshape(blue,[],1);
    
colours = [red green blue];
transformed = double(colours) * T' + [0 128 128];
imageY  = uint8(reshape(transformed(:,1), RowNumber, ColumnNumber)');
imageCb = uint8(reshape(transformed(:,2), RowNumber, ColumnNumber)');
imageCr = uint8(reshape(transformed(:,3), RowNumber, ColumnNumber)');
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