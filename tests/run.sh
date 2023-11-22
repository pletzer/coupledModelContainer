#!/usr/bin/bash

ml purge
ml Apptainer

# run test_netcdf
apptainer exec ../esmfenv83.sif ./test_netcdf

# run test_esmf
apptainer exec ../esmfenv83.sif ./test_esmf
