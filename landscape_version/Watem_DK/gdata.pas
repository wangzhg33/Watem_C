unit gdata;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, RData;

Type
 Graster = array of array of Longint; //integer; //smallint;

  Procedure SetDynamicGData(var Z:GRaster);
  procedure GetGfile(var Z:GRaster; filename:string);
  Procedure DisposeDynamicGdata(var Z:GRaster);
  Procedure SetzeroG(var Z:Graster);
  Procedure Get32bitGFile(var Z:RRaster; filename:string; var G : GRaster);

implementation


Procedure SetRasterBorders(var Z:GRaster);
var
i,j       : integer;
begin
Z[0,0]:= Z[1,1];
   Z[0,(ncol+1)] := Z[1,ncol];
   Z[nrow+1,0] := Z[nrow,1];
   Z[nrow+1,ncol+1] := Z[nrow,ncol];
   for j := 1 to ncol do
       begin
         Z[0,j] := Z[1,j];
         Z[(nrow+1),j]:=Z[nrow,j];
       end;
   for  i := 1 to nrow do
        begin
          Z[i,0] := Z[i,1];
          Z[i,ncol+1] := Z[i,ncol];
        end;
end;


Procedure SetDynamicGData(var Z:GRaster);
var
i       : integer;
begin
     SetLength(Z,nrow+2);
     for i := Low(Z) to high(Z) do
      Setlength(Z[i],ncol+2);
end;

Procedure DisposeDynamicGdata(var Z:GRaster);
var
i       : integer;
begin
for i := Low(Z) to high(Z) do
      Z[i]:=NIL;
 Z:=NIL;
end;

procedure GetGfile(var Z:GRaster; filename:string);  { TODO -oKVO -cinsert blockread for byte and ascii files :  }
var
i,j,hulpgetal: integer;
docfileIMG : textfile;
fileIMG : file of smallint;//integer;//textfile ;
textfileIMG : textfile ;
bytefileIMG : file of byte;
docnfileIMG,NfileIMG,dumstr : string;
idrisi32,asciidatatype,bytebinary :boolean;
bytedata : byte;
testarray: array of smallint;
begin
      dumstr := filename;
      if ExtractFileExt(dumstr)='.img' then  idrisi32:=false else idrisi32:=true;
      hulpgetal := length(dumstr)-2;      delete(dumstr,hulpgetal,3);
      if Idrisi32 then
      begin
      docNfileIMG := dumstr + 'rdc' ;     NfileIMG := dumstr + 'rst';
      end
      else
       begin
        docNfileIMG := dumstr + 'doc' ;     NfileIMG := dumstr + 'img';
       end;
      // INLEZEN NCOLS
      Assignfile(docfileIMG, docNfileIMG);   reset(docfileIMG);
      if Idrisi32 then readln(docfileImg,dumstr);
      for i := 1 to 2 do
       readln(docfileIMG, dumstr);delete (dumstr,1,14);
         if (dumstr='real') {or (dumstr='byte')} then
         begin
         // showmessage('File type must be integer !!'+chr(13)+'Please Re-enter data');     ERROR message
         closefile(docfileIMG);
         exit;
         end;
        if dumstr='byte' then bytebinary:=true else bytebinary:=false;
        readln(docfileIMG, dumstr);delete (dumstr,1,14);
        if dumstr='binary' then asciidatatype:=false else asciidatatype:=true;
        readln(docfileIMG, dumstr);delete (dumstr,1,14);
        ncol := strtoint(dumstr);
     // INLEZEN NROWS
     readln(docfileIMG, dumstr);   delete (dumstr,1,14);
     nrow := strtoint(dumstr);
     readln(docfileIMG, dumstr);   delete(dumstr,1,14);
     if dumstr='plane' then Raster_Projection:=plane else Raster_Projection:=LATLONG;
     readln(docfileIMG);
     readln(docfileIMG);           readln(docfileIMG,dumstr);
     delete(dumstr,1,14);          MINX := strtofloat(dumstr);
     readln(docfileIMG,dumstr);   delete(dumstr,1,14);
     MAXX :=strtofloat(dumstr);  readln(docfileIMG,dumstr);
     delete(dumstr,1,14);           MINY := strtofloat(dumstr);
     readln(docfileIMG,dumstr);   delete(dumstr,1,14);
     MAXY :=  strtofloat(dumstr);   readln(docfileIMG);
     readln(docfileIMG, dumstr);    delete(dumstr,1,14);
     res := strtofloat(dumstr);
     // Inlezen gegevens
     SetDynamicGData(Z);
     SetZeroG(Z);
      if asciidatatype then
      begin
       assignfile(textFileIMG, NfileIMG);
       reset (textfileIMG);
        for i:= 1 to nrow do
        for j:= 1 to ncol do
        read(textfileIMG, Z[i,j]);
        Closefile(textfileimg);
      end
      else
       begin
         if bytebinary then
          begin
           assignfile(byteFileIMG, NfileIMG);
           reset (bytefileIMG);
            for i:= 1 to nrow do
             for j:= 1 to ncol do
              begin
               read(bytefileIMG, bytedata);
               Z[i,j]:=bytedata
              end;
           Closefile(byteFileimg);
           end
          else
           begin
            assignfile(FileIMG, NfileIMG);
            reset (fileIMG);
            {for i:= 1 to nrow do
            for j:= 1 to ncol do
             read(fileIMG, Z[i,j]);}
             setlength(testarray,ncol+1);
             for i:= 1 to nrow do
              begin
               blockread(fileIMG, testarray[0],ncol);
                for j:= 0 to ncol-1 do
                 Z[i,j+1]:=testarray[j];
              end;
             testarray:=NIL;
             Closefile(fileimg);
           end;
       end;
     Closefile(DocfileImg);
     SetRasterBorders(Z);

end;

Procedure SetzeroG(var Z:Graster);
var
i,j:integer;
begin
for i:=Low(Z) to High(Z) do
 for j:=Low(Z[i]) to High(Z[i]) do
  begin
    Z[i,j]:=0
  end;
end;


Procedure Get32bitGFile(var Z:RRaster; filename:string; var G : GRaster);
var
i,j:integer;
begin

GetRFile(Z,filename);
SetDynamicGData(G);
  for i:=Low(Z) to High(Z) do
   for j:=Low(Z[i]) to High(Z[i]) do
    begin
     G[i,j]:=Round(Z[i,j]);
    end;
 SetzeroR(Z);

end;


end.

