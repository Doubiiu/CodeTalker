#!/bin/sh
set -x
set -e
export OMP_NUM_THREADS=10
export KMP_INIT_AT_FORK=FALSE

PYTHON=python3

exp_name=$1
config=$2
dataset=$3
stage=$4

if [ "${stage}" == "s1" ]; then
    TRAIN_CODE=train_vq.py
    TEST_CODE=test_vq.py
    echo "Training for Discrete Motion Prior"
else
    TRAIN_CODE=train_pred.py
    TEST_CODE=test_pred.py
    echo "Training for Speech-Driven Motion Synthesis"
fi


exp_dir=RUN/${dataset}/${exp_name}
model_dir=${exp_dir}/model
result_dir=${exp_dir}/result

now=$(date +"%Y%m%d_%H%M%S")

mkdir -p ${model_dir} ${result_dir}
mkdir -p ${exp_dir}/result

export PYTHONPATH=./
echo $OMP_NUM_THREADS | tee -a ${exp_dir}/train-$now.log
nvidia-smi | tee -a ${exp_dir}/train-$now.log
which pip | tee -a ${exp_dir}/train-$now.log


## TRAIN
$PYTHON -u main/${TRAIN_CODE} \
  --config=${config} \
  save_path ${exp_dir} \
  2>&1 | tee -a ${exp_dir}/train-$now.log

## TEST
$PYTHON -u main/${TEST_CODE} \
  --config=${config} \
  save_folder ${exp_dir}/result \
  model_path ${model_dir}/model.pth.tar \
  2>&1 | tee -a ${exp_dir}/test-$now.log

