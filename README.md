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

To run any executable, e.g. WRF, within the container, type
```
apptainer exec wrf.sif /software/WRF-4.1.1/main/wrf.exe
```
where "/software/WRF-4.1.1/main/wrf.exe" is the full path to the executable stored inside the container. Additional options can be passed to this executable if desired.

## MPI code running under SLURM

MPI calls can be delegated from inside the container to the host, which, in the case of SLURM, will manage resources. For instance, 
```
...
#SBATCH --ntasks = 40
...
srun apptainer exec wrf.sif /software/WRF-4.1.1/main/wrf.exe
```
will assign 40 MPI tasks to the containerized executable.


## Mounted directories

You will likely need to access data stored on NeSI's file system. As built, the image will mount:

 * /nesi/nobackup
 * /nesi/project
 * /home

So you can 
```
...
cd <wrf_input_dir>
srun apptainer exec wrf.sif /software/WRF-4.1.1/main/wrf.exe
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

