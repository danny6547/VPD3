function cout = validateCellStr(c, varargin)
%validateCellStr Trigger formatted error message for non-cellstr inputs
%   validateCellStr(c) will call function VALIDATEATTRIBUES on C and return
% an error message formatted similarly to that of VALIDATEATTRIBUES if all
% C is not a string or cell array of strings. Output COUT will be a cell
% array of strings if no error is thrown.

% Input
validateattributes(c, {'char', 'cell'}, {},...
        varargin{:});

funcname = '';
if nargin > 1 && ~isempty(varargin{1})
    funcname = varargin{1};
    validateattributes(funcname, {'char'}, {'vector'}, 'validateCellStr',...
        'funcname', 2);
end

varname = '';
if nargin > 2 && ~isempty(varargin{2})
    varname = varargin{2};
    validateattributes(varname, {'char'}, {'vector'}, 'validateCellStr',...
        'varname', 3);
end

argindex = [];
if nargin > 3 && ~isempty(varargin{3})
    argindex = varargin{3};
    validateattributes(argindex, {'numeric'}, {'scalar', '>', 0, 'integer'},...
        'validateCellStr', 'argindex', 4);
    argI = num2str(argindex);
end

try cout = cellstr(c);
    
catch e
    
    if strcmp(e.identifier, 'MATLAB:cellstr:InputClass')
        
        errmsg1 = 'Expected input to be a string or cell array of strings.';
        errid = 'MATLAB:expectedCellOrCellStr';
        
        if ~isempty(funcname)
            errid = ['MATLAB:' funcname ':expectedCellOrCellStr'];
            errmsg = ['Error using ', funcname, '\n', errmsg1];
        else
            errmsg = errmsg1;
        end
        
        if ~isempty(argindex)
            if ~isempty(varname)
                errmsg = strrep(errmsg, 'input', ...
                    ['input number ', argI, ', ' varname, ',']);
            else
                errmsg = strrep(errmsg, 'input', ['input number ', argI]);
            end
        else
            if ~isempty(varname)
                errmsg = strrep(errmsg, 'input', varname);
            end
        end
        
%         if ~isempty(varname)
%             errmsg = strrep(errmsg, 'input', varname);
% %             errmsg = strcat(errmsg, ['Expected ' varname ...
% %                 ' to be a string or cell array of strings']);
%         end
%         
%         if ~isempty(argindex)
%             if ~isempty(varname)
%                 errmsg = [errmsg1, 'Expected input number ' argI ', ' ...
%                     varname ', to be a string or cell array of strings.'];
% %                 errmsg = strrep(errmsg, varname, ...
% %                     ['input number ' argI ', ' varname ', ']);
%             else
%                 errmsg = strrep(errmsg, 'input', ['input number ' argI]);
%             end
%         end
        
        me = MException(errid, errmsg);
        throwAsCaller(me);

    else
    
        rethrow(e);
    end
end
end