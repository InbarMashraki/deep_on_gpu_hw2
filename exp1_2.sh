#!/bin/bash

# Ensure the script exits if any command fails
set -e
NUM_NODES=1
NUM_CORES=2
NUM_GPUS=1
MAIL_USER="yonathanw@campus.technion.ac.il"
MAIL_TYPE=ALL # Valid values are NONE, BEGIN, END, FAIL, REQUEUE, ALL
# Define the output directory
OUTPUT_DIR="/home/yonathanw/CS236781/Homework2/out"

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_DIR


# Function to run experiment 1.1
run_exp_1_2(){
  KS=(32 64 128)
  LS=(8)
  # Loop through each configuration and submit the experiment
  for K in "${KS[@]}"; do
      for L in "${LS[@]}"; do
          RUN_NAME="exp1_2_L${L}_K${K}"

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
conda activate cs236781-hw2-git

# Run the experiment
python -m hw2.experiments run-exp -n "exp1_2" \
    --seed 42 --bs-train 64 --batches 1500 --bs-test 64 \
    --epochs 20 --early-stopping 5 \
    --filters-per-layer ${K} --layers-per-block ${L} \
    --pool-every 6 --hidden-dims 128\
    --lr 4e-4 --reg 5e-4 --model-type cnn \
    --out-dir /home/yonathanw/CS236781/Homework2/results

echo "*** SLURM BATCH JOB '${RUN_NAME}' DONE ***"
EOF
      done
  done
}

# Call the function to run experiment 1.2
run_exp_1_2
