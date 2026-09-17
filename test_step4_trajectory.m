%TEST_STEP4_TRAJECTORY Standalone check of the Step 4 minimum-curvature engine.
%
%   Covers Test 1 (straight vertical section) and Test 2 (full survey,
%   checked against an INDEPENDENTLY computed reference file) from the
%   project testing strategy.
%
%   Run this file directly in MATLAB with engine/ and reference/ on the
%   path (or run from the pgg327_app/ folder as-is).

clear; clc;
addpath('engine');

%% Test 1: straight vertical section (MD 0-2000, Inc=Az=0 throughout)
fprintf('=== Test 1: straight vertical section ===\n');
vertSurvey = table([0;1000;2000], [0;0;0], [0;0;0], ...
    'VariableNames', {'MD_ft','Inc_deg','Az_deg'});
vertTraj = computeMinimumCurvature(vertSurvey);
disp(vertTraj);

tol = 1e-9;
assert(all(abs(vertTraj.beta_deg) < tol), 'beta should be ~0 for a vertical section.');
assert(all(abs(vertTraj.DLS_deg100ft) < tol), 'DLS should be ~0 for a vertical section.');
assert(abs(vertTraj.RF(2) - 1) < tol && abs(vertTraj.RF(3) - 1) < tol, 'RF should be exactly 1 when beta=0.');
assert(abs(vertTraj.TVD_ft(end) - 2000) < tol, 'TVD should equal MD for a vertical section.');
assert(all(vertTraj.N_ft == 0) && all(vertTraj.E_ft == 0), 'N/E should stay 0 for a vertical section.');
fprintf('PASS: beta~=0, DLS~=0, RF==1, TVD==MD, N==E==0.\n\n');

%% Test 2: full exam survey vs. independently computed reference
fprintf('=== Test 2: full survey vs. independent reference ===\n');
rawSurvey = getExaminationSurvey();
[cleanSurvey, log] = validateSurvey(rawSurvey);
assert(height(log) == 0, 'Exam survey should be clean going into Step 4.');

trajectory = computeMinimumCurvature(cleanSurvey);
disp(trajectory);

refPath = fullfile('reference', 'expected_trajectory.csv');
assert(isfile(refPath), 'Reference file not found: %s', refPath);
ref = readtable(refPath);

numTol = 1e-2;  % ft / deg -- generous enough to absorb rounding in the
                 % reference file, tight enough to catch real bugs
fields = {'beta_deg','RF','dTVD_ft','dN_ft','dE_ft','TVD_ft','N_ft','E_ft','DLS_deg100ft'};
allOK = true;
for k = 1:numel(fields)
    f = fields{k};
    diffs = abs(trajectory.(f) - ref.(f));
    maxDiff = max(diffs);
    ok = maxDiff < numTol;
    allOK = allOK && ok;
    fprintf('[%s] %-14s max abs diff = %.6f\n', tern(ok,'PASS','FAIL'), f, maxDiff);
end
assert(allOK, 'MATLAB trajectory does not match the independent reference within tolerance.');
fprintf('\nAll Step 4 checks passed -- MATLAB output matches independent verification.\n');

% ----- local helper -----
function s = tern(cond, a, b)
if cond, s = a; else, s = b; end
end
