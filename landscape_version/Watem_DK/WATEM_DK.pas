program WATEM_DK;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, fileutil, Dos, gdata, idrisi_proc, lateralredistribution, rdata,
  surface, vector, CustApp, variables,carboncycling, model_implementation;

type

  { TWATEMApplication }

  TWATEMApplication = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
    procedure Set_Parameter_Values; virtual;
  end;

{ TWATEMApplication }

var
//execution var
  hr, mins, se, s1 : word;


procedure StartClock;
begin
  GetTime (hr,mins,se,s1);
end;

Function StopClock:string;
var
  hr2, min2, se2  : word;
begin
  GetTime (hr2, min2, se2, s1);
  result := inttostr(se2-se+(min2-mins)*60+(hr2-hr)*60*60);
end;

Procedure TWATEMApplication.Set_Parameter_Values;
begin

  if Hasoption('c14input') then c14filename:=GetOptionValue('c14input');
  if Hasoption('c13input') then c13filename:=GetOptionValue('c13input');
  if Hasoption('Cs137input') then Cs137filename:=GetOptionValue('Cs137input');

  if Hasoption('d','dtm') then dtmfilename:=GetOptionValue('d','dtm');
  if Hasoption('p','prc') then prcfilename:=GetOptionValue('p','prc');
  if Hasoption('u','RKCP') then RKCPfilename:=GetOptionValue('u','RKCP');
  if Hasoption('k','ktc') then ktcfilename:=GetOptionValue('k','ktc');
  if Hasoption('o','outf') then outfilename:=GetOptionValue('o','outf') else outfilename:='watem_out.rst';
  if Hasoption('t','tfca') then TFCA:=strtoint(GetOptionValue('t','tfca')) else TFCA:=100;
  if Hasoption('r','ra') then
   begin
   if GetOptionValue('r','ra')='sd' then ra:=sdra else
      if GetOptionValue('r','ra')='mf' then ra:=mfra;
   end   else ra:=mfra;
  if Hasoption('b','BD') then BD:=strtoint(GetOptionValue('b','BD')) else BD:=1350;


  if Hasoption('erosion_start_year') then erosion_start_year:=strtoint(GetOptionValue('erosion_start_year')) else erosion_start_year:=1950;
  if Hasoption('erosion_end_year') then erosion_end_year:=strtoint(GetOptionValue('erosion_end_year')) else erosion_end_year:=2015;

  if Hasoption('depth_interval') then depth_interval:=strtoint(GetOptionValue('depth_interval')) else depth_interval:=5;
  if Hasoption('depth') then depth:=strtoint(GetOptionValue('depth')) else depth:=100;
  if Hasoption('tillage_depth') then tillage_depth:=strtoint(GetOptionValue('tillage_depth')) else tillage_depth:=25;

  if Hasoption('deltaC13_ini_top') then deltaC13_ini_top:=strtofloat(GetOptionValue('deltaC13_ini_top')) else deltaC13_ini_top:=-27.0;
  if Hasoption('deltaC13_ini_bot') then deltaC13_ini_bot:=strtofloat(GetOptionValue('deltaC13_ini_bot')) else deltaC13_ini_bot:=-26.0;

  if Hasoption('time_equilibrium') then time_equilibrium:=strtoint(GetOptionValue('time_equilibrium')) else time_equilibrium:=10000;

  if Hasoption('k1') then k1:=strtofloat(GetOptionValue('k1')) else k1:=2.1;
  if Hasoption('k2') then k2:=strtofloat(GetOptionValue('k2')) else k2:=0.03;
  if Hasoption('k3') then k3:=strtofloat(GetOptionValue('k3')) else k3:=0.002;
  if Hasoption('hAS') then hAS:=strtofloat(GetOptionValue('hAS')) else hAS:=0.12;
  if Hasoption('hAP') then hAP:=strtofloat(GetOptionValue('hAP')) else hAP:=0.01;
  if Hasoption('hSP') then hSP:=strtofloat(GetOptionValue('hSP')) else hSP:=0.12;
  if Hasoption('r0') then r0:=strtofloat(GetOptionValue('r0')) else r0:=1.0;
  if Hasoption('C_input') then C_input:=strtofloat(GetOptionValue('C_input')) else C_input:=2.0;
  if Hasoption('C_input2') then C_input2:=strtofloat(GetOptionValue('C_input2')) else C_input2:=0.5;
  if Hasoption('r_exp') then r_exp:=strtofloat(GetOptionValue('r_exp')) else r_exp:=3.30;
  if Hasoption('i_exp') then i_exp:=strtofloat(GetOptionValue('i_exp')) else i_exp:=6.0;
  if Hasoption('C13_discri') then C13_discri:=strtofloat(GetOptionValue('C13_discri')) else C13_discri:=0.9965;
  if Hasoption('C14_discri') then C14_discri:=strtofloat(GetOptionValue('C14_discri')) else C14_discri:=0.996;
  if Hasoption('deltaC13_input_default') then deltaC13_input_default:=strtofloat(GetOptionValue('deltaC13_input_default')) else deltaC13_input_default:=-29.0;
  if Hasoption('deltaC14_input_default') then deltaC14_input_default:=strtofloat(GetOptionValue('deltaC14_input_default')) else deltaC14_input_default:=100.0;
  if Hasoption('Cs137_input_default') then Cs137_input_default:=strtofloat(GetOptionValue('Cs137_input_default')) else Cs137_input_default:=0.0;

  if Hasoption('Sand_ini_top') then Sand_ini_top:=strtofloat(GetOptionValue('Sand_ini_top')) else Sand_ini_top:=15.0;
  if Hasoption('Silt_ini_top') then Silt_ini_top:=strtofloat(GetOptionValue('Silt_ini_top')) else Silt_ini_top:=70.0;
  if Hasoption('Clay_ini_top') then Clay_ini_top:=strtofloat(GetOptionValue('Clay_ini_top')) else Clay_ini_top:=15.0;

  if Hasoption('Sand_ini_bot') then Sand_ini_bot:=strtofloat(GetOptionValue('Sand_ini_bot')) else Sand_ini_bot:=15.0;
  if Hasoption('Silt_ini_bot') then Silt_ini_bot:=strtofloat(GetOptionValue('Silt_ini_bot')) else Silt_ini_bot:=70.0;
  if Hasoption('Clay_ini_bot') then Clay_ini_bot:=strtofloat(GetOptionValue('Clay_ini_bot')) else Clay_ini_bot:=15.0;

  if Hasoption('K0') then K0:=strtofloat(GetOptionValue('K0')) else K0:=0.09;
  if Hasoption('Kfzp') then Kfzp:=strtofloat(GetOptionValue('Kfzp')) else Kfzp:=0.01;
  if Hasoption('v0') then v0:=strtofloat(GetOptionValue('v0')) else v0:=0.018;
  if Hasoption('vfzp') then vfzp:=strtofloat(GetOptionValue('vfzp')) else vfzp:=0.01;

  if Hasoption('a_erer') then a_erer:=strtofloat(GetOptionValue('a_erer')) else a_erer:=1.0;
  if Hasoption('b_erero') then b_erero:=strtofloat(GetOptionValue('b_erero')) else b_erero:=2000.0;
  if Hasoption('b_erdepo') then b_erdepo:=strtofloat(GetOptionValue('b_erdepo')) else b_erdepo:=2000.0;

  if Hasoption('time_step') then time_step:=strtoint(GetOptionValue('time_step')) else time_step:=5;

 // if Hasoption('unstable') then unstable:=strtoboolean(GetOptionValue('unstable')) else unstable:=FALSE;

end;

procedure TWATEMApplication.DoRun;
var
  Time:String;
  ErrorMsg: String;
begin

StartClock;
writeln('WATEM V3 BETA version July 2014');
writeln('Reference: Van Oost et al 2000, Landscape Ecology');
Set_Parameter_Values;

writeln('Reading data');
GetRFile(DTM,dtmfilename);
GetRFile(RKCP,RKCPfilename);
GetRFile(ktc,ktcfilename);
Get32bitGFile(LS,prcfilename,PRC); // LS is temp RRaster to read in parcel
Allocate_Memory;
writeln('Reading data ... done');
//
////CalculateSlopeAspect;
//writeln('topo calculations');
//Topo_Calculations(ra,DTM, LS, SLOPE, ASPECT, UPAREA, TFCA);
//Water(WATEREROS, LS, RKCP, ktc, TFCA, ra, BD);
//writeln('Water Erosion Module');
//writeIdrisi32file(ncol,nrow, outfilename, WATEREROS);
//writeIdrisi32file(ncol,nrow, ChangeFileExt(outfilename,'')+'_LS', LS);
//writeIdrisi32file(ncol,nrow, ChangeFileExt(outfilename,'')+'_uparea', UPAREA);

carbon;
export_txt;

writeln('Writing Output');
Release_Memory;
Time:=StopClock;
  Writeln('Program Execution Time: ',Time,' sec');

Terminate;
end;

constructor TWATEMApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TWATEMApplication.Destroy;
begin
  inherited Destroy;
end;

procedure TWATEMApplication.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ',ExeName,' -h');
end;

var
  Application: TWATEMApplication;
begin
  Application:=TWATEMApplication.Create(nil);
  Application.Title:='Watem';
  Application.Run;
  Application.Free;
end.

