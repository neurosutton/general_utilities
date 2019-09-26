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

data_dir = '/Volumes/bk/data/images/priming'
analysis_dir = '/Volumes/bk/data/analysis/brianne/priming/contrasts'

# Following result directory name: contrast file, compose a result dictionary
results_to_grab = {'fp_results':['con_0004','con_0005','con_0008'], 'fp_results_post':['con_0004','con_0005','con_0008'], 'fp_results_aCompCorr':['con_0004','con_0005','con_0008'], 'fp_resultsArt_aCompCorr_post':['con_0004','con_0005','con_0008'], 'priming_results':['con_0001','con_0003'], 'priming_results_aCompCorr':['con_0001', 'con_0003']}

for destination in results_to_grab.keys():
    dest_dir = os.path.join(analysis_dir,destination)
    if not os.path.isdir(dest_dir):
        os.makedirs(dest_dir)

subj_list = glob.glob(os.path.join(data_dir,'*subj_list*'))[0]

# import the labels
df = pd.DataFrame(pd.read_csv(subj_list))
df.dropna(inplace=True)
subj_col = [col for col in df.columns if 'subj' in col]
group_col = [col for col in df.columns if 'group' in col]
for ix,row in df.iterrows():
    subj = row[subj_col].values[0]
    group = row[group_col].values[0]
    for result_dir, con_list in results_to_grab.items():
        for con in con_list:
            try:
                src_files = glob.glob(os.path.join(data_dir, subj + '*', result_dir, con + '.nii'))
            except Exception as e:
                print (e)
            if len(src_files) == 0:
                try:
                    src_files = glob.glob(os.path.join(data_dir, subj.lower() + '*', result_dir, con + '.nii'))
                except Exception as e:
                    print(e)
                    print('{} did not have a file for {}.'.format(subj,os.path.join(data_dir, subj + '*', result_dir, con + '.nii')))
                    
            if len(src_files) > 0 :
                dest_dir = os.path.join(analysis_dir, result_dir)
                for s, src_file in enumerate(src_files):
                    try:
                        shutil.copyfile(src_file,os.path.join(dest_dir, subj + '_' + group + '_' + con + '_' + str(s) + '.nii'))
                    except Exception as e:
                        print(e)


