#!/bin/bash

#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --array=1-10
#SBATCH --partition=statdept,volfovskylab-low,herringlab-low
#SBATCH --account=statdept

singularity exec ../openblasr_geospatial.simg Rscript tps_cv_cluster.R $SLURM_ARRAY_TASK_ID

