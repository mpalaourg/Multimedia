function qBlock = quantizeJPEG(dctBlock, qTable, qScale)
%quantizeJPEG
%Inputs:
%dctBlock: Block with the DCT coefficients.                     [8-by-8]
%qTable: The quantization table.                                [8-by-8]
%qScale: The scale of the quantization.                         [scalar]
%return:
%qBlock: The quantization symbols, of the DCT coefficients.    [8-by-8]
%
%The quantization symbols are the point wise division of:
% DCT Coefficients
% ----------------, where qScale control the scale of the quantization.
%  qScale * qTable
%Finnaly, the symbols will be rounded (to the nearest neighbor).
%
if ~isequal(size(dctBlock), [8 8]), error('Error. 1st argument {dctBlock} must be a 8x8 matrix.'); end
if ~isequal(size(qTable), [8 8]),   error('Error. 2nd argument {qTable} must be a 8x8 matrix.'); end
if ~isscalar(qScale),               error('Error. 3rd argument {qScale} must be scalar.'); end

qBlock =  round(dctBlock ./ (qScale * qTable));
end