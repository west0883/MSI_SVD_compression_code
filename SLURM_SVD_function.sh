#!/bin/bash -l        
#SBATCH --time=7:00:00
#SBATCH --ntasks=1
#SBATCH --mem=350g
#SBATCH --mail-type=ALL  
#SBATCH --mail-user=west0883@umn.edu 
#SBATCH -p ram1t
#SBATCH --array=1087,1088,1096


# Use '%A' for array-job ID, '%J' for job ID and '%a' for task ID

module load matlab
matlab -nodisplay -nodesktop -r "SVD_forMSI_function($SLURM_ARRAY_TASK_ID); exit;"

