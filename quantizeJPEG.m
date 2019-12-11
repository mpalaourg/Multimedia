function qBlock = quantizeJPEG(dctBlock, qTable, qScale)
if ~isequal(size(dctBlock), [8 8]), error('Error. 1st argument {dctBlock} must be a 8x8 matrix.'); end
if ~isequal(size(qTable), [8 8]),   error('Error. 2nd argument {qTable} must be a 8x8 matrix.'); end
if ~isscalar(qScale),               error('Error. 3rd argument {qScale} must be scalar.'); end

qBlock =  round(dctBlock ./ (qScale * qTable));
end