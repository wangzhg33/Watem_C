function result=deltaC13_to_ratio(deltaC13)
PDB=0.0112372;
result=(deltaC13/1000+1)*PDB;
end