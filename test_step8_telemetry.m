%TEST_STEP8_TELEMETRY Standalone check of the Step 8 telemetry engine.
%
%   Verifies the personalization offset is applied correctly and ONLY
%   to hook load, equipment limits stay untouched, and the no-hindsight
%   slicing function structurally blocks access to future stages.
%
%   Run this file directly in MATLAB with engine/ on the path.

clear; clc;
addpath('engine');

n = getStudentSerialNumber();
baseParams = getBaseParameters();
caseDef = buildCaseDefinition(n, baseParams);

fprintf('=== Personalization (serial n = %d, PLACEHOLDER) ===\n', n);
fprintf('HL offset = %d kips\n\n', caseDef.HLOffset_kips);

%% Apply personalization
raw = getExaminationTelemetry();
personalized = applyPersonalizedTelemetry(raw, caseDef.HLOffset_kips);

fprintf('=== Raw vs personalized hook load ===\n');
disp(table(raw.Stage, raw.HookLoad_kips, personalized.HookLoad_kips, ...
    'VariableNames', {'Stage','HL_raw_kips','HL_personalized_kips'}));

assert(isequal(personalized.HookLoad_kips, raw.HookLoad_kips + caseDef.HLOffset_kips), ...
    'Personalized hook load does not equal raw + offset for every stage.');
fprintf('PASS: HL_personalized = HL_raw + %d kips for all 9 stages.\n\n', caseDef.HLOffset_kips);

%% Confirm every OTHER column is untouched
otherCols = {'Stage','Marker','StaticMin','Torque_ftlbf','SPP_psi','Qout_pct','RPM','WOB_klbf','ROP_fthr'};
for k = 1:numel(otherCols)
    c = otherCols{k};
    assert(isequal(raw.(c), personalized.(c)), ...
        'Column %s should be unchanged by personalization but was not.', c);
end
fprintf('PASS: all non-hook-load columns unchanged by personalization.\n\n');

%% Confirm equipment limits are untouched by personalization
assert(caseDef.HLlimit_kips == baseParams.HLlimit_kips, 'HL limit was altered by personalization.');
assert(caseDef.Tlimit_ftlbf == baseParams.Tlimit_ftlbf, 'Torque limit was altered by personalization.');
assert(caseDef.SPPlimit_psi == baseParams.SPPlimit_psi, 'SPP limit was altered by personalization.');
fprintf('PASS: equipment limits untouched (%.0f kips / %.0f ft-lbf / %.0f psi).\n\n', ...
    caseDef.HLlimit_kips, caseDef.Tlimit_ftlbf, caseDef.SPPlimit_psi);

%% No-hindsight slicing
fprintf('=== No-hindsight slicing (getTelemetrySlice) ===\n');
for stage = [1 3 5 9]
    slice = getTelemetrySlice(personalized, stage);
    assert(height(slice) == stage, 'Slice at stage %d should have exactly %d rows.', stage, stage);
    assert(max(slice.Stage) == stage, 'Slice at stage %d should not contain stage > %d.', stage, stage);
    fprintf('PASS: slice at stage %d has %d row(s), max stage in slice = %d.\n', ...
        stage, height(slice), max(slice.Stage));
end

% Out-of-range stage should error, not silently return something wrong
try
    getTelemetrySlice(personalized, 10);
    error('Expected getTelemetrySlice to reject stage=10 but it did not.');
catch ME
    if strcmp(ME.identifier, 'MATLAB:getTelemetrySlice:expectedNonempty') || contains(ME.message, 'currentStage')
        fprintf('PASS: stage=10 correctly rejected (out of range).\n');
    else
        rethrow(ME);
    end
end

fprintf('\nAll Step 8 checks passed.\n');
