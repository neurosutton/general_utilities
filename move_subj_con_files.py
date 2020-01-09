#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Sep  9 09:16:28 2019

@author: neurosutton

Input: Two column csv with subject IDs and group designation.
Output: Analysis directories with copies of the contrasts of interest, renamed to include group designations per the analytic strategy. 
"""

import glob
import os
import pandas as pd
import shutil
from pathlib import Path

task='sz_gift'

if task == 'priming':
    data_dir = '/Volumes/bk/data/images/priming'
    analysis_dir = '/Volumes/bk/data/analysis/brianne/priming/contrasts'
    
    # Following result directory name: contrast file, compose a result dictionary
    results_to_grab = {'fp_results':['con_0004','con_0005','con_0008'], 'fp_results_post':['con_0004','con_0005','con_0008'], 'fp_results_aCompCorr':['con_0004','con_0005','con_0008'], 'fp_resultsArt_aCompCorr_post':['con_0004','con_0005','con_0008'], 'priming_results':['con_0001','con_0003'], 'priming_results_aCompCorr':['con_0001', 'con_0003']}
    
elif task == 'wlm':
    data_dir = '/mnt/mac/subjects'
    analysis_dir = '/mnt/mac/contrasts'
    results_to_grab = {'fp_results':['con_0004','con_0005','con_0008'], 'fp_results_irepi':['con_0004','con_0005','con_0008']}

elif task == 'exobk':
    data_dir = '/data/images/exobk'
    analysis_dir = '/data/analysis/brianne/exobx/contrasts'
    
    # Following result directory name: contrast file, compose a result dictionary
    results_to_grab = {'fp_resultsArt':['con_0005']} 
    
elif task == 'craving':
    data_dir = '/data/images/nicotine'
    analysis_dir = '/data/analysis/brianne/nicotine/contrasts_matchMike'
    results_to_grab = {'craving_results':['con_0001','con_0002', 'con_0004', 'con_0005','con_0006', 'con_0007', 'con_0009']}  #'craving_resultsArt_aCompCorr':['con_0001','con_0002', 'con_0006', 'con_0007', 'con_0009']
    
elif task == 'sz':
    data_dir = '/data/images/sz_jensen'
    analysis_dir = '/data/analysis/brianne/sz/cobre_images'
    results_to_grab = {'rest':['swrest']}  

elif task == 'sz_gift':
    data_dir = '/data/analysis/brianne/sz/012020_gift'
    analysis_dir = '/data/analysis/brianne/sz/012020_gift/ics_for_secondLevel'
    results_to_grab = {'':['_component_ica_s1_']}    

## Main script ##
for destination in results_to_grab.keys():
    dest_dir = os.path.join(analysis_dir,destination)
    if not os.path.isdir(dest_dir):
        os.makedirs(dest_dir)

subj_list = glob.glob(os.path.join(data_dir,'*subj_list*'))[0]
subj_ext = Path(subj_list).suffix

# import the labels
if subj_ext == '.xlsx':
    df = pd.DataFrame(pd.read_excel(subj_list))
else:
    df = pd.DataFrame(pd.read_csv(subj_list))
    
df.dropna(inplace=True, how='all')
subj_col = [col for col in df.columns if 'name' in col.lower()]
df[subj_col] = df[subj_col].astype(str)
group_col = [col for col in df.columns if 'group' in col]
group_dict = {}
df.drop_duplicates(subset=subj_col)

for ix,row in df.iterrows():
    subj = row[subj_col].values[0]
        
    try:
        group = row[group_col].values[0]
    except AttributeError:
        if row[group_col] not in group_dict.keys():
            new_group = row[group_col] 
            i = len(group_dict.values) + 1
            group_dict[new_group] = i
# Get the numeric representation of the group
        group = group_dict[row[group_col]]
        
    for result_dir, con_list in results_to_grab.items():
        for con in con_list:
            try:
                src_files = glob.glob(os.path.join(data_dir, '*' + subj + '*', result_dir, con + '.nii'))
            except Exception as e:
                print (e)
            if len(src_files) == 0:
                try:
                    src_files = glob.glob(os.path.join(data_dir, subj.lower() + '*', result_dir, con + '.nii'))
                except Exception as e:
                    print (e)                    
            if len(src_files) == 0:
                try:
                    src_files = glob.glob(os.path.join(data_dir, "_" + subj + con + '.nii'))
                except Exception as e:
                    print(e)
                    print('{} did not have a file for {}.'.format(subj,os.path.join(data_dir, subj + '*', result_dir, con + '.nii')))
                    
            if len(src_files) > 0 :
                dest_dir = os.path.join(analysis_dir, result_dir)
                for s, src_file in enumerate(src_files):
                    try:
                        shutil.copyfile(src_file,os.path.join(dest_dir, subj + '_' + group + '_' + con + '_' + str(s+1) + '.nii'))
                    except Exception as e:
                        print(e)


