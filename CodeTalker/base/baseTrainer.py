#!/usr/bin/env python
import torch
from os.path import join
import torch.distributed as dist
from .utilities import check_makedirs
from collections import OrderedDict
from torch.nn.parallel import DataParallel, DistributedDataParallel


def step_learning_rate(base_lr, epoch, step_epoch, multiplier=0.1):
    lr = base_lr * (multiplier ** (epoch // step_epoch))
    return lr


def poly_learning_rate(base_lr, curr_iter, max_iter, power=0.9):
    """poly learning rate policy"""
    lr = base_lr * (1 - float(curr_iter) / max_iter) ** power
    return lr


def adjust_learning_rate(optimizer, lr):
    for param_group in optimizer.param_groups:
        param_group['lr'] = lr


def save_checkpoint(model, other_state={}, sav_path='', filename='model.pth.tar', stage=1):
    if isinstance(model, (DistributedDataParallel, DataParallel)):
        weight = model.module.state_dict()
    elif isinstance(model, torch.nn.Module):
        weight = model.state_dict()
    else:
        raise ValueError('model must be nn.Module or nn.DataParallel!')
    check_makedirs(sav_path)

    if stage == 2: # remove vqvae part
        for k in list(weight.keys()):
            if 'autoencoder' in k:
                weight.pop(k)

    other_state['state_dict'] = weight
    filename = join(sav_path, filename)
    torch.save(other_state, filename)



def load_state_dict(model, state_dict, strict=True):
    if isinstance(model, (DistributedDataParallel, DataParallel)):
        model.module.load_state_dict(state_dict, strict=strict)
    else:
        model.load_state_dict(state_dict, strict=strict)


def state_dict_remove_module(state_dict):
    new_state_dict = OrderedDict()
    for k, v in state_dict.items():
        # name = k[7:]  # remove 'module.' of dataparallel
        name = k.replace('module.', '')
        new_state_dict[name] = v
    return new_state_dict


def reduce_tensor(tensor, args):
    rt = tensor.clone()
    dist.all_reduce(rt, op=dist.ReduceOp.SUM)
    rt /= args.world_size
    return rt
