function huffStream = huffEnc(runSymbols, isLuminance)
if ~ismatrix(runSymbols),  error('Error. 1st argument {runSymbols} must be a Rx2 matrix.'); end
if ~isscalar(isLuminance), error('Error. 2nd argument {isLuminance} must be scalar.'); end

global DC_Huff_L DC_Huff_C AC_Huff_L AC_Huff_C;
if isLuminance
    DC_Huff = DC_Huff_L;
    AC_Huff = AC_Huff_L;
else
    DC_Huff = DC_Huff_C;
    AC_Huff = AC_Huff_C;
end
[RowNumber, ~] = size(runSymbols); huffStream = [];
%~ First, match the symbol with the 'Category' ~%
% The symbol belongs to 'Category' when the following apply:
%           -2^(Category) < Symbol < 2^(Category)
%~ Category and Additional Bits for DC coefficient ~%
for Category = 0:11
    if runSymbols(1,2) > -2^Category && runSymbols(1,2) < 2^Category    % Table F.1
        DC_Magn = Category;
        dcAdditionalBits = getBinary(runSymbols(1,2), Category);
        break;
    end
end
%~ Category and Additional Bits for AC coefficients ~%
AC_Magn = dec2hex(zeros(RowNumber-1, 1)); acAdditionalBits = string( zeros(RowNumber-1, 1));
for j = 2:RowNumber
% RunLengths [15 0] and [0 0] DOESNT HAVE any additional bits
    if isequal(runSymbols(j,:), [15 0]) || isequal(runSymbols(j,:), [0 0])
        AC_Magn(j-1) = dec2hex(0);
        acAdditionalBits(j-1) = '';
    else
        for Category = 1:10
            if runSymbols(j,2) > -2^Category && runSymbols(j,2) < 2^Category % Table F.2
                AC_Magn(j-1) = dec2hex(Category);
                acAdditionalBits(j-1) = getBinary(runSymbols(j,2), Category);
                break;
            end
        end
    end
end
%~ Compute Huffman code of DC Coefficient ~%
index = find(DC_Huff(:,1) == string(DC_Magn));
if index
    huffStream = strcat(char(huffStream), char(DC_Huff(index, 3)), char(dcAdditionalBits));
end
%~ Compute Huffman code of AC Coefficients ~%
for i = 2:RowNumber
    index = find(AC_Huff(:,1) == string(dec2hex(runSymbols(i,1))) & ...
                 AC_Huff(:,2) == string(AC_Magn(i-1)));
    if index
        huffStream = strcat(char(huffStream), char(AC_Huff(index, 4)), char(acAdditionalBits(i-1)));
    end
end
%getByteStreamFromArray(huffStream)
end

function binValue = getBinary(num, Category)
%~ Based on Category, produce the binary / huffman value of num ~%
if ~Category, binValue = 0; return; end % IF category = 0, then binary value is zero too.

binValue = bitget(abs(num),Category:-1:1);
if num < 0
    binValue = ~binValue;
end
binValue = string(binValue * 1);
binValue = strjoin(binValue(:),"");
end