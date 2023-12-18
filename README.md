# Coupled Model Container
Collection of definition files for creating containerized coupled models

## Overview

The containerization of an executable, be it a coupled model or the WRF code, allows you to freely move the executable to other platforms, which may run different operating systems. In effect the containerization protects you from variations in operating systems, including future updates. 

The executable is encoded in a "container image", a file that contains the executable with its dependencies (compilers, tools, libraries and operating system). In the case of "Apptainer", this is a "sif" file, for instance "esmfenv86.sif". 

## Setup on NeSI's mahuika platform

To access the "apptainer" command, type
```
ml Apptainer/1.2.2
```

Note: some operations like `apptainer pull` will cache files, by default in your home directory. In order to avoid hitting your `$HOME` disk storage quota on NeSI platform, we recommend to
```
export APPTAINER_CACHEDIR=/nesi/nobackup/YOUR_PROJECT/tmp
```

## Building an executable using a containerized environment

These instructions assume you have cloned this repository
```
git clone git@github.com:pletzer/coupled_model_apptainer.git
```
or, alternatively,
```
git clone https://github.com/pletzer/coupled_model_apptainer.git
```
and have navigated into the `coupled_model_apptainer` directory:
```
cd coupled_model_apptainer
```


You will need to fetch a container with pre-installed compilers (Intel and MPI) and libraries (HDF5, NetCDF and 
ESMF). Different versions of ESMF can be downloaded, e.g. ESMF 8.6

```
apptainer pull esmfenv86.sif oras://ghcr.io/pletzer/coupled_model_apptainer_esmfenv86:latest
```
This could take some time as the image's size is about 5GB. 

Occasionally, you may get an error such as
```
FATAL:   While pulling image from oci registry: error fetching image to cache: unable to Download Image: unable to pull from registry: failed to copy: ...
```
Try again and it should work.

Once the image is downloaded start the container
```
apptainer shell esmfenv86.sif
```
You will now be in the container's shell -- the look and feel will be that of a simple Linux system with basic tools and 
the `vim` editor installed. 

Note: you cannot change the environment, i.e. you cannot install anything in the container once it has been built (although there may be ways around this). 

Some directories (`/nesi/project` etc, see below) are automatically mounted by the apptainer shell -- you can build code in these mounted directories. Naturally, any executable built by the container can only be run within the container, see section below.

You can check your environment, e.g.
```
Apptainer> mpiifort --version
ifort (IFORT) 2021.8.0 20221119
Copyright (C) 1985-2022 Intel Corporation.  All rights reserved.
```
NetCDF and other libraries are installed under `/software/lib` and the include  and Fortran module files are under `/software/include`. The ESMF libraries are installed under
```
Apptainer> ls /software/lib/libO/Linux.intel.64.intelmpi.default/
esmf.mk    libesmf.so		    libesmftrace_static.a  preload.sh
libesmf.a  libesmftrace_preload.so  libpioc.a
```
File `/software/lib/libO/Linux.intel.64.intelmpi.default/esmf.mk` will reveal ESMF version and the compiler settings used to build the library.

## Mounted directories

You will likely need to access data stored on NeSI's file system. As built, the image will mount:

 * /nesi/nobackup
 * /nesi/project
 * /home


## Building the coupled model

To build the coupled atmosphere-ocean code, type 
```
Apptainer> git clone git@github.com:alenamalyarenko/pskrips
Apptainer> cd pskrips
Apptainer> git fetch --all
Apptainer> git checkout app_avx
Apptainer> bash install_model_for_alex_pletzer.sh
```
in any of the mounted directories. The build process could take several hours. Note: you can build the coupled model in any directory. 


The coupled model application is called `esmf_application`:
```
Apptainer> find . -name esmf_application
models/PSKRIPS/PSKRIPSv2/coupledCode/esmf_application
```
Exit the container shell with
```
Apptainer> exit
```

## Running the coupled model

The MPI calls of the `esmf_application` can be delegated from inside the container to the host. This is required when running on multiple nodes and in order to achieve the best performance, 
since the MPI version inside the container does not know about the hardware on the host.

Below we show an example of a SLURM script that runs `esmf_application` from within the container. 
```bash
...
#SBATCH --ntasks = 48
#SBATCH --partition = milan
#SBATCH --hint = nomultithread # the default is multithread on mahuika
...
module load Apptainer
module load intel        # load the Intel MPI
export I_MPI_FABRICS=ofi # turn off shm to allow the code to run on multiple nodes

# -B /opt/slurm/lib64/ binds this directory to the image when running on mahuika, 
# it is required  for the image's MPI to find the libpmi2.so library. This path
# may be different on a different host.
SIF_FILE="PATH_TO/esmfenv86.sif"
ESMF_APP="PATH_TO/esmf_application"
srun apptainer exec -B /opt/slurm/lib64/ $SIF_FILE $ESMF_APP
```


