function block = iBlockDCT(dctBlock)
%iBlockDCT
%Inputs:
%dctBlock: The DCT coefficients for this block.                    [8-by-8]
%return:
%block: A matrix that contains a part of the a component (Y or Cb or Cr). [8-by-8]
%
% At first use idct2 to compute the values of this block. Then, undo the 
% offset of the blocks value by 2^(8-1) (8 bit colour resolution).
%
if ~isequal(size(dctBlock), [8 8]), error('Error. The argument {dctBlock} must be a 8x8 matrix.'); end
    block = idct2(dctBlock) + 128;
end