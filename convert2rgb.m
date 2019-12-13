function imageRGB = convert2rgb(imageY, imageCr, imageCb, subimg)

if ~isequal(size(subimg), [1 3]), error('Error. 4th argument {subimg} must be a 1x3 vector.'); end
%~ Initialize matrix T, used for the transformation ~%
T = [0.299   0.587       0.114;
    -0.168736 -0.331264  0.5;
     0.5      -0.418688 -0.081312];
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
red = zeros(RowNumber, ColumnNumber, 'uint8'); green = zeros(RowNumber, ColumnNumber, 'uint8'); 
blue = zeros(RowNumber, ColumnNumber, 'uint8');
for i = 1:RowNumber
    for j = 1:ColumnNumber
        itransformed = (double([imageY(i,j) imageCb_rec(i,j) imageCr_rec(i,j)]) - [0 128 128]) * invT';
        red(i,j)   = uint8(itransformed(1,1));
        green(i,j) = uint8(itransformed(1,2));
        blue(i,j)  = uint8(itransformed(1,3)); 
    end
end
imageRGB(:,:,1) = red; imageRGB(:,:,2) = green; imageRGB(:,:,3) = blue;
end