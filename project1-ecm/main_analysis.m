% Project 1: Battery Simulation Using ECM
% Lawaz Islam, 110189519
% Advanced Energy Storage Systems, ELEC8900-30-R-2025F
%
% This script reproduces every result in the project report (Q1-Q4):
%   Q1: 2RC equivalent-circuit terminal voltage under step / square / sine
%       current inputs
%   Q2: Nyquist (EIS) plot of the 2RC model's impedance
%   Q3: Series/parallel pack scaling of resistance and capacity
%   Q4: Full pack simulation under UDDS and HWFET drive cycles
%       (requires UDDScurrent.mat / HWFETcurrent.mat, provided by the
%       course and not included in this repo -- see README)
%
% Verified independently in Octave 8.4.0 (see repo README for the
% verification table).

clc, clear, close all;

%% Cell-level ECM parameters (Table 1)
Delta        = 10e-3;      % simulation sampling time [s] (10 ms, per assignment Table 1)
Batt.Cbatt   = 4;         % battery capacity [Ah]
Batt.ModelID = 4;         % 2RC model
Batt.R0      = 20*1e-3;   % ohmic resistance [ohm]
Batt.R1      = 5*1e-3;    % RC1 resistance [ohm]
Batt.C1      = 2400;      % RC1 capacitance [F]
Batt.R2      = 15*1e-3;   % RC2 resistance [ohm]
Batt.C2      = 5;         % RC2 capacitance [F]

Batt.SOCsf = .175;        % SOC scaling factor (epsilon)
Batt.Kbatt = [-9.0818; 103.0870; -18.1846; 2.0625; -0.1018; -76.6037; ...
              141.1994; -1.1168];   % Combined+3 OCV model coefficients

%% Q1(a) - Step response: 0 -> -1C at t = 5s
Td = 10;
t  = (0:Delta:Td)';
I  = zeros(size(t));
I(t>=5) = -Batt.Cbatt;

V = battSIM(I, Batt, Delta);
plotVI(t,I,V);
title('Q1(a): Step current (0 -> -1C at 5s)');

%% Q1(b) - Square wave, +/-1C, 10s period, 0-60s
Td = 60;
t  = (0:Delta:Td)';
f  = 0.05;
I  = -Batt.Cbatt * sign(sin(2*pi*f*t));   % manual square wave (no signal-pkg dependency)

V = battSIM(I, Batt, Delta);
plotVI(t,I,V);
title('Q1(b): Square-wave current (+/-1C, 10s period)');

%% Q1(c) - Sinusoidal, +/-1C, 0.05 Hz
Td = 100;
t  = (0:Delta:Td)';
f  = 0.05;
I  = -Batt.Cbatt * sin(2*pi*f*t);

V = battSIM(I, Batt, Delta);
plotVI(t,I,V);
title('Q1(c): Sinusoidal current (+/-1C, 0.05Hz)');

%% Q2 - Nyquist plot of the 2RC impedance
freq  = logspace(log10(1e-3), log10(1e3), 100);
w     = 2*pi*freq;
Zfunc = @(p, w) p(1) + ...                          % R0
    p(2)./(1 + (1j*w)*p(2)*p(3)) + ...               % R1 || C1
    p(4)./(1 + (1j*w)*p(4)*p(5));                    % R2 || C2

p = [Batt.R0, Batt.R1, Batt.C1, Batt.R2, Batt.C2];
Z = Zfunc(p,w);

figure(Name='Nyquist plot');
hold on; grid on; axis('padded')
plot(real(Z),-imag(Z),'o-')
xlabel('Re(Z)'); ylabel('-Im(Z)')
title('Q2: Nyquist plot, 2RC ECM (1e-3 to 1e3 Hz)')

%% Q3 - Pack scaling (110 series, 72 parallel)
Ns = 110;
Np = 72;
R_pack = (Ns/Np) * Batt.R0;
C_pack = Batt.Cbatt * Np;
fprintf('Pack resistance R_pack = %.5f ohm\n', R_pack);
fprintf('Pack capacity   C_pack = %.1f Ah\n', C_pack);

%% Q4 - Pack simulation under UDDS and HWFET (R-int model)
% Requires UDDScurrent.mat and HWFETcurrent.mat (standard EPA drive-cycle
% current traces provided by the course). Not bundled in this repo -- see
% README for why, and Project 2 for a separate implementation of the SOC/
% capacity workflow using these same profile types.
%
% load('UDDScurrent.mat');
% t = UDDScurrent(:,1); I = UDDScurrent(:,2); Delta = mean(gradient(t));
% [V,SOC] = packSIM(I, Delta, Batt, Np, Ns);
%
% load('HWFETcurrent.mat');
% t = HWFETcurrent(:,1); I = HWFETcurrent(:,2); Delta = mean(gradient(t));
% [V,SOC] = packSIM(I, Delta, Batt, Np, Ns);
