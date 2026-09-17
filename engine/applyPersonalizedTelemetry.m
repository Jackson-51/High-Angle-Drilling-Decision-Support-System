function telemetryPersonalized = applyPersonalizedTelemetry(telemetryRaw, HLOffset_kips)
%APPLYPERSONALIZEDTELEMETRY Apply the personalized hook-load offset (Section 4.3).
%
%   telemetryPersonalized = applyPersonalizedTelemetry(telemetryRaw, HLOffset_kips)
%
%   Input:
%       telemetryRaw  - table from getExaminationTelemetry.m (PUBLISHED
%                       values; HookLoad_kips not yet personalized)
%       HLOffset_kips - scalar, from caseDef.HLOffset_kips (= n mod 3)
%
%   Output:
%       telemetryPersonalized - same table, HookLoad_kips += HLOffset_kips
%                       for every row. All other columns (Torque, SPP,
%                       Qout, RPM, WOB, ROP, StaticMin) pass through
%                       UNCHANGED -- the personalization rule (Section
%                       4.3) only touches hook load.
%
%   IMPORTANT: equipment limits (HLlimit_kips etc.) are NEVER touched by
%   this function, or by personalization in general -- they live only
%   in caseDef/baseParams and are never derived from telemetry.

telemetryPersonalized = telemetryRaw;
telemetryPersonalized.HookLoad_kips = telemetryRaw.HookLoad_kips + HLOffset_kips;

end
