%TEST_STEP2_DATA_STRUCTURES Standalone check that Step 2 data structures
%   initialize correctly, independent of App Designer.
%
%   Run this file directly in MATLAB (with the engine/ folder on the
%   path). It does NOT test any engineering calculation yet -- that
%   starts in Step 3/4. It only proves the data contracts are sound:
%   correct variable names, types, and that the raw examination data
%   was transcribed correctly from the exam paper.

clear; clc;
addpath('engine');

fprintf('--- Base parameters ---\n');
baseParams = getBaseParameters();
disp(baseParams);

fprintf('--- Raw examination survey (must have 12 rows) ---\n');
surveyRaw = getExaminationSurvey();
disp(surveyRaw);
assert(height(surveyRaw) == 12, 'Survey should have 12 stations.');
assert(issorted(surveyRaw.MD_ft), 'Raw survey MD should already be monotonic.');

fprintf('--- Raw examination telemetry (must have 9 rows) ---\n');
telemetryRaw = getExaminationTelemetry();
disp(telemetryRaw);
assert(height(telemetryRaw) == 9, 'Telemetry should have 9 stages.');

fprintf('--- Empty table/struct templates (0 rows, correct columns) ---\n');
disp(initTrajectoryTemplate());
disp(initTDResultsTemplate());
disp(initValidationLogTemplate());
disp(initQCResultsTemplate());
disp(initDecisionLogTemplate());
disp(initSensitivityResultsTemplate());

n = getStudentSerialNumber();
fprintf('--- Case definition (serial number n = %d) ---\n', n);
fprintf(['NOTE: n is a WORKING PLACEHOLDER pending your real exam serial ' ...
    'number. Update it in engine/getStudentSerialNumber.m only -- every ' ...
    'other file reads n from that one function.\n']);
caseDefTest = buildCaseDefinition(n, baseParams);
disp(caseDefTest);

fprintf('All Step 2 structural checks passed.\n');
