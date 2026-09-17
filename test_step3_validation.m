%TEST_STEP3_VALIDATION Standalone check of the Step 3 validation engine.
%
%   Covers Test 4 (bad-data rejection) from the project testing
%   strategy, and demonstrates every bad-data example listed in the
%   examination (Section 21): non-numeric MD, negative MD, duplicate
%   MD, decreasing MD, inclination >180, missing value, invalid
%   friction factor, negative limit.
%
%   Run this file directly in MATLAB with engine/ on the path.

clear; clc;
addpath('engine');

%% Baseline: the clean, published exam survey should pass with zero issues
fprintf('=== Baseline: clean exam survey ===\n');
rawSurvey = getExaminationSurvey();
[cleanSurvey, log] = validateSurvey(rawSurvey);
assert(height(cleanSurvey) == 12, 'Clean survey should keep all 12 rows.');
assert(height(log) == 0, 'Clean survey should produce zero log entries.');
fprintf('PASS: 12/12 rows kept, 0 validation issues.\n\n');

%% Bad-data cases -- each takes the clean survey and corrupts ONE row
badCases = struct('name', {}, 'survey', {}, 'expectField', {});

% 1. Non-numeric MD (simulated as NaN, which is what readtable produces
%    when a spreadsheet cell contains text in a numeric column)
s = rawSurvey; s.MD_ft(5) = NaN;
badCases(end+1) = struct('name','Non-numeric MD','survey',s,'expectField','MD_ft/Inc_deg/Az_deg');

% 2. Negative MD
s = rawSurvey; s.MD_ft(5) = -4000;
badCases(end+1) = struct('name','Negative MD','survey',s,'expectField','MD_ft');

% 3. Duplicate MD
s = rawSurvey; s.MD_ft(5) = s.MD_ft(4); % row 5 repeats row 4's MD
badCases(end+1) = struct('name','Duplicate MD','survey',s,'expectField','MD_ft');

% 4. Decreasing MD
s = rawSurvey; s.MD_ft(5) = 2500; % less than row 4's 3000
badCases(end+1) = struct('name','Decreasing MD','survey',s,'expectField','MD_ft');

% 5. Inclination out of range (>180)
s = rawSurvey; s.Inc_deg(8) = 200;
badCases(end+1) = struct('name','Inclination > 180','survey',s,'expectField','Inc_deg');

% 6. Missing value
s = rawSurvey; s.Az_deg(6) = NaN;
badCases(end+1) = struct('name','Missing value','survey',s,'expectField','MD_ft/Inc_deg/Az_deg');

fprintf('=== Injected bad-row cases ===\n');
for k = 1:numel(badCases)
    [clean_k, log_k] = validateSurvey(badCases(k).survey);
    caught = height(log_k) >= 1 && height(clean_k) == 11;
    fprintf('[%s] %s\n', caseResultStr(caught), badCases(k).name);
    if height(log_k) >= 1
        fprintf('    -> Row %d, Field=%s, Issue="%s", Action=%s\n', ...
            log_k.RowIndex(1), log_k.Field(1), log_k.Issue(1), log_k.Action(1));
    end
    assert(caught, 'Bad-data case "%s" was not caught as expected.', badCases(k).name);
end
fprintf('\n');

%% Scalar parameter checks: invalid friction factor, negative limit
fprintf('=== Scalar parameter checks ===\n');
[isValid, msg] = checkPositiveParam(-0.10, 'Friction factor');
fprintf('[%s] Invalid friction factor (-0.10): %s\n', caseResultStr(~isValid), msg);
assert(~isValid, 'Negative friction factor should be rejected.');

[isValid, msg] = checkPositiveParam(-410, 'Hook-load limit');
fprintf('[%s] Negative equipment limit (-410): %s\n', caseResultStr(~isValid), msg);
assert(~isValid, 'Negative equipment limit should be rejected.');

[isValid, ~] = checkPositiveParam(0.2525, 'Friction factor');
fprintf('[%s] Valid friction factor (0.2525) correctly accepted.\n', caseResultStr(isValid));
assert(isValid, 'Valid friction factor should be accepted.');

fprintf('\nAll Step 3 validation checks passed.\n');

% ----- local helper -----
function s = caseResultStr(pass)
if pass
    s = 'PASS';
else
    s = 'FAIL';
end
end
