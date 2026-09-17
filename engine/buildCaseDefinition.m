function caseDef = buildCaseDefinition(serialNumber, baseParams)
%BUILDCASEDEFINITION Apply the examination's personalization rule (Section 4.3).
%
%   caseDef = buildCaseDefinition(serialNumber, baseParams)
%
%   Inputs:
%       serialNumber - positive integer, the student's attendance-sheet
%                      exam serial number (n)
%       baseParams   - struct from getBaseParameters() (optional; will
%                      be fetched automatically if omitted)
%
%   Output:
%       caseDef - struct:
%           SerialNumber     n
%           MW_ppg           personalized mud weight
%                             = MW_base + 0.02*(n mod 5)
%           mu               personalized friction factor
%                             = mu_base + 0.005*((n mod 4) - 1.5)
%           HLOffset_kips    personalized hook-load telemetry offset
%                             = (n mod 3)
%           HLlimit_kips     UNCHANGED equipment limit (traceability copy)
%           Tlimit_ftlbf     UNCHANGED equipment limit
%           SPPlimit_psi     UNCHANGED equipment limit
%
%   Equipment limits are explicitly NOT modified by personalization
%   (examination Section 4.3) -- copied through unchanged so the Case
%   Definition panel can display everything from one struct without
%   risk of a limit accidentally being touched elsewhere in the app.

if nargin < 2 || isempty(baseParams)
    baseParams = getBaseParameters();
end

validateattributes(serialNumber, {'numeric'}, {'scalar','integer','positive'}, ...
    mfilename, 'serialNumber');

caseDef.SerialNumber  = serialNumber;
caseDef.MW_ppg        = baseParams.MW_base_ppg + 0.02 * mod(serialNumber, 5);
caseDef.mu            = baseParams.mu_base + 0.005 * (mod(serialNumber, 4) - 1.5);
caseDef.HLOffset_kips = mod(serialNumber, 3);

% Equipment limits pass through UNCHANGED -- kept in caseDef only for
% single-source display in the Case Definition panel.
caseDef.HLlimit_kips  = baseParams.HLlimit_kips;
caseDef.Tlimit_ftlbf  = baseParams.Tlimit_ftlbf;
caseDef.SPPlimit_psi  = baseParams.SPPlimit_psi;

end
