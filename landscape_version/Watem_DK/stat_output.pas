unit Stat_output;

{$mode objfpc}{$H+}

interface

  uses
  Classes, SysUtils, RData, GData, surface, variables, math;

Procedure Write_STAT(var Z:RRaster; filename:String);

implementation

var

Sed_DAT : array[1..1000000,1..6] of single;
Export_file: Textfile;

Procedure Write_STAT(var Z:RRaster; filename:String);
var
i,j,teller : integer;
sum : double;
begin

  for  i:=1 to 1000000 do
   for j:= 1 to 6 do
    Sed_DAT[i,j]:=0;

  Assignfile(Export_file,filename+'.txt');
  Rewrite(Export_file);
  Writeln(Export_file, 'Parcel_ID', chr(9), 'Gross Erosion (m3)', chr(9),'Gross Depo (m3)',chr(9), 'm2 Ero', chr(9),'m2 depo',  chr(9),'Net Ero (m3)', chr(9),'Average IR/R Ratio');


  //test KVO interrill
  SetDynamicRData(UPAREA);
 SetzeroR(UPAREA);
 for i:= 1 to nrow do
 for j:= 1 to ncol do
  begin
          If Is_Export_Cell(i,j) then continue;
          UPAREA[i,j]:= 0.4*6.86*power(tan(CalculateSlope(i,j)),0.84);
          UPAREA[i,j] := UPAREA[i,j]/(LS[i,j]-UPAREA[i,j]);
  end;
 //writeIdrisi32file(ncol,nrow, ChangeFileExt(outfilename,'')+'_IR_Rill_Ratio', UPAREA);


   for teller:= ncol*nrow downto 1
   do begin // begin lus
     i:=row[teller];  j:=column[teller];
     IF Not(Is_Export_Cell(i,j)) and (PRC[i,j]>0) then // if cell is outside area or river cell
      begin

       if Z[i,j]<0 then Sed_DAT[PRC[i,j],1] :=  Sed_DAT[PRC[i,j],1] + Z[i,j]*sqr(RES) else
          Sed_DAT[PRC[i,j],2] :=  Sed_DAT[PRC[i,j],2] + Z[i,j]*sqr(RES);
       if Z[i,j]<0 then Sed_DAT[PRC[i,j],3] :=  Sed_DAT[PRC[i,j],3]+1 else
          Sed_DAT[PRC[i,j],4] :=  Sed_DAT[PRC[i,j],4]+1;
       if Z[i,j]<0 then Sed_DAT[PRC[i,j],6] :=  Sed_DAT[PRC[i,j],6] + UPAREA[i,j]; // IR-R Ratio only for eroding areas
     end;
    end; // end grid loop

    for  i:=1 to 1000000 do
     begin
       sum := (Sed_DAT[i,3]+Sed_DAT[i,4]);
       if sum > 0 then Sed_DAT[i,5]:= (Sed_DAT[i,1] + Sed_DAT[i,2]);
     end;

    for  i:=1 to 1000000 do
           if (Sed_DAT[i,3]+Sed_DAT[i,4])>0 then  Writeln(Export_file, inttostr(i), chr(9), floattostr(Sed_DAT[i,1]), chr(9), floattostr(Sed_DAT[i,2]), chr(9),floattostr(Sed_DAT[i,3]*sqr(RES)),chr(9), floattostr(Sed_DAT[i,4]*sqr(RES)), chr(9),floattostr(Sed_DAT[i,5]),chr(9),floattostr(Sed_DAT[i,6]/max(Sed_DAT[i,3],1)));

    Closefile(Export_file);
    DisposeDynamicRdata(UPAREA);
end;



end.

