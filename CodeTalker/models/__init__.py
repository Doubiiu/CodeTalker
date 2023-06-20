def get_model(cfg):
    ## old
    if cfg.arch == 'stage1_vocaset':
        from models.stage1_vocaset import VQAutoEncoder as Model
        model = Model(args=cfg)
    elif cfg.arch == 'stage1_BIWI':
        from models.stage1_BIWI import VQAutoEncoder as Model
        model = Model(args=cfg)
    elif cfg.arch == 'stage2':
        from models.stage2 import CodeTalker as Model
        model = Model(args=cfg)
    else:
        raise Exception('architecture not supported yet'.format(cfg.arch))
    return model