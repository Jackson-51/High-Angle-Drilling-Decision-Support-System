function tdPartial = accumulateDragTorque(tdPartial)
%ACCUMULATEDRAGTORQUE Eqs (12)-(13b): cumulative drag and surface torque.
%
%   tdPartial = accumulateDragTorque(tdPartial)
%
%   Adds cumDrag_lb and cumTorque_ftlbf columns to the table produced by
%   computeSegmentForces.m. Both equations are plain sums over segments
%   with no recursive/directional dependency, so accumulation simply
%   follows table row order (top-down, by increasing MD). The value at
%   the LAST row is the total drag / surface torque for the full string
%   as currently run to that bit depth.

n = height(tdPartial);
cumDrag_lb      = zeros(n,1);
cumTorque_ftlbf = zeros(n,1);

for i = 2:n
    cumDrag_lb(i)      = cumDrag_lb(i-1)      + tdPartial.Ff_lb(i);    % Eq (12)
    cumTorque_ftlbf(i) = cumTorque_ftlbf(i-1) + tdPartial.dT_ftlbf(i); % Eq (13b)
end

tdPartial.cumDrag_lb      = cumDrag_lb;
tdPartial.cumTorque_ftlbf = cumTorque_ftlbf;

end
