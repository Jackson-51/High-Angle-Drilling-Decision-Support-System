function sensTemplate = initSensitivityResultsTemplate()
%INITSENSITIVITYRESULTSTEMPLATE Empty struct schema for sensitivity output.
%   Populated by the Step-12 sensitivity engine.
%
%   Fields:
%       muList            (1x4 double)  the four friction-factor cases
%       pickup_kips       (1x4 double)  surface pickup HL per case
%       slackoff_kips     (1x4 double)  surface slack-off HL per case
%       drag_lb           (1x4 double)  total drag per case
%       torque_ftlbf      (1x4 double)  surface torque per case
%       uncertaintyCase   (string)      label of the extra case run
%                                       (e.g. '+5% string weight')
%       uncertaintyResult (struct)      same four outputs, single case

sensTemplate.muList            = [];
sensTemplate.pickup_kips       = [];
sensTemplate.slackoff_kips     = [];
sensTemplate.drag_lb           = [];
sensTemplate.torque_ftlbf      = [];
sensTemplate.uncertaintyCase   = "";
sensTemplate.uncertaintyResult = struct('pickup_kips',[],'slackoff_kips',[], ...
    'drag_lb',[],'torque_ftlbf',[]);

end
