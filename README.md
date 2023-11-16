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

## How to remotely fectch a container

For instance,
```
apptainer pull emsfenv.sif oras://ghcr.io/pletzer/test_apptainer_deploy_esmfenv84:latest
```

To run any executable, e.g. WRF, within the container, type
```
apptainer exec wrf.sif /software/WRF-4.1.1/main/wrf.exe
```
where "/software/WRF-4.1.1/main/wrf.exe" is the full path to the executable stored inside the container. Additional options can be passed to this executable if desired.

## MPI code running under SLURM

MPI calls can be delegated from inside the container to the host, which, in the case of SLURM, will manage resources. For instance, 
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
srun apptainer exec -B /opt/slurm/lib64/ wrf.sif /software/WRF-4.1.1/main/wrf.exe
```
will assign 40 MPI tasks to the containerized executable.

For this to work, the MPI version inside the container has to match that on the host. The images are built using 
```
Apptainer> mpiexec --version
Intel(R) MPI Library for Linux* OS, Version 2021.8 Build 20221129 (id: 339ec755a1)
Copyright 2003-2022, Intel Corporation.
```
On mahuika, we have
```
ml Apptainer
ml intel
$ mpiexec --version
Intel(R) MPI Library for Linux* OS, Version 2021.5 Build 20211102 (id: 9279b7d62)
Copyright 2003-2021, Intel Corporation.
```

## Mounted directories

You will likely need to access data stored on NeSI's file system. As built, the image will mount:

 * /nesi/nobackup
 * /nesi/project
 * /home

So you can 
```bash
...
cd <wrf_input_dir>

ml intel
export I_MPI_FABRICS=ofi

srun apptainer exec -B /opt/slurm/lib64/ wrf.sif /software/WRF-4.1.1/main/wrf.exe
```
and run the application therein.

## Setup on NeSI's mahuika platform

To access the "apptainer" command, type
"""
ml Apptainer/1.2.2
"""

## How to build wrf.sif

Type
```bash
sbatch wrf_build.sl
```
to build the wrf container. This will take definition file "wrf.def" and build the image "wrf.sif" from it.

You can check that the "sif" file built correcty by typing
```
apptainer shell wrf.sif
```
You will land in a shell environment. You may type any Unix command. For instance, check that the executable "wrf.exe" has been 
built:
```
Apptainer> ls -l /software/WRF-4.1.1/main/wrf.exe
-rwxrwxr-x 1 root root 57364712 Oct 17 20:23 /software/WRF-4.1.1/main/wrf.exe
```
Type "exit" to leave the shell. 

