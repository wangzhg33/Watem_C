unit ReadInParameters;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, RData, GData, Surface, Inifiles;

Procedure ReadInRasters_Update(year:integer);
Procedure ReadInRasters;
procedure ReadInParam(Ini_Filename:string);
procedure Read_DBS;
procedure Get_Erosion_parameters(i,j:integer; var Rf,Kf,Cf,Pf,kTc,ktil,harvestero : double);
Procedure Get_Carbon_parameters(i,j : integer; var Cin_Manure,Cin_Roots,Cin_Residues,ck1,ck2,zz,zr,ck_DA,hc,hm,Temp,clay_percent:double);
Procedure Allocate_Memory;
Procedure Release_Memory;

//Record for model variables
Type
  TDBSrecord = record
   Cf         : Double;   //RUSLE C-factor
   Pf         : Double;   //RUSLE P-factor              Unit -
   kTC        : Double;   //Transport capacity          Unit Kg/m
   HarvestEro : Double;
   ktil       : Double;   //Unit Kg/(m.yr)
   Cin_Manure : Double;   //Manure input in plough      Unit Kg/m≤
   Cin_Roots  : Double;
   Cin_Residues:Double;
   ck1        : Double;   //loss rate constant young pool
   ck2        : Double;   //loss rate constant old pool
   zz         : Double;   //Root input shape parameter
   zr         : Double;   //Root input shape parameter 2 (depth of mixing layer)
   ck_DA      : Double;   //Depth attenuation of decomposition constants
   hc         : Double;   //humification coefficient plant
   hm         : Double;   //humification coefficient manure
 end;

var
  //internal variables

  DBS           : array of TDBSrecord ;         //array of TDBSrecord to create a database where var=f(parcelID)
  CY            : array of RRaster;             // 3D array for young C pool
  CO            : array of RRaster;             // 3D array for old C pool

  CLatFlux      : RRaster;                      // Lateral C flux due to erosion (wat+til) (kg C )  CHECK UNITS
  CVerFlux      : RRaster;                      // Vertical soil-atmosphere C flux (kg C )

  {Rasters to be read in--------------------------------------------------------}
   WI         : GRaster;    {Wetness scalar Index from TOPMODEL: base=100}
   YieldVar   : GRaster;    {Infield yield variabilty map, scalar value: base=100}
   CLAYP      : GRaster;    {Infield Clay percentage map, %clay}
   AIRTEMP    : GRaster;    {Infield Air Temperature map, °C*10}
   K_factor   : GRaster;    {RUSLE K-factor map kg m² h m-² MJ-1 mm-1}
   R_factor   : GRaster;    {unit MJ mm m-2 h-1 a-1 *1000}
  {End Rasters to be read in----------------------------------------------------}

  {Parameters to be read form ini-file------------------------------------------}
  Inifile     : TInifile;
  {workingdir}
  datadir           : string;
  File_output_dir   : string;
  {Maps_Filenames}
  DTM_filename        : string;       {unit m}
  RUNOFF_filename     : string;       {unit upstream area in m2 or # cells}
  PARCEL_filename     : string;       {unit id, 1 to 3200 for parcels, -1 for river, 0 for outside area}
  WI_filename         : string;
  YIELDVAR_filename   : string;
  CLAYP_filename      : string;
  AIRTEMP_filename    : string;
  K_Factor_filename   : string;
  R_Factor_filename   : string;
  {Temporal_Filename}
  PRC_Update_Filename  : string;
  Rfac_Update_Filename  : string;
  Kfac_Update_Filename  : string;
  {Database_Dimensions}
  Database_Max_Year     :integer;
  Database_Max_ParcelID :integer;
  {Database_Filenames}
  {Database_Defaultvalues}

  {General}
  startyear   : integer;
  endyear     : integer;

  {Soil}
   BD          : integer;

  {Model structure}
   NDepthLayers : integer;
   deltaZ       : double;
   NPlough_Layers : integer;      //number of layers considered as mixed plough layers
   ra : Troutingalgorithm;        //type of routing  sdra= steepest descent mfra=multiple flow
   Topo_Threshold      : double;  //threshold between mf and sd routing algorithms in cells

  {Carbon}


  {Output_Files}
  WriteOutput_Years_Filename : string;
  WriteOutput_Years        :array[1..10000] of integer;
  write_CPools             :boolean;
  Write_WATEREROS          :boolean;
  Write_TILEROS            :boolean;
  Write_UPAREA             :boolean;
  Write_LS                 :boolean;
  Write_Carbon             :boolean;
  Write_LatCflux           :boolean;
  Write_VerCflux           :boolean;
  Write_Sediexport         :boolean;
  Write_Cexport            :boolean;

  {End Parameters to be read form ini-file--------------------------------------}


implementation

Procedure Read_OutputYears;
var
datafile   : Textfile;
teller     : integer;
begin
Try
    assignfile(datafile,datadir+'\'+WriteOutput_Years_Filename);
    reset(datafile);
    teller:=0;
     while not Eof(datafile) do
      begin
        Inc(teller);
        Readln(datafile, WriteOutput_Years[teller]);
       end;
     closefile(datafile);
Except
  writeln('Error in WriteOutput_Years_Filename');
end;
end;

Procedure ReadInRasters;
begin
  GetRFile(DTM,datadir+DTM_Filename);
  GetGFile(PRC,datadir+PARCEL_filename);
 // GetGFile(WI,datadir+WI_filename);  not used
  GetGFile(YIELDVAR,datadir+YIELDVAR_filename);
  GetGFile(CLAYP,datadir+CLAYP_filename);
  GetGFile(AIRTEMP,datadir+AIRTEMP_filename);
  GetGFile(K_factor,datadir+K_Factor_filename);
  GetGFile(R_factor,datadir+R_Factor_filename);

end;

Function Check_Update_Raster(DB_filename:string;year:integer):boolean;
var
datafile    : Textfile;
nextyear    : Integer;
UpdateFile  : Boolean;
begin
  assignfile(datafile,datadir+DB_filename);
    reset(datafile);
    readln(datafile); //skip header
    UpdateFile:=false;

     while not (Eof(datafile)) and (not(UpdateFile)) do
      begin
        Readln(datafile, nextyear);
        if year=nextyear then UpdateFile:=true;
       end;
     closefile(datafile);
     Check_Update_Raster:=UpdateFile;
end;

Procedure ReadInRasters_Update(year:integer);
var
newfilename : String;
begin

  if Check_Update_Raster(PRC_Update_Filename,year) then
   begin
     newfilename:=PARCEL_filename;
     Insert('_'+inttostr(year),newfilename,pos(ExtractFileExt(PARCEL_filename),newfilename));
     GetGFile(PRC,datadir+newfilename);
   end;

end;

procedure Get_Erosion_parameters(i,j:integer; var Rf,Kf,Cf,Pf,kTc,ktil,harvestero : double);
begin
Rf:=R_Factor[i,j]/1000;     //divde by 1000 to get {unit MJ mm m-2 h-1 a-1}
Kf:=K_Factor[i,j];
Cf:=DBS[PRC[i,j]].Cf;
Pf:=DBS[PRC[i,j]].Pf;
kTc:=DBS[PRC[i,j]].kTc;
HarvestEro:=DBS[PRC[i,j]].HarvestEro;
ktil:=DBS[PRC[i,j]].ktil;
end;

Procedure Get_Carbon_parameters(i,j : integer; var Cin_Manure,Cin_Roots,Cin_Residues,ck1,ck2,zz,zr,ck_DA,hc,hm,Temp,clay_percent:double);
begin
//From Database
Cin_Manure     := DBS[PRC[i,j]].Cin_Manure;
Cin_Roots      := DBS[PRC[i,j]].Cin_Roots;
Cin_Residues   := DBS[PRC[i,j]].Cin_Residues;
ck1            := DBS[PRC[i,j]].ck1;
ck2            := DBS[PRC[i,j]].ck2;
zz             := DBS[PRC[i,j]].zz;
zr             := DBS[PRC[i,j]].zr;
ck_DA          := DBS[PRC[i,j]].ck_DA;
hc             := DBS[PRC[i,j]].hc;
hm             := DBS[PRC[i,j]].hm;
Temp           := AirTemp[i,j]/10.0; {from 0.1 °C to °C}
clay_percent   := round(ClayP[i,j]);
end;


procedure ReadInParam(Ini_Filename:string);
var
  dummy_str   : string;
  dummy_int   : integer;
  Inifile     : Tinifile;
begin
  Inifile:= Tinifile.create(Ini_Filename);
  {Datadir}
  datadir   :=(Inifile.Readstring  ('Workingdir','datadir',dummy_str));
  File_output_dir   :=(Inifile.Readstring  ('Workingdir','File_output_dir',dummy_str));
  {Map_Filenames}
  DTM_filename              :=Inifile.Readstring  ('Maps_Filenames','DTM_filename',dummy_str);
  RUNOFF_filename           :=Inifile.Readstring  ('Maps_Filenames','Runoff_filename',dummy_str);
  PARCEL_filename           :=Inifile.ReadString  ('Maps_Filenames','PARCEL_filename',dummy_str);
  WI_filename               :=Inifile.Readstring  ('Maps_Filenames','WI_filename',dummy_str);
  YIELDVAR_filename         :=Inifile.Readstring  ('Maps_Filenames','YIELDVAR_filename',dummy_str);
  CLAYP_filename            :=Inifile.Readstring  ('Maps_Filenames','CLAYP_filename',dummy_str);
  AIRTEMP_filename          :=Inifile.Readstring  ('Maps_Filenames','AIRTEMP_filename',dummy_str);
  K_Factor_filename         :=Inifile.Readstring  ('Maps_Filenames','K_Factor_filename',dummy_str);
  R_Factor_filename         :=Inifile.Readstring  ('Maps_Filenames','R_Factor_filename',dummy_str);
  {Temporal_Filename}
  PRC_Update_Filename       :=Inifile.Readstring  ('Temporal_Filename','PRC_Update_Filename',dummy_str);
  Rfac_Update_Filename       :=Inifile.Readstring  ('Temporal_Filename','Rfac_Update_Filename',dummy_str);
  Kfac_Update_Filename       :=Inifile.Readstring  ('Temporal_Filename','Kfac_Update_Filename',dummy_str);
  {Database_Dimensions}
  Database_Max_Year         :=Inifile.ReadInteger ('Database_Dimensions','Database_Max_Year',dummy_int);
  Database_Max_ParcelID     :=Inifile.ReadInteger ('Database_Dimensions','Database_Max_ParcelID',dummy_int);

  {General}
  startyear:=Inifile.ReadInteger ('General','startyear',dummy_int);
  endyear:=Inifile.ReadInteger ('General','endyear',dummy_int);
  {Soil}
  BD:= Inifile.ReadInteger ('Soil','BD',dummy_int);
  {Modelstructure}
  NDepthLayers:= Inifile.ReadInteger('Modelstructure', 'NDepthLayers',dummy_int);
  deltaZ:=strtofloat(Inifile.ReadString ('Modelstructure','deltaZ',dummy_str));
  NPlough_Layers:= Inifile.ReadInteger('Modelstructure', 'NPlough_Layers',dummy_int);
  dummy_str:=(Inifile.ReadString ('Modelstructure','Routing_algorithm',dummy_str));
  if dummy_str='sdra' then
   ra:=sdra else
    if dummy_str='mfra' then
     ra:=mfra;
  Topo_Threshold:= strtofloat(Inifile.ReadString('Modelstructure','Topo_Threshold',dummy_str));
  {Options}
  {Watererosion}

  {Output_Files}
  WriteOutput_Years_Filename    :=Inifile.Readstring  ('Output_Files','WriteOutput_Years_Filename',dummy_str);
  if (Inifile.ReadBool('Output_Files','write_CPools',false))=true then write_CPools:=true else write_CPools:=false;
  if (Inifile.ReadBool('Output_Files','Write_WATEREROS',false))=true then Write_WATEREROS:=true else Write_WATEREROS:=false;
  if (Inifile.ReadBool('Output_Files','Write_TILEROS',false))=true then Write_TILEROS:=true else Write_TILEROS:=false;
  if (Inifile.ReadBool('Output_Files','Write_UPAREA',false))=true then Write_UPAREA:=true else Write_UPAREA:=false;
  if (Inifile.ReadBool('Output_Files','Write_LS',false))=true then Write_LS:=true else Write_LS:=false;
  if (Inifile.ReadBool('Output_Files','Write_Carbon',false))=true then Write_Carbon:=true else Write_Carbon:=false;
  if (Inifile.ReadBool('Output_Files','Write_LatCflux',false))=true then Write_LatCflux:=true else Write_LatCflux:=false;
  if (Inifile.ReadBool('Output_Files','Write_VerCflux',false))=true then Write_VerCflux:=true else Write_VerCflux:=false;
  if (Inifile.ReadBool('Output_Files','Write_Sediexport',false))=true then Write_Sediexport:=true else Write_Sediexport:=false;
  if (Inifile.ReadBool('Output_Files','Write_Cexport',false))=true then Write_Cexport:=true else Write_Cexport:=false;

  Read_OutputYears;
  //Set Datadirectories for input & outpt
  Setcurrentdir(datadir);
  if not DirectoryExists(File_output_dir) then CreateDir(File_output_dir);  // add exception if not possible

  Inifile.free;
end;

procedure Read_DBS;
var
inputfile : textfile;
i,j       : integer;
nrow_parc,prcid  : integer;

begin
SetLength(DBS, Database_Max_ParcelID+1);
 assignfile(inputfile, datadir+'DBS.txt');
 reset (inputfile);
 Readln(inputfile, nrow_parc);
 Readln(inputfile); // skip text header
 for i:= 1 to nrow_parc do
     read(inputfile, prcid, DBS[prcid].Cf,DBS[prcid].Pf,DBS[prcid].kTC,DBS[prcid].HarvestEro,DBS[prcid].ktil,
     DBS[prcid].Cin_Manure,DBS[prcid].Cin_Roots,DBS[prcid].Cin_Residues,DBS[prcid].ck1,
     DBS[prcid].ck2,DBS[prcid].zz,DBS[prcid].zr,DBS[prcid].ck_DA,DBS[prcid].hc,DBS[prcid].hm);

 Closefile(inputfile);
end;







end.

