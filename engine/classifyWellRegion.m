function region = classifyWellRegion(Inc_deg)
%CLASSIFYWELLREGION Label each station by well-path region (Section B).
%
%   region = classifyWellRegion(Inc_deg)
%
%   This is an EDUCATIONAL, inclination-only threshold classification,
%   not a rigorous geometric/industry-standard definition -- state that
%   plainly in the report. Adjust the thresholds below if you want a
%   different convention; they are intentionally isolated in one place.
%
%   Thresholds:
%       Inc <= 2 deg         -> "Vertical"
%       2 < Inc < 60 deg      -> "Build/Deviated"
%       60 <= Inc < 85 deg    -> "Lateral-entry"
%       Inc >= 85 deg         -> "Horizontal/Lateral"

n = numel(Inc_deg);
region = strings(n,1);

for i = 1:n
    inc = Inc_deg(i);
    if inc <= 2
        region(i) = "Vertical";
    elseif inc < 60
        region(i) = "Build/Deviated";
    elseif inc < 85
        region(i) = "Lateral-entry";
    else
        region(i) = "Horizontal/Lateral";
    end
end

end
