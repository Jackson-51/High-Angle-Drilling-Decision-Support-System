function BF = computeBuoyancyFactor(MW_ppg, steelDensity_ppg)
%COMPUTEBUOYANCYFACTOR Eq (7): BF = 1 - MW/65.5
%
%   BF = computeBuoyancyFactor(MW_ppg, steelDensity_ppg)
%
%   Input:
%       MW_ppg           - mud weight (ppg)
%       steelDensity_ppg - steel density equivalent (ppg); optional,
%                          defaults to the examination's 65.5 ppg via
%                          getBaseParameters.m if omitted
%
%   Output:
%       BF - buoyancy factor, dimensionless

if nargin < 2 || isempty(steelDensity_ppg)
    base = getBaseParameters();
    steelDensity_ppg = base.steelDensity_ppg;
end

BF = 1 - (MW_ppg / steelDensity_ppg);

end
