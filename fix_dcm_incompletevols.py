# Call this script with the path to your dicom folder as argument
# e.g., python fix_dcm_incompletevols.py dicom_folder
# p.c.klink@gmail.com
# Generalizations and modifications to the comparison logic added by neurosutton

import os, sys, shutil, glob
import pydicom

if len(sys.argv) > 1:
    dcm_dir = sys.argv[1]
    dcmpath = os.path.join(os.getcwd(), dcm_dir)

    valid_dcm_extns = ['dcm','ima','dicom'] # can add other dicom extensions as necessary
    possible_files = glob.glob(os.path.join(dcmpath, '*'))
    print('Found {} files in {}'.format(len(possible_files),os.path.join(dcmpath, '*')))

    # check each possible entry to make sure the file is a dicom file
    dcm_list = [f for f in possible_files if f.split('.')[-1].lower() in valid_dcm_extns]
    if not dcm_list:
        print('Did not find dicom files to convert.\nDid specify the dicom folder?\n')

    # get the temporal position tag for all dcm files
    # Logic for the next block is to find repeating field that prescribes acquisition. The repeating field will be counted below to define the number of slices.
    print('Scanning ' + dcmpath + ' for dcm files...')
    volnum =[];
    for f in (dcm_list):
        try:
            dcm_info = pydicom.filereader.dcmread(f,stop_before_pixels=True)
            #volnum.append(dcm_info.TemporalPositionIdentifier) # This field was not available for neurosutton's scans
            volnum.append(dcm_info.SliceLocation)
        except Exception as e:
            print('{}: {}'.format(f,e))

    # how many slices in each volume
    vol_list=[];
    for i in set(volnum):
        vol_list.append(volnum.count(i))
    print('{} slices'.format(len(vol_list)))

    # get the indexes of the slices belonging to the last (incomplete) volume
    if max(vol_list) != min(vol_list):
        last_full_acq = min(vol_list)*len(vol_list)
        print(last_full_acq)
        del_dcm = [i for i,x in enumerate(volnum) if i >= last_full_acq]
        print('The following slice files will be ignored')
        print(del_dcm)

        if os.path.isdir(os.path.join(dcmpath , 'orphan_dcm')) is False:
            os.mkdir(os.path.join(dcmpath , 'orphan_dcm'))
        if os.path.isdir(os.path.join(dcmpath , 'corrected_dcm')) is False:
            os.mkdir(os.path.join(dcmpath , 'corrected_dcm'))

        print('Moving {} orphan dcm files to orphan_dcm'.format(len(del_dcm)))
        # print('Moving the following orphan dcm files to orphan_dcm')
        for f in del_dcm:
            #print(dcm_list[f])
            orphan_filename = os.path.split(dcm_list[f])
            shutil.move(dcm_list[f], os.path.join(dcmpath , 'orphan_dcm' , orphan_filename[1]))

        # remove the corrupted entries from the original list (accomodates original extensions)
        del dcm_list[last_full_acq::]

        print('Moving the rest of the dcm files to corrected_dcm')
        for f in dcm_list:
            shutil.move(f,os.path.join(dcmpath , 'corrected_dcm',))

    else:
        print('All volumes are complete, will not mess with dcm files.')
else:
    print('No dicom-folder specified. Please re-run with path argument.')
