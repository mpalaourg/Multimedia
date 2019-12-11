function imageRGB = convert2rgb(imageY, imageCr, imageCb, subimg)

if ~isequal(size(subimg), [1 3]), error('Error. 4th argument {subimg} must be a 1x3 vector.'); end
%~ Initialize matrix T, used for the transformation ~%
T = [0.299   0.587   0.114;
    0.5000  -0.4187 -0.0813;
    -0.1687 -0.3313  0.5000];
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
    for rows = 1:RowNumber
        for columns = 1:2:ColumnNumber
            imageCb_rec(rows, columns + 1) = imageCb_rec(rows, columns);
            imageCr_rec(rows, columns + 1) = imageCr_rec(rows, columns);
        end
    end
elseif isequal(subimg, [4 2 0])
    imageCb_rec(1:2:end,1:2:end) = imageCb;
    imageCr_rec(1:2:end,1:2:end) = imageCr;
    %~ Interpolation with nearest neighbor ~% (Moving window 2x2)
    for rows = 1:2:RowNumber
        for columns = 1:2:ColumnNumber
            imageCb_rec(rows, columns + 1)     = imageCb_rec(rows, columns);
            imageCb_rec(rows + 1, columns)     = imageCb_rec(rows, columns);
            imageCb_rec(rows + 1, columns + 1) = imageCb_rec(rows, columns);
            
            imageCr_rec(rows, columns + 1)     = imageCr_rec(rows, columns);
            imageCr_rec(rows + 1, columns)     = imageCr_rec(rows, columns);
            imageCr_rec(rows + 1, columns + 1) = imageCr_rec(rows, columns);
        end
    end
else
    error('Error. The provided subsampling rate doesnt exist.');
end
%~ From YCbCr transform to RGB ~%
imageRGB(:, :, 1) = imageY * invT(1,1) + (imageCr_rec-128) * invT(1,2) + (imageCb_rec-128) * invT(1,3);
imageRGB(:, :, 2) = imageY * invT(2,1) + (imageCr_rec-128) * invT(2,2) + (imageCb_rec-128) * invT(2,3);
imageRGB(:, :, 3) = imageY * invT(3,1) + (imageCr_rec-128) * invT(3,2) + (imageCb_rec-128) * invT(3,3);
end