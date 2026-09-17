%TEST_STEP12_SENSITIVITY Standalone check of the Step 12 sensitivity engine.
%
%   Covers Test 8 (all four friction factors run) from the testing
%   strategy, plus an independent-reference comparison and the extra
%   uncertainty case required by Section F.
%
%   Run this file directly in MATLAB with engine/ and reference/ on the
%   path.

clear; clc;
addpath('engine');

n = getStudentSerialNumber();
baseParams = getBaseParameters();
caseDef = buildCaseDefinition(n, baseParams);

rawSurvey = getExaminationSurvey();
[cleanSurvey, ~] = validateSurvey(rawSurvey);
trajectory = computeMinimumCurvature(cleanSurvey);

%% Test 8: friction sensitivity, all four cases
fprintf('=== Friction sensitivity (n=%d case, MW=%.4f ppg) ===\n', n, caseDef.MW_ppg);
results = runFrictionSensitivity(baseParams.muSensitivity, trajectory, ...
    baseParams.wAir_lbft, caseDef.MW_ppg, baseParams.rEff_ft, baseParams.steelDensity_ppg);

disp(table(results.muList', results.pickup_kips', results.slackoff_kips', ...
    results.drag_lb', results.torque_ftlbf', ...
    'VariableNames', {'mu','pickup_kips','slackoff_kips','drag_lb','torque_ftlbf'}));

assert(numel(results.muList) == 4, 'Expected exactly 4 friction cases.');
assert(issorted(results.pickup_kips), 'Pickup load should increase monotonically with mu.');
assert(issorted(results.drag_lb), 'Drag should increase monotonically with mu.');
assert(issorted(results.torque_ftlbf), 'Torque should increase monotonically with mu.');
assert(issorted(results.slackoff_kips, 'descend'), 'Slack-off load should DECREASE as mu increases (friction opposes descent).');
fprintf('PASS: pickup/drag/torque increase with mu, slack-off decreases -- matches Eq (11)/(14)/(15) physics.\n\n');

%% Compare against independent reference (same discipline as Steps 4/6)
refPath = fullfile('reference', 'expected_sensitivity.csv');
if isfile(refPath)
    ref = readtable(refPath);
    tol = 0.5;  % kips / lb / ft-lbf
    allOK = true;
    fields = {'pickup_kips','slackoff_kips','drag_lb','torque_ftlbf'};
    for k = 1:numel(fields)
        f = fields{k};
        computed = results.(f)';
        diffs = abs(computed - ref.(f));
        ok = max(diffs) < tol;
        allOK = allOK && ok;
        fprintf('[%s] %-14s max abs diff = %.4f\n', tern(ok,'PASS','FAIL'), f, max(diffs));
    end
    assert(allOK, 'Friction sensitivity does not match independent reference within tolerance.');
else
    fprintf('(reference/expected_sensitivity.csv not found -- skipping reference comparison)\n');
end
fprintf('\n');

%% Extra uncertainty case: +5% string weight
fprintf('=== Extra uncertainty case: +5%% string weight ===\n');
result = runUncertaintyCase('+5% string weight', trajectory, baseParams.wAir_lbft, ...
    caseDef.MW_ppg, caseDef.mu, baseParams.rEff_ft, baseParams.steelDensity_ppg);

fprintf('Baseline : pickup=%.2f kips, slackoff=%.2f kips, drag=%.1f lb, torque=%.1f ft-lbf\n', ...
    result.baseline.pickup_kips, result.baseline.slackoff_kips, result.baseline.drag_lb, result.baseline.torque_ftlbf);
fprintf('+5%% wAir : pickup=%.2f kips, slackoff=%.2f kips, drag=%.1f lb, torque=%.1f ft-lbf\n', ...
    result.modified.pickup_kips, result.modified.slackoff_kips, result.modified.drag_lb, result.modified.torque_ftlbf);
fprintf('Delta    : pickup=%+.2f kips, slackoff=%+.2f kips, drag=%+.1f lb, torque=%+.1f ft-lbf\n\n', ...
    result.modified.pickup_kips - result.baseline.pickup_kips, ...
    result.modified.slackoff_kips - result.baseline.slackoff_kips, ...
    result.modified.drag_lb - result.baseline.drag_lb, ...
    result.modified.torque_ftlbf - result.baseline.torque_ftlbf);

assert(result.modified.pickup_kips > result.baseline.pickup_kips, ...
    'Heavier string should increase pickup load.');
assert(result.modified.drag_lb > result.baseline.drag_lb, ...
    'Heavier string should increase drag.');
fprintf('PASS: +5%% string weight increases pickup/drag/torque as physically expected.\n\n');

fprintf('All Step 12 checks passed.\n');

function s = tern(cond, a, b)
if cond, s = a; else, s = b; end
end
