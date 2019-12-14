function huffStream = huffEnc(runSymbols)
if ~ismatrix(runSymbols), error('Error. The argument {runSymbols} must be a Rx2 matrix.'); end
global DC_Huff_L DC_Huff_C AC_Huff_L AC_Huff_C;
% How to distinquish luminate from chromatic, so i can pick the right ISO  Table ?

[RowNumber, ~] = size(runSymbols); huffStream = [];
%~ First, match the symbol with the 'Category' ~%
% The symbol belongs to 'Category' when the following apply:
%           -2^(Category) < Symbol < 2^(Category)
for Category = 0:11
    if runSymbols(1,2) > -2^Category && runSymbols(1,2) < 2^Category 
        DC_Magn = dec2hex(Category);
        dcAdditionalBits = getBinary(runSymbols(1,2), Category);
        break;
    end
end
AC_Magn = dec2hex(zeros(RowNumber-1, 1)); acAdditionalBits = string( zeros(RowNumber-1, 1));
for j = 2:RowNumber
    for Category = 1:10
        if runSymbols(j,2) > -2^Category && runSymbols(j,2) < 2^Category 
            AC_Magn(j-1) = dec2hex(Category);
            acAdditionalBits(j-1) = getBinary(runSymbols(j,2), Category);
            break;
        end
    end
end
%~ DC Coefficient ~%
index = find(DC_Huff_L(:,1) == string(DC_Magn));
if index
    huffStream = strcat(char(huffStream), char(DC_Huff_L(index, 3)), char(dcAdditionalBits));
end
%~ AC Coefficients ~%
for i = 2:RowNumber
    index = find(AC_Huff_L(:,1) == string(runSymbols(i,1)) & AC_Huff_L(:,2) == string( AC_Magn(i-1) ));
    if index
        huffStream = strcat(char(huffStream), char(AC_Huff_L(index, 4)), char(acAdditionalBits(i-1)));
    end
end
%getByteStreamFromArray(huffStream)
end

function binValue = getBinary(num, Category)
%~ Based on Category, produce the binary / huffman value of num ~%
binValue = bitget(abs(num),Category:-1:1);
if num < 0
    binValue = ~binValue;
end
binValue = string(binValue * 1);
binValue = strjoin(binValue(:),"");
end