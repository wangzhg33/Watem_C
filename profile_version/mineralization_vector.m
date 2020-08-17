function result=mineralization_vector(layer_num,depth_interval,r0,r_exp)

r_exp_cm=r_exp/100; %to convert the unit of r_exp from m-1 to cm-1
for i=1:layer_num
    ave_depth_layer=(i-0.5)*depth_interval;
    r_vertical(i)=r0*exp(-r_exp_cm*ave_depth_layer);
    
end
result=r_vertical';
end