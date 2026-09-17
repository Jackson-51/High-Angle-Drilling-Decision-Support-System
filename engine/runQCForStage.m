function qcRow = runQCForStage(telemetryPersonalized, currentStage, limits, params)
%RUNQCFORSTAGE Orchestration wrapper: QC result for ONE stage.
%
%   qcRow = runQCForStage(telemetryPersonalized, currentStage, limits, params)
%
%   Thin wrapper only. Goes through getTelemetrySlice.m even though QC
%   only needs the current stage's own row -- this keeps ONE consistent
%   access pattern for telemetry across the whole project (nothing ever
%   reads telemetryPersonalized directly), so the no-hindsight rule
%   can't be bypassed by a shortcut later.
%
%   Output: qcRow - single-row table matching initQCResultsTemplate.m

slice = getTelemetrySlice(telemetryPersonalized, currentStage);
row = slice(end, :);  % the current stage's own data only

[U_H, U_T, U_P, Umax] = computeUtilization(row.HookLoad_kips, row.Torque_ftlbf, ...
    row.SPP_psi, limits);
[status, trigger] = assignQCStatus(U_H, U_T, U_P, row.Qout_pct, params);

qcRow = table(row.Stage, U_H, U_T, U_P, Umax, string(status), trigger, ...
    'VariableNames', {'Stage','U_H','U_T','U_P','Umax','Status','ControllingTrigger'});

end
