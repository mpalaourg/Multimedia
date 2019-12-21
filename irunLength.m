function qBlock = irunLength(runSymbols, DCpred)
%irunLength
%Inputs:
%runSymbols: Matrix contain pairs of (precedingZeros, quantSymbol). [R-by-2]
%DCpred: The prediction for the DC coefficient.                     [scalar]
%return:
%qBlock: The quantization symbols, of the DCT coefficients.         [8-by-8]
%
%First, i handle the DC coefficient. The DC value of qBlock, is the sum between 
%the first quantSymbol and DCpred. Then, for the AC coefficients check (for
%each row) the value of the precedingZeros and create a vector of those 
%precedingZeros followed by the quantSymbol. ([0 0 0 ... 0 0 quantSymbol])
%For each row, horrizontally concat the generated vectors.
%There are some special cases:
% i)  [15 0], must create a vector which contains 15 zeros. (ZRL)
% ii) [0  0], must fill qBlock with zeros, until the length of 64. (EOB)
%Finally, undo the ZigZag re-order, to get the [8-by-8] qBlock.
%
if ~ismatrix(runSymbols), error('Error. 1st argument {runSymbols} must be a Rx2 matrix.'); end
if ~isscalar(DCpred),     error('Error. 2nd argument {DCpred} must be scalar.'); end

[RowNumber, ~] = size(runSymbols);
qBlock(1,1) = runSymbols(1,2) + DCpred;
for i = 2:RowNumber                                     % For each row, minus DC coefficient
    if isequal(runSymbols(i,:), [15 0])
        qBlock = [qBlock zeros(1, runSymbols(i,1))];    % Place only the 15 zeros
    elseif isequal(runSymbols(i,:), [0 0])
        qBlock = [qBlock zeros(1, 64-length(qBlock))];  % The rest is zeros
    else
        qBlock = [qBlock [zeros(1, runSymbols(i,1)) runSymbols(i,2)]];
    end
end
%~ Undo the ZigZag reorder ~%
index = [1  2  6  7  15 16 28 29; 
         3  5  8  14 17 27 30 43;
         4  9  13 18 26 31 42 44;
         10 12 19 25 32 41 45 54;
         11 20 24 33 40 46 53 55;
         21 23 34 39 47 52 56 61;
         22 35 38 48 51 57 60 62;
         36 37 49 50 58 59 63 64];
qBlock = qBlock(index);                               % Re-order array based on the ziz-zag indexes.
end
