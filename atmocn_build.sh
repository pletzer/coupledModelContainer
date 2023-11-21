#!/usr/bin/bash
# Instructions on how to build the coupler in an apptainer container. These instructions
# should be executed by the container's shell
# apptainer shell esmfenv84.sif
# with esmfenv84.sif having been downloaded by
# apptainer pull esmfenv84.sif oras://ghcr.io/pletzer/coupled_model_apptainer_esmfenv84:latest


# get the code
git clone git@github.com:alenamalyarenko/pskrips
cd pskrips
git checkout x_ap

export WRF_DIR=$(pwd)/models/PWRF/PWRF-4.1.3_PSKRIPSv1.0/
export PWRF_DIR=$WRF_DIR
export MITGCM_DIR=$(pwd)/models/MITgcm-checkpoint67m
export PSKRIPS_DIR=$(pwd)/models/PSKRIPS/PSKRIPSv1/
export SKRIPS_DIR=$(pwd)/models/PSKRIPS/scripps_kaust_model-2.0a/scripps_kaust_model-master
export MITGCM_OPT=linux_amd64_ifort_coupled
export ESMF_OS=Linux
export SKRIPS_NETCDF_INCLUDE=-I$NETCDF_INC
export SKRIPS_NETCDF_LIB=-L$NETCDF_LIB
export SKRIPS_MPI_DIR=$MPI_DIR
export ESMF_LIB=$ESMF_LIB_DIR
export ESMFMKFILE=$ESMF_LIB/esmf.mk
export LD_LIBRARY_PATH=$ESMF_LIB/${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}

# compile PWRF
cd models/PWRF/PWRF-4.1.3_PSKRIPSv1.0
./clean -a
./clean -a
# clean removes the configure.wrf file
cp ../configure_apptainer.wrf configure.wrf
echo "compiling PWRF"
./compile em_real >& compile.log
tail -40 compile.log

echo "compiling mitgcm..."
cd ../../PSKRIPS/PSKRIPSv1/
cp mitCode_PSKRIPS/* code/ # copy the scripts to install MITGCM
cd build
./makescript_fwd.sio.shaheen ${MITGCM_DIR} # install MITGCM, generate *.f files

# should have mitgcmuv created in this directory

cp ${MPI_DIR}/include/mpif* . 
./mkmod.sh ocn # install MITGCM as a library, generate *.mod files
cd ..

# build the test coupler
#mkdir coupledCode
cp coupledCode_PSKRIPS/* coupledCode/ 
cd coupledCode
./Allmake.sh
if [ -f ./esmf_application ]; then 
    echo "esmf_application was successfully built"
fi
