#!/bin/bash -e
#SBATCH --job-name=atmocn_build
#SBATCH --partition=milan
#SBATCH --time=0-04:00:00
#SBATCH --mem=10GB
#SBATCH --cpus-per-task=2
# load environment module
module purge
module load Apptainer/1.2.2

rm -rf pskrips
apptainer exec esmfenv84.sif bash atmocn_build.sh

