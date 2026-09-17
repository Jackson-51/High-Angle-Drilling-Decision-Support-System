%TEST_STEP10_DECISION Standalone check of the Step 10 decision-engine mechanism.
%
%   Demonstrates the SOFTWARE MECHANICS only: rationale packaging, the
%   stage-gate, quantitative deltas, and the two data-driven candidate
%   flags. The six-question TEXT used below is a SAMPLE placeholder to
%   prove the code works -- it is NOT engineering analysis and must not
%   be submitted as your answer. Replace it with your own reasoning
%   when you wire this into the app in Step 11.
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

%% Rebuild the Step 9 QC progression (needed as input to this step's helpers)
qcResults = initQCResultsTemplate();
for stage = 1:9
    qcResults = [qcResults; runQCForStage(telemetry, stage, limits, qcParams)]; %#ok<AGROW>
end

%% --- Gate logic: blocked with no rationale, unblocked once complete ---
fprintf('=== Stage-gate mechanics ===\n');
decisionLog = initDecisionLogTemplate();

[canGo, msg] = canAdvanceStage(decisionLog, 1);
fprintf('Before any rationale recorded: canAdvance=%d ("%s")\n', canGo, msg);
assert(canGo == false, 'Should be blocked with no rationale recorded.');

% INCOMPLETE sample -- one field left blank on purpose, to prove the
% gate catches partial answers too, not just totally empty ones.
incompleteRow = buildStageRationale(1, "Stable baseline, first reading.", ...
    "", "SAFE", "", "", "");
decisionLogPartial = [decisionLog; incompleteRow];
[canGo, msg] = canAdvanceStage(decisionLogPartial, 1);
fprintf('With PARTIAL rationale (some fields blank): canAdvance=%d ("%s")\n', canGo, msg);
assert(canGo == false, 'Should still be blocked with an incomplete rationale.');

% SAMPLE, placeholder-only, all six fields filled -- structural test ONLY.
sampleRow = buildStageRationale(1, ...
    "SAMPLE placeholder -- replace with your own Q1 answer.", ...
    "SAMPLE placeholder -- replace with your own Q2 answer.", ...
    "SAMPLE placeholder -- replace with your own Q3 answer.", ...
    "SAMPLE placeholder -- replace with your own Q4 answer.", ...
    "SAMPLE placeholder -- replace with your own Q5 answer.", ...
    "SAMPLE placeholder -- replace with your own Q6 answer.");
decisionLogComplete = [decisionLog; sampleRow];
[canGo, msg] = canAdvanceStage(decisionLogComplete, 1);
fprintf('With ALL SIX fields filled (sample text): canAdvance=%d\n', canGo);
assert(canGo == true, 'Should be unblocked once all six fields are non-empty.');
fprintf('PASS: gate correctly blocks empty/partial rationale, unblocks complete rationale.\n\n');

%% --- Quantitative deltas (numeric aid, not interpretation) ---
fprintf('=== Stage-over-stage deltas (numeric only) ===\n');
for stage = 1:9
    d = computeStageDeltas(telemetry, stage);
    if stage == 1
        fprintf('Stage %d: (no previous stage)\n', stage);
    else
        fprintf('Stage %d: dHL=%+.0f kips  dTorque=%+.0f ft-lbf  dSPP=%+.0f psi  dQout=%+.0f%%  dROP=%+.0f ft/hr\n', ...
            stage, d.dHL_kips, d.dTorque_ftlbf, d.dSPP_psi, d.dQout_pct, d.dROP_fthr);
    end
end
fprintf('\n');

%% --- Data-driven candidate flags (signals, not final answers) ---
fprintf('=== Candidate flags (inputs to YOUR reasoning, not the final answer) ===\n');
firstFlagStage = findFirstNonSafeStage(qcResults);
peakUtilStage  = findPeakUtilizationStage(qcResults);
fprintf('First stage where status leaves SAFE : Stage %d\n', firstFlagStage);
fprintf('Stage with highest Umax              : Stage %d (Umax=%.3f)\n', ...
    peakUtilStage, qcResults.Umax(qcResults.Stage == peakUtilStage));
fprintf(['NOTE: these are candidate signals only. Your "earliest defensible ' ...
    'intervention" and "worst stage" answers (Section E) must weigh the full ' ...
    'picture -- convergence of indicators, flow-out trend, ROP/WOB decline -- ' ...
    'and must be defended using only information available up to that stage.\n']);

fprintf('\nAll Step 10 mechanism checks passed.\n');
fprintf(['\nREMINDER: the six-question answers, earliest-intervention defense, ' ...
    'worst-stage explanation, and Stage 8/9 recovery decision are the graded, ' ...
    'individual-judgment content of Section E (20 marks). This step only built ' ...
    'the software that stores and gates that content -- writing it is on you.\n']);
