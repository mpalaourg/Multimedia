function qBlock = irunLength(runSymbols, DCpred)
if ~ismatrix(runSymbols), error('Error. 1st argument {runSymbols} must be a Rx2 matrix.'); end
if ~isscalar(DCpred),     error('Error. 2nd argument {DCpred} must be scalar.'); end

[RowNumber, ~] = size(runSymbols);
qBlock(1,1) = runSymbols(1,2) + DCpred;
for i = 2:RowNumber         % for each row, minus DC coefficient
    qBlock = [qBlock [zeros(1, runSymbols(i,1)) runSymbols(i,2)]];
end
%~ Undo the ZigZag reorder ~%
index_8 = zigZag(8) + 1;
qBlock = qBlock(index_8);                           % Re-order array based on the ziz-zag indexes.
end

function matrix = zigZag(n)
matrix = zeros(n); counter = 1;
flipCol = true; flipRow = false;

%~ Top diagonal of the matrix. ~%
for i = 2:n
    row = (1:i); column = (1:i);
    if flipCol
        column = fliplr(column);
        flipRow = true;
        flipCol = false;
    elseif flipRow
        row = fliplr(row);
        flipRow = false;
        flipCol = true;           
    end
% Selects a diagonal of the zig-zag matrix and places the correct integer 
% value in each index along that diagonal.
    for j = (1:numel(row))
        matrix(row(j),column(j)) = counter;
        counter = counter + 1;
    end   
end

%~ Bottom diagonal of the matrix. ~%
for i = 2:n
    row = (i:n); column = (i:n);
    if flipCol
        column = fliplr(column);
        flipRow = true;
        flipCol = false;
    elseif flipRow
        row = fliplr(row);
        flipRow = false;
        flipCol = true;           
    end
% Selects a diagonal of the zig-zag matrix and places the correct integer 
% value in each index along that diagonal.
    for j = (1:numel(row))
        matrix(row(j),column(j)) = counter;
        counter = counter + 1;
    end   
end
end