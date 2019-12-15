function binValue = getBinary(num, Category)
%~ Based on Category, produce the binary / huffman value of num ~%
binValue = bitget(abs(num),Category:-1:1);
if num < 0
    binValue = ~binValue;
end
binValue = string(binValue * 1);
binValue = strjoin(binValue(:),"");
end