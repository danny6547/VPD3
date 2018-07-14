function obj = createDir(obj, varargin)
%createDir Create directory for analysis
%   Detailed explanation goes here

if nargin > 1
    
    dirpath = varargin{1};
    validateattributes(dirpath, {'char'}, {'vector'}, 'cMTurkHIT.createDir',...
        'dirpath', 2);
    obj.Directory = dirpath;
end

% Error if dir not given
dirpath = obj.Directory;
if isempty(dirpath)
    
    errid = 'CannotMakeDir:DirNotGiven';
    errmsg = 'Directory path string must be given before it can be created';
    error(errid, errmsg);
end

% Make top-level
mkdir(dirpath);

% Make sub-dirs
mkdir(dirpath, obj.InputDirectory);
mkdir(dirpath, obj.ScriptDirectory);
mkdir(dirpath, obj.OutputDirectory);
mkdir(dirpath, obj.ImageDirectory);
end