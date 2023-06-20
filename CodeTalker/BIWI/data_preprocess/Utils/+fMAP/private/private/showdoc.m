function showdoc(mpath)
%SHOWDOC Shows the HTML document for an m-file
%
% [ Syntax ]
%   - showdoc(mname, mpath)
%
% [ History ]
%   - Created by Dahua Lin, on Jul 7, 2007
%

if exist('web', 'file') == 2
    [parent, name] = fileparts(mpath);
    docpath = fullfile(parent, 'doc/helps', ['mdoc.ann_mwrapper.' name '.mfile.xml']);
    
    web(['file:///', docpath], '-notoolbar');    
else
    error('ann_mwrapper:showdoc:noweb', ...
        'The MATLAB does not support HTML-browsing.');
end