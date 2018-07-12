function [filename] = prependScriptPath(obj, filename)
%prependScriptPath Prepend path to Script dir to filename if path not given
%   Detailed explanation goes here

[pth, nm, ext] = fileparts(filename);
if isempty(pth)

    filename = fullfile(obj.Directory, obj.ScriptDirectory, [nm, ext]);
end
end