function deltas = computeStageDeltas(telemetryPersonalized, currentStage)
%COMPUTESTAGEDELTAS Quantitative stage-over-stage change (Section E aid).
%
%   deltas = computeStageDeltas(telemetryPersonalized, currentStage)
%
%   Purely numeric -- computes how much each measurement changed versus
%   the PREVIOUS stage only, via getTelemetrySlice (so it is structurally
%   impossible for this to look ahead). This is a computational aid for
%   answering Q1 ("what changed?"); it does NOT interpret or diagnose
%   anything -- that judgment is yours to write.
%
%   Output: struct with dHL_kips, dTorque_ftlbf, dSPP_psi, dQout_pct,
%   dRPM, dWOB_klbf, dROP_fthr (current - previous). All fields are NaN
%   at stage 1, since there is no previous stage to compare against.

slice = getTelemetrySlice(telemetryPersonalized, currentStage);
cur = slice(end, :);

if currentStage == 1
    deltas = struct('dHL_kips',NaN,'dTorque_ftlbf',NaN,'dSPP_psi',NaN, ...
        'dQout_pct',NaN,'dRPM',NaN,'dWOB_klbf',NaN,'dROP_fthr',NaN);
    return
end

prev = slice(end-1, :);
deltas.dHL_kips      = cur.HookLoad_kips - prev.HookLoad_kips;
deltas.dTorque_ftlbf = cur.Torque_ftlbf  - prev.Torque_ftlbf;
deltas.dSPP_psi      = cur.SPP_psi       - prev.SPP_psi;
deltas.dQout_pct     = cur.Qout_pct      - prev.Qout_pct;
deltas.dRPM          = cur.RPM           - prev.RPM;
deltas.dWOB_klbf      = cur.WOB_klbf      - prev.WOB_klbf;
deltas.dROP_fthr     = cur.ROP_fthr      - prev.ROP_fthr;

end
