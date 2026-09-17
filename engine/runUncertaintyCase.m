function result = runUncertaintyCase(caseType, trajectory, wAir_lbft, MW_ppg, mu, rEff_ft, steelDensity_ppg)
%RUNUNCERTAINTYCASE One additional quantified uncertainty case (Section F).
%
%   result = runUncertaintyCase(caseType, trajectory, wAir_lbft, MW_ppg, mu, rEff_ft, steelDensity_ppg)
%
%   Supported caseType values (case-insensitive):
%       "+5% string weight"   - wAir_lbft increased by 5%
%       "mud weight +0.5ppg"  - MW_ppg increased by 0.5 ppg
%
%   Both hold mu at its CURRENT value (personalized or otherwise) --
%   this case is about weight/mud uncertainty, not friction, which is
%   already covered by runFrictionSensitivity.m.
%
%   Output: struct with:
%       caseType  - the case label, echoed back
%       baseline  - struct: pickup_kips, slackoff_kips, drag_lb, torque_ftlbf
%       modified  - same four fields, under the perturbed input

switch lower(string(caseType))
    case "+5% string weight"
        wAirModified = wAir_lbft * 1.05;
        MWModified   = MW_ppg;
    case "mud weight +0.5ppg"
        wAirModified = wAir_lbft;
        MWModified   = MW_ppg + 0.5;
    otherwise
        error('runUncertaintyCase:unknownCase', 'Unknown caseType: %s', caseType);
end

tdBaseline = computeTorqueAndDrag(trajectory, wAir_lbft, MW_ppg, mu, rEff_ft, steelDensity_ppg);
tdModified = computeTorqueAndDrag(trajectory, wAirModified, MWModified, mu, rEff_ft, steelDensity_ppg);

result.caseType = string(caseType);
result.baseline = struct( ...
    'pickup_kips',   tdBaseline.HL_PU_lb(end) / 1000, ...
    'slackoff_kips', tdBaseline.HL_SO_lb(end) / 1000, ...
    'drag_lb',       tdBaseline.cumDrag_lb(end), ...
    'torque_ftlbf',  tdBaseline.cumTorque_ftlbf(end));
result.modified = struct( ...
    'pickup_kips',   tdModified.HL_PU_lb(end) / 1000, ...
    'slackoff_kips', tdModified.HL_SO_lb(end) / 1000, ...
    'drag_lb',       tdModified.cumDrag_lb(end), ...
    'torque_ftlbf',  tdModified.cumTorque_ftlbf(end));

end
