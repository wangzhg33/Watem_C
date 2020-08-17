if depositionrate>0.00001 %scenario of deposition
    for t=startyear:endyear

        depositionlayer=floor(depositionrate/depthinterval);
        deltah=mod(depositionrate,depthinterval);

        Atem=AC0;
        Stem=SC0;
        Ptem=PC0;
        if  depositionlayer
            for i=1:depositionlayer
                AC0(i)=Atem(1);
                SC0(i)=Stem(1);
                PC0(i)=Ptem(1);
            end
        end
        AC0(depositionlayer+1)=deltah*(1/depthinterval)*Atem(1)+(depthinterval-deltah)*(1/depthinterval)*Atem(1);
        SC0(depositionlayer+1)=deltah*(1/depthinterval)*Stem(1)+(depthinterval-deltah)*(1/depthinterval)*Stem(1);
        PC0(depositionlayer+1)=deltah*(1/depthinterval)*Ptem(1)+(depthinterval-deltah)*(1/depthinterval)*Ptem(1);
        for i=(depositionlayer+2):(depthinterval*(1/depthinterval)):layernumber
            AC0(i)=deltah*(1/depthinterval)*Atem(i-1-depositionlayer)+(depthinterval-deltah)*(1/depthinterval)*Atem(i-depositionlayer);
            SC0(i)=deltah*(1/depthinterval)*Stem(i-1-depositionlayer)+(depthinterval-deltah)*(1/depthinterval)*Stem(i-depositionlayer);
            PC0(i)=deltah*(1/depthinterval)*Ptem(i-1-depositionlayer)+(depthinterval-deltah)*(1/depthinterval)*Ptem(i-depositionlayer);
        end
        A(:,t)=Ass+(AC0-Ass).*exp(-k1*r);
        S(:,t)=Sss+(SC0-Sss-hAS*(k1*r.*AC0-Cinput)./(r*(k2-k1))).*exp(-k2*r)+...
            (hAS*(k1*r.*AC0-Cinput)./(r*(k2-k1))).*exp(-k1*r);
        P(:,t)=(hAP*k1*r.*(Cinput/k1./r+(AC0-Cinput/k1./r).*exp(-k1*r))+...
            hSP*k2*r.*(hAS*k1*(Cinput/k1./r+(AC0-Cinput/k1./r).*exp(-k1*r))/k2+...
            (SC0-hAS*k1.*(Cinput/k1./r+(AC0-Cinput/k1./r).*exp(-k1*r))/k2).*exp(-k2*r)))/k3./r+...
            (PC0-(hAP*k1*r.*(Cinput/k1./r+(AC0-Cinput/k1./r).*exp(-k1*r))+...
            hSP*k2*r.*(hAS*k1*(Cinput/k1./r+(AC0-Cinput/k1./r).*exp(-k1*r))/k2+...
            (SC0-hAS*k1*(Cinput/k1./r+(AC0-Cinput/k1./r).*exp(-k1*r))/k2).*exp(-k2*r)))/k3./r).*exp(-k3*r);
    end
else %scenario of deposition
    for t=startyear:endyear
        depositionlayer=-ceil(depositionrate/depthinterval);
        deltah=mod(depositionrate,depthinterval);

        Atem=AC0;
        Stem=SC0;
        Ptem=PC0;

        for i=1:(layernumber-depositionlayer-1)
            AC0(i)=deltah*(1/depthinterval)*Atem(depositionlayer+i)+(depthinterval-deltah)*(1/depthinterval)*Atem(depositionlayer+i+1);
            SC0(i)=deltah*(1/depthinterval)*Stem(depositionlayer+i)+(depthinterval-deltah)*(1/depthinterval)*Stem(depositionlayer+i+1);
            PC0(i)=deltah*(1/depthinterval)*Ptem(depositionlayer+i)+(depthinterval-deltah)*(1/depthinterval)*Ptem(depositionlayer+i+1);
        end
        AC0(layernumber-depositionlayer)=Atem(layernumber);
        SC0(layernumber-depositionlayer)=Stem(layernumber);
        PC0(layernumber-depositionlayer)=Ptem(layernumber);
        if depositionlayer
            for i=(layernmuber-depositionlayer+1):layernumber
                AC0(i)=Atem(layernumber);
                SC0(i)=Stem(layernumber);
                PC0(i)=Ptem(layernumber);
            end
        end
        A(:,t)=Ass+(AC0-Ass).*exp(-k1*r);
        S(:,t)=Sss+(SC0-Sss-hAS*(k1*r.*AC0-Cinput)./(r*(k2-k1))).*exp(-k2*r)+...
            (hAS*(k1*r.*AC0-Cinput)./(r*(k2-k1))).*exp(-k1*r);
        P(:,t)=(hAP*k1*r.*(Cinput/k1./r+(AC0-Cinput/k1./r).*exp(-k1*r))+...
            hSP*k2*r.*(hAS*k1*(Cinput/k1./r+(AC0-Cinput/k1./r).*exp(-k1*r))/k2+...
            (SC0-hAS*k1.*(Cinput/k1./r+(AC0-Cinput/k1./r).*exp(-k1*r))/k2).*exp(-k2*r)))/k3./r+...
            (PC0-(hAP*k1*r.*(Cinput/k1./r+(AC0-Cinput/k1./r).*exp(-k1*r))+...
            hSP*k2*r.*(hAS*k1*(Cinput/k1./r+(AC0-Cinput/k1./r).*exp(-k1*r))/k2+...
            (SC0-hAS*k1*(Cinput/k1./r+(AC0-Cinput/k1./r).*exp(-k1*r))/k2).*exp(-k2*r)))/k3./r).*exp(-k3*r);
    end
end

