function trajectoryTemplate = initTrajectoryTemplate()
%INITTRAJECTORYTEMPLATE Empty typed table schema for minimum-curvature output.
%   Populated by the Step-4 minimum-curvature engine. Defined now so
%   every later function agrees on variable names/types/units before
%   any calculation code is written.
%
%   Variables (units):
%       MD_ft, Inc_deg, Az_deg   station values, pass-through
%       beta_deg                 dogleg angle (deg, reported; rad internally)
%       RF                       ratio factor (-)
%       dTVD_ft, dN_ft, dE_ft    interval increments (ft)
%       TVD_ft, N_ft, E_ft       cumulative coordinates (ft)
%       DLS_deg100ft             dogleg severity (deg/100ft)
%       Region                   vertical / build / lateral / horizontal

varNames = {'MD_ft','Inc_deg','Az_deg','beta_deg','RF', ...
            'dTVD_ft','dN_ft','dE_ft','TVD_ft','N_ft','E_ft', ...
            'DLS_deg100ft','Region'};
varTypes = {'double','double','double','double','double', ...
            'double','double','double','double','double','double', ...
            'double','string'};

trajectoryTemplate = table('Size',[0 numel(varNames)], ...
    'VariableTypes', varTypes, 'VariableNames', varNames);

end
