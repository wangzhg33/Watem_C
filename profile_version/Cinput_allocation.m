function result=Cinput_allocation(C_input,C_input2,layer_num,depth_interval,i_exp,BD)

i_exp_cm=i_exp/100;
total_Cin_layer_relative=0;

for i=1:layer_num
    ave_depth_layer=(i-0.5)*depth_interval;
    Cin_layer_relative(i)=exp(-i_exp_cm*ave_depth_layer);
    total_Cin_layer_relative=total_Cin_layer_relative+Cin_layer_relative(i);
end

for i=1:layer_num
    Cin_vertical(i)=C_input*Cin_layer_relative(i)/total_Cin_layer_relative;
    Cin_vertical(i)=Cin_vertical(i)*100*100*1000/depth_interval/10000/BD;  % convert the input unit from  Mg C ha-1 yr-1 to % of a layer one year
    
end

input_allocation2=Cin_vertical;

temp_Cinput=C_input2*100*100*1000/depth_interval/10000/BD;  %convert the input unit from  Mg C ha-1 yr-1 to % of a layer one year
input_allocation2(1)=input_allocation2(1)+temp_Cinput;

result=input_allocation2';

end