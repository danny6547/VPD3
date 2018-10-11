function validateInteger(val, varargin)
%validateInteger Validate that value is a regular integer
%   Detailed explanation goes here

validateattributes(val, {'numeric'}, ...
    {'real', 'positive', 'integer', 'scalar'}, varargin{:});
end