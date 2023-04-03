function seg = readSym(filename, ifZero)

if ~exist('ifZero', 'var')
	ifZero = false;
end

fileID = fopen(filename, 'r');

s = textscan(fileID, '%d');
seg = double(s{1});
n = length(seg);

if ifZero
	seg = seg + 1;
end

if (min(seg) == 0)
    seg = seg + 1;
end

fclose(fileID);