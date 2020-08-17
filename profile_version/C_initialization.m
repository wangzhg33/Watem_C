A_12=Cin./(r*k1);
S_12=hAS*Cin./(r*k2);
P_12=(hAP*k1*A_12+hSP*k2*S_12)/k3;

C13C12ratio_top=deltaC13_to_ratio(deltaC13_ini_top);
C13C12ratio_bot=deltaC13_to_ratio(deltaC13_ini_bot);
C14C12ratio_top=DeltaC14_to_ratio(DeltaC14_ini_top,deltaC13_ini_top);
C14C12ratio_bot=DeltaC14_to_ratio(DeltaC14_ini_bot,deltaC13_ini_bot);

for i=1:layer_num
    C13C12_ratio_profile(i)=C13C12ratio_top-(i-1)*(C13C12ratio_top-C13C12ratio_bot)/layer_num;
    C14C12_ratio_profile(i)=C14C12ratio_top-(i-1)*(C14C12ratio_top-C14C12ratio_bot)/layer_num;
end

A_13=A_12.*C13C12_ratio_profile';
S_13=S_12.*C13C12_ratio_profile';
P_13=P_12.*C13C12_ratio_profile';

A_14=A_12.*C14C12_ratio_profile';
S_14=S_12.*C14C12_ratio_profile';
P_14=P_12.*C14C12_ratio_profile';