function result=tillage_mix(C,tillage_depth,depth_interval)
tillage_layer=round(tillage_depth/depth_interval);
ave=mean(C(1:tillage_layer));

for i=1:tillage_layer
    C(i)=ave;
end

result=C;
end