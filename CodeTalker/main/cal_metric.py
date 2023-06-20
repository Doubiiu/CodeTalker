import numpy as np
import argparse
import os
import pickle


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--train_subjects", type=str, default="F2 F3 F4 M3 M4 M5")
    parser.add_argument("--pred_path", type=str, default="RUN/BIWI/CodeTalker_s2/result/npy/")
    parser.add_argument("--gt_path", type=str, default="./BIWI/vertices_npy/")
    parser.add_argument("--region_path", type=str, default="BIWI/regions/")
    parser.add_argument("--templates_path", type=str, default="BIWI/templates.pkl")
    args = parser.parse_args()

    train_subject_list = args.train_subjects.split(" ")
    sentence_list = ["e"+str(i).zfill(2) for i in range(37,41)]

    with open(args.templates_path, 'rb') as fin:
        templates = pickle.load(fin,encoding='latin1')

    with open(os.path.join(args.region_path, "lve.txt")) as f:
        maps = f.read().split(", ")
        mouth_map = [int(i) for i in maps]

    with open(os.path.join(args.region_path, "fdd.txt")) as f:
        maps = f.read().split(", ")
        upper_map = [int(i) for i in maps]
    

    cnt = 0
    vertices_gt_all = []
    vertices_pred_all = []
    motion_std_difference = []

    for subject in train_subject_list:
        for sentence in sentence_list:
            vertices_gt = np.load(os.path.join(args.gt_path,subject+"_"+sentence+".npy")).reshape(-1,23370,3)
            vertices_pred = np.load(os.path.join(args.pred_path,subject+"_"+sentence+"_condition_"+subject+".npy")).reshape(-1,23370,3)
            vertices_pred = vertices_pred[:vertices_gt.shape[0],:,:]

            motion_pred = vertices_pred - templates[subject].reshape(1,23370,3)
            motion_gt = vertices_gt - templates[subject].reshape(1,23370,3)

            cnt += vertices_gt.shape[0]

            vertices_gt_all.extend(list(vertices_gt))
            vertices_pred_all.extend(list(vertices_pred))

            L2_dis_upper = np.array([np.square(motion_gt[:,v, :]) for v in upper_map])
            L2_dis_upper = np.transpose(L2_dis_upper, (1,0,2))
            L2_dis_upper = np.sum(L2_dis_upper,axis=2)
            L2_dis_upper = np.std(L2_dis_upper, axis=0)
            gt_motion_std = np.mean(L2_dis_upper)
            
            L2_dis_upper = np.array([np.square(motion_pred[:,v, :]) for v in upper_map])
            L2_dis_upper = np.transpose(L2_dis_upper, (1,0,2))
            L2_dis_upper = np.sum(L2_dis_upper,axis=2)
            L2_dis_upper = np.std(L2_dis_upper, axis=0)
            pred_motion_std = np.mean(L2_dis_upper)

            motion_std_difference.append(gt_motion_std - pred_motion_std)

    print('Frame Number: {}'.format(cnt))

    vertices_gt_all = np.array(vertices_gt_all)
    vertices_pred_all = np.array(vertices_pred_all)
    

    L2_dis_mouth_max = np.array([np.square(vertices_gt_all[:,v, :]-vertices_pred_all[:,v,:]) for v in mouth_map])
    L2_dis_mouth_max = np.transpose(L2_dis_mouth_max, (1,0,2))
    L2_dis_mouth_max = np.sum(L2_dis_mouth_max,axis=2)
    L2_dis_mouth_max = np.max(L2_dis_mouth_max,axis=1)

    print('Lip Vertex Error: {:.4e}'.format(np.mean(L2_dis_mouth_max)))
    print('FDD: {:.4e}'.format(sum(motion_std_difference)/len(motion_std_difference)))

    
if __name__=="__main__":
    main()