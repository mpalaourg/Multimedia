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
[RowNumber, ~] = size(runSymbols); strHuff = [];
%~ First, match the symbol with the 'Category' ~%
% The symbol belongs to 'Category' when the following apply:
%           -2^(Category) < Symbol < 2^(Category)
%~ Category and Additional Bits for DC coefficient ~%
Category = 0;   % Category = 0, ONLY FOR Symbol = 0
if runSymbols(1,2)
    Category = floor( log2( abs(runSymbols(1,2)) ) ) + 1; % Table F.1
end
DC_Magn = Category;
dcAdditionalBits = getBinary(runSymbols(1,2), Category);

%~ Category and Additional Bits for AC coefficients ~%
AC_Magn = dec2hex(zeros(RowNumber-1, 1)); acAdditionalBits = string( zeros(RowNumber-1, 1));
for j = 2:RowNumber
% RunLengths [15 0] and [0 0] DOESNT HAVE any additional bits
    if isequal(runSymbols(j,:), [15 0]) || isequal(runSymbols(j,:), [0 0])
        AC_Magn(j-1) = dec2hex(0);
        acAdditionalBits(j-1) = '';
    else
        Category = floor( log2( abs(runSymbols(j,2)) ) ) + 1; % Table F.2
        AC_Magn(j-1) = dec2hex(Category);
        acAdditionalBits(j-1) = getBinary(runSymbols(j,2), Category);
    end
end
%~ Compute Huffman code of DC Coefficient ~%
index = find(DC_Huff(:,1) == string(DC_Magn));
if index
    strHuff = strcat(char(strHuff), char(DC_Huff(index, 3)), char(dcAdditionalBits));
end
%~ Compute Huffman code of AC Coefficients ~%
for i = 2:RowNumber
    index = find(AC_Huff(:,1) == string(dec2hex(runSymbols(i,1))) & ...
                 AC_Huff(:,2) == string(AC_Magn(i-1)));
    if index
        strHuff = strcat(char(strHuff), char(AC_Huff(index, 4)), char(acAdditionalBits(i-1)));
    end
end
%~ Transform huffman from char to bytestream (uint8) ~%
remBits = mod(length(strHuff), 8);
if remBits
    addBits = string(ones(1,8-remBits));
    strHuff = strcat(char(strHuff), char(strjoin(addBits(:), "")));
end
huffStream = uint8(zeros(1,length(strHuff)/8)); idx = 1;
for i = 1:8:length(strHuff)
   huffStream(idx) = bin2dec(strHuff(i:i+7));
   idx = idx + 1;
end
end

function binValue = getBinary(num, Category)
%~ Based on Category, produce the binary / huffman value of num ~%
if ~Category, binValue = 0; return; end % IF category = 0, then binary value is zero too.

binValue = bitget(abs(num),Category:-1:1);
if num < 0
    binValue = ~binValue;
end
binValue = string(binValue * 1);        % Logical to int, then to string
binValue = strjoin(binValue(:),"");
end