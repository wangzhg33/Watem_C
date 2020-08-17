function result=ratio_to_deltaC13(ratio)
PDB=0.0112372;
result=(ratio/PDB-1)*1000;
end