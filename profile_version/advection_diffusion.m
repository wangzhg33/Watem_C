function result=advection_diffusion(K,v,C,unstable,depth_interval,layer_num)
if nargin>6
    errordlg('Input arguements exceed');
elseif nargin<6
    errordlg('Not enough input arguments');
else
    dt=1;
    dz=depth_interval;
    C_temp=zeros(layer_num+4,4);
    vz=zeros(layer_num+4);
    Kz=zeros(layer_num+4);
    
    for i=1:layer_num
        C_temp(i+2,1)=C(i);
        vz(i+2)=v(i);
        Kz(i+2)=K(i);
    end
    C_temp(layer_num+3,1)=C_temp(layer_num+2,1);
    vz(1)=vz(3); vz(2)=vz(3); vz(layer_num+3)=vz(layer_num+2);
    Kz(1)=Kz(3); Kz(2)=Kz(3); Kz(layer_num+3)=Kz(layer_num+2);
    
    N=layer_num+3;
    dzdub=2*dz;
    dzsq=dz^2;
    
    for i=2:N-1
        v_z=(vz(i+1)-vz(i-1))/dzdub;
        K_z=(Kz(i+1)-Kz(i-1))/dzdub;
        depth_1d=(C_temp(i+1,1)-C_temp(i-1,1))/dzdub;
        depth_2d=(C_temp(i+1,1)-2*C_temp(i,1)+C_temp(i-1,1))/dzsq;
        time_1D=Kz(i)*depth_2d+K_z*depth_1d-(vz(i)*depth_1d+C_temp(i,1)*v_z);
        C_temp(i,2)=time_1D*dt+C_temp(i,1);
        
    end
    C_temp(N,2)=C_temp(N-1,2);
    C_temp(3,2)=C_temp(3,2)+C_temp(2,2);
    C_temp(2,2)=0;
    
    for i=1:layer_num+3
        if C_temp(i,2)<0
            unstable=true;
        end
    end
    
    sum_C1=0;
    for i=1:layer_num
        sum_C1=sum_C1+C(i);
    end
    
    sum_C2=0;
    for i=2:layer_num+2  %%% Should it be layer_num+1 ?
        sum_C2=sum_C2+C_temp(i,2);
    end
    
    ratio=sum_C1/sum_C2;
    for i=3:layer_num+3
        C_temp(i,2)=C_temp(i,2)*ratio;
    end
    
    for i=1:layer_num
        C(i)=C_temp(i+2,2);
    end
    
    result=C;
end

end