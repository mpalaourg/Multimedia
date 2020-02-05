function imgRec = JPEGdecode(JPEGenc)
if ~iscell(JPEGenc),              error('Error. Argument {JPEGenc} must be a cell array.'); end
%~ Get the tables for the first cell ~%
tableStruct = JPEGenc{1,1};
qTableL = tableStruct.qTableL;
qTableC = tableStruct.qTableC;
%DCL = tableStruct.DCL; DCC = tableStruct.DCC;
%ACL = tableStruct.ACL; ACC = tableStruct.ACC;
DC_PredY = 0; DC_PredCr = 0; DC_PredCb = 0;
numberOfY = 0; numberOfCb = 0; numberOfCr = 0;
for i = 2:length(JPEGenc)
    currStruct = JPEGenc{i};
    idxVer = currStruct.indVer; idxHor = currStruct.indHor;
    switch currStruct.blkType
        case "Y"
            myrunSymbolsY = huffDec(currStruct.huffStream, 1);      % isLuminance = 1 FOR Y
            quantblockY = irunLength(myrunSymbolsY, DC_PredY);
            de_quantblockY  = dequantizeJPEG(quantblockY, qTableL, 1);
            idctblockY  = iBlockDCT(de_quantblockY);
            row = (idxHor - 1) * 8 + 1; column = (idxVer - 1) * 8 + 1;
            imageY_rec(row:row+7, column:column+7) = idctblockY;
            DC_PredY = quantblockY(1,1);                            % For the next iteration
            numberOfY = numberOfY + 1;
        case "Cb"
            myrunSymbolsCb = huffDec(currStruct.huffStream, 0);     % isLuminance = 0 FOR Cb
            quantblockCb = irunLength(myrunSymbolsCb, DC_PredCb);
            de_quantblockCb  = dequantizeJPEG(quantblockCb, qTableC, 1);
            idctblockCb  = iBlockDCT(de_quantblockCb);
            row = (idxVer - 1) * 8 + 1; column = (idxHor - 1) * 8 + 1;
            imageCb_rec(row:row+7, column:column+7) = idctblockCb;
            DC_PredCb = quantblockCb(1,1);                          % For the next iteration
            numberOfCb = numberOfCb + 1;
        case "Cr"
            myrunSymbolsCr = huffDec(currStruct.huffStream, 0);     % isLuminance = 0 FOR Cb
            quantblockCr = irunLength(myrunSymbolsCr, DC_PredCr);
            de_quantblockCr  = dequantizeJPEG(quantblockCr, qTableC, 1);
            idctblockCr  = iBlockDCT(de_quantblockCr);
            row = (idxVer - 1) * 8 + 1; column = (idxHor - 1) * 8 + 1;
            imageCr_rec(row:row+7, column:column+7) = idctblockCr;
            DC_PredCr = quantblockCr(1,1);                          % For the next iteration
            numberOfCr = numberOfCr + 1;
    end
end
if numberOfY == numberOfCb
    subimg = [4 4 4];
elseif numberOfY == 2 * numberOfCb
    subimg = [4 2 2];
else
    subimg = [4 2 0];
end
imgRec = convert2rgb(imageY_rec, imageCr_rec, imageCb_rec, subimg);
end