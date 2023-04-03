function [VERT, TRIV] = readObj(filename)

if length(strsplit(filename,'.')) > 1
    fid = fopen(filename,'r');
else % without file extension
    fid = fopen([filename, '.obj'],'r');
end

if fid==-1
    error('Cannot open the file: %s\n',filename);
end

%C = textscan(fid,'%s %f %f %f','Whitespace',' //','commentStyle','#');
C = textscan(fid,'%s %f %f %f','commentStyle','#');


fclose(fid);

vertices = strcmp(C{1}(:), 'v');

X = C{2}(vertices);
Y = C{3}(vertices);
Z = C{4}(vertices);

VERT = [X,Y,Z];

triangles = strcmp(C{1}(:),'f');

ntriangles = sum(triangles);

T1 = C{2}(triangles);
T2 = C{3}(triangles);
T3 = C{4}(triangles);
TRIV = [T1 T2 T3];

%trisurf(T,X,Y,Z);

end
