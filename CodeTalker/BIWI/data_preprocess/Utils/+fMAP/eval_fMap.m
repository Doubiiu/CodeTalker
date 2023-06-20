function err = eval_fMap(S1, S2, L1, L2, fmap, type)
   map = fMAP.fMap2pMap(L1, L2, fmap);
   err = fMAP.eval_pMap(S1, S2, map, type);
end