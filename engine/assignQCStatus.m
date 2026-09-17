function [status, controllingTrigger] = assignQCStatus(U_H, U_T, U_P, Qout_pct, params)
%ASSIGNQCSTATUS Eq (17): SAFE / CAUTION / CRITICAL + an EXPLAINED trigger.
%
%   [status, controllingTrigger] = assignQCStatus(U_H, U_T, U_P, Qout_pct, params)
%
%   Input:
%       U_H, U_T, U_P - utilization ratios from computeUtilization.m
%       Qout_pct      - measured flow-out efficiency, %
%       params        - struct: cautionLow (0.80), criticalHigh (1.00),
%                       QoutCaution (95), QoutCritical (85)
%
%   Output:
%       status             - "SAFE" | "CAUTION" | "CRITICAL"
%       controllingTrigger - string naming WHICH measurement(s) drove
%                            the assigned status. Section D explicitly
%                            requires this ("a colored lamp alone
%                            receives limited credit") -- a lamp with no
%                            explanation is not enough.
%
%   Design: utilization and flow-out are evaluated as two independent
%   severity tracks (SAFE=1, CAUTION=2, CRITICAL=3); the overall status
%   is the WORSE of the two, and the controlling-trigger string lists
%   only the track(s) that are actually AT that worst severity level --
%   so a case like Stage 6 (flow-out critical while hook-load/torque
%   are merely at caution) correctly reports flow-out as the sole
%   controlling trigger, not the caution-level mechanical values.

Umax = max([U_H, U_T, U_P]);
[~, idx] = max([U_H, U_T, U_P]);
utilLabels = {'U_H (hook load)', 'U_T (torque)', 'U_P (SPP)'};
utilLabel = utilLabels{idx};

if Umax >= params.criticalHigh
    utilLevel = 3;
elseif Umax >= params.cautionLow
    utilLevel = 2;
else
    utilLevel = 1;
end

if Qout_pct < params.QoutCritical
    flowLevel = 3;
elseif Qout_pct < params.QoutCaution
    flowLevel = 2;
else
    flowLevel = 1;
end

overallLevel = max(utilLevel, flowLevel);
levelNames = {'SAFE','CAUTION','CRITICAL'};
status = levelNames{overallLevel};

triggers = {};
if overallLevel > 1 && utilLevel == overallLevel
    triggers{end+1} = sprintf('%s = %.3f', utilLabel, Umax);
end
if overallLevel > 1 && flowLevel == overallLevel
    triggers{end+1} = sprintf('Qout = %.0f%%', Qout_pct);
end

if isempty(triggers)
    controllingTrigger = "None -- all indicators within SAFE band";
else
    controllingTrigger = string(strjoin(triggers, '; '));
end

end
