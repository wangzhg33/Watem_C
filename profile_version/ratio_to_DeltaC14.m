function result=ratio_to_DeltaC14(ratio,deltaC13)
C14C12_ratio_reference=1.176e-12;
C14C12_ratio_SN=ratio*(1-2*(25+deltaC13)/1000);
result=(C14C12_ratio_SN/C14C12_ratio_reference-1)*1000;
end