function stage = findPeakUtilizationStage(qcResults)
%FINDPEAKUTILIZATIONSTAGE Data-driven candidate flag -- NOT the graded answer.
%
%   stage = findPeakUtilizationStage(qcResults)
%
%   Returns the stage with the highest Umax in the given qcResults
%   table (only stages already run, per the no-hindsight rule). This is
%   ONE legitimate signal for "worst stage" (Section E) -- but the exam
%   also wants you to weigh flow-out deterioration, declining ROP/WOB,
%   and the CONVERGENCE of multiple indicators. A stage with the single
%   highest Umax is not automatically the worst stage if another stage
%   shows more indicators degrading together. Use this as one input to
%   your own written reasoning, not the final answer.

[~, idx] = max(qcResults.Umax);
stage = qcResults.Stage(idx);

end
