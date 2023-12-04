#!/usr/bin/bash

INC_DIRS="-I/software/include -I/software/mod/modO/Linux.intel.64.intelmpi.default"
LIB_DIRS="-L/software/lib -L/software/lib/libO/Linux.intel.64.intelmpi.default"
LIBS="-lesmf -lpnetcdf -lnetcdff -lnetcdf -lhdf5 -lpioc"

ml purge
ml Apptainer

# compile test_netcdf
apptainer exec ../esmfenv83.sif mpiifort $INC_DIRS test_netcdf.f90 -o test_netcdf $LIB_DIRS $LIBS

# compile test_esmf
apptainer exec ../esmfenv83.sif mpiifort $INC_DIRS test_esmf.f90 -o test_esmf $LIB_DIRS $LIBS
