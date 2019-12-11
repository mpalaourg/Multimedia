function [imageY, imageCb, imageCr] = convert2ycbcr(imageRGB, subimg)
if ndims(imageRGB) ~=3, error('Error. 1st argument {imageRGB} must be a 3d matrix.'); end
if ~isequal(size(subimg), [1 3]), error('Error. 2nd argument {subimg} must be a 1x3 vector.'); end
%~ Initialize matrix T, used for the transformation ~%
T = [0.299   0.587       0.114;
     0.5      -0.418688 -0.081312;
    -0.168736 -0.331264  0.5];
%~ Get the individuals colors from the RGB image and transform to YCbCr ~%
red = imageRGB(:,:,1); green = imageRGB(:,:,2); blue = imageRGB(:,:,3);

imageY  = red * T(1,1) + green * T(1,2) + blue * T(1,3);
imageCr = 128 + red * T(2,1) + green * T(2,2) + blue * T(2,3);
imageCb = 128 + red * T(3,1) + green * T(3,2) + blue * T(3,3);

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