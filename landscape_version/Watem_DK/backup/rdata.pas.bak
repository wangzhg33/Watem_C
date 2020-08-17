unit RData;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

Type
 Rraster = array of array of single ;

Type
  TRaster_Projection=(plane,LATLONG);

  Procedure SetDynamicRData(var Z:RRaster);
  Procedure DisposeDynamicRdata(var Z:RRaster);
  Procedure GetRFile(var Z:RRaster; filename:string);
  Procedure SetzeroR(var Z:Rraster);

var
  NROW,NCOL: integer;
  RES : double;   // fixed resolution for plane proj and dx=dy
  MINX, MAXX, MINY, MAXY, MINZ, MAXZ : double;
  Raster_Projection: TRaster_Projection;

implementation

Procedure SetRasterBorders(var Z:RRaster);
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


Procedure SetDynamicRData(var Z:RRaster);
var
i       : integer;
begin
     SetLength(Z,nrow+2);
     for i := Low(Z) to high(Z) do
      Setlength(Z[i],ncol+2);
end;

Procedure DisposeDynamicRdata(var Z:RRaster);
var
i       : integer;
begin
for i := Low(Z) to high(Z) do
      Z[i]:=NIL;
 Z:=NIL;
end;

Procedure GetRFile(var Z:RRaster; filename:string); { TODO -okvo -cEfficiency : Use TFileStream instead of readln for file input-output }
var
i,j,hulpgetal,result: integer;
docfileIMG : textfile;
fileIMG : file of single ;
textfileIMG : textfile ;
docnfileIMG,NfileIMG,dumstr : string;
idrisi32,asciidatatype :boolean;
testarray: array of single;
Filestream: TFileStream;
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
        if (dumstr='integer') or (dumstr='byte') then
         begin
         //showmessage('Data type must be real !!'+chr(13)+'Please Re-enter data');    //replace with ERROR message
          closefile(docfileIMG);
         exit;
         end;
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
     res := strtofloat(dumstr);  // if (res=0.0) then showmessage('Resolution is invalid');   ADD ERROR message
        // Inlezen gegevens
     SetDynamicRData(Z);
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
         assignfile(FileIMG, NfileIMG);
         reset(fileIMG);

         setlength(testarray,ncol+1);
         for i:= 1 to nrow do
         begin
          blockread(fileIMG, testarray[0],ncol);
          for j:= 0 to ncol-1 do
           Z[i,j+1]:=testarray[j];
         end;
         testarray:=NIL;

         //old read
         {for i:= 1 to nrow do
         for j:= 1 to ncol do
          begin
            read(fileIMG, Z[i,j]);
          end}

        Closefile(Fileimg);

       end;
     Closefile(DocfileImg);
     SetRasterBorders(Z);

 end;

Procedure SetzeroR(var Z:Rraster);
var
i,j:integer;
begin
for i:=Low(Z) to High(Z) do
 for j:=Low(Z[i]) to High(Z[i]) do
  begin
    Z[i,j]:=0
  end;
end;


end.

