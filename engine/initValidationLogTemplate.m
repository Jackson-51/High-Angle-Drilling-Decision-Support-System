function logTemplate = initValidationLogTemplate()
%INITVALIDATIONLOGTEMPLATE Empty typed table schema for the validation log.
%   Populated by the Step-3 validation engine. One row per issue found,
%   NOT one row per input row -- clean rows generate no entry.
%
%   Variables:
%       RowIndex   (double)  1-based row in the raw survey where issue found
%       Field      (string)  which column triggered the issue
%       Issue      (string)  human-readable description
%       Action     (string)  'Rejected' | 'Quarantined' | 'Corrected'

varNames = {'RowIndex','Field','Issue','Action'};
varTypes = {'double','string','string','string'};

logTemplate = table('Size',[0 numel(varNames)], ...
    'VariableTypes', varTypes, 'VariableNames', varNames);

end
