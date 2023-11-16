# coupledModelContainer
Collection of definition files for creating containerized coupled models

## Overview

The containerization of an executable, be it a coupled model or the WRF code, allows you to freely move the executable to other platforms, which may run different operating systems. In effect the containerization insulates you from variations in operating systems, including future updates. 

The executable is encoded in a "container image", a static file that contains the executable with its dependencies (compilers, tools, libraries and operating system). In the case of "Apptainer", this is a "sif" file, for instance "wrf.sif". 

## Setup on NeSI's mahuika platform

To access the "apptainer" command, type
"""
ml Apptainer/1.2.2
"""

## Building an executable using a containerized environment

You will need to fetch a container with pre-installed compilers (Intel and MPI) and libraries (HDF5, NetCDF and 
ESMF). Different versions of ESMF can be downloaded, e.g. ESMF 8.4

```
apptainer pull emsfenv84.sif oras://ghcr.io/pletzer/test_apptainer_deploy_esmfenv84:latest
```
This could take some time as the image is about 5GB. Once the image is downloaded start the container
```
apptainer shell esmfenv84.sif
```
You will now be in the container's shell -- the look and feel will be that of a simple Linux with basic tools and 
the `vim` editor installed. Note: you can change the environment. However, given that some directories (`/nesi/project` etc, see below) are automatically mounted you can build code in these directories using the container environment. Naturally, any executable built by
the container can only be run within the container, see section below.

You can check your environment, e.g.
```
Apptainer> mpiifort --version
ifort (IFORT) 2021.8.0 20221119
Copyright (C) 1985-2022 Intel Corporation.  All rights reserved.
```
NetCDF and other libraries are installed under `/software/lib` and the include files are under `/software/include`. The ESMF libraries are installed under
```
Apptainer> ls /software/lib/libO/Linux.intel.64.intelmpi.default/
esmf.mk    libesmf.so		    libesmftrace_static.a  preload.sh
libesmf.a  libesmftrace_preload.so  libpioc.a
```

To build the coupled atmosphere-ocean code, type
```
bash atmocn_build.sh
```
This will download the coupled code (you will need access to the `pskrips` repo), build the PWRF libraries, mitGCM and the ESMF executable `esmf_application`:
```
Apptainer> find pskrips/ -name esmf_application
pskrips/models/PSKRIPS/PSKRIPSv1/coupledCode/esmf_application
```
Exit the container shell with
```
Apptainer> exit
```

## Running the coupled model

The MPI calls of the `esmf_application` can be delegated from inside the container to the host. This is desirable since 
the MPI version inside the container does not have enough information to achieve the best parallel execution performance 
given the hardware on the host. It may also be necessary when running on multiple nodes.

Below we show an example of a SLURM script that runs `esmf_application` from within the container. 
```bash
...
#SBATCH --ntasks = 40
...
module load Apptainer
module load intel        # load the Intel MPI
export I_MPI_FABRICS=ofi # turn off shm to allow the code to run on multiple nodes

# -B /opt/slurm/lib64/ binds this directory to the image when running on mahuika, 
# it is required  for the image's MPI to find the libpmi2.so library. This path
# may be different on a different host.
srun apptainer exec -B /opt/slurm/lib64/ esmfenv84.sif pskrips/models/PSKRIPS/PSKRIPSv1/coupledCode/esmf_application
```

It is likely that fo this to work, the MPI version inside the container must match that on the host. The images are built using 
```
Apptainer> mpiexec --version
Intel(R) MPI Library for Linux* OS, Version 2021.8 Build 20221129 (id: 339ec755a1)
Copyright 2003-2022, Intel Corporation.
```
whereas on mahuika, we have
```
ml Apptainer
ml intel
$ mpiexec --version
Intel(R) MPI Library for Linux* OS, Version 2021.5 Build 20211102 (id: 9279b7d62)
Copyright 2003-2021, Intel Corporation.
```
so there is a slight difference of versions, which does not appear to affect the execution.

## Mounted directories

You will likely need to access data stored on NeSI's file system. As built, the image will mount:

 * /nesi/nobackup
 * /nesi/project
 * /home

