function tdTemplate = initTDResultsTemplate()
%INITTDRESULTSTEMPLATE Empty typed table schema for torque & drag output.
%   Populated by the Step-6 torque-and-drag engine.
%
%   Variables (units):
%       MD_ft, Inc_deg          station values
%       dW_lb                   buoyed segment weight (lb)
%       N_lb                    approx. normal/contact force (lb)
%       Ff_lb                   friction force (lb)
%       dT_ftlbf                segment torque contribution (ft-lbf)
%       cumDrag_lb              cumulative drag (lb)
%       cumTorque_ftlbf         cumulative surface torque (ft-lbf)
%       HL_PU_lb, HL_SO_lb      pickup / slack-off hook load trend (lb)

varNames = {'MD_ft','Inc_deg','dW_lb','N_lb','Ff_lb','dT_ftlbf', ...
            'cumDrag_lb','cumTorque_ftlbf','HL_PU_lb','HL_SO_lb'};
varTypes = repmat({'double'}, 1, numel(varNames));

tdTemplate = table('Size',[0 numel(varNames)], ...
    'VariableTypes', varTypes, 'VariableNames', varNames);

end
