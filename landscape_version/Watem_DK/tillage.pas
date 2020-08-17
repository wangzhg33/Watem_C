unit tillage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,  RData, Surface, variables;

Procedure tillage_dif;

implementation

var
SEDI_OUT: RRaster;
SEDI_IN : RRaster;

Procedure tillage_dif;// Based on Watem Tillage model
var
plowvol:double;
i,j,k,l,m,n,o,p,count:integer;
CSN,SN,PART1,PART2 : double;
asp : double;
k1,l1,k2,l2:smallint;
K3,aspectgrid:double;
SEDI_IN, CS_IN, OUTM,CSOUT:Rraster;
adjust,area, ploweros : double;
outflux, outprop, outflux_CY, outflux_CO : double;
begin
// Create temp 2D maps
SetDynamicRData(SEDI_IN);
SetDynamicRData(SEDI_OUT);

//************************

//CalculateSlopeAspect;

for i := 1 to nrow do
 for j := 1 to ncol do
 BEGIN // begin eerste matrix-lus

  If PRC[i,j]<10 then continue;
  K3:= KTIL;

 if Raster_projection=plane then area:=sqr(res)
 else  area:=X_Resolution(i,j)*Y_Resolution(i,j);
 aspectgrid:=CalculateASPECT(i,j);

 // Calculate Sediment (OUTM) & Carbon (CSOUT) outflow for cell i,j
 ADJUST := ABS(cos(aspectgrid))+ABS(sin(aspectgrid));
 outflux:=K3*sin(CalculateSlope(i,j))*RES*ADJUST/BD; //OUTFLOW in m3
 outprop:=(outflux/(PDEPTH*area));
 //////

 // Calculate distribution of outflow flux over neighbours using flux decomposition algorithm (Desmet & Govers, 1997)
 PART1 := 0.0; PART2 := 0.0;
 k1:=0;l1:=0;k2:=0;l2:=0;
 CSN:=(ABS(cos(aspectgrid)))/(ABS(SIN(aspectgrid))+ABS(COS(aspectgrid)));
 SN :=(ABS(sin(aspectgrid)))/(ABS(SIN(aspectgrid))+ABS(COS(aspectgrid)));
 asp:=aspectgrid*(180/PI); //aspect from rad to degress

 IF (asp >= 0.0) AND (asp <= 90.0) THEN  BEGIN
        PART1 := CSN;
PART2 := SN;
K1 := -1;L1 := 0 ;K2 := 0 ;L2 := 1 ;  END else
 BEGIN
      IF (asp > 90.0) AND (asp < 180.0) THEN BEGIN
 PART1 := SN;
 PART2 := CSN;
 K1 := 0; L1 := 1; K2 := 1; L2 := 0; END else
      BEGIN
       IF (asp >= 180.0)AND (asp<= 270.0) THEN  BEGIN
   PART1 := CSN;
   PART2 := SN;
   K1 := 1; L1 := 0; K2 := 0; L2 := -1; end else
       BEGIN
        IF (asp>270.0)then begin
   PART1 := SN;
   PART2 := CSN;
   K1 := 0; L1 := -1;K2 := -1; L2 := 0; END;
       END;END;END;
  ///////////////
 If (PRC[i+K1,j+L1]=PRC[i,j]) then
 begin
  SEDI_OUT[i,j]:=SEDI_OUT[i,j]+PART1*outflux;
  SEDI_IN[i+K1,j+L1]:= SEDI_IN[i+K1,j+L1]+PART1*outflux;

  end;

 If (PRC[i+K2,j+L2]=PRC[i,j]) then
 begin
  SEDI_OUT[i,j]:=SEDI_OUT[i,j]+PART2*outflux;
  SEDI_IN[i+K2,j+L2]:= SEDI_IN[i+K2,j+L2]+PART2*outflux  ;
  end;

 END; //einde matrixlus

for o := 1 to nrow do  // tweede matrixlus nadat alle in- en outfluxen berekend zijn
 for p := 1 to ncol do
BEGIN
    If PRC[o,p]<10 then continue;
    if Raster_projection=plane then area:=sqr(res)
     else  area:=X_Resolution(i,j)*Y_Resolution(i,j);
    ploweros:=(SEDI_IN[o,p]-SEDI_OUT[o,p])/area;   // unit: m
    TILEROS[o,p]:=ploweros;

END;//                                     Einde  tweede matrixlus

//update profiles in response to erosion/deposition

// Dispose Temp 2D maps
 DisposeDynamicRdata(SEDI_IN);
 DisposeDynamicRdata(SEDI_OUT);
 //********************
end;




end.


