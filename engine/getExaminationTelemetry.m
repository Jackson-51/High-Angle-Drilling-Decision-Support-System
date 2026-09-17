function telemetryRaw = getExaminationTelemetry()
%GETEXAMINATIONTELEMETRY Raw 9-stage surface telemetry as published (Section 4.4).
%   HookLoad_kips here is the PUBLISHED value. The personalized offset
%   (n mod 3) must be added separately by a later Step-8 function --
%   do not bake the offset into this table.
%
%   Output:
%       telemetryRaw - table, variables:
%           Stage, Marker, StaticMin, HookLoad_kips, Torque_ftlbf,
%           SPP_psi, Qout_pct, RPM, WOB_klbf, ROP_fthr

Stage         = (1:9)';
Marker        = {'T0';'T1';'T2';'T3';'T4';'T5';'T6';'T7';'T8'};
StaticMin     = [0;0;0;4;2;3;2;0;0];
HookLoad_kips = [292;305;328;352;382;401;416;343;312];
Torque_ftlbf  = [4950;5210;5690;6210;6980;7420;7670;5980;5440];
SPP_psi       = [1540;1605;1680;1795;1965;2140;2280;1710;1625];
Qout_pct      = [100;99;97;94;90;83;78;96;99];
RPM           = [110;110;108;104;98;92;86;90;94];
WOB_klbf      = [22;22;21;19;15;12;8;10;12];
ROP_fthr      = [41;39;35;27;18;10;4;8;14];

telemetryRaw = table(Stage, Marker, StaticMin, HookLoad_kips, Torque_ftlbf, ...
    SPP_psi, Qout_pct, RPM, WOB_klbf, ROP_fthr);

end
