function [subj_t1_dir, subj_t1_file, file_ext] = locate_t1(modality,subj)
dir_check = strfind(pwd, subj(1:4));

if isempty(dir_check);
    cwd = [pwd, filesep, subj];
else
    cwd = pwd;
end
check = textscan(cwd,'%s','Delimiter','/');
ix = strfind(check{1,1},subj);
if sum(arrayfun(@(x) isempty(x),ix))<1;
    ix = strfind(check{1,1},subj(1:3));
end

%% Define the project directory
ix = ~cellfun('isempty',ix);
if sum(ix) > 0;
    % If there is an intervening folder, this condition will find the locate the common path up to that point.
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
[t1_file] = rdir(x);
if length(t1_file) < 1 ;
    x = strcat(proj_dir,filesep,subj,'*',filesep,'*',upper(modality),'*',filesep,'*','.nii');
    [t1_file] = rdir(x);
    if length(t1_file) < 1 ;
        try
            x = strcat(proj_dir,filesep,subj(1:end-1),'*',filesep,'*', modality,'*',filesep,'*','.nii'); %Trying to just find the "prefix" version. May cause an error! Check the selected T1 for the batch.
            [t1_file] = rdir(x);
        catch
            disp('Unable to determine your file structure for T1s');
        end
    end
end

tmp = arrayfun(@(x) strfind(x.name,'brain'), t1_file, 'UniformOutput',false);
t1_file = t1_file(find(cellfun(@isempty,tmp)));
tmp = arrayfun(@(x) strfind(x.name,'Bias'), t1_file, 'UniformOutput',false);
t1_file = t1_file(find(cellfun(@isempty,tmp)));

val=cellfun(@(x) numel(x),t1_file.name); %compare the length of all the nii's

t1_file =  t1_file(val==min(val));
[t1_file] = t1_file.name; %partial name, can't use as output filepath
t1_name = (strcat(t1_file,',1'));
[subj_t1_dir subj_t1_file file_ext] = fileparts(t1_file);
subj_t1_file = strcat(subj_t1_file,file_ext);
end
