function trajectory = computeMinimumCurvature(surveyClean)
%COMPUTEMINIMUMCURVATURE Minimum-curvature trajectory calc (Eqs 1-6).
%
%   trajectory = computeMinimumCurvature(surveyClean)
%
%   Input:
%       surveyClean - VALIDATED table (output of validateSurvey.m) with
%                     variables MD_ft, Inc_deg, Az_deg, MD strictly
%                     increasing.
%
%   Output:
%       trajectory - table, schema = initTrajectoryTemplate.m, ONE ROW
%                    PER STATION (not per interval). Row i holds the
%                    increment/DLS for the interval ENDING at station i;
%                    row 1 (the first station) is the start point and
%                    carries zero increments by definition -- there is
%                    no interval before it.
%
%   Convention: radians used internally for all trig; beta and DLS are
%   converted back to degrees only for the reported output (per the
%   examination's explicit instruction in Section 6).
%
%   Numerical note: cosBeta is clamped to [-1,1] before acos() to guard
%   against floating-point rounding pushing a value marginally outside
%   that domain (e.g. 1.0000000002), which would otherwise return a
%   complex number instead of erroring loudly.

MD_ft   = surveyClean.MD_ft;
Inc_deg = surveyClean.Inc_deg;
Az_deg  = surveyClean.Az_deg;
n = numel(MD_ft);

beta_deg     = zeros(n,1);
RF           = ones(n,1);
dTVD_ft      = zeros(n,1);
dN_ft        = zeros(n,1);
dE_ft        = zeros(n,1);
DLS_deg100ft = zeros(n,1);
TVD_ft       = zeros(n,1);
N_ft         = zeros(n,1);
E_ft         = zeros(n,1);

Inc_rad = deg2rad(Inc_deg);
Az_rad  = deg2rad(Az_deg);

for i = 2:n
    dMD = MD_ft(i) - MD_ft(i-1);
    I1 = Inc_rad(i-1); I2 = Inc_rad(i);
    A1 = Az_rad(i-1);  A2 = Az_rad(i);

    % --- Eq (1): dogleg angle ---
    cosBeta = cos(I1)*cos(I2) + sin(I1)*sin(I2)*cos(A2 - A1);
    cosBeta = min(1, max(-1, cosBeta));  % numerical safety clamp
    beta = acos(cosBeta);  % rad

    % --- Eq (2): ratio factor ---
    if beta == 0
        rf = 1;
    else
        rf = (2/beta) * tan(beta/2);
    end

    % --- Eq (3)-(5): coordinate increments ---
    dtvd = (dMD/2) * (cos(I1) + cos(I2)) * rf;
    dn   = (dMD/2) * (sin(I1)*cos(A1) + sin(I2)*cos(A2)) * rf;
    de   = (dMD/2) * (sin(I1)*sin(A1) + sin(I2)*sin(A2)) * rf;

    % --- Eq (6): dogleg severity, deg/100ft ---
    if dMD == 0
        dls = 0;  % degenerate interval; should not occur post-validation
    else
        dls = (rad2deg(beta) / dMD) * 100;
    end

    beta_deg(i)     = rad2deg(beta);
    RF(i)            = rf;
    dTVD_ft(i)       = dtvd;
    dN_ft(i)         = dn;
    dE_ft(i)         = de;
    DLS_deg100ft(i)  = dls;

    TVD_ft(i) = TVD_ft(i-1) + dtvd;
    N_ft(i)   = N_ft(i-1) + dn;
    E_ft(i)   = E_ft(i-1) + de;
end

Region = classifyWellRegion(Inc_deg);

trajectory = table(MD_ft, Inc_deg, Az_deg, beta_deg, RF, dTVD_ft, dN_ft, dE_ft, ...
    TVD_ft, N_ft, E_ft, DLS_deg100ft, Region);

end
