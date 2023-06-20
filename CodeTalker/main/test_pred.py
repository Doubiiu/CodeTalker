#!/usr/bin/env python
import os
import cv2
import torch
import numpy as np

from base.utilities import get_parser, get_logger
from models import get_model
from base.baseTrainer import load_state_dict

cfg = get_parser()
os.environ["CUDA_VISIBLE_DEVICES"] = ','.join(str(x) for x in cfg.test_gpu)

cv2.ocl.setUseOpenCL(False)
cv2.setNumThreads(0)


def main():
    global cfg, logger

    logger = get_logger()
    logger.info(cfg)
    logger.info("=> creating model ...")
    model = get_model(cfg)
    model = model.cuda()

    if os.path.isfile(cfg.model_path):
        logger.info("=> loading checkpoint '{}'".format(cfg.model_path))
        checkpoint = torch.load(cfg.model_path, map_location=lambda storage, loc: storage.cpu())
        load_state_dict(model, checkpoint['state_dict'], strict=False)
        logger.info("=> loaded checkpoint '{}'".format(cfg.model_path))
    else:
        raise RuntimeError("=> no checkpoint flound at '{}'".format(cfg.model_path))

    # ####################### Data Loader ####################### #
    from dataset.data_loader import get_dataloaders
    dataset = get_dataloaders(cfg)
    test_loader = dataset['test']

    test(model, test_loader)


def test(model, test_loader):
    model.eval()
    save_folder = os.path.join(cfg.save_folder, 'npy')
    if not os.path.exists(save_folder):
        os.makedirs(save_folder)
    train_subjects_list = [i for i in cfg.train_subjects.split(" ")]

    with torch.no_grad():
        for i, (audio, vertice, template, one_hot_all, file_name) in enumerate(test_loader):
            audio = audio.cuda(non_blocking=True)
            one_hot_all = one_hot_all.cuda(non_blocking=True)
            vertice = vertice.cuda(non_blocking=True)
            template = template.cuda(non_blocking=True)

            train_subject = "_".join(file_name[0].split("_")[:-1])
            if train_subject in train_subjects_list:
                condition_subject = train_subject
                iter = train_subjects_list.index(condition_subject)
                one_hot = one_hot_all[:,iter,:]
                prediction = model.predict(audio, template, one_hot)
                prediction = prediction.squeeze() 
                np.save(os.path.join(save_folder, file_name[0].split(".")[0]+"_condition_"+condition_subject+".npy"), prediction.detach().cpu().numpy())
            else:
                for iter in range(one_hot_all.shape[-1]):
                    condition_subject = train_subjects_list[iter]
                    one_hot = one_hot_all[:,iter,:]
                    prediction = model.predict(audio, template, one_hot)
                    prediction = prediction.squeeze()
                    np.save(os.path.join(save_folder, file_name[0].split(".")[0]+"_condition_"+condition_subject+".npy"), prediction.detach().cpu().numpy())


if __name__ == '__main__':
    main()
