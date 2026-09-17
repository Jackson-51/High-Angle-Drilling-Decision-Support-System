function logTemplate = initDecisionLogTemplate()
%INITDECISIONLOGTEMPLATE Empty typed table schema for the stage decision log.
%   Populated by the Step-10 decision engine. One row per stage; a row
%   cannot be marked Confirmed=true until all six questions are
%   non-empty (enforced in the UI layer, Step 11).
%
%   Variables:
%       Stage                (double)
%       WhatChanged          (string)  Q1
%       ControllingFactor    (string)  Q2
%       AssignedStatus       (string)  Q3
%       Uncertainty          (string)  Q4
%       RecommendedAction    (string)  Q5
%       EvidenceNeededNext   (string)  Q6
%       Confirmed            (logical) gate flag for stage advancement

varNames = {'Stage','WhatChanged','ControllingFactor','AssignedStatus', ...
            'Uncertainty','RecommendedAction','EvidenceNeededNext','Confirmed'};
varTypes = {'double','string','string','string','string','string','string','logical'};

logTemplate = table('Size',[0 numel(varNames)], ...
    'VariableTypes', varTypes, 'VariableNames', varNames);

end
