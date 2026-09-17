function params = getBaseParameters()
%GETBASEPARAMETERS Fixed examination base parameters (Section 4.2).
%   These values are NOT altered by personalization. Equipment limits
%   must remain exactly as published regardless of student serial number.
%
%   Output:
%       params - struct with fields (units noted):
%           BitDepth_ft         (ft)    bit depth at situation start
%           MW_base_ppg         (ppg)   base mud weight
%           wAir_lbft           (lb/ft) drillstring air weight
%           steelDensity_ppg    (ppg)   steel density equivalent for BF
%           mu_base             (-)     base friction factor
%           muSensitivity       (-)     1x4 friction sensitivity cases
%           rEff_ft             (ft)    effective pipe radius for torque
%           HLlimit_kips        (kips)  hook-load limit
%           Tlimit_ftlbf        (ft-lbf) surface torque limit
%           SPPlimit_psi        (psi)   standpipe pressure limit
%           cautionLow          (-)     caution band lower utilization (0.80)
%           criticalHigh        (-)     critical utilization trigger (1.00)
%           QoutCaution         (%)     caution flow-out threshold (95)
%           QoutCritical        (%)     critical flow-out threshold (85)

params.BitDepth_ft      = 11000;
params.MW_base_ppg      = 11.6;
params.wAir_lbft        = 21.0;
params.steelDensity_ppg = 65.5;
params.mu_base          = 0.26;
params.muSensitivity    = [0.22 0.26 0.30 0.34];
params.rEff_ft          = 0.18;
params.HLlimit_kips     = 410;
params.Tlimit_ftlbf     = 7500;
params.SPPlimit_psi     = 2250;
params.cautionLow       = 0.80;
params.criticalHigh     = 1.00;
params.QoutCaution      = 95;
params.QoutCritical     = 85;

end
