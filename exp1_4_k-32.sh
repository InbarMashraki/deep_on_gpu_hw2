cat << 'EOF' > your_script.sh
#!/bin/bash

# Ensure the script exits if any command fails
set -e
NUM_NODES=1
NUM_CORES=2
NUM_GPUS=1
MAIL_USER="inbar.m@campus.technion.ac.il"
MAIL_TYPE=ALL # Valid values are NONE, BEGIN, END, FAIL, REQUEUE, ALL
# Define the output directory
OUTPUT_DIR="/home/inbar.m/hw/deep_on_gpu_hw2/out"

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Function to run experiment 1.4
run_exp_1_4(){
  K=(32)
  LS=(8 16 32)
  # Loop through each configuration and submit the experiment
  for L in "\${LS[@]}"; do
      RUN_NAME="exp1_4_\${L}_K\${K[0]}"
      
      sbatch \
        -N \$NUM_NODES \
        -c \$NUM_CORES \
        --gres=gpu:\$NUM_GPUS \
        --job-name "\${RUN_NAME}" \
        --mail-user \$MAIL_USER \
        --mail-type \$MAIL_TYPE \
        -o "\${OUTPUT_DIR}/\${RUN_NAME}.out" \
        <<EOF
#!/bin/bash
echo "*** SLURM BATCH JOB '\${RUN_NAME}' STARTING ***"

# Setup the conda env
source \$HOME/miniconda3/etc/profile.d/conda.sh
conda activate cs236781-hw

# Run the experiment
python -m hw2.experiments run-exp -n "exp1_4" \
    --seed 42 --bs-train 32 --batches 1500 --bs-test 32 \
    --epochs 30 --early-stopping 3 \
    --filters-per-layer \${K[0]} --layers-per-block \${L} \
    --pool-every 4 --hidden-dims 128 \
    --lr 1e-4 --reg 1e-4 --model-type ResNet \
    --out-dir /home/inbar.m/hw/deep_on_gpu_hw2/results

echo "*** SLURM BATCH JOB '\${RUN_NAME}' DONE ***"
EOF
  done
}

# Call the function to run experiment 1.4
run_exp_1_4
EOF
