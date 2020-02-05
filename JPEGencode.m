function JPEGenc = JPEGencode(img, subimg, qScale)
if ndims(img) ~=3,                error('Error. 1st argument {img} must be a 3d matrix.'); end
if ~isequal(size(subimg), [1 3]), error('Error. 2nd argument {subimg} must be a 1x3 vector.'); end
if ~isscalar(qScale),             error('Error. 3rd argument {qScale} must be scalar.'); end
%~ Create the tables needed ~%
ISO_Tables;
global qTableL qTableC;
%[qTableL, qTableC] = changedTables(0);
global DC_Huff_L DC_Huff_C AC_Huff_L AC_Huff_C;

DCL = cell(1,1); DCC = cell(1,1); ACL = cell(1,1); ACC = cell(1,1);
DCL{1,1} = DC_Huff_L; DCC{1,1} = DC_Huff_C;
ACL{1,1} = AC_Huff_L; ACC{1,1} = AC_Huff_C;
%~ Create the struct for the first cell ~%
tableStruct = struct;
tableStruct.qTableL = qTableL * qScale;
tableStruct.qTableC = qTableC * qScale;
tableStruct.DCL = DCL; tableStruct.DCC = DCC;
tableStruct.ACL = ACL; tableStruct.ACC = ACC;

JPEGenc{1,1} = tableStruct;
%~ Transform to YCbCr to begin the convertion ~%
[imageY, imageCb, imageCr] = convert2ycbcr(img, subimg);
%~ Organize the cells to appropiate order ~%
[RowNumber, ColumnNumber] = size(imageY);
%~ Store the Y blocks ~%
idxHor = 0;
for row = 1:8:RowNumber
    idxHor = idxHor + 1;
    idxVer = 0;
    for column = 1:8:ColumnNumber
        idxVer = idxVer + 1;
        tmpBlockY = cell(1, 3);                              % Create a cell to store block Y and position.
        tmpBlockY{1, 1} = imageY(row:row+7, column:column+7);
        tmpBlockY{1, 2} = idxVer; tmpBlockY{1, 3} = idxHor;
        Yblocks{idxHor, idxVer}= tmpBlockY;
    end
end
%~ Determine the y index from subimg ~%
if ~isequal(subimg, [4 2 0]) % if not 4:2:0
    y_index = 1:idxHor*idxVer;      %Take the blocks sequentially
else                         % for 4:2:0
    y_index = [];                   %Take the blocks in z form
    for j = 1:2:idxHor
        for i = 1:2:idxVer
            curr_pos = (j-1)*idxVer + i;
            y_index = [y_index curr_pos curr_pos+1 curr_pos+idxVer curr_pos+1+idxVer];
        end
    end
end
%~ Create the rest of the cell ~%
DC_PredY = 0;
for i = 1:length(y_index)
        blockY  = Yblocks{y_index(i)}{1};
        dctblockY  = blockDCT(blockY);
        quantblockY  = quantizeJPEG(dctblockY, qTableL, qScale);
        runSymbolsY = runLength(quantblockY, DC_PredY);
        huffStreamY = huffEnc(runSymbolsY,  1);                 % isLuminance = 1 FOR Y
        DC_PredY = quantblockY(1,1);                            % For the next iteration
%~ Save the struct for the associated block ~%
        currStruct = struct;
        currStruct.blkType = "Y";
        currStruct.indHor = Yblocks{y_index(i)}{3}; currStruct.indVer = Yblocks{y_index(i)}{2};
        currStruct.huffStream = huffStreamY;
        JPEGenc{end+1,1} = currStruct;
end

[RowNumber, ColumnNumber] = size(imageCb);
DC_PredCr = 0; DC_PredCb = 0; idxVer = 0;
for row = 1:8:RowNumber
    idxVer = idxVer + 1;
    idxHor = 0;
    for column = 1:8:ColumnNumber
        idxHor = idxHor + 1;
        blockCr = imageCr(row:row+7, column:column+7);
        blockCb = imageCb(row:row+7, column:column+7);
        
        dctblockCr = blockDCT(blockCr);
        dctblockCb = blockDCT(blockCb);
        
        quantblockCr = quantizeJPEG(dctblockCr, qTableC, qScale);
        quantblockCb = quantizeJPEG(dctblockCb, qTableC, qScale);
        
        runSymbolsCr = runLength(quantblockCr, DC_PredCr);
        runSymbolsCb = runLength(quantblockCb, DC_PredCb);
        
        huffStreamCr = huffEnc(runSymbolsCr,  0); % isLuminance = 0 FOR Cr
        huffStreamCb = huffEnc(runSymbolsCb,  0); % isLuminance = 0 FOR Cb
        
        DC_PredCr = quantblockCr(1,1);            % For the next iteration
        DC_PredCb = quantblockCb(1,1);            % For the next iteration
%~ Save the struct for the associated block ~%
        currStruct = struct;
        currStruct.blkType = "Cr";
        currStruct.indHor = idxHor; currStruct.indVer = idxVer;
        currStruct.huffStream = huffStreamCr;
        JPEGenc{end+1,1} = currStruct;
        
        currStruct = struct;
        currStruct.blkType = "Cb";
        currStruct.indHor = idxHor; currStruct.indVer = idxVer;
        currStruct.huffStream = huffStreamCb;
        JPEGenc{end+1,1} = currStruct;
    end
end

end