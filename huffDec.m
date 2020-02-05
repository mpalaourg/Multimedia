function runSymbols = huffDec(huffStream, isLuminance)
%huffEnc
%Inputs:
%huffStream: A matrix of uint8 (bytes) contains the huffman code.
%isLuminance: TO BE DELETED
%return:
%runSymbols: Matrix contain pairs of (precedingZeros, quantSymbol). [R-by-2]
%
% Each step is explained later.
%
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
    index = find(DC_Huff(:) == string(currChar));
    if index                                            % Found the category
        Category = index - 1;
        if Category
            currChar = strHuff(i+1:i+Category);         % The additional Bits
            dcAdditionalValue = getDecimal(currChar);
            endOfDC = i + length(currChar);
        else
            dcAdditionalValue = 0;                      % DC Value = 0, has zero additional Value
            endOfDC = i;
        end
        runSymbols(1,:) = [0 dcAdditionalValue];
        break;                                          % break from loop
    end
end

%~ Decode Huffman Code, for AC Coefficients ~%
% There are 4 cases: 
%  i)index = 1, EOB
%  ii) index = 152, ZRL
%  iii) to be between 1 and 152, offset = 1 and
%  iv) to be above 152, offset = 2.
% For cases 3 and 4, i compute the remInd = (index-offset)mod10.
%   If remInd != 0, then Category = remInd and run = floor(index/10)
%   If remInd  = 0, then Category = 10     and run = floor(index/10) - 1
currChar = []; j = endOfDC + 1;
while ( j < totalSize+1)
    currChar = strcat(char(currChar), strHuff(j));
    index = find(AC_Huff(:) == string(currChar));
    if index == 1                                       % EOB
        runSymbols = [runSymbols; [0 0]]; 
        break
    elseif index == 152                                 % ZRL
        runSymbols = [runSymbols; [15 0]]; 
        currChar = [];
    elseif index
        if index > 152
            index = index - 1;                          % Cause of the ZRL in index = 152
        end      
        index = index - 1;                              % Cause of the EOB in index = 1
        remInd = mod(index, 10);                        % Remainings 
        if ~remInd
            Category = 10;                              % i.e index 100 -> is 9/A
            run = floor(index/10) - 1;
        else
            Category = remInd;                      
            run = floor(index/10);
        end
        currChar = strHuff(j+1:j+Category);             % The additional Bits
        acAdditionalValue = getDecimal(currChar);
        runSymbols = [runSymbols; [run acAdditionalValue]];
        j = j + length(currChar);                       % Go on to the next AC coeficient.
        currChar = [];
    end
    j = j + 1;
end
end

function decValue = getDecimal(currChar)
%~ Based on Category, invert the huffman code ~%
if currChar(1) == '0'                             % Negative values begin with 0
    currChar = double(currChar) - 48;             % Convert char to double (ascii - 48)
    currChar = ~currChar;                         % Compute the 1's complement.
    currChar = string(currChar * 1);              % Logical to int, then to string.
    decValue = -bin2dec(strjoin(currChar(:),"")); % Concat the string.
    return;
end
decValue = bin2dec(currChar);                     % For positive values, compute the decimal value of the binary.
return;
end