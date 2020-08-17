year_loop_num=floor((erosion_end_year-erosion_start_year)/time_step);

for year_loop=1:year_loop_num
    t=start_year+(year_loop-1)*time_step;
    
    if t<C13_input(1,1) || t>C13_input(end,1)
        deltaC13_input=deltaC13_input_default;
    else
        for m=1:length(C13_input(:,1))
            if t==C13_input(m,1)
                deltaC13_input=C13_input(m,2);
                break;
            else
                deltaC13_input=deltaC13_input_default;
            end
        end
    end
    C13C12ratio_input=deltaC13_to_ratio(deltaC13_input);
    C13_in=Cin*C13C12ratio_input;
    
    if t<C14_input(1,1) || t>C14_input(end,1)
        DeltaC14_input=DeltaC14_input_default;
    else
        for m=1:length(C14_input(:,1))
            if t==C14_input(m,1)
                DeltaC14_input=C14_input(m,2);
                break;
            else
                DeltaC14_input=DeltaC13_input_default;
            end
        end
    end
    C14C12ratio_input=DeltaC14_to_ratio(DeltaC14_input,deltaC13_input);
    C14_in=Cin*C14C12ratio_input;
    
    if ero_rate>0
        A_12=evolution_erosion(ero_rate,A_12,depth_interval,layer_num);
        S_12=evolution_erosion(ero_rate,S_12,depth_interval,layer_num);
        P_12=evolution_erosion(ero_rate,P_12,depth_interval,layer_num);
        A_13=evolution_erosion(ero_rate,A_13,depth_interval,layer_num);
        S_13=evolution_erosion(ero_rate,S_13,depth_interval,layer_num);
        P_13=evolution_erosion(ero_rate,P_13,depth_interval,layer_num);
        A_14=evolution_erosion(ero_rate,A_14,depth_interval,layer_num);
        S_14=evolution_erosion(ero_rate,S_14,depth_interval,layer_num);
        P_14=evolution_erosion(ero_rate,P_14,depth_interval,layer_num);
    else
        A_12=evolution_deposition(-ero_rate,A_12,depth_interval,layer_num);
        S_12=evolution_deposition(-ero_rate,S_12,depth_interval,layer_num);
        P_12=evolution_deposition(-ero_rate,P_12,depth_interval,layer_num);
        A_13=evolution_deposition(-ero_rate,A_13,depth_interval,layer_num);
        S_13=evolution_deposition(-ero_rate,S_13,depth_interval,layer_num);
        P_13=evolution_deposition(-ero_rate,P_13,depth_interval,layer_num);
        A_14=evolution_deposition(-ero_rate,A_14,depth_interval,layer_num);
        S_14=evolution_deposition(-ero_rate,S_14,depth_interval,layer_num);
        P_14=evolution_deposition(-ero_rate,P_14,depth_interval,layer_num);
        
    end
    [A_12,S_12,P_12]=carbon_cycling(k1,k2,k3,hAS,hAP,hSP,Cin,r,A_12,S_12,P_12);
    [A_13,S_13,P_13]=carbon_cycling(k1*C13_discri,k2*C13_discri,k3*C13_discri,hAS,hAP,hSP,C13_in,r,A_13,S_13,P_13);
    [A_14,S_14,P_14]=carbon_cycling(k1*C14_discri,k2*C14_discri,k3*C14_discri,hAS,hAP,hSP,C14_in,r,A_14,S_14,P_14);
    
    A_14=C14_decay(A_14,time_step);
    S_14=C14_decay(S_14,time_step);
    P_14=C14_decay(P_14,time_step);
    
    if unstable==false
        A_12=advection_diffusion(K_coe,v_coe,A_12,unstable,depth_interval,layer_num);
        S_12=advection_diffusion(K_coe,v_coe,S_12,unstable,depth_interval,layer_num);
        P_12=advection_diffusion(K_coe,v_coe,P_12,unstable,depth_interval,layer_num);
        A_13=advection_diffusion(K_coe,v_coe,A_13,unstable,depth_interval,layer_num);
        S_13=advection_diffusion(K_coe,v_coe,S_13,unstable,depth_interval,layer_num);
        P_13=advection_diffusion(K_coe,v_coe,P_13,unstable,depth_interval,layer_num);
        A_14=advection_diffusion(K_coe,v_coe,A_14,unstable,depth_interval,layer_num);
        S_14=advection_diffusion(K_coe,v_coe,S_14,unstable,depth_interval,layer_num);
        P_14=advection_diffusion(K_coe,v_coe,P_14,unstable,depth_interval,layer_num); 
        
    end
    
    A_12=tillage_mix(A_12,tillage_depth,depth_interval);
    S_12=tillage_mix(S_12,tillage_depth,depth_interval);
    P_12=tillage_mix(P_12,tillage_depth,depth_interval);
    A_13=tillage_mix(A_13,tillage_depth,depth_interval);
    S_13=tillage_mix(S_13,tillage_depth,depth_interval);
    P_13=tillage_mix(P_13,tillage_depth,depth_interval);
    A_14=tillage_mix(A_14,tillage_depth,depth_interval);
    S_14=tillage_mix(S_14,tillage_depth,depth_interval);
    P_14=tillage_mix(P_14,tillage_depth,depth_interval);
    
end