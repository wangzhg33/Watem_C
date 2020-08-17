function result=C14_decay(C14,time_step)
%half_life=5730;
decay_rate=0.99987905; 

result=C14*decay_rate^time_step;

end