#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon May 18 10:23:02 2020

Create a useful loop that will make all the sessiondata files for batch_plsgui.
The batch_plsgui requires a separate text file for all subjects. Eventually, this script with take json input to setup the sessiondata template and make the text files for all subjects.

@author: brianne
"""
import sys, subprocess

if not 3 == sys.version_info[0]:
        raise Exception("Must be using Python 3.5")
elif not 5 == sys.version_info[1]:
        raise Exception("Must be using Python 3.5")
        
import matlab.engine        
import os, shutil, sys, select
import glob
import collections
import pandas as pd
import json
import re

# To start, just use the following template.
plsgui_dir = '/home/brianne/tools/toolboxes/plsgui'
study = 'priming'
study_main_dir = 'contrasts_preprocThr2_2020'
study_con_dir = 'priming'
study_dir = os.path.normpath(os.path.join('/data/analysis/brianne',study,study_main_dir,study_con_dir))

# The analysis couldn't find any voxels with just the threshold and the mask needed to be resliced.
brain_mask = '/usr/local/MATLAB/tools/spm12/canonical/ravg152T1_brain_mask.nii'

# Find the subjects
subjs = glob.glob(os.path.join(study_dir,'*nii'))

print('Making text files for {} people'.format(len(subjs)))
for subj in subjs:
    subj_name = ('_').join(subj.split('/')[-1].split('_')[0:2])
    txt_file_loc = os.path.join(study_dir,subj_name+'.txt')
    print(subj_name)
    with open(txt_file_loc,'w') as f:
        f.write("prefix {}\n".format(subj_name))
        f.write("brain_region {}\n".format(brain_mask))
        f.write("across_run 1\n")
        f.write("single_subj 0\n")
        f.write("data_files {}\n".format(subj))
        
        f.write("cond_name high_cal\n")
        f.write("ref_scan_onset 0\n")
        f.write("num_ref_scan 1\n")
        f.write("block_onsets 20 52 76 92 100 116 132 140 156 164 180 196 220 228 244 252 268 276 300 316\n")
        f.write("block_length 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8\n")
        
        f.write("cond_name low_cal\n")
        f.write("ref_scan_onset 0\n")
        f.write("num_ref_scan 1\n")
        f.write("block_onsets 4 12 28 36 44 60 68 84 108 124 148 172 188 204 212 236 260 284 292 308\n")
        f.write("block_length 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8\n")
       

setup_files = glob.glob(os.path.join(study_dir,'*txt'))
print('Starting MATLAB')
eng=matlab.engine.connect_matlab()
try:
    eng.clear # Make sure the old variables are flushed.
    eng.addpath(eng.genpath(plsgui_dir));
    eng.cd(study_dir);
    for setup_file in setup_files:
        setup_file = setup_file.split('/')[-1]
        eng.workspace['in_file'] = setup_file
        eng.eval('batch_plsgui (in_file)')
except:
     print('Try the following in the MATLAB command window\n')
     print("l = glob('*txt')\nfor i=1:length(l)\nbatch_plsgui(l{i})\nend")
eng.quit()