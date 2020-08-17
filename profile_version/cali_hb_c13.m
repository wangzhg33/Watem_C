clear;
close all;

%%% define global viables
global depth_considered depth_interval erosion_start_year erosion_end_year...
    tillage_depth deltaC13_ini_top deltaC13_ini_bot DeltaC14_ini_top DeltaC14_ini_bot...
    time_equilibrium k1 k2 k3 hAS hAP hSP r0 C_input C_input2 r_exp i_exp...
    C13_discri C14_discri deltaC13_input_default DeltaC14_input_default...
    K0 Kfzp v0 vfzp time_step unstable layer_num;

std_C=0.224;% unit %
std_C13=0.907; %unit per mil


erosion_start_year = 1910;
erosion_end_year = 2010;

% variables for C cycling
depth_interval = 5;
depth_considered = 100;

tillage_depth = 25;

deltaC13_ini_top = -27.0;
deltaC13_ini_bot = -27.0;
DeltaC14_ini_top = 50.0;
DeltaC14_ini_bot = -500.0;

time_equilibrium = 10000;
k1 = 2.1;
k2 = 0.03;
k3 = 0.002;
hAS = 0.12;
hAP = 0.01;
hSP = 0.01;
r0 = 1.035;% r0=2.07*?T-5.4)/10; T=9.5


C_input = 2; %input from root

C_input2 = 0; % input from manure, residue
r_exp = 3.30;
i_exp = 20;
C13_discri = 0.9965;
C14_discri = 0.996;
deltaC13_input_default = -30.6;
DeltaC14_input_default = 100.0;

C13_input_filename='data\C13input.txt';
C14_input_filename='data\C14input.txt';

%C_obs=importada('obs_data\);
fid=fopen('obs_data\HB_C_obs.txt');
C_obs=textscan(fid,'%f%f%f%f%f%f','headerlines',2,'delimiter','\t');
fclose(fid);

fid=fopen('obs_data\HB_C13_obs.txt');
C13_obs=textscan(fid,'%f%f%f%f%f%f','headerlines',1,'delimiter','\t');
fclose(fid);

fid=fopen('calibration\HB.txt','w');
fprintf(fid,'%s\t %s\t %s\t %s\t %s\r\n','K0','v0','ero_rate','depo_rate','RRMSE');

RRMSE=0;


for m_k=0.4:0.025:0.8    
    for m_v=0.001:0.001:0.006        
        for ero_sequence_1=-0.005:0.0005:-0.001            
            for ero_sequence_2=0.001:0.00025:0.003                
                for pro_num=1:3
                    if pro_num==1
                        ero_rate=0;
                    elseif pro_num==2
                        ero_rate=ero_sequence_1;
                    elseif pro_num==3
                        ero_rate=ero_sequence_2;
                    end
                    
                    
                    
                    K0 = m_k;
                    v0 = m_v;
                    
                    %K0 = 0.0;
                    Kfzp = 0.01;
                    
                    %v0 = 0.0;
                    vfzp = 0.01;
                    
                    time_step = 1;
                    
                    C_input=C_input*time_step;
                    C_input2=C_input2*time_step;
                    k1=k1*time_step;
                    k2=k2*time_step;
                    k3=k3*time_step;
                    
                    K0=K0*time_step;
                    v0=v0*time_step;
                    
                    unstable=false;
                    
                    %ero_rate=0.01;% positive for erosion, negative for deposition
                    
                    layer_num=round(depth_considered /depth_interval);
                    BD=1350; %bulk density kg/m3
                    
                    K_coe=K_vector(K0,Kfzp,depth_interval,layer_num);
                    v_coe=v_vector(v0,vfzp,depth_interval,layer_num);
                    r=mineralization_vector(layer_num,depth_interval,r0,r_exp);
                    Cin = Cinput_allocation(C_input,C_input2,layer_num,depth_interval,i_exp,BD);
                    C_initialization;
                    C_equilibrium;
                    carbon;
                    
                    C=A_12+A_13+A_14+S_12+S_13+S_14+P_12+P_13+P_14;                   
                    
                    C_12=A_12+S_12+P_12;
                    C_13=A_13+S_13+P_13;
                    C_14=A_14+S_14+P_14;
                    
                    PDB = 0.0112372;
                    delta_c13 = ((A_13+S_13+P_13)./(A_12+S_12+P_12)/PDB-1)*1000;
                    
                    C14C12_ratio_reference=1.176e-12;
                    ratio=C_14./C_12;
                    
                    C14C12_ratio_SN=ratio.*(1-2*(25+delta_c13)/1000);
                    
                    Delta_C14=(C14C12_ratio_SN./C14C12_ratio_reference-1)*1000;
                    
                    if pro_num==1
                        C_measured=C_obs{1};
                        C13_measured=C13_obs{1};
                    elseif pro_num==2
                        C_measured=C_obs{3};
                        C13_measured=C13_obs{3};
                    elseif pro_num==3
                        C_measured=C_obs{5};
                        C13_measured=C13_obs{5};
                    end

                    RRMSE=RRMSE+sum(((C-C_measured)/std_C).^2)+sum(((delta_c13-C13_measured)/std_C13).^2);
  
                end
                RRMSE_sr=RRMSE^(1/2);
                fprintf(fid,'%f\t %f\t %f\t %f\t %f\r\n',m_k,m_v,ero_sequence_1,ero_sequence_2,RRMSE_sr);
                RRMSE=0;
            end
        end
    end
    
    
end

fclose(fid);