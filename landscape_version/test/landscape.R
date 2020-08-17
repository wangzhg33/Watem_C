# Scenario with erosion

rm(list=ls())
graphics.off()
options(scipen = 999)
###### Set root folder

scena_no<-3

current_dir <-getwd()

setwd(paste(current_dir,'Catchments',sep='/'))
#setwd("H:/integrate_model/Calibration/Catchments")

library(raster)
library(tools)
library(ggplot2)
library(readr)

logi_crop <- FALSE
e <- extent(2585022+6.25*10,2585085+6.25*10,5622409,5622472)

input_dir <- "input_data"
work_dir <- "data"

###### LAND USE
parcel_fileName <- "PARCEL.tif"
PARCEL <- raster(paste(input_dir,parcel_fileName,sep='/'))
if (logi_crop==TRUE) {PARCEL<-crop(PARCEL,e)}
writeRaster(PARCEL, filename =paste0(work_dir,'/LAND_USE.RST'),            
            format ='IDRISI',NAflag =0, datatype ="INT2S",overwrite =TRUE)

######## C Factor
Cfactor_fileName <- "C_factor.tif"
C <- raster(paste(input_dir,Cfactor_fileName,sep='/'))
if (logi_crop==TRUE) {C<-crop(C,e)}
writeRaster(C, filename = paste0(work_dir,'/C_factor.RST'),
            format = "IDRISI",NAflag = 0,datatype = "FLT4S",overwrite = TRUE) 

######## K Factor
Kfactor_fileName <- "K_factor.tif"
K <- raster(paste(input_dir,Kfactor_fileName,sep='/'))
if (logi_crop==TRUE) {K<-crop(K,e)}
writeRaster(K, filename = paste0(work_dir,'/K_factor.RST'),
            format = "IDRISI",NAflag = 0,datatype = "FLT4S",overwrite = TRUE)

######## P Factor
Pfactor_fileName <- "P_factor.tif"
P <- raster(paste(input_dir,Pfactor_fileName,sep='/'))
if (logi_crop==TRUE) {P<-crop(P,e)}
writeRaster(P, filename = paste0(work_dir,'/P_factor.RST'),
            format = "IDRISI",NAflag = 0,datatype = "FLT4S",overwrite = TRUE) 

######## R Factor
Rfactor_fileName <- "R_factor.tif"
R <- raster(paste(input_dir,Rfactor_fileName,sep='/'))
if (logi_crop==TRUE) {R<-crop(R,e)}
writeRaster(R, filename = paste0(work_dir,'/R_factor.RST'),
            format = "IDRISI",NAflag = 0,datatype = "FLT4S",overwrite = TRUE) 

######## RKP multiplication
RKP<-R*K*P/1000

writeRaster(RKP, filename = paste0(work_dir,'/RKP.RST'),
            format = "IDRISI",NAflag = 0,datatype = "FLT4S",overwrite = TRUE) 

# DEM
DEM_fileName <- "DEM.tif"
DEM <- raster(paste(input_dir,DEM_fileName,sep='/'))
if (logi_crop==TRUE) {DEM<-crop(DEM,e)}
writeRaster(DEM, filename = paste0(work_dir,'/DEM.RST'),
            format = "IDRISI",NAflag = 0,datatype = "FLT4S",overwrite = TRUE) 

ktc <- raster(paste(input_dir,parcel_fileName,sep='/'))
if (logi_crop==TRUE) {ktc<-crop(ktc,e)}
writeRaster(ktc, filename = paste0(work_dir,"/KTC.rst"),
            format = "IDRISI",NAflag = 0,datatype = "INT2S",overwrite = TRUE) 

# RUN landscape model ########################
# write command


### close erosion by setting start year and end year
### close diffusion and advection by setting K0 and v0


erosion_start_year <- 1967
erosion_end_year <- 2000

## variables for C cycling
depth_interval <- 1
depth <- 50

tillage_depth <- 1

deltaC13_ini_top <- -27.0
deltaC13_ini_bot <- -26.0
deltaC14_ini_top <- 50.0
deltaC14_ini_bot <- -500.0

time_equilibrium <- 1000
k1 <- 2.1
k2 <- 0.03
k3 <- 0.002
hAS <- 0.12
hAP <- 0.01
hSP <- 0.01
r0 <- 1
C_input <- 2.0 ##input from root
C_input2 <- 0.5## input from manure, residue
r_exp <- 3.30
i_exp <- 20
C13_discri <- 0.9977
C14_discri <- 0.996
deltaC13_input_default <- -29.0
deltaC14_input_default <- 100.0
Cs137_input_default <- 0.0

Sand_ini_top <- 15
Silt_ini_top <- 70
Clay_ini_top <- 15
Sand_ini_bot <- 15
Silt_ini_bot <- 70
Clay_ini_bot <- 15

K0 <- 0.09
Kfzp <- 0.01
v0 <- 0.018
vfzp <- 0.01

a_erer <- 1.0
b_erero <- 2000.0
b_erdepo <- -4000.0

time_step <- 1

unstable <- FALSE              


temp_k <- 1

for (temp_data_1 in 1:1) {
  
  ktc <- raster(paste(input_dir,parcel_fileName,sep='/'))
  
  ktc <- ktc*3
  
  if (logi_crop==TRUE) {ktc<-crop(ktc,e)}
  writeRaster(ktc, filename = paste0(work_dir,"/KTC.rst"),
              format = "IDRISI",NAflag = 0,datatype = "INT2S",overwrite = TRUE) 
  
  for (temp_data_2 in 1:1){
    
    
    RKP<-R*K*P/10000
    
    writeRaster(RKP, filename = paste0(work_dir,'/RKP.RST'),
                format = "IDRISI",NAflag = 0,datatype = "FLT4S",overwrite = TRUE) 
    
    
    cmd <- paste0("WATEM_DK.exe -dir ",work_dir,
                  " -o ","output",
                  " -d ","DEM.rst",
                  " -p ","LAND_USE.rst",
                  " -u ","RKP.rst",
                  " -c ","C_factor.rst",
                  " -k ","KTC.rst",
                  " -MC_f 1 -t 100 -r mf -b 1400 -ktil 0 -pdep 25 -frac 0 -w 1 -w_d_exp 0",
                  " -C_input ", toString(format(C_input,nsmall=3)),
                  " -C_input2 ", toString(format(C_input2,nsmall=3)),
                  " -depth ", toString(depth),
                  " -depth_interval ",toString(depth_interval),
                  " -tillage_depth ",toString(tillage_depth),
                  " -time_equilibrium ", toString(time_equilibrium),
                  " -erosion_start_year ", toString(erosion_start_year),
                  " -erosion_end_year ",toString(erosion_end_year),
                  " -k1 ",toString(format(k1,nsmall=3))," -k2 ",toString(format(k2,nsmall=3)),
                  " -k3 ",toString(format(k3,nsmall=3)),
                  " -hAS ",toString(format(hAS,nsmall=3))," -hAP ",toString(format(hAP,nsmall=3)),
                  " -hSP ",toString(format(hSP,nsmall=3)),                
                  " -r_exp ",toString(format(r_exp,nsmall=3))," -i_exp ",toString(format(i_exp,nsmall=3)),
                  " -a_erer ",toString(format(a_erer,nsmall=3))," -b_erero ",toString(format(b_erero,nsmall=3)),
                  #                " -b_erdepo ",toString(format(b_erdepo,nsmall=3)),                  
                  " -K0 ",toString(format(K0,nsmall=3))," -Kfzp ",toString(format(Kfzp,nsmall=3)),
                  " -v0 ",toString(format(v0,nsmall=3))," -vfzp ",toString(format(vfzp,nsmall=3)),                
                  " -C13_discri ",toString(format(C13_discri,nsmall=3)),
                  " -C14_discri ",toString(format(C14_discri,nsmall=3)),
                  #               " -deltaC13_input ",toString(format(deltaC13_input,nsmall=3)),
                  " -deltaC14_input_default ",toString(format(deltaC14_input_default,nsmall=3)),
                  " -Cs137_input_default ",toString(format(Cs137_input_default,nsmall=3)),                
                  " -time_step ",toString(time_step),
                  " -c14input ","C14input.txt",
                  " -c13input ","C13input.txt",
                  " -Cs137input ","Cs137_input.txt")
    
    
    # run command
    system(cmd)
    
    Ero <- raster(paste0(work_dir,'/output/Werodep_in_m.rst'))
    
    C_stock <- raster(paste0(work_dir,'/output/C_stock.rst'))
    A12_erosion <- raster(paste0(work_dir,'/output/A12_erosion.rst'))
    S12_erosion <- raster(paste0(work_dir,'/output/S12_erosion.rst'))
    P12_erosion <- raster(paste0(work_dir,'/output/P12_erosion.rst'))
    
    A12_1 <- raster(paste0(work_dir,'/output/A12_1.rst'))
    S12_1 <- raster(paste0(work_dir,'/output/S12_1.rst'))
    P12_1 <- raster(paste0(work_dir,'/output/P12_1.rst'))
    
    
    C12_erosion <- A12_erosion + S12_erosion + P12_erosion
    
    C12_1 <- A12_1 + S12_1 + P12_1
    
    ratio <- C12_erosion/Ero
    
    
    row_num=nrow(C_stock)
    col_num=ncol(C_stock)
    
    
    PDB <- 0.0112372
    
  
    data_a12 <- read.table(paste0(work_dir,'/A12.txt'))
    data_a12 <- as.matrix(data_a12)
    
    data_s12 <- read.table(paste0(work_dir,'/S12.txt'))
    data_s12 <- as.matrix(data_s12)
  
    data_p12 <- read.table(paste0(work_dir,'/P12.txt'))
    data_p12 <- as.matrix(data_p12)
    
    data_a13 <- read.table(paste0(work_dir,'/A13.txt'))
    data_a13 <- as.matrix(data_a13)
    
    data_s13 <- read.table(paste0(work_dir,'/S13.txt'))
    data_s13 <- as.matrix(data_s13)
    
    data_p13 <- read.table(paste0(work_dir,'/P13.txt'))
    data_p13 <- as.matrix(data_p13)
    
    data_a14 <- read.table(paste0(work_dir,'/A14.txt'))
    data_a14 <- as.matrix(data_a14)
    
    data_s14 <- read.table(paste0(work_dir,'/S14.txt'))
    data_s14 <- as.matrix(data_s14)
    
    data_p14 <- read.table(paste0(work_dir,'/P14.txt'))
    data_p14 <- as.matrix(data_p14)

    data_Cs137 <- read.table(paste0(work_dir,'/Cs137.txt'))
    data_Cs137 <- as.matrix(data_Cs137)
  
    
    # for (i in 1:50){
    #   temp_a12 <- raster(paste0(work_dir,'/output/A12_',i,'.rst'))
    #   temp_a13 <- raster(paste0(work_dir,'/output/A13_',i,'.rst'))
    #   temp_a14 <- raster(paste0(work_dir,'/output/A14_',i,'.rst'))
    #   temp_s12 <- raster(paste0(work_dir,'/output/S12_',i,'.rst'))
    #   temp_s13 <- raster(paste0(work_dir,'/output/S13_',i,'.rst'))
    #   temp_s14 <- raster(paste0(work_dir,'/output/S14_',i,'.rst'))      
    #   temp_p12 <- raster(paste0(work_dir,'/output/P12_',i,'.rst'))
    #   temp_p13 <- raster(paste0(work_dir,'/output/P13_',i,'.rst'))
    #   temp_p14 <- raster(paste0(work_dir,'/output/P14_',i,'.rst'))     
    #   
    #   if (i==1){
    #     A12_1_50 <- temp_a12
    #     A13_1_50 <- temp_a13
    #     A14_1_50 <- temp_a14
    #     S12_1_50 <- temp_s12
    #     S13_1_50 <- temp_s13
    #     S14_1_50 <- temp_s14        
    #     P12_1_50 <- temp_p12
    #     P13_1_50 <- temp_p13
    #     P14_1_50 <- temp_p14        
    #     
    #   }
    #   else {
    #     A12_1_50 <- A12_1_50 + temp_a12
    #     A13_1_50 <- A13_1_50 + temp_a13
    #     A14_1_50 <- A14_1_50 + temp_a14
    #     S12_1_50 <- S12_1_50 + temp_s12
    #     S13_1_50 <- S13_1_50 + temp_s13
    #     S14_1_50 <- S14_1_50 + temp_s14
    #     P12_1_50 <- P12_1_50 + temp_p12
    #     P13_1_50 <- P13_1_50 + temp_p13
    #     P14_1_50 <- P14_1_50 + temp_p14        
    #     
    #   }
    #   
    # }
    
    
    
    
    
    c <- data_a12+data_a13+data_a14+data_s12+data_s13+data_s14+data_p12+data_p13+data_p14
    c12 <- data_a12+data_s12+data_p12
    c13 <- data_a13+data_s13+data_p13
    c14 <- data_a14+data_s14+data_p14
    
    
    
    delta_c13 <- ((data_a13+data_s13+data_p13)/(data_a12+data_s12+data_p12)/PDB-1)*1000
    
    C14C12_ratio_reference<-1.176/1E12
    
    ratio<-(data_a14+data_s14+data_p14)/(data_a12+data_s12+data_p12)  
    C14C12_ratio_SN<-ratio*(1-2*(25+delta_c13)/1000)
    Delta_c14<-(C14C12_ratio_SN/C14C12_ratio_reference-1)*1000
    
    
    C_stock_1_25 <- colSums(c[1:25,])
    C_stock_26_50 <- colSums(c[26:50,])
    
    C_stock_1_25 <-  C_stock_1_25* 1350 /100 /100  # conver from percent to kg / m2
    C_stock_26_50 <- C_stock_26_50 * 1350 /100 /100  # conver from percent to kg / m2
    
    
    delta_c13_1_25 <- colMeans(delta_c13[1:25,])
    delta_c13_26_50 <- colMeans(delta_c13[26:50,])
    
    Delta_c14_1_25 <- colMeans(Delta_c14[1:25,])
    Delta_c14_26_50 <- colMeans(Delta_c14[26:50,])
    
    

    C_stock_1_25 <- matrix(C_stock_1_25,col_num,row_num)
    C_stock_1_25 <- t(C_stock_1_25)
    C_stock_1_25 <- raster(C_stock_1_25)
    writeRaster(C_stock_1_25, filename = paste0(work_dir,'/C_stock_1_25.tif'),
                format = "GTiff",NAflag = 0,datatype = "FLT4S",overwrite = TRUE)
    
    
    C_stock_26_50 <- matrix(C_stock_26_50,col_num,row_num)
    C_stock_26_50 <- t(C_stock_26_50)
    C_stock_26_50 <- raster(C_stock_26_50)
    writeRaster(C_stock_26_50, filename = paste0(work_dir,'/C_stock_26_50.tif'),
                format = "GTiff",NAflag = 0,datatype = "FLT4S",overwrite = TRUE)
    
    delta_c13_1_25 <- matrix(delta_c13_1_25,col_num,row_num)
    delta_c13_1_25 <- t(delta_c13_1_25)
    delta_c13_1_25 <- raster(delta_c13_1_25)
    writeRaster(delta_c13_1_25, filename = paste0(work_dir,'/delta_c13_1_25.tif'),
                format = "GTiff",NAflag = 0,datatype = "FLT4S",overwrite = TRUE)
    
    
    delta_c13_26_50 <- matrix(delta_c13_26_50,col_num,row_num)
    delta_c13_26_50 <- t(delta_c13_26_50)
    delta_c13_26_50 <- raster(delta_c13_26_50)
    writeRaster(delta_c13_26_50, filename = paste0(work_dir,'/delta_c13_26_50.tif'),
                format = "GTiff",NAflag = 0,datatype = "FLT4S",overwrite = TRUE)
    
    
    Delta_c14_1_25 <- matrix(Delta_c14_1_25,col_num,row_num)
    Delta_c14_1_25 <- t(Delta_c14_1_25)
    Delta_c14_1_25 <- raster(Delta_c14_1_25)
    writeRaster(Delta_c14_1_25, filename = paste0(work_dir,'/Delta_c14_1_25.tif'),
                format = "GTiff",NAflag = 0,datatype = "FLT4S",overwrite = TRUE)    
    
    Delta_c14_26_50 <- matrix(Delta_c14_26_50,col_num,row_num)
    Delta_c14_26_50 <- t(Delta_c14_26_50)
    Delta_c14_26_50 <- raster(Delta_c14_26_50)
    writeRaster(Delta_c14_26_50, filename = paste0(work_dir,'/Delta_c14_26_50.tif'),
                format = "GTiff",NAflag = 0,datatype = "FLT4S",overwrite = TRUE)
    
  }
}



setwd("..")

