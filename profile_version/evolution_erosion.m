function result=evolution_erosion(ero_rate,profile,depth_interval,layer_num)
new_profile=zeros(1,length(profile));

erosion_layer= floor(ero_rate*100/depth_interval); % multiply 100 to convert from m to cm
delta_h=ero_rate*100-erosion_layer*depth_interval; % convert m to cm

for i=1: layer_num-erosion_layer-1
    new_profile(i)=(depth_interval-delta_h)/depth_interval*profile(erosion_layer+i)+delta_h/depth_interval*profile(erosion_layer+i+1);
end

new_profile(layer_num-erosion_layer)=profile(layer_num);

if erosion_layer>0
    for i=layer_num-erosion_layer+1 :layer_num
        new_profile(i)=profile(layer_num);
    end
    
end

result=new_profile';
end