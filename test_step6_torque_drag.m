%TEST_STEP6_TORQUE_DRAG Standalone check of the Step 6 torque & drag engine.
%
%   Covers Test 3 (two consecutive segments, independently verified)
%   from the project testing strategy, plus a full-table comparison
%   against an independently computed reference file (same discipline
%   as Step 4). Uses the current PLACEHOLDER serial number (n=40).
%
%   Run this file directly in MATLAB with engine/ and reference/ on the
%   path (or run from the pgg327_app/ folder as-is).

clear; clc;
addpath('engine');

%% Setup: case + trajectory
n = getStudentSerialNumber();
baseParams = getBaseParameters();
caseDef = buildCaseDefinition(n, baseParams);

fprintf('=== Case (serial n = %d, PLACEHOLDER) ===\n', n);
fprintf('MW = %.4f ppg | mu = %.4f | HL offset = %d kips\n\n', ...
    caseDef.MW_ppg, caseDef.mu, caseDef.HLOffset_kips);

rawSurvey = getExaminationSurvey();
[cleanSurvey, ~] = validateSurvey(rawSurvey);
trajectory = computeMinimumCurvature(cleanSurvey);

%% Run the T&D engine
tdResults = computeTorqueAndDrag(trajectory, baseParams.wAir_lbft, ...
    caseDef.MW_ppg, caseDef.mu, baseParams.rEff_ft, baseParams.steelDensity_ppg);
disp(tdResults);

%% Sanity check: BF
BF = computeBuoyancyFactor(caseDef.MW_ppg, baseParams.steelDensity_ppg);
fprintf('BF = %.6f (expected ~0.822901 for MW=11.6, steel=65.5)\n\n', BF);
assert(abs(BF - 0.822901) < 1e-4, 'BF does not match expected value for n=40 case.');

%% Test 3: two consecutive segments, hand/independent-calc reconciliation
fprintf('=== Test 3: two consecutive segments (MD 5000-6000 and 6000-7000) ===\n');
row6 = tdResults(tdResults.MD_ft == 6000, :);  % segment ending at MD=6000
row7 = tdResults(tdResults.MD_ft == 7000, :);  % segment ending at MD=7000

fprintf('Segment ending MD=6000: dW=%.1f lb, N=%.1f lb, Ff=%.1f lb, dT=%.1f ft-lbf\n', ...
    row6.dW_lb, row6.N_lb, row6.Ff_lb, row6.dT_ftlbf);
fprintf('Segment ending MD=7000: dW=%.1f lb, N=%.1f lb, Ff=%.1f lb, dT=%.1f ft-lbf\n\n', ...
    row7.dW_lb, row7.N_lb, row7.Ff_lb, row7.dT_ftlbf);

% Independently computed expected values (n=40 case: MW=11.6, mu=0.2525,
% wAir=21, steelDensity=65.5, rEff=0.18), reconciled by hand/Python:
%   Segment ending MD=6000: IncAvg=28.50 deg, dW=17280.9, N=8245.7, Ff=2082.0, dT=374.8
%   Segment ending MD=7000: IncAvg=42.50 deg, dW=17280.9, N=11674.8, Ff=2947.9, dT=530.6
tol = 1;  % lb / ft-lbf
assert(abs(row6.dW_lb - 17280.9) < tol, 'Segment MD=6000 dW mismatch.');
assert(abs(row6.N_lb  - 8245.7)  < tol, 'Segment MD=6000 N mismatch.');
assert(abs(row6.Ff_lb - 2082.0)  < tol, 'Segment MD=6000 Ff mismatch.');
assert(abs(row6.dT_ftlbf - 374.8) < 1, 'Segment MD=6000 dT mismatch.');

assert(abs(row7.dW_lb - 17280.9) < tol, 'Segment MD=7000 dW mismatch.');
assert(abs(row7.N_lb  - 11674.8) < tol, 'Segment MD=7000 N mismatch.');
assert(abs(row7.Ff_lb - 2947.9)  < tol, 'Segment MD=7000 Ff mismatch.');
assert(abs(row7.dT_ftlbf - 530.6) < 1, 'Segment MD=7000 dT mismatch.');
fprintf('PASS: both segments match independent hand/Python calculation.\n\n');

%% Full-table comparison against independent reference
fprintf('=== Full table vs. independent reference ===\n');
refPath = fullfile('reference', 'expected_td_results.csv');
assert(isfile(refPath), 'Reference file not found: %s', refPath);
ref = readtable(refPath);

numTol = 2;  % lb / ft-lbf -- generous enough for rounding, tight enough for bugs
fields = {'dW_lb','N_lb','Ff_lb','dT_ftlbf','cumDrag_lb','cumTorque_ftlbf','HL_PU_lb','HL_SO_lb'};
allOK = true;
for k = 1:numel(fields)
    f = fields{k};
    diffs = abs(tdResults.(f) - ref.(f));
    maxDiff = max(diffs);
    ok = maxDiff < numTol;
    allOK = allOK && ok;
    fprintf('[%s] %-16s max abs diff = %.4f\n', tern(ok,'PASS','FAIL'), f, maxDiff);
end
assert(allOK, 'MATLAB T&D output does not match the independent reference within tolerance.');

%% Surface values vs. equipment limits (informational, not pass/fail)
fprintf('\n=== Surface values vs. equipment limits (n=40 case) ===\n');
surfaceHL_PU_kips = tdResults.HL_PU_lb(end) / 1000;
surfaceTorque = tdResults.cumTorque_ftlbf(end);
fprintf('Model pickup HL at surface : %.1f kips  (limit %.0f kips)\n', ...
    surfaceHL_PU_kips, baseParams.HLlimit_kips);
fprintf('Model surface torque       : %.1f ft-lbf (limit %.0f ft-lbf)\n', ...
    surfaceTorque, baseParams.Tlimit_ftlbf);
fprintf(['NOTE: this simplified segment model is NOT expected to reproduce ' ...
    'the measured telemetry values directly -- it has no WOB/BHA term and ' ...
    'ignores buckling/contact redistribution. Compare trends and orders of ' ...
    'magnitude, not exact matches; discuss this explicitly in the report.\n']);

fprintf('\nAll Step 6 checks passed.\n');

% ----- local helper -----
function s = tern(cond, a, b)
if cond, s = a; else, s = b; end
end
