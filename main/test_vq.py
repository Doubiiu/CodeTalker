#!/usr/bin/env python
import os
import torch
import numpy as np
import cv2

from base.utilities import get_parser, get_logger
from models import get_model
from base.baseTrainer import load_state_dict

cv2.ocl.setUseOpenCL(False)
cv2.setNumThreads(0)

cfg = get_parser()
os.environ["CUDA_VISIBLE_DEVICES"] = ','.join(str(x) for x in cfg.test_gpu)

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
        load_state_dict(model, checkpoint['state_dict'])
        logger.info("=> loaded checkpoint '{}'".format(cfg.model_path))
    else:
        raise RuntimeError("=> no checkpoint flound at '{}'".format(cfg.model_path))

    # ####################### Data Loader ####################### #
    from dataset.data_loader import get_dataloaders
    dataset = get_dataloaders(cfg)
    test_loader = dataset['test']

    test(model, test_loader, save=True)



def test(model, test_loader, save=False):
    model.eval()
    save_folder = os.path.join(cfg.save_folder, 'npy')
    if not os.path.exists(save_folder):
        os.makedirs(save_folder)

    with torch.no_grad():
        for i, (data, template, _, file_name) in enumerate(test_loader):
            data = data.cuda(non_blocking=True)
            template = template.cuda(non_blocking=True)

            out, _, _ = model(data, template)

            out = out.squeeze()

            if save:
                np.save(os.path.join(save_folder, file_name[0].split(".")[0]+".npy"), out.detach().cpu().numpy())


if __name__ == '__main__':
    main()
