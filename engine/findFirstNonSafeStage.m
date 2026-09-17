function stage = findFirstNonSafeStage(qcResults)
%FINDFIRSTNONSAFESTAGE Data-driven candidate flag -- NOT the graded answer.
%
%   stage = findFirstNonSafeStage(qcResults)
%
%   Returns the first stage in qcResults (which must contain only
%   stages already run -- never future ones) where Status ~= "SAFE".
%   This is a raw signal: "first stage where a threshold was crossed."
%
%   The examination's "earliest defensible intervention" (Section E) is
%   a professional judgment call that may legitimately differ from
%   this -- e.g. treating a single borderline reading with caution
%   rather than acting on it immediately is itself a defensible
%   position, provided you justify it. Use this as ONE input to your
%   own written reasoning, not as the final answer.
%
%   Returns [] if every stage in qcResults is SAFE.

idx = find(qcResults.Status ~= "SAFE", 1, 'first');
if isempty(idx)
    stage = [];
else
    stage = qcResults.Stage(idx);
end

end
