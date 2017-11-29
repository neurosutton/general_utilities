function [subj_dir, subj_file, file_ext] = locate_scan_file(modality,subj)
% Purpose: Build the file path for various modalities to be preprocessed
% by our custom pipelines. By default, the script will find the T1 
% directory and scan for a given subject.
%
% Author: Brianne Mohl, PhD 2017
%
% Expected input includes a subject ID, since this script is not intended
% as a stand-alone, but rather part of the pipelines.

if exist('subj','var')
    dir_check = strfind(pwd, subj(1:4));
end
cwd = pwd;
check = textscan(cwd,'%s','Delimiter','/');
ix = strfind(check{1,1},subj); %index that matches the subject string with the cells, so that the code can support relative paths
if isempty(arrayfun(@(x) isempty(x),ix));
    ix = strfind(check{1,1},subj(1:3)); %This index catches cases where the study and subject naming schemes are similar, but there was no subject name in the cell array
end
ix = ~cellfun('isempty',ix);
if sum(ix) > 0;
    ix = find(ix==1);
    ix = (max(ix)); %finds the last instance
    proj_dir = fullfile(filesep,check{1,1}{1:ix-1});
else
    proj_dir = fullfile(filesep,check{1,1}{1:end});
end

if ~exist ('modality','var');
    modality = 't1'; %default value used in other scripts.
end

x = strcat(proj_dir,filesep,subj,'*',filesep,'*',modality,'*',filesep,'*.nii');
scan_file = glob(x);
if length(scan_file) < 1 ;
    x = strcat(proj_dir,filesep,subj,'*',filesep,'*',upper(modality),'*',filesep,'*','.nii');  % creates a touch of flexibilty by allowing different case
    scan_file = glob(x);
    if length(scan_file) < 1 ;
        try
            x = strcat(proj_dir,filesep,subj(1:end-1),'*',filesep,'*', modality,'*',filesep,'*','.nii'); %Trying to just find the "prefix" version. May cause an error! Check the selected T1 for the batch.
            scan_file = glob(x);
        catch
            fprintf('Cannot auto-detect %s, please select the file.\n',modality)
            pmpt = fprintf('Select the first persons %s file',modality);
            scan_file = cellstr(spm_select([1,Inf],'file',pmpt,'',pwd));

        end
    end
end

tmp = cellfun(@(x) strfind(x,'brain'), scan_file, 'UniformOutput',false);
scan_file = scan_file(find(cellfun('isempty',tmp)));

val=cellfun(@(x) numel(x),{scan_file}); %compare the length of all the nii's
if eq(val,0)
    subj_dir = [];
    subj_file = [];
    file_ext = [];
    return
else
    scan_file =  scan_file(val==min(val));
    [scan_file] = char(scan_file); %partial name, can't use as output filepath
    t1_name = (strcat(scan_file,',1'));
    [subj_dir subj_file file_ext] = fileparts(scan_file);
    subj_file = strcat(subj_file,file_ext);
end
end
