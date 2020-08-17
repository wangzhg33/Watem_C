clear;
close all;

%%% define global viables
global depth_considered depth_interval erosion_start_year erosion_end_year...
    tillage_depth deltaC13_ini_top deltaC13_ini_bot DeltaC14_ini_top DeltaC14_ini_bot...
    time_equilibrium k1 k2 k3 hAS hAP hSP r0 C_input C_input2 r_exp i_exp...
    C13_discri C14_discri deltaC13_input_default DeltaC14_input_default...
    K0 Kfzp v0 vfzp time_step unstable layer_num;

erosion_start_year = 1900;
erosion_end_year = 1900;

% variables for C cycling
depth_interval = 5;
depth_considered = 100;

tillage_depth = 5;

deltaC13_ini_top = -27.0;
deltaC13_ini_bot = -26.0;
DeltaC14_ini_top = 50.0;
DeltaC14_ini_bot = -500.0;

time_equilibrium = 100000;
k1 = 2.1;
k2 = 0.03;
k3 = 0.002;
hAS = 0.12;
hAP = 0.01;
hSP = 0.01;
r0 = 1;
C_input = 2.0; %input from root
C_input2 = 0; % input from manure, residue
r_exp = 3.30;
i_exp = 20;
C13_discri = 0.9977;
C14_discri = 0.996;
deltaC13_input_default = -29.0;
DeltaC14_input_default = 100.0;

C13_input_filename='data\C13input.txt';
C14_input_filename='data\C14input.txt';


K0 = 0.0;
Kfzp = 0.01;
v0 = 0.0;
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

ero_rate=0.01;% positive for erosion, negative for deposition

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

figure(1)
h=plot(C,(0.5:length(C)-0.5)*depth_interval);
set(h,'linestyle','none','marker','o','markerfacecolor','k','markeredgecolor','k');
set(gca,'ydir','reverse','xaxislocation','top','xlim',[-0.3, 2.5],'fontsize',15);
xlabel('C (%)'); ylabel('Depth (cm)');
text(-0.6,-10,'(a)','fontsize',15);
print(gcf,'-djpeg','-r500','figs/C_reference');


C_12=A_12+S_12+P_12;
C_13=A_13+S_13+P_13;
C_14=A_14+S_14+P_14;


PDB = 0.0112372;
delta_c13 = ((A_13+S_13+P_13)./(A_12+S_12+P_12)/PDB-1)*1000;

C14C12_ratio_reference=1.176e-12;
ratio=C_14./C_12;

C14C12_ratio_SN=ratio.*(1-2*(25+delta_c13)/1000);
 
Delta_C14=(C14C12_ratio_SN./C14C12_ratio_reference-1)*1000;


figure(2)
h=plot(delta_c13,(0.5:length(delta_c13)-0.5)*depth_interval);
set(h,'linestyle','none','marker','o','markerfacecolor','k','markeredgecolor','k');
set(gca,'ydir','reverse','xaxislocation','top','xlim',[-28,-21],'fontsize',15);
xlabel('\delta^{13}C (‰)'); ylabel('Depth (cm)');
text(-28.6,-10,'(a)','fontsize',15);
print(gcf,'-djpeg','-r500','figs/C13_reference');


figure(3)
h=plot(Delta_C14,(0.5:length(Delta_C14)-0.5)*depth_interval);
set(h,'linestyle','none','marker','o','markerfacecolor','k','markeredgecolor','k');
set(gca,'ydir','reverse','xaxislocation','top','xlim',[-700,200],'fontsize',15);
xlabel('\Delta^{14}C (‰)'); ylabel('Depth (cm)');
text(-800,-10,'(a)','fontsize',15);
print(gcf,'-djpeg','-r500','figs/C14_reference');


