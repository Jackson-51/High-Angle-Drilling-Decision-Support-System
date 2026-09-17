function [canAdvance, msg] = canAdvanceStage(decisionLog, stage)
%CANADVANCESTAGE Stage-gate check (Section D: block advancement until
%   a rationale is recorded).
%
%   [canAdvance, msg] = canAdvanceStage(decisionLog, stage)
%
%   Returns true only if decisionLog contains a row for `stage` with
%   Confirmed == true. This is the function the "Next Stage" button
%   callback (Step 11) must call before incrementing app.CurrentStage --
%   it must refuse to advance and show msg via uialert if false.

rowIdx = decisionLog.Stage == stage;

if ~any(rowIdx)
    canAdvance = false;
    msg = sprintf('No rationale recorded yet for stage %d.', stage);
    return
end

if decisionLog.Confirmed(rowIdx)
    canAdvance = true;
    msg = '';
else
    canAdvance = false;
    msg = sprintf('Stage %d rationale is incomplete -- all six questions must be answered.', stage);
end

end
