function idx = readKidCor(path)

fileID = fopen(path,'r');
idx = fscanf(fileID, '%u\t%u');
fclose(fileID);

idx = reshape(idx, [2,numel(idx)/2])';