function tdPartial = computeHookLoadTrends(tdPartial)
%COMPUTEHOOKLOADTRENDS Eqs (14)-(15): pickup and slack-off hook-load trend.
%
%   tdPartial = computeHookLoadTrends(tdPartial)
%
%   BOUNDARY CONDITION (stated explicitly, required by Section C):
%   HL_PU and HL_SO both start at 0 lb at MD=0 (surface, no pipe run
%   yet).
%
%   SUMMATION DIRECTION: accumulation proceeds top-down, in the SAME
%   row order as the segment table (increasing MD) -- consistent with
%   Eq (9)'s own indexing, and avoids needing a separate bottom-up pass.
%   This produces a hook-load PROFILE vs MD (needed for the required
%   "pickup/slack-off vs MD" plot): the value at each row is "the
%   surface hook load if the string currently extends to that depth."
%   The value at the LAST row (bit depth) is therefore the surface
%   hook load for the full string as run -- this is the number compared
%   against the equipment limit and against measured telemetry in the
%   QC engine (Step 9).
%
%   SIGN CONVENTION: friction ADDS to the axial load during pickup
%   (friction resists upward motion, so more force is needed at
%   surface) and SUBTRACTS during slack-off (friction resists downward
%   motion, so less force reaches surface) -- exactly as written in
%   Eqs (14)-(15).

n = height(tdPartial);
HL_PU_lb = zeros(n,1);
HL_SO_lb = zeros(n,1);

Inc_deg = tdPartial.Inc_deg;

for i = 2:n
    incAvg_rad = deg2rad((Inc_deg(i-1) + Inc_deg(i)) / 2);
    axialWeightComponent = tdPartial.dW_lb(i) * cos(incAvg_rad);

    HL_PU_lb(i) = HL_PU_lb(i-1) + axialWeightComponent + tdPartial.Ff_lb(i);  % Eq (14)
    HL_SO_lb(i) = HL_SO_lb(i-1) + axialWeightComponent - tdPartial.Ff_lb(i);  % Eq (15)
end

tdPartial.HL_PU_lb = HL_PU_lb;
tdPartial.HL_SO_lb = HL_SO_lb;

end
