Landscape version:
The model is programmed in Pascal. The codes are in the folder of 'WATEM_DK'. An executable file can be generated from the codes. The folder of 'test' contains an example of the application of the model. This example is consistent of input data，an executable file and a R script. To run the R script, the following packages should be installed: tools, raster, sp, rstudio, stats, grDevices, utils, datasets, methods, base, graphics.
Profile version:
An example of run the soil profile version (reference_scenario.m) is presented in the code files. The users should first assign values of relevant parameters (see Table 1 for the names and descriptions of these variables), and then run the three main C cycling processes: ‘C_initialization’, ‘C_equilibrium’, ‘carbon’.
