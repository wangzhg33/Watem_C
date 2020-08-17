function result=evolution_deposition(depo_rate,profile,depth_interval,layer_num)
new_profile=zeros(1,length(profile));

deposition_layer=floor(depo_rate*100/depth_interval); % mind the sign of deposition rate
delta_h=depo_rate*100-deposition_layer*depth_interval;

if  deposition_layer>0
    for i=1:deposition_layer
        new_profile(i)=profile(1);
    end
    
end
new_profile(deposition_layer+1)=delta_h/depth_interval*profile(1)+(depth_interval-delta_h)/depth_interval*profile(1);

for i=deposition_layer+2:layer_num
    new_profile(i)=delta_h/depth_interval*profile(i-1-deposition_layer)+(depth_interval-delta_h)/depth_interval*profile(i-deposition_layer);
    
end

result=new_profile';

end