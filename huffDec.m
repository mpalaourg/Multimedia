function runSymbols = huffDec(huffStream, isLuminance)
if ~isscalar(isLuminance), error('Error. 2nd argument {isLuminance} must be scalar.'); end
%~ Transform from bytestream to char ~%
strHuff = [];
for i = 1:length(huffStream)
    currBin = bitget(huffStream(i), 8:-1:1);
    strHuff = strcat(char(strHuff), char(strjoin(string(currBin(:)),"")));
end

global DC_Huff_L DC_Huff_C AC_Huff_L AC_Huff_C;
if isLuminance
    DC_Huff = DC_Huff_L;
    AC_Huff = AC_Huff_L;
else
    DC_Huff = DC_Huff_C;
    AC_Huff = AC_Huff_C;
end
totalSize = length(strHuff); currChar = [];
%~ Decode Huffman Code, for DC Coefficient ~%
for i = 1:totalSize
    currChar = strcat(char(currChar), strHuff(i));
    index = find(DC_Huff(:,3) == string(currChar));
    if index                                            % Found the category
        Category = double(DC_Huff(index,1));            % Get the addtional bit length
        if Category
            currChar = strHuff(i+1:i+Category);      % The additional Bits
            dcAdditionalValue = getDecimal(currChar);
            endOfDC = i + length(currChar);
        else
            dcAdditionalValue = 0;                      % DC Value = 0, has zero additional Value
            endOfDC = i;
        end
        strSymbols(1,:) = [0 dcAdditionalValue];
        break;                                          % break from loop
    end
end
%~ Decode Huffman Code, for AC Coefficients ~%
currChar = []; j = endOfDC + 1;
while ( j < totalSize+1)
    currChar = strcat(char(currChar), strHuff(j));
    index = find(AC_Huff(:,4) == string(currChar));
    if index == 1                         % EOB
        strSymbols = [strSymbols; [AC_Huff(index,1) 0]]; 
        break
    elseif index == 152                   % [15 0]
        strSymbols = [strSymbols; [AC_Huff(index,1) 0]]; 
        currChar = [];
    elseif index
        Category = hex2dec(AC_Huff(index,2));
        currChar = strHuff(j+1:j+Category);          % The additional Bits
        acAdditionalValue = getDecimal(currChar);
        strSymbols = [strSymbols; [AC_Huff(index,1) acAdditionalValue]];
        j = j + length(currChar);                       % Go on to the next AC coeficient.
        currChar = [];
    end
    j = j + 1;
end
runSymbols(:,1) = hex2dec(strSymbols(:,1));
runSymbols(:,2) = double(strSymbols(:,2));
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