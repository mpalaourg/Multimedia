function dctBlock = blockDCT(block)
%blockDCT
%Inputs:
%block: A matrix that contains a part of the a component (Y or Cb or Cr). [8-by-8]
%return:
%dctBlock: The DCT coefficients for this block.                    [8-by-8]
%
% At first offset the blocks value by 2^(8-1) (8 bit colour resolution).
% Then, use dct2 to compute the DCT coefficients for this block.
%
if ~isequal(size(block), [8 8]), error('Error. The argument {block} must be a 8x8 matrix.'); end
    dctBlock = dct2(double(block) - 128);
end