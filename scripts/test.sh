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
    TEST_CODE=test_vq.py
else
    TEST_CODE=test_pred.py
fi

exp_dir=RUN/${dataset}/${exp_name}
model_dir=${exp_dir}/model
result_dir=${exp_dir}/result

mkdir -p ${model_dir} ${result_dir}

now=$(date +"%Y%m%d_%H%M%S")
export PYTHONPATH=./

$PYTHON -u main/${TEST_CODE} \
 --config=${config} \
 save_folder ${result_dir} \
 model_path ${model_dir}/model.pth.tar \
 2>&1 | tee ${exp_dir}/test-$now.log
