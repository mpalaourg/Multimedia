function runSymbols = runLength(qBlock, DCpred)
%runLength
%Inputs:
%qBlock: The quantization symbols, of the DCT coefficients.         [8-by-8]
%DCpred: The prediction for the DC coefficient.                     [scalar]
%return:
%runSymbols: Matrix contain pairs of (precedingZeros, quantSymbol). [R-by-2]
%
%First, i handle the DC coefficient. The quantSymbol, is the difference
%between the current DC value and the previous (DCpred) and the precedingZeros
%are 0. Then, for the AC coefficients re-order qBlock according to ZigZag 
%rule and count the zeros before a non-zero value (quantSymbol) appear. 
%There are some special cases:
% i)  No more than 15 consecutively zeros can be handled. (ZRL)
% ii) If the last elements of qBlock are zero, runlength is [0 0]. (EOB)
%
if ~isequal(size(qBlock), [8 8]), error('Error. 1st argument {qBlock} must be a 8x8 matrix.'); end
if ~isscalar(DCpred),             error('Error. 2nd argument {DCpred} must be scalar.'); end

DC_coef = qBlock(1,1) - DCpred;                     % DC coefficient has different handling
%~ ZigZag re-ordering of the matrix ~%
idx = reshape(1:numel(qBlock), size(qBlock));       % Create indexes.
idx = fliplr(spdiags(fliplr(idx)));                 % Get the indexes at a diagonial convenient form
idx(:,1:2:end) = flipud(idx(:,1:2:end));            % Reverse order of odd columns
idx(idx==0) = [];                                   % Discard the zero - indexes
qBlock = qBlock(idx);                               % Re-order array based on the ziz-zag indexes.

runSymbols = [0 DC_coef]; precedingZeros = 0;
for i=2:length(qBlock)                              % For all the AC coefficients
    if qBlock(i)                                    % Next Symbol Found, Update runSymbols
        runSymbols = [runSymbols; [precedingZeros qBlock(i)]];
        precedingZeros = 0;                         % Reset the procedure
    elseif i == length(qBlock)                      % EOB and qBlock(end) == 0
        while isequal(runSymbols(end,:), [15 0])    % Check if [15 0] was inserted at the end
            runSymbols(end, :) = [];                % If that's the case, delete them to place [0 0]
        end
        runSymbols = [runSymbols; [0 0]];           % Remaining symbols is 0
    else
        precedingZeros = precedingZeros + 1;        % Count the preceding zeros
        if precedingZeros == 15                     % At 15, reset and add [15 0]
            runSymbols = [runSymbols; [15 0]];      % Runlength supports only 15 consecutively zeros.
            precedingZeros = 0;
        end
    end
end
end