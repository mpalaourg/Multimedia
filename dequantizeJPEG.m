function dctBlock = dequantizeJPEG(qBlock, qTable, qScale)
if ~isequal(size(qBlock), [8 8]), error('Error. 1st argument {qBlock} must be a 8x8 matrix.'); end
if ~isequal(size(qTable), [8 8]), error('Error. 2nd argument {qTable} must be a 8x8 matrix.'); end
if ~isscalar(qScale),             error('Error. 3rd argument {qScale} must be scalar.'); end

dctBlock = qBlock .* (qScale * qTable);
end