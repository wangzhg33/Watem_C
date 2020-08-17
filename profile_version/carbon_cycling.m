function [A_updated,S_updated,P_updated]=carbon_cycling(k1,k2,k3,hAS,hAP,hSP,Cinput,r,A,S,P)
if nargin>11
    errordlg('Input arguements exceed');
elseif nargin<11
    errordlg('Not enough input arguments');
else
    
    Ass=Cinput./(r*k1);
    Sss=hAS*Cinput./(r*k2);
    
    A_updated=Ass+(A-Ass).*exp(-k1*r);
    S_updated=Sss+(S-Sss-hAS*(k1*r.*A-Cinput)./(r*(k2-k1))).*exp(-k2*r)+...
        (hAS*(k1*r.*A-Cinput)./(r*(k2-k1))).*exp(-k1*r);
    P_updated=(hAP*k1*r.*(Cinput/k1./r+(A-Cinput/k1./r).*exp(-k1*r))+...
        hSP*k2*r.*(hAS*k1*(Cinput/k1./r+(A-Cinput/k1./r).*exp(-k1*r))/k2+...
        (S-hAS*k1.*(Cinput/k1./r+(A-Cinput/k1./r).*exp(-k1*r))/k2).*exp(-k2*r)))/k3./r+...
        (P-(hAP*k1*r.*(Cinput/k1./r+(A-Cinput/k1./r).*exp(-k1*r))+...
        hSP*k2*r.*(hAS*k1*(Cinput/k1./r+(A-Cinput/k1./r).*exp(-k1*r))/k2+...
        (S-hAS*k1*(Cinput/k1./r+(A-Cinput/k1./r).*exp(-k1*r))/k2).*exp(-k2*r)))/k3./r).*exp(-k3*r);
end
end