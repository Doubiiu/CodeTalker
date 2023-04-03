function seg = readVts(filename)

fileID = fopen(filename, 'r');

s = textscan(fileID, '%d');
seg = reshape(double(s{1}), [4,length(s{1})/4])';
seg = seg(:,1) + 1;

fclose(fileID);