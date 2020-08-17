function result=DeltaC14_to_ratio(DeltaC14,deltaC13)
C14C12_ratio_reference=1.176e-12;
C14C12_ratio_SN=C14C12_ratio_reference*(DeltaC14/1000+1);
result=C14C12_ratio_SN/(1-2*(25+deltaC13)/1000);
end