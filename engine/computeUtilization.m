function [U_H, U_T, U_P, Umax] = computeUtilization(HL_meas_kips, T_meas_ftlbf, SPP_meas_psi, limits)
%COMPUTEUTILIZATION Eq (16): dimensionless utilization ratios.
%
%   [U_H, U_T, U_P, Umax] = computeUtilization(HL_meas_kips, T_meas_ftlbf, SPP_meas_psi, limits)
%
%   Input:
%       HL_meas_kips   - measured (personalized) hook load, kips
%       T_meas_ftlbf   - measured torque, ft-lbf
%       SPP_meas_psi   - measured standpipe pressure, psi
%       limits         - struct: HLlimit_kips, Tlimit_ftlbf, SPPlimit_psi
%                        (ALWAYS the unchanged published limits -- never
%                        personalized, per Section 4.3)
%
%   Output:
%       U_H, U_T, U_P  - individual utilization ratios (-)
%       Umax           - max(U_H, U_T, U_P)

U_H = HL_meas_kips  / limits.HLlimit_kips;
U_T = T_meas_ftlbf  / limits.Tlimit_ftlbf;
U_P = SPP_meas_psi  / limits.SPPlimit_psi;
Umax = max([U_H, U_T, U_P]);

end
