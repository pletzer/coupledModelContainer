# coupledModelContainer
Collection of definition files for creating containerized coupled models

### WRF

On NeSI's mahuika platform, type
```bash
ml Apptainer
sbatch wrf_build.sl
```
to build the wrf container

Once the job finishes, a file wrf.sif will be created. You can execute a command inside the container using the syntax
```bash
apptainer exec wrf.sif <command>
```

Examples:
```bash
apptainer exec wrf.sif ls /nesi/project
```

