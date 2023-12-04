#!/usr/bin/bash

ml purge
ml Apptainer

# run test_netcdf
srun -p milan apptainer exec ../esmfenv83.sif ./test_netcdf

# run test_esmf
srun -p milan apptainer exec ../esmfenv83.sif ./test_esmf
