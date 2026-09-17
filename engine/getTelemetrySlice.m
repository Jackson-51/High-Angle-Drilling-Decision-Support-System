function telemetrySlice = getTelemetrySlice(telemetryPersonalized, currentStage)
%GETTELEMETRYSLICE Structural enforcement of the no-hindsight rule (Section E).
%
%   telemetrySlice = getTelemetrySlice(telemetryPersonalized, currentStage)
%
%   Returns ONLY rows 1:currentStage of the telemetry table. Every
%   decision-layer function (Step 10 onward) must be called with the
%   OUTPUT of this function, never with the full telemetry table --
%   that is what makes hindsight-based reasoning structurally
%   impossible rather than merely discouraged by instruction.
%
%   Input:
%       telemetryPersonalized - full 9-stage table
%       currentStage          - integer, 1..height(telemetryPersonalized)
%
%   Output:
%       telemetrySlice - table, rows 1:currentStage only

validateattributes(currentStage, {'numeric'}, ...
    {'scalar','integer','positive','<=', height(telemetryPersonalized)}, ...
    mfilename, 'currentStage');

telemetrySlice = telemetryPersonalized(1:currentStage, :);

end
