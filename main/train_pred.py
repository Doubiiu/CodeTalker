#!/usr/bin/env python
import os
import time
import numpy as np
import torch
import torch.backends.cudnn as cudnn
import torch.nn as nn
import torch.nn.parallel
import torch.optim
import torch.utils.data
import torch.multiprocessing as mp
import torch.distributed as dist
from tensorboardX import SummaryWriter
import cv2

from base.baseTrainer import poly_learning_rate, reduce_tensor, save_checkpoint
from base.utilities import get_parser, get_logger, main_process, AverageMeter
from models import get_model
from torch.optim.lr_scheduler import StepLR

cv2.ocl.setUseOpenCL(False)
cv2.setNumThreads(0)

import warnings
warnings.filterwarnings("ignore")


def main():
    args = get_parser()
    os.environ["CUDA_VISIBLE_DEVICES"] = ','.join(str(x) for x in args.train_gpu)
    cudnn.benchmark = True

    if args.dist_url == "env://" and args.world_size == -1:
        args.world_size = int(os.environ["WORLD_SIZE"])
    args.distributed = args.world_size > 1 or args.multiprocessing_distributed
    args.ngpus_per_node = len(args.train_gpu)
    if len(args.train_gpu) == 1:
        args.train_gpu = args.train_gpu[0]
        args.sync_bn = False
        args.distributed = False
        args.multiprocessing_distributed = False

    if args.multiprocessing_distributed:
        args.world_size = args.ngpus_per_node * args.world_size
        mp.spawn(main_worker, nprocs=args.ngpus_per_node, args=(args.ngpus_per_node, args))
    else:
        main_worker(args.train_gpu, args.ngpus_per_node, args)


def main_worker(gpu, ngpus_per_node, args):
    cfg = args
    cfg.gpu = gpu

    if cfg.distributed:
        if cfg.dist_url == "env://" and cfg.rank == -1:
            cfg.rank = int(os.environ["RANK"])
        if cfg.multiprocessing_distributed:
            cfg.rank = cfg.rank * ngpus_per_node + gpu
        dist.init_process_group(backend=cfg.dist_backend, init_method=cfg.dist_url, world_size=cfg.world_size,
                                rank=cfg.rank)
    # ####################### Model ####################### #
    global logger, writer
    logger = get_logger()
    writer = SummaryWriter(cfg.save_path)
    model = get_model(cfg)
    if cfg.sync_bn:
        logger.info("using DDP synced BN")
        model = torch.nn.SyncBatchNorm.convert_sync_batchnorm(model)
    if main_process(cfg):
        logger.info(cfg)
        logger.info("=> creating model ...")
        # model.summary(logger, writer)
    if cfg.distributed:
        torch.cuda.set_device(gpu)
        cfg.batch_size = int(cfg.batch_size / ngpus_per_node)
        cfg.batch_size_val = int(cfg.batch_size_val / ngpus_per_node)
        cfg.workers = int(cfg.workers / ngpus_per_node)
        model = torch.nn.parallel.DistributedDataParallel(model.cuda(gpu), device_ids=[gpu])
    else:
        torch.cuda.set_device(gpu)
        model = model.cuda()

    # ####################### Loss ############################# #
    loss_fn = nn.MSELoss()


    # ####################### Optimizer ######################## #
    if cfg.use_sgd:
        optimizer = torch.optim.SGD(model.parameters(), lr=cfg.base_lr, momentum=cfg.momentum,
                                    weight_decay=cfg.weight_decay)
    else:
        optimizer = torch.optim.Adam(filter(lambda p: p.requires_grad,model.parameters()), lr=cfg.base_lr)

    if cfg.StepLR:
        scheduler = StepLR(optimizer, step_size=cfg.step_size, gamma=cfg.gamma)
    else:
        scheduler = None

    # ####################### Data Loader ####################### #
    from dataset.data_loader import get_dataloaders
    dataset = get_dataloaders(cfg)
    train_loader = dataset['train']

    if cfg.evaluate:
        val_loader = dataset['valid']

    # ####################### Train ############################# #
    for epoch in range(cfg.start_epoch, cfg.epochs):
        loss_train, motion_loss_train, reg_loss_train = train(train_loader, model, loss_fn, optimizer, epoch, cfg)
        epoch_log = epoch + 1
        if cfg.StepLR:
            scheduler.step()
        if main_process(cfg):
            logger.info('TRAIN Epoch: {} '
                        'loss_train: {} '
                        .format(epoch_log, loss_train)
                        )
            for m, s in zip([loss_train, motion_loss_train, reg_loss_train],
                            ["train/loss", "train/motion_loss", "train/reg_loss"]):
                writer.add_scalar(s, m, epoch_log)


        if cfg.evaluate and (epoch_log % cfg.eval_freq == 0):
            loss_val = validate(val_loader, model, loss_fn, cfg)
            if main_process(cfg):
                logger.info('VAL Epoch: {} '
                            'loss_val: {} '
                            .format(epoch_log, loss_val)
                            )
                for m, s in zip([loss_val],
                                ["val/loss"]):
                    writer.add_scalar(s, m, epoch_log)


        if (epoch_log % cfg.save_freq == 0) and main_process(cfg):
            save_checkpoint(model,
                            sav_path=os.path.join(cfg.save_path, 'model'),
                            stage=2
                            )


def train(train_loader, model, loss_fn, optimizer, epoch, cfg):
    batch_time = AverageMeter()
    data_time = AverageMeter()
    loss_meter = AverageMeter()
    loss_motion_meter = AverageMeter()
    loss_reg_meter = AverageMeter()


    model.train()
    model.autoencoder.eval()
    end = time.time()
    max_iter = cfg.epochs * len(train_loader)
    for i, (audio, data, template, one_hot, filename) in enumerate(train_loader):
        # pdb.set_trace()
        ####################
        current_iter = epoch * len(train_loader) + i + 1
        data_time.update(time.time() - end)

        #################### cpu to gpu
        audio = audio.cuda(cfg.gpu, non_blocking=True)
        data = data.cuda(cfg.gpu, non_blocking=True) 
        template = template.cuda(cfg.gpu, non_blocking=True)
        one_hot = one_hot.cuda(cfg.gpu, non_blocking=True)


        loss, loss_detail = model(audio, template, data, one_hot, criterion=loss_fn)

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        ######################
        batch_time.update(time.time() - end)
        end = time.time()
        for m, x in zip([loss_meter, loss_motion_meter, loss_reg_meter],
                        [loss, loss_detail[0], loss_detail[1]]):
            m.update(x.item(), 1)

        if cfg.poly_lr:
            current_lr = poly_learning_rate(cfg.base_lr, current_iter, max_iter, power=cfg.power)
            for param_group in optimizer.param_groups:
                param_group['lr'] = current_lr
        else:
            current_lr = optimizer.param_groups[0]['lr']

        # calculate remain time
        remain_iter = max_iter - current_iter
        remain_time = remain_iter * batch_time.avg
        t_m, t_s = divmod(remain_time, 60)
        t_h, t_m = divmod(t_m, 60)
        remain_time = '{:02d}:{:02d}:{:02d}'.format(int(t_h), int(t_m), int(t_s))

        if (i + 1) % cfg.print_freq == 0 and main_process(cfg):
            logger.info('Epoch: [{}/{}][{}/{}] '
                        'Data: {data_time.val:.3f} ({data_time.avg:.3f}) '
                        'Batch: {batch_time.val:.3f} ({batch_time.avg:.3f}) '
                        'Remain: {remain_time} '
                        'Loss: {loss_meter.val:.4f} '
                        .format(epoch + 1, cfg.epochs, i + 1, len(train_loader),
                                batch_time=batch_time, data_time=data_time,
                                remain_time=remain_time,
                                loss_meter=loss_meter
                                ))
            for m, s in zip([loss_meter],
                            ["train_batch/loss"]):
                writer.add_scalar(s, m.val, current_iter)
            writer.add_scalar('learning_rate', current_lr, current_iter)

    return loss_meter.avg, loss_motion_meter.avg, loss_reg_meter.avg


def validate(val_loader, model, loss_fn, cfg):
    loss_meter = AverageMeter()
    model.eval()

    train_subjects_list = [i for i in cfg.train_subjects.split(" ")]
    with torch.no_grad():
        for i, (audio, vertice, template, one_hot_all, file_name) in enumerate(val_loader):
            audio = audio.cuda(cfg.gpu, non_blocking=True)
            one_hot_all = one_hot_all.cuda(cfg.gpu, non_blocking=True)
            vertice = vertice.cuda(cfg.gpu, non_blocking=True)
            template = template.cuda(cfg.gpu, non_blocking=True)

            train_subject = "_".join(file_name[0].split("_")[:-1])
            if train_subject in train_subjects_list:
                condition_subject = train_subject
                iter = train_subjects_list.index(condition_subject)
                one_hot = one_hot_all[:,iter,:]
                loss, _ = model(audio, template, vertice, one_hot, criterion=loss_fn)
                loss_meter.update(loss.item(), 1)
            else:
                for iter in range(one_hot_all.shape[-1]):
                    condition_subject = train_subjects_list[iter]
                    one_hot = one_hot_all[:,iter,:]
                    loss, _ = model(audio, template, vertice, one_hot, criterion=loss_fn)
                    loss_meter.update(loss.item(), 1)

            # if cfg.distributed:
            #     loss = reduce_tensor(loss, cfg)

    return loss_meter.avg


if __name__ == '__main__':
    main()
