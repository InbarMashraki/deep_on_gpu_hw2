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

# Function to run experiment 1.4 for K=(64 128 256) and varying L
run_exp_1_4_L2(){
  K=(64 128 256)
  L=(2 4 8)

  for L in "${L[@]}"; do
      K_STRING=$(IFS="-" ; echo "${K[*]}")
      RUN_NAME="exp1_4_L${L}_K${K_STRING}"
      
      sbatch \
        -N $NUM_NODES \
        -c $NUM_CORES \
        --gres=gpu:$NUM_GPUS \
        --job-name "${RUN_NAME}" \
        --mail-user $MAIL_USER \
        --mail-type $MAIL_TYPE \
        -o "${OUTPUT_DIR}/${RUN_NAME}.out" \
        <<EOF
#!/bin/bash
echo "*** SLURM BATCH JOB '${RUN_NAME}' STARTING ***"

# Setup the conda env
source \$HOME/miniconda3/etc/profile.d/conda.sh
conda activate cs236781-hw

# Run the experiment
python -m hw2.experiments run-exp -n "exp1_4" \
    --seed 42 --bs-train 32 --batches 1500 --bs-test 32 \
    --epochs 30 --early-stopping 3 \
    --filters-per-layer ${K[@]} --layers-per-block ${L} \
    --pool-every 4 --hidden-dims 128 \
    --lr 1e-4 --reg 1e-4 --model-type ResNet \
    --out-dir /home/inbar.m/hw/deep_on_gpu_hw2/results

echo "*** SLURM BATCH JOB '${RUN_NAME}' DONE ***"
EOF
  done
}

# Call the function to run experiment 1.4 for L2
run_exp_1_4_L2