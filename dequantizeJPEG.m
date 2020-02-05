function dctBlock = dequantizeJPEG(qBlock, qTable, qScale)
%dequantizeJPEG
%Inputs:
%qBlock: The quantization symbols, of the DCT coefficients.    [8-by-8]
%qTable: The quantization table.                               [8-by-8]
%qScale: The scale of the quantization.                        [scalar]
%return:
%dctBlock: Block with the DCT coefficients.                    [8-by-8]
%
% To undo the quantization, the quantization symbols will be multiplied -point
% wise- by (qScale * qTable), where qScale control the scale of the quantization.
%               Quantization symbols .* (qScale * qTable)
%

if ~isequal(size(qBlock), [8 8]), error('Error. 1st argument {qBlock} must be a 8x8 matrix.'); end
if ~isequal(size(qTable), [8 8]), error('Error. 2nd argument {qTable} must be a 8x8 matrix.'); end
if ~isscalar(qScale),             error('Error. 3rd argument {qScale} must be scalar.'); end

dctBlock = qBlock .* (qScale * qTable);
end