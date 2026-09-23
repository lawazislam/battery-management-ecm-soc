function [V,SOC] = packSIM(I, Delta,Batt,Np,Ns)
C_pack = Batt.Cbatt*Np;
R_pack = (Ns/Np)*Batt.R0;

SOC = zeros(size(I)); SOC(1)=.5;
for k=2:length(I)
    SOC(k)= SOC(k-1) + (1/(3600*C_pack))*I(k)*Delta;
end

% Determination of OCV
E = Batt.SOCsf; % scaling factor
Kbatt = Batt.Kbatt;
K0 = Kbatt(1); K1 = Kbatt(2); K2 = Kbatt(3);
K3 = Kbatt(4); K4 = Kbatt(5); K5 = Kbatt(6);
K6 = Kbatt(7); K7 = Kbatt(8);

zs = (1 - 2*E)*SOC + E;

Vo = K0+K1./zs + K2./(zs.^2) + K3./(zs.^3)+K4./(zs.^4) + K5*zs + K6*log(zs) + K7*log(1-zs);

V    = Ns*Vo + (Ns/Np)*R_pack*I;
end
