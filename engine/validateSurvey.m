function [cleanSurvey, log] = validateSurvey(rawSurvey)
%VALIDATESURVEY Row-level validation of the raw MD-Inc-Az survey (Section B).
%
%   [cleanSurvey, log] = validateSurvey(rawSurvey)
%
%   Input:
%       rawSurvey - table with variables MD_ft, Inc_deg, Az_deg
%                   (schema must match getExaminationSurvey.m)
%
%   Outputs:
%       cleanSurvey - table, same schema, VALID ROWS ONLY
%       log         - table (schema: initValidationLogTemplate.m), one
%                     row per issue found. Clean rows generate no entry.
%
%   DESIGN DECISION (stated explicitly, not hidden): this function
%   REJECTS bad rows (removes them from cleanSurvey) rather than
%   "quarantining" them (keeping but flagging). Rejection is simpler to
%   reason about and still satisfies the examination's "refuse or
%   quarantine" requirement (Section B / Section 21). The log preserves
%   full traceability of what was removed and why.
%
%   Only the FIRST issue found on a given row is logged, and no further
%   checks run on that row -- this keeps the log readable (one row =
%   one primary reason for rejection) at the cost of not reporting
%   every simultaneous problem on a badly malformed row.

log = initValidationLogTemplate();

requiredCols = {'MD_ft','Inc_deg','Az_deg'};
if ~all(ismember(requiredCols, rawSurvey.Properties.VariableNames))
    log = addLogEntry(log, 0, 'Table', ...
        'Required column(s) MD_ft/Inc_deg/Az_deg missing from input table', ...
        'Rejected');
    cleanSurvey = rawSurvey([], requiredCols(ismember(requiredCols, ...
        rawSurvey.Properties.VariableNames)));
    return
end

nRows = height(rawSurvey);
keepMask = true(nRows, 1);

for i = 1:nRows
    md  = rawSurvey.MD_ft(i);
    inc = rawSurvey.Inc_deg(i);
    az  = rawSurvey.Az_deg(i);

    % --- Missing value (also catches non-numeric text that failed to
    %     parse during import, which readtable typically turns into NaN
    %     in a double-typed column) ---
    if ismissing(md) || ismissing(inc) || ismissing(az)
        log = addLogEntry(log, i, 'MD_ft/Inc_deg/Az_deg', ...
            'Missing or non-numeric value in row', 'Rejected');
        keepMask(i) = false;
        continue
    end

    % --- Negative MD ---
    if md < 0
        log = addLogEntry(log, i, 'MD_ft', ...
            sprintf('Negative MD (%.1f ft) is not physically valid', md), ...
            'Rejected');
        keepMask(i) = false;
        continue
    end

    % --- Inclination range [0, 180] deg ---
    if inc < 0 || inc > 180
        log = addLogEntry(log, i, 'Inc_deg', ...
            sprintf('Inclination (%.1f deg) outside valid range [0,180]', inc), ...
            'Rejected');
        keepMask(i) = false;
        continue
    end

    % --- Azimuth range [0, 360) deg ---
    if az < 0 || az >= 360
        log = addLogEntry(log, i, 'Az_deg', ...
            sprintf('Azimuth (%.1f deg) outside valid range [0,360)', az), ...
            'Rejected');
        keepMask(i) = false;
        continue
    end
end

% --- Monotonic MD check (column-level, run against the RAW MD sequence
%     regardless of other rows' validity -- duplicate/decreasing MD is
%     a property of the depth sequence itself) ---
mdCol = rawSurvey.MD_ft;
for i = 2:nRows
    if keepMask(i) % don't double-log a row already rejected above
        if mdCol(i) == mdCol(i-1)
            log = addLogEntry(log, i, 'MD_ft', ...
                sprintf('Duplicate MD value (%.1f ft repeats row %d)', mdCol(i), i-1), ...
                'Rejected');
            keepMask(i) = false;
        elseif mdCol(i) < mdCol(i-1)
            log = addLogEntry(log, i, 'MD_ft', ...
                sprintf('Decreasing MD (%.1f ft after %.1f ft) violates monotonic requirement', ...
                mdCol(i), mdCol(i-1)), 'Rejected');
            keepMask(i) = false;
        end
    end
end

cleanSurvey = rawSurvey(keepMask, :);

end

% ----- local helper -----
function log = addLogEntry(log, rowIndex, field, issue, action)
newRow = table(rowIndex, string(field), string(issue), string(action), ...
    'VariableNames', log.Properties.VariableNames);
log = [log; newRow];
end
