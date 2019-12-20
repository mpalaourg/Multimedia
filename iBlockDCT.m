function block = iBlockDCT(dctBlock)
    block = idct2(dctBlock) + 128;
end