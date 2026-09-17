function tdResults = computeTorqueAndDrag(trajectory, wAir_lbft, MW_ppg, mu, rEff_ft, steelDensity_ppg)
%COMPUTETORQUEANDDRAG Orchestration wrapper for the full T&D engine (Eqs 7-15).
%
%   tdResults = computeTorqueAndDrag(trajectory, wAir_lbft, MW_ppg, mu, rEff_ft, steelDensity_ppg)
%
%   This is a THIN WRAPPER ONLY -- it contains no calculation logic of
%   its own, it just calls the four independently-testable functions
%   below in sequence. If you find yourself adding a formula directly
%   here, it belongs in one of those four functions instead
%   (architecture rule: UI/orchestration never computes).
%
%   Calls, in order:
%       computeBuoyancyFactor  (Eq 7)
%       computeSegmentForces   (Eqs 8-11, 13a)
%       accumulateDragTorque   (Eqs 12, 13b)
%       computeHookLoadTrends  (Eqs 14-15)
%
%   Output: tdResults - table matching initTDResultsTemplate.m schema.

if nargin < 6 || isempty(steelDensity_ppg)
    base = getBaseParameters();
    steelDensity_ppg = base.steelDensity_ppg;
end

BF = computeBuoyancyFactor(MW_ppg, steelDensity_ppg);
tdResults = computeSegmentForces(trajectory, wAir_lbft, BF, mu, rEff_ft);
tdResults = accumulateDragTorque(tdResults);
tdResults = computeHookLoadTrends(tdResults);

end
