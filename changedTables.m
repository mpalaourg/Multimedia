function [qTableL, qTableC] = changedTables(num)
%~ Change qTableL, qTableC ~%
qTableL = [16 11 10 16 24 40 51 61;     12 12 14 19 26 58 60 55;
           14 13 16 24 40 57 69 56;     14 17 22 29 51 87 80 62;
           18 22 37 56 68 109 103 77;   24 35 55 64 81 104 113 92;
           49 64 78 87 103 121 120 101; 72 92 95 98 112 100 103 99];
qTableC = [17 18 24 47 99 99 99 99; 
           18 21 26 66 99 99 99 99;
           24 26 56 99 99 99 99 99;
           47 66 99 99 99 99 99 99;
           99 99 99 99 99 99 99 99;
           99 99 99 99 99 99 99 99;
           99 99 99 99 99 99 99 99;
           99 99 99 99 99 99 99 99];
%~ For zeroing, change 99 to 1000 ~%
qTableL = qTableL'; qTableC = qTableC';
qTableL = [qTableL(1:end-num) 1000*ones(1,num)];% 'num' high frequency 
qTableC = [qTableC(1:end-num) 1000*ones(1,num)];% 'num' high frequency 
qTableL = reshape(qTableL, [8 8]); qTableL = qTableL';
qTableC = reshape(qTableC, [8 8]); qTableC = qTableC';
end