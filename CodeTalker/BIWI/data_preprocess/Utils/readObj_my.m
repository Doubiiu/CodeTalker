function [UV,Normal,VERT, TRIV] = readObj_my(filename)

%{
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
%}
% set up field types
v = []; vt = []; vn = []; f.v = []; f.vt = []; f.vn = [];
fid = fopen(filename);
% parse .obj file 
while 1    
    tline = fgetl(fid);
    if ~ischar(tline),   break,   end  % exit at end of file 
     ln = sscanf(tline,'%s',1); % line type 
     disp(ln)
    switch ln
        case 'v'   % mesh vertexs
            v = [v; sscanf(tline(2:end),'%f')'];
        case 'vt'  % texture coordinate
            vt = [vt; sscanf(tline(3:end),'%f')'];
        case 'vn'  % normal coordinate
            vn = [vn; sscanf(tline(3:end),'%f')'];
        case 'f'   % face definition
            fv = []; fvt = []; fvn = [];
            str = textscan(tline(2:end),'%s'); str = str{1};
       
           nf = length(findstr(str{1},'/')); % number of fields with this face vertices
           [tok str] = strtok(str,'//');     % vertex only
            for k = 1:length(tok) fv = [fv str2num(tok{k})]; end
           
            if (nf > 0) 
            [tok str] = strtok(str,'//');   % add texture coordinates
                for k = 1:length(tok) fvt = [fvt str2num(tok{k})]; end
            end
            if (nf > 1) 
            [tok str] = strtok(str,'//');   % add normal coordinates
                for k = 1:length(tok) fvn = [fvn str2num(tok{k})]; end
            end
             f.v = [f.v; fv]; f.vt = [f.vt; fvt]; f.vn = [f.vn; fvn];
    end
end
fclose(fid);
% set up matlab object 
obj.v = v; obj.vt = vt; obj.vn = vn; obj.f = f;

VERT = obj.v;
TRIV = obj.f.v;
UV=obj.vt;
Normal=obj.vn;
end

