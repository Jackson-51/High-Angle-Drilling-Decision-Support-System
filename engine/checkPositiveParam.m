function [isValid, msg] = checkPositiveParam(value, name)
%CHECKPOSITIVEPARAM Validate a scalar parameter that must be positive.
%   Used for scalar case-level values that are NOT survey rows: friction
%   factor, mud weight, and the three equipment limits (Section B / F).
%
%   [isValid, msg] = checkPositiveParam(value, name)
%
%   Inputs:
%       value - the number to check
%       name  - human-readable name, used in the message (e.g.
%               'Friction factor', 'Hook-load limit')
%
%   Outputs:
%       isValid - logical
%       msg     - string, empty if isValid is true

if ~isnumeric(value) || ~isscalar(value) || isnan(value) || value <= 0
    isValid = false;
    msg = sprintf('%s must be a positive numeric value (got: %s).', ...
        name, mat2str(value));
else
    isValid = true;
    msg = '';
end

end
