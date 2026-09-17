function results = runFrictionSensitivity(muList, trajectory, wAir_lbft, MW_ppg, rEff_ft, steelDensity_ppg)
%RUNFRICTIONSENSITIVITY Eqs (7)-(15) re-run across friction-factor cases (Section F).
%
%   results = runFrictionSensitivity(muList, trajectory, wAir_lbft, MW_ppg, rEff_ft, steelDensity_ppg)
%
%   Runs the FULL torque-and-drag engine once per entry in muList,
%   holding every other input fixed, and reports the SURFACE (final
%   row) values for pickup, slack-off, drag, and torque. mu is ALWAYS
%   passed explicitly into computeTorqueAndDrag -- never read from a
%   case struct -- so this sweep cannot accidentally reuse your
%   personalized mu instead of the sweep value.
%
%   Output: struct matching the friction-related fields of
%   initSensitivityResultsTemplate.m:
%       muList, pickup_kips, slackoff_kips, drag_lb, torque_ftlbf
%       (each 1xN, N = numel(muList))

n = numel(muList);
pickup_kips   = zeros(1, n);
slackoff_kips = zeros(1, n);
drag_lb       = zeros(1, n);
torque_ftlbf  = zeros(1, n);

for k = 1:n
    td = computeTorqueAndDrag(trajectory, wAir_lbft, MW_ppg, muList(k), rEff_ft, steelDensity_ppg);
    pickup_kips(k)   = td.HL_PU_lb(end) / 1000;
    slackoff_kips(k) = td.HL_SO_lb(end) / 1000;
    drag_lb(k)       = td.cumDrag_lb(end);
    torque_ftlbf(k)  = td.cumTorque_ftlbf(end);
end

results.muList        = muList;
results.pickup_kips   = pickup_kips;
results.slackoff_kips = slackoff_kips;
results.drag_lb       = drag_lb;
results.torque_ftlbf  = torque_ftlbf;

end
