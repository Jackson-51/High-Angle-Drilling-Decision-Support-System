function surveyRaw = getExaminationSurvey()
%GETEXAMINATIONSURVEY Raw MD-Inc-Az survey exactly as published (Section 4.1).
%   This is the *raw* station data. It must be run through the
%   minimum-curvature engine (Step 4) -- do not hand-type calculated
%   trajectory columns (examination requirement, Section 4.1).
%
%   Output:
%       surveyRaw - table, variables:
%           MD_ft   (ft)  measured depth
%           Inc_deg (deg) inclination
%           Az_deg  (deg) azimuth

MD_ft   = [0;1000;2000;3000;4000;5000;6000;7000;8000;9000;10000;11000];
Inc_deg = [0;0;0;6;12;22;35;50;68;82;88;90];
Az_deg  = [0;0;0;35;40;48;60;72;82;89;90;90];

surveyRaw = table(MD_ft, Inc_deg, Az_deg);

end
