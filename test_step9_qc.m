%TEST_STEP9_QC Standalone check of the Step 9 QC engine.
%
%   Runs QC progressively, stage by stage (simulating "Run Stage" clicks
%   in the eventual app), and checks the resulting SAFE/CAUTION/CRITICAL
%   sequence against independently hand-verified expected statuses for
%   the n=40 placeholder case. This sequence should also visibly track
%   the exam's own narrative description of each stage (Section 4.4).
%
%   Run this file directly in MATLAB with engine/ on the path.

clear; clc;
addpath('engine');

n = getStudentSerialNumber();
baseParams = getBaseParameters();
caseDef = buildCaseDefinition(n, baseParams);

limits = struct('HLlimit_kips', caseDef.HLlimit_kips, ...
                 'Tlimit_ftlbf', caseDef.Tlimit_ftlbf, ...
                 'SPPlimit_psi', caseDef.SPPlimit_psi);
qcParams = struct('cautionLow', baseParams.cautionLow, ...
                   'criticalHigh', baseParams.criticalHigh, ...
                   'QoutCaution', baseParams.QoutCaution, ...
                   'QoutCritical', baseParams.QoutCritical);

rawTelemetry = getExaminationTelemetry();
telemetry = applyPersonalizedTelemetry(rawTelemetry, caseDef.HLOffset_kips);

%% Independently hand-verified expected statuses (n=40 case: +1 kip offset)
expectedStatus = ["SAFE","SAFE","CAUTION","CAUTION","CAUTION","CRITICAL","CRITICAL","CAUTION","SAFE"];

fprintf('=== QC progression, revealed stage by stage (n=%d case) ===\n', n);
qcResults = initQCResultsTemplate();
for stage = 1:9
    qcRow = runQCForStage(telemetry, stage, limits, qcParams);
    qcResults = [qcResults; qcRow]; %#ok<AGROW>

    fprintf('Stage %d [%s]: U_H=%.3f U_T=%.3f U_P=%.3f Umax=%.3f | %s\n', ...
        stage, qcRow.Status, qcRow.U_H, qcRow.U_T, qcRow.U_P, qcRow.Umax, ...
        qcRow.ControllingTrigger);

    assert(qcRow.Status == expectedStatus(stage), ...
        'Stage %d: expected status %s but got %s.', stage, expectedStatus(stage), qcRow.Status);
end
fprintf('\nPASS: all 9 stages match independently verified expected status.\n\n');

%% Test 5 (from the testing strategy): threshold transitions
fprintf('=== Test 5: utilization threshold transitions ===\n');
% Just under caution (0.799) should be SAFE if Qout is also fine
[s, ~] = assignQCStatus(0.799, 0.5, 0.5, 100, qcParams);
assert(s == "SAFE", 'Umax=0.799 with good Qout should be SAFE.');
% Exactly at caution boundary (0.80) should be CAUTION
[s, ~] = assignQCStatus(0.80, 0.5, 0.5, 100, qcParams);
assert(s == "CAUTION", 'Umax=0.80 exactly should be CAUTION (boundary is inclusive).');
% Exactly at critical boundary (1.00) should be CRITICAL
[s, ~] = assignQCStatus(1.00, 0.5, 0.5, 100, qcParams);
assert(s == "CRITICAL", 'Umax=1.00 exactly should be CRITICAL (boundary is inclusive).');
% Qout exactly 95 should NOT trigger caution (threshold is <95)
[s, ~] = assignQCStatus(0.5, 0.5, 0.5, 95, qcParams);
assert(s == "SAFE", 'Qout=95 exactly should still be SAFE (caution is <95, not <=95).');
% Qout exactly 85 should NOT trigger critical (threshold is <85), should be CAUTION-band via 85<=Qout<95? 85 is not <95 boundary... check: Qout=85 -> not <85 (critical false), and 85<95 -> caution true
[s, ~] = assignQCStatus(0.5, 0.5, 0.5, 85, qcParams);
assert(s == "CAUTION", 'Qout=85 exactly should be CAUTION (85 <= Qout < 95 band).');
fprintf('PASS: all threshold boundary transitions behave as specified in Eq (17).\n\n');

fprintf('All Step 9 checks passed.\n');
