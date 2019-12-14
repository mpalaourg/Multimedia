function runSymbols = huffDec(huffStream)
%getArrayFromByteStream(huffStream)
global DC_Huff_L DC_Huff_C AC_Huff_L AC_Huff_C;
totalSize = length(huffStream); currChar = [];
%~ Find DC Value ~%
for i = 1:totalSize
    currChar = strcat(char(currChar), huffStream(i));
    index = find(DC_Huff_L(:,3) == string(currChar));
    if index                                            % Found the category
        Category = double(DC_Huff_L(index,1));
        currChar = huffStream(i+1:i+Category);          % The additional Bits
        dcAdditionalValue = getDecimal(currChar);
        runSymbols(1,:) = [0 dcAdditionalValue];
        endOfDC = i+Category;
        break;                                          % break from loop
    end
end
%~ Find AC Values ~%
currChar = []; j = endOfDC + 1;
while ( j < totalSize)
    currChar = strcat(char(currChar), huffStream(j));
    index = find(AC_Huff_L(:,4) == string(currChar));
    if index
        Category = double(AC_Huff_L(index,2));
        currChar = huffStream(j+1:j+Category);          % The additional Bits
        acAdditionalValue = getDecimal(currChar);
        runSymbols = [runSymbols; [double(AC_Huff_L(index,1)) acAdditionalValue]];
        currChar = [];
        j = j + Category;                               % Go on to the next AC coeficient.
    end
    j = j + 1;
end

end
function decValue = getDecimal(currChar)
%~ Based on Category, invert the huffman code ~%
if currChar(1) == '0'                % Negative values begin with 0
    currChar = double(currChar) - 48; % Convert char to double (ascii - 48)
    currChar = ~currChar;
    currChar = string(currChar * 1);
    decValue = -bin2dec(strjoin(currChar(:),""));
    return;
end
decValue = bin2dec(currChar);
return;
end