#!/usr/bin/bash

ml purge
ml Apptainer

# run test_netcdf
apptainer exec ../esmfenv84.sif ./test_netcdf

# run test_esmf
#apptainer exec ../esmfenv84.sif "LD_LIBRARY_PATH=/software/lib:/software/lib/libO/Linux.intel.64.intelmpi.default:$LD_LIBRARY_PATH; ./test_esmf"
