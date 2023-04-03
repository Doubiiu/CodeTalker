function opts = setopts(opts0, varargin)
%SETOPTS Sets the options and makes the option-struct
%
% [ Syntax ]
%   - opts = setopts([], name1, value1, name2, value2, ...)
%   - opts = setopts([], {name1, value1, name2, value2, ...})
%   - opts = setopts([], newopts)
%   - opts = setopts(opts0, ...)
%
% [ Arguments ]
%   - opts0:        the original options
%   - namei:        the i-th option name
%   - valuei:       the value of the i-th option
%   - opts:         the updated options
%
% [ Description ]
%   - opts = setopts([], name1, value1, name2, value2, ...) makes an
%     option structure using the name-value pairs. The names should be
%     all strings.
%
%     The constructed structure will be like the following:
%     \{
%         opts.name1 = value1
%         opts.name2 = value2
%           ...
%     \}
%     
%   - opts = setopts([], {name1, value1, name2, value2, ...}) makes an 
%     option structure using the name-value pairs encapsulated in 
%     a cell array. It is equivalent to the un-encapsulated form.
%
%   - opts = setopts([], newopts) makes an option structure by copying
%     the fields in newopts.
%
%   - opts = setopts(opts0, ...) updates the original structure opts0. 
%     Suppose there is a name-value pair with name abc, then
%       - if opts0 has a field named abc, then opts.abc will be set to
%         the supplied value;
%       - if opts0 does not has a field named abc, then a new field will 
%         be added to opts
%       - The remaining fields of opts0 that are not in the name-value
%         pairs will be copied to the opts using original values.
%
% [ Remarks ]
%   - The MATLAB builtin function struct can also make struct with name
%     value pairs. However, there are two significant differences:
%       # when the values are cell arrays, the function struct will build
%         a struct array and deal the values in the cell arrays to
%         multiple structs. While the function setopts will always make 
%         a scalar struct, the value in cell form will be directly set
%         as the value of the corresponding field as a whole.
%       # The function setopts can make a new option structure by updating
%         an existing one. It is suitable to the cases that there is a set
%         of default options, and the user only wants to change some of
%         them without changing the other. The setopts function offers a 
%         convenient way to tune a subset of options in the multi-option
%         applications.
%
%   - In the name-value list, multiple items with the same name is allowed.
%     Under the circumstances, only the rightmost value takes effect. This
%     design facilitates the use of a chain of option-setters. Each setter
%     can simply make its changes by appending some name-value pairs,
%     thereby the last changes will finally take effect.
%
% [ Examples ]
%   - Construct default options and then update it
%     \{
%          default_opts = setopts([], ...
%               'timeout', 30, ...
%               'method', 'auto', ...
%               'acts', {'open', 'edit', 'close'} );
%          
%          >>  default_opts.timeout = 30
%              default_opts.method = 'auto'
%              default_opts.acts = {'open', 'edit', 'close'}
%
%          user_opts = setopts(default_opts, ...
%               'timeout', 50, ...
%               'acts', {'open', 'edit', 'submit', 'close'}, ...
%               'info', 'something');
%
%          >>  user_opts.timeout = 50
%              user_opts.method = 'auto'
%              user_opts.acts = {'open', 'edit', 'submit', 'close'}
%              user_opts.info = 'something'
%     \}
%
%   - Set options with a chain of name-value pairs
%     \{
%           p1 = {'timeout', 30, 'method', 'auto'}
%           p2 = {'info', [1 2], 'timeout', 50}
%           p3 = {'keys', {'a', 'b'}, 'info', [10 20]}
%           
%           opts = setopts([], [p1, p2, p3])
%           
%           >> opts.timeout = 50
%              opts.method = 'auto'
%              opts.info = [10 20]
%              opts.keys = {'a', 'b'}
%     \}
%
%   - Update a struct with another one
%     \{
%           s0 = struct('handle', 1, 'width', 10, 'height', 20)
%           su = struct('width', 15, 'height', 25)
%
%           s1 = setopts(s0, su)
%
%           >> s1.handle = 1
%              s1.width = 15
%              s2.height = 25
%     \}
%
% [ History ]
%   - Created by Dahua Lin, on Jun 28, 2007
%

%% parse and verify input arguments

if isempty(opts0)
    opts = [];
elseif isstruct(opts0) && isscalar(opts0)
    opts = opts0;        
else
    error('dmtoolbox:setopts:invalidarg', ...
        'opts0 should be either a struct scalar or empty.');
end

if nargin > 1
    fparam = varargin{1};
    if isstruct(fparam)
        if nargin > 2
            error('dmtoolbox:setopts:invalidarg', ...
                'No input arguments are allowed to follow the struct parameter');
        end
        params = fparam;
    elseif iscell(fparam)
        if nargin > 2
            error('dmtoolbox:setopts:invalidarg', ...
                'No input arguments are allowed to follow the cell parameter');
        end
        params = fparam;
    elseif ischar(fparam)
        params = varargin;
    else
        error('dmtoolbox:setopts:invalidarg', 'The input argument list is illegal.');
    end    
else
    return;
end

%% main delegate

if iscell(params)
    opts = setopts_with_cell(opts, params);
else
    opts = setopts_with_struct(opts, params);
end


%% core functions

function opts = setopts_with_cell(opts, params)

names = params(1:2:end);
values = params(2:2:end);
n = length(names);

if length(values) ~= n
    error('dmtoolbox:setopts:invalidarg', 'The names and values should form pairs');
end

for i = 1 : n
    opts.(names{i}) = values{i};
end

function opts = setopts_with_struct(opts, params)

fns = fieldnames(params);
n = length(fns);

for i = 1 : n
    fn = fns{i};
    opts.(fn) = params.(fn);
end



