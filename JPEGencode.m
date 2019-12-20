function JPEGenc = JPEGencode(img, subimg, qScale)
if ndims(img) ~=3,                error('Error. 1st argument {img} must be a 3d matrix.'); end
if ~isequal(size(subimg), [1 3]), error('Error. 2nd argument {subimg} must be a 1x3 vector.'); end
if ~isscalar(qScale),             error('Error. 3rd argument {qScale} must be scalar.'); end
%~ Create the tables needed ~%
ISO_Tables;
qTableL = [16 11 10 16 24 40 51 61;     12 12 14 19 26 58 60 55;
           14 13 16 24 40 57 69 56;     14 17 22 29 51 87 80 62;
           18 22 37 56 68 109 103 77;   24 35 55 64 81 104 113 92;
           49 64 78 87 103 121 120 101; 72 92 95 98 112 100 103 99];
qTableC = [17 18 24 47 99 99 99 99; 
           18 21 26 66 99 99 99 99;
           24 26 56 99 99 99 99 99;
           47 66 99 99 99 99 99 99;
           99 99 99 99 99 99 99 99;
           99 99 99 99 99 99 99 99;
           99 99 99 99 99 99 99 99;
           99 99 99 99 99 99 99 99];
DCL = cell(1,1); DCC = cell(1,1); ACL = cell(1,1); ACC = cell(1,1);
DCL{1,1} = DC_Huff_L; DCC{1,1} = DC_Huff_C;
ACL{1,1} = AC_Huff_L; ACC{1,1} = AC_Huff_C;
%~ Create the struct for the first cell ~%
tableStruct = struct;
tableStruct.qTableL = qTableL;
tableStruct.qTableC = qTableC;
tableStruct.DCL = DCL; tableStruct.DCC = DCC;
tableStruct.ACL = ACL; tableStruct.ACC = ACC;
%~ Transform to YCbCr to begin the convertion ~%
clear imageY imageCb imageCr
clear imageY_rec imageCr_rec imageCb_rec
[imageY, imageCb, imageCr] = convert2ycbcr(img, subimg);

JPEGenc{1,1} = tableStruct;
%~ Create the rest of the cell ~%
[RowNumber, ColumnNumber] = size(imageY);
DC_PredY = 0; idxVer = 0;
for row = 1:8:RowNumber
    idxVer = idxVer + 1;
    idxHor = 0;
    for column = 1:8:ColumnNumber
        idxHor = idxHor + 1;
        blockY  = imageY(row:row+7, column:column+7);
        dctblockY  = blockDCT(blockY);
        quantblockY  = quantizeJPEG(dctblockY, qTableL, qScale);
        runSymbolsY = runLength(quantblockY, DC_PredY);
        huffStreamY = huffEnc(runSymbolsY,  1); % isLuminance = 1 FOR Y
        DC_PredY = quantblockY(1,1);            % For the next iteration
%~ Save the struct for the associated block ~%
        currStruct = struct;
        currStruct.blkType = "Y";
        currStruct.indHor = idxHor; currStruct.indVer = idxVer;
        currStruct.huffStream = huffStreamY;
        JPEGenc{end+1,1} = currStruct;
    end
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