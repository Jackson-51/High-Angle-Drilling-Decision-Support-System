function tdPartial = computeSegmentForces(trajectory, wAir_lbft, BF, mu, rEff_ft)
%COMPUTESEGMENTFORCES Eqs (8)-(11) and (13a): per-segment buoyed weight,
%   normal/contact force, friction force, and torque contribution.
%
%   tdPartial = computeSegmentForces(trajectory, wAir_lbft, BF, mu, rEff_ft)
%
%   Input:
%       trajectory - table from computeMinimumCurvature.m (MD_ft,
%                    Inc_deg columns used; one row per station)
%       wAir_lbft  - drillstring air weight (lb/ft), scalar
%       BF         - buoyancy factor (-), scalar, from computeBuoyancyFactor
%       mu         - friction factor (-), scalar. ALWAYS pass this
%                    explicitly -- never read it implicitly from a case
%                    struct inside this function -- so the sensitivity
%                    engine (Step 12) can override it cleanly per run.
%       rEff_ft    - effective pipe radius (ft), scalar
%
%   Output:
%       tdPartial - table, one row per station (row 1 = zero, matching
%                   the trajectory table convention -- there is no
%                   interval before the first station):
%           MD_ft, Inc_deg   (pass-through)
%           dW_lb            Eq (9)  buoyed segment weight
%           N_lb             Eq (10) approximate normal/contact force
%           Ff_lb            Eq (11) friction force
%           dT_ftlbf         Eq (13a) segment torque contribution
%
%   ASSUMPTION (stated explicitly -- the examination's equation
%   notation does not pin this down): "I_i" in Eq (10) is taken as the
%   AVERAGE inclination across the segment (mean of the two bounding
%   stations), consistent with the averaging convention already used
%   for cos(I_i)+cos(I_i+1) in the minimum-curvature TVD equation
%   (Eq 3). Using a single station's inclination instead is an equally
%   defensible alternative -- change the one line marked below if you
%   want that convention instead.
%
%   LIMITATION: this simplified model uses inclination only and
%   ignores azimuth change, curvature/stiffness, buckling, and contact
%   redistribution -- consistent with the examination's explicit
%   statement that Weeks 3-4 use a transparent first-order model, not
%   a full stiff-string/buckling-aware commercial model.

w_b = BF * wAir_lbft;  % Eq (8)

MD_ft   = trajectory.MD_ft;
Inc_deg = trajectory.Inc_deg;
n = numel(MD_ft);

dW_lb    = zeros(n,1);
N_lb     = zeros(n,1);
Ff_lb    = zeros(n,1);
dT_ftlbf = zeros(n,1);

for i = 2:n
    dMD = MD_ft(i) - MD_ft(i-1);
    incAvg_deg = (Inc_deg(i-1) + Inc_deg(i)) / 2;   % <- assumption line
    incAvg_rad = deg2rad(incAvg_deg);

    dw     = w_b * dMD;                 % Eq (9)
    nforce = dw * sin(incAvg_rad);      % Eq (10), simplified approximation
    ff     = mu * nforce;               % Eq (11)
    dt     = ff * rEff_ft;              % Eq (13a)

    dW_lb(i)    = dw;
    N_lb(i)     = nforce;
    Ff_lb(i)    = ff;
    dT_ftlbf(i) = dt;
end

tdPartial = table(MD_ft, Inc_deg, dW_lb, N_lb, Ff_lb, dT_ftlbf);

end
