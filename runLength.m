function runSymbols = runLength(qBlock, DCpred)
if ~isequal(size(qBlock), [8 8]), error('Error. 1st argument {qBlock} must be a 8x8 matrix.'); end
if ~isscalar(DCpred),             error('Error. 2nd argument {DCpred} must be scalar.'); end

DC_coef = qBlock(1,1) - DCpred; % DC coefficient has different handling
%~ ZigZag re-ordering of the matrix ~%
idx = reshape(1:numel(qBlock), size(qBlock));   % Create indexes.
idx = fliplr(spdiags(fliplr(idx)));             % Get the indexes at a diagonial convenient form
idx(:,1:2:end) = flipud(idx(:,1:2:end));        % Reverse order of odd columns
idx(idx==0) = [];                               % Discard the zero - indexes
qBlock = qBlock(idx);                           % Re-order array based on the ziz-zag indexes.

runSymbols = 1; % To be removed
end