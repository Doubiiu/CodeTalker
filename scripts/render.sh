export PYTHONPATH=./
python main/render.py \
--dataset <vocaset|BIWI>  \
--dataset_dir . \
--pred_path RUN/<vocaset|BIWI>/<exp_name>/result/npy/ \
--output_path RUN/<vocaset|BIWI>/<exp_name>/result/render/ 