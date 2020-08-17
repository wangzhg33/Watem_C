unit model_implementation;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math,gdata, rdata, surface, idrisi_proc, lateralredistribution,
  carboncycling,variables;
procedure Carbon;
Procedure export_txt;
procedure test_AD;
implementation

procedure test_AD;

var
  C12_profile: array of single;
  i,t: integer;
  K,v: array of single;
  test_file1,test_file2:textfile;
  C12_ini_top,C12_ini_bot:single;
begin
   setlength(C12_profile,layer_num+2);
   C12_ini_top:=1.5;
   C12_ini_bot:=0.1;

  for i:=1 to layer_num do
     begin
       C12_profile[i]:=C12_ini_top-(i-1)*(C12_ini_top-C12_ini_bot)/layer_num;

     end;

  assignfile(test_file1,'D:/ZhengangW/integrate_model/test_file1.txt');
  rewrite(test_file1);
  for i:=1 to layer_num do
     begin
       writeln(test_file1,C12_profile[i]);
     end;
  closefile(test_file1);

  K:=K_coefficient;
  v:=v_coefficient;

  for t:=1 to 100 do
     begin
       if unstable= FALSE then
          Adevection_diffusion(K,v,C12_profile,unstable);
     end;

  assignfile(test_file2,'D:/ZhengangW/integrate_model/test_file2.txt');
  rewrite(test_file2);
  for i:=1 to layer_num do
     begin
       writeln(test_file2,C12_profile[i]);
     end;
  closefile(test_file2);

  end;

procedure Carbon;
var
  i,j,t,k,m: integer;
  Cin,r,C13_in,C14_in: array of single;
  temp_A12,temp_S12,temp_P12: array of single;
  temp_A13,temp_S13,temp_P13: array of single;
  temp_A14,temp_S14,temp_P14: array of single;
  temp_CLAY, temp_SILT, temp_SAND, temp_ROCK,temp_Cs137: array of single;
  A12_content,S12_content,P12_content: single;
  A13_content,S13_content,P13_content: single;
  A14_content,S14_content,P14_content: single;
  Clay_content,Silt_content,Sand_content,Rock_content,Cs137_content: single;
  C13C12ratio_input,C14C12ratio_input: single;
  deltaC13_input,DeltaC14_input,Rate_Cs137_input:single;
  output_file:textfile;
  C13_input, C14_input,Cs137_input:textfile;
  C13_num, C14_num,Cs137_num: integer;
  C13_year, C14_year,Cs137_year:array of integer;
  C13_series,C14_series,Cs137_series:array of single;
  year_loop,year_loop_num: integer;
  K_coe,v_coe:array of single;
  temp_Cstock,temp_Csactivity: single;

  temp_file:textfile;

 begin
   setlength(temp_A12,layer_num+2);
   setlength(temp_S12,layer_num+2);
   setlength(temp_P12,layer_num+2);
   setlength(temp_A13,layer_num+2);
   setlength(temp_S13,layer_num+2);
   setlength(temp_P13,layer_num+2);
   setlength(temp_A14,layer_num+2);
   setlength(temp_S14,layer_num+2);
   setlength(temp_P14,layer_num+2);
   setlength(temp_CLAY,layer_num+2);
   setlength(temp_SILT,layer_num+2);
   setlength(temp_SAND,layer_num+2);
   setlength(temp_ROCK,layer_num+2);
   setlength(temp_CS137,layer_num+2);

   Setlength(C13_in,layer_num+2);
   Setlength(C14_in,layer_num+2);

   writeln('Initilize carbon and profile');
   Carbon_Initilization;
   Texture_Initialization;
   Cs137_Initialization;
   writeln('allocate C input');
   Cin:=input_allocation2;
   writeln('extrapolate mineralization rate');
   r:=mineralization_extrapolation;

   K_coe:=K_coefficient;
   v_coe:=v_coefficient;

  assignfile(C13_input,c13filename);
  reset(C13_input);
  readln(C13_input,C13_num);
  setlength(C13_year,C13_num+2);
  setlength(C13_series,C13_num+2);

  for i:=1 to C13_num do
     begin
        readln(C13_input,C13_year[i],C13_series[i]);
     end;
  closefile(C13_input);

  assignfile(C14_input,c14filename);
  reset(C14_input);
  readln(C14_input,C14_num);
  setlength(C14_year,C14_num+2);
  setlength(C14_series,C14_num+2);

  for i:=1 to C14_num do
     begin
        readln(C14_input,C14_year[i],C14_series[i]);
     end;
  closefile(C14_input);

  assignfile(Cs137_input,cs137filename);
  reset(Cs137_input);
  readln(Cs137_input,Cs137_num);
  setlength(Cs137_year,Cs137_num+2);
  setlength(Cs137_series,Cs137_num+2);

  for i:=1 to Cs137_num do
     begin
        readln(Cs137_input,Cs137_year[i],Cs137_series[i]);
     end;
  closefile(Cs137_input);

   writeln('erosion and C cycling');
   year_loop_num:=floor((erosion_end_year-erosion_start_year)/time_step);


  assignfile(temp_file,'F:/Geoscientific model development/integrate_model/Calibration/Catchments/data/c_profile1.txt');
   rewrite(temp_file);

   for year_loop:=1 to year_loop_num do

   begin
      //writeln('erosion');
      t:=erosion_start_year+(year_loop-1)*time_step;
      //writeln(inttostr(t));

   if (t<C13_year[1]) OR (t>C13_year[C14_num]) then
        begin
            DeltaC13_input:=DeltaC13_input_default;
        end
      else
        begin
            for m:=1 to C13_num do
               begin
                  if (t=C13_year[m]) then
                     DeltaC13_input:=C13_series[m]; // it is ratio, not need to multiply the time-step
               end;

        end;

  C13C12ratio_input:=deltaC13_to_ratio(deltaC13_input);

  for i:=1 to layer_num  do
     begin
        C13_in[i]:=Cin[i]*C13C12ratio_input;
     end;


      if (t<C14_year[1]) OR (t>C14_year[C14_num]) then
        begin
            DeltaC14_input:=DeltaC14_input_default;
        end
      else
        begin
            for m:=1 to C14_num do
               begin
                  if (t=C14_year[m]) then
                     DeltaC14_input:=C14_series[m]; // it is ratio, not need to multiply the time-step
               end;

        end;

  C14C12ratio_input:=DeltaC14_to_ratio(DeltaC14_input,deltaC13_input);

  for i:= 1 to layer_num do
     begin
        C14_in[i]:=Cin[i]*C14C12ratio_input;
     end;

     if (t<Cs137_year[1]) OR (t>Cs137_year[Cs137_num]) then
        begin
            Rate_Cs137_input:=Cs137_input_default;
        end
      else
        begin
            for m:=1 to Cs137_num do
               begin
               if (t=Cs137_year[m]) then
                  Rate_Cs137_input:=Cs137_series[m]*time_step;    // it is amount, need to multiply the time-step
               end;
        end;

      Water(WATEREROS,A12_eros, S12_eros, P12_eros,A13_eros, S13_eros, P13_eros,
            A14_eros, S14_eros, P14_eros,Clay_eros, Silt_eros, Sand_eros,Rock_eros,Cs137_eros, LS, RKCP, ktc, TFCA, ra, BD);
      //writeln('profile evolution');
      for i:=1 to nrow do
        for j:=1 to ncol do
          //for i:=1 to 1 do
            //for j:=10 to 10 do
           begin
             for k:=1 to layer_num do
               begin
                  temp_A12[k]:=A12[k,i,j];
                  temp_S12[k]:=S12[k,i,j];
                  temp_P12[k]:=P12[k,i,j];
                  temp_A13[k]:=A13[k,i,j];
                  temp_S13[k]:=S13[k,i,j];
                  temp_P13[k]:=P13[k,i,j];
                  temp_A14[k]:=A14[k,i,j];
                  temp_S14[k]:=S14[k,i,j];
                  temp_P14[k]:=P14[k,i,j];
                  temp_CLAY[k]:=CLAY[k,i,j];
                  temp_SILT[k]:=SILT[k,i,j];
                  temp_SAND[k]:=SAND[k,i,j];
                  temp_ROCK[k]:=ROCK[k,i,j];
                  temp_Cs137[k]:=CS137[k,i,j];
               end;

             if (WATEREROS[i,j]>0) AND (WATEREROS[i,j]*time_step< depth/100/2) then  // case of deposition, deposition depth should be lower than half of the depth considered
                 begin

                    A12_content:=A12_EROS[i,j]/WATEREROS[i,j]; // get the C content
                    S12_content:=S12_EROS[i,j]/WATEREROS[i,j];
                    P12_content:=P12_EROS[i,j]/WATEREROS[i,j];
                    A13_content:=A13_EROS[i,j]/WATEREROS[i,j]; // get the C content
                    S13_content:=S13_EROS[i,j]/WATEREROS[i,j];
                    P13_content:=P13_EROS[i,j]/WATEREROS[i,j];
                    A14_content:=A14_EROS[i,j]/WATEREROS[i,j]; // get the C content
                    S14_content:=S14_EROS[i,j]/WATEREROS[i,j];
                    P14_content:=P14_EROS[i,j]/WATEREROS[i,j];
                    Clay_content:=Clay_EROS[i,j]/WATEREROS[i,j]; // get the C content
                    Silt_content:=Silt_EROS[i,j]/WATEREROS[i,j];
                    Sand_content:=Sand_EROS[i,j]/WATEREROS[i,j];
                    Rock_content:=Rock_EROS[i,j]/WATEREROS[i,j];
                    Cs137_content:=Cs137_EROS[i,j]/WATEREROS[i,j];

                    Evolution_deposition(WATEREROS[i,j]*time_step,A12_content,temp_A12);
                    Evolution_deposition(WATEREROS[i,j]*time_step,S12_content,temp_S12);
                    Evolution_deposition(WATEREROS[i,j]*time_step,P12_content,temp_P12);
                    Evolution_deposition(WATEREROS[i,j]*time_step,A13_content,temp_A13);
                    Evolution_deposition(WATEREROS[i,j]*time_step,S13_content,temp_S13);
                    Evolution_deposition(WATEREROS[i,j]*time_step,P13_content,temp_P13);
                    Evolution_deposition(WATEREROS[i,j]*time_step,A14_content,temp_A14);
                    Evolution_deposition(WATEREROS[i,j]*time_step,S14_content,temp_S14);
                    Evolution_deposition(WATEREROS[i,j]*time_step,P14_content,temp_P14);
                    Evolution_deposition(WATEREROS[i,j]*time_step,Clay_content,temp_Clay);
                    Evolution_deposition(WATEREROS[i,j]*time_step,Silt_content,temp_Silt);
                    Evolution_deposition(WATEREROS[i,j]*time_step,Sand_content,temp_Sand);
                    Evolution_deposition(WATEREROS[i,j]*time_step,Rock_content,temp_Rock);
                    Evolution_deposition(WATEREROS[i,j]*time_step,Cs137_content,temp_Cs137);
                 end
             else if (WATEREROS[i,j]<0) AND (abs(WATEREROS[i,j]*time_step)<depth/100/2) then     // case of erosion, erosion depth should be lower than half of the depth considered
                 begin
                     Evolution_erosion(-WATEREROS[i,j]*time_step,temp_A12);
                     Evolution_erosion(-WATEREROS[i,j]*time_step,temp_S12);
                     Evolution_erosion(-WATEREROS[i,j]*time_step,temp_P12);
                     Evolution_erosion(-WATEREROS[i,j]*time_step,temp_A13);
                     Evolution_erosion(-WATEREROS[i,j]*time_step,temp_S13);
                     Evolution_erosion(-WATEREROS[i,j]*time_step,temp_P13);
                     Evolution_erosion(-WATEREROS[i,j]*time_step,temp_A14);
                     Evolution_erosion(-WATEREROS[i,j]*time_step,temp_S14);
                     Evolution_erosion(-WATEREROS[i,j]*time_step,temp_P14);
                     Evolution_erosion(-WATEREROS[i,j]*time_step,temp_Clay);
                     Evolution_erosion(-WATEREROS[i,j]*time_step,temp_Silt);
                     Evolution_erosion(-WATEREROS[i,j]*time_step,temp_Sand);
                     Evolution_erosion(-WATEREROS[i,j]*time_step,temp_Rock);
                     Evolution_erosion(-WATEREROS[i,j]*time_step,temp_Cs137);
                   end;

             Carbon_Cycling(k1,k2,k3,hAS,hAP,hSP,Cin,r,temp_A12,temp_S12,temp_P12);
             Carbon_Cycling(k1*C13_discri,k2*C13_discri,k3*C13_discri,hAS,hAP,hSP,C13_in,r,temp_A13,temp_S13,temp_P13);
             Carbon_Cycling(k1*C14_discri,k2*C14_discri,k3*C14_discri,hAS,hAP,hSP,C14_in,r,temp_A14,temp_S14,temp_P14);

             tillage_mix(temp_A12); tillage_mix(temp_S12); tillage_mix(temp_P12);
             tillage_mix(temp_A13); tillage_mix(temp_S13); tillage_mix(temp_P13);
             tillage_mix(temp_A14); tillage_mix(temp_S14); tillage_mix(temp_P14);

             Cs137_fallout(Rate_Cs137_input,temp_Cs137); tillage_mix(temp_Cs137);

             C14_decay(temp_A14);
             C14_decay(temp_S14);
             C14_decay(temp_P14);

             Cs137_decay(temp_Cs137);

             if unstable= FALSE then
                begin
                    Adevection_diffusion(K_coe,v_coe,temp_A12,unstable);
                    Adevection_diffusion(K_coe,v_coe,temp_S12,unstable);
                    Adevection_diffusion(K_coe,v_coe,temp_P12,unstable);
                    Adevection_diffusion(K_coe,v_coe,temp_A13,unstable);
                    Adevection_diffusion(K_coe,v_coe,temp_S13,unstable);
                    Adevection_diffusion(K_coe,v_coe,temp_P13,unstable);
                    Adevection_diffusion(K_coe,v_coe,temp_A14,unstable);
                    Adevection_diffusion(K_coe,v_coe,temp_S14,unstable);
                    Adevection_diffusion(K_coe,v_coe,temp_P14,unstable);
                    Adevection_diffusion(K_coe,v_coe,temp_Cs137,unstable);
                end;

             tillage_mix(temp_A12); tillage_mix(temp_S12); tillage_mix(temp_P12);
             tillage_mix(temp_A13); tillage_mix(temp_S13); tillage_mix(temp_P13);
             tillage_mix(temp_A14); tillage_mix(temp_S14); tillage_mix(temp_P14);
             tillage_mix(temp_Clay); tillage_mix(temp_Silt); tillage_mix(temp_Sand); tillage_mix(temp_Rock); tillage_mix(temp_Cs137);

             for k:=1 to layer_num do
               begin
                  A12[k,i,j]:=temp_A12[k];
                  S12[k,i,j]:=temp_S12[k];
                  P12[k,i,j]:=temp_P12[k];
                  A13[k,i,j]:=temp_A13[k];
                  S13[k,i,j]:=temp_S13[k];
                  P13[k,i,j]:=temp_P13[k];
                  A14[k,i,j]:=temp_A14[k];
                  S14[k,i,j]:=temp_S14[k];
                  P14[k,i,j]:=temp_P14[k];
                  Clay[k,i,j]:=temp_Clay[k];
                  Silt[k,i,j]:=temp_Silt[k];
                  Sand[k,i,j]:=temp_Sand[k];
                  Rock[k,i,j]:=temp_Rock[k];
                  Cs137[k,i,j]:=temp_Cs137[k];
               end;
           end;
   for k:=1 to layer_num do
     begin
        if k=layer_num then
             write(temp_file,A12[k,9,2]+S12[k,9,2]+P12[k,9,2],char(13))
        else
             write(temp_file,A12[k,9,2]+S12[k,9,2]+P12[k,9,2],char(9));
     end;

   end;
   closefile(temp_file);

       for i:=1 to nrow do
        for j:=1 to ncol do
          begin
            temp_Cstock:=0;
            temp_Csactivity:=0;
            for k:=1 to layer_num do
              begin
                 temp_Cstock:=temp_Cstock+(A12[k,i,j]+S12[k,i,j]+P12[k,i,j]+A13[k,i,j]+S13[k,i,j]+P13[k,i,j]+A14[k,i,j]+S14[k,i,j]+P14[k,i,j])*depth_interval;
                 temp_Csactivity:=temp_Csactivity+CS137[k,i,j]*depth_interval;
              end;
            C_STOCK[i,j]:=temp_Cstock/100/100*BD; // unit kg/m2
            CS137_ACTIVITY[i,j]:=temp_Csactivity/100*BD;  // unit Bq/m2
          end;

 end;

Procedure export_txt;
var
A12_file,A13_file,A14_file:textfile;
S12_file,S13_file,S14_file:textfile;
P12_file,P13_file,P14_file:textfile;
CLAY_file, SILT_file, SAND_file, ROCK_file,CS137_file:textfile;

i,j,k:integer;
begin
assignfile(A12_file,'A12.txt'); rewrite(A12_file);
assignfile(A13_file,'A13.txt'); rewrite(A13_file);
assignfile(A14_file,'A14.txt'); rewrite(A14_file);
assignfile(S12_file,'S12.txt'); rewrite(S12_file);
assignfile(S13_file,'S13.txt'); rewrite(S13_file);
assignfile(S14_file,'S14.txt'); rewrite(S14_file);
assignfile(P12_file,'P12.txt'); rewrite(P12_file);
assignfile(P13_file,'P13.txt'); rewrite(P13_file);
assignfile(P14_file,'P14.txt'); rewrite(P14_file);
assignfile(CLAY_file,'CLAY.txt'); rewrite(CLAY_file);
assignfile(SILT_file,'SILT.txt'); rewrite(SILT_file);
assignfile(SAND_file,'SAND.txt'); rewrite(SAND_file);
assignfile(ROCK_file,'ROCK.txt'); rewrite(ROCK_file);
assignfile(CS137_file,'Cs137.txt'); rewrite(CS137_file);

for k:=1 to layer_num do
  for i:=1 to nrow do
    for j:=1 to ncol do
      begin
        if (i=nrow) AND (j=ncol) then
           begin
             write(A12_file,A12[k,i,j]); write(A12_file,char(13));
             write(A13_file,A13[k,i,j]); write(A13_file,char(13));
             write(A14_file,A14[k,i,j]); write(A14_file,char(13));
             write(S12_file,S12[k,i,j]); write(S12_file,char(13));
             write(S13_file,S13[k,i,j]); write(S13_file,char(13));
             write(S14_file,S14[k,i,j]); write(S14_file,char(13));
             write(P12_file,P12[k,i,j]); write(P12_file,char(13));
             write(P13_file,P13[k,i,j]); write(P13_file,char(13));
             write(P14_file,P14[k,i,j]); write(P14_file,char(13));
             write(CLAY_file,CLAY[k,i,j]); write(CLAY_file,char(13));
             write(SILT_file,SILT[k,i,j]); write(SILT_file,char(13));
             write(SAND_file,SAND[k,i,j]); write(SAND_file,char(13));
             write(ROCK_file,ROCK[k,i,j]); write(ROCK_file,char(13));
             write(CS137_file,CS137[k,i,j]); write(CS137_file,char(13));
           end
        else
           begin
             write(A12_file,A12[k,i,j]); write(A12_file,char(9));
             write(A13_file,A13[k,i,j]); write(A13_file,char(9));
             write(A14_file,A14[k,i,j]); write(A14_file,char(9));
             write(S12_file,S12[k,i,j]); write(S12_file,char(9));
             write(S13_file,S13[k,i,j]); write(S13_file,char(9));
             write(S14_file,S14[k,i,j]); write(S14_file,char(9));
             write(P12_file,P12[k,i,j]); write(P12_file,char(9));
             write(P13_file,P13[k,i,j]); write(P13_file,char(9));
             write(P14_file,P14[k,i,j]); write(P14_file,char(9));
             write(CLAY_file,CLAY[k,i,j]); write(CLAY_file,char(9));
             write(SILT_file,SILT[k,i,j]); write(SILT_file,char(9));
             write(SAND_file,SAND[k,i,j]); write(SAND_file,char(9));
             write(ROCK_file,ROCK[k,i,j]); write(ROCK_file,char(9));
             write(CS137_file,CS137[k,i,j]); write(CS137_file,char(9));
           end;

      end;

closefile(A12_file);closefile(A13_file);closefile(A14_file);
closefile(S12_file);closefile(S13_file);closefile(S14_file);
closefile(P12_file);closefile(P13_file);closefile(P14_file);
closefile(CLAY_file);closefile(SILT_file);closefile(SAND_file);closefile(ROCK_file);closefile(CS137_file);

end;

end.

