function qcTemplate = initQCResultsTemplate()
%INITQCRESULTSTEMPLATE Empty typed table schema for per-stage QC results.
%   Populated by the Step-9 QC engine.
%
%   Variables:
%       Stage                (double)
%       U_H, U_T, U_P, Umax  (double)  utilization ratios (-)
%       Status               (string)  'SAFE'|'CAUTION'|'CRITICAL'
%       ControllingTrigger   (string)  which measurement is binding

varNames = {'Stage','U_H','U_T','U_P','Umax','Status','ControllingTrigger'};
varTypes = {'double','double','double','double','double','string','string'};

qcTemplate = table('Size',[0 numel(varNames)], ...
    'VariableTypes', varTypes, 'VariableNames', varNames);

end
