function a_4dto3d_batch(in_subj,task)

home_dir = pwd; %The project-level folder
cd(home_dir);

if strcmp('all',in_subj)
        find_subj_names = dir('*');
        fsndirs = [find_subj_names(:).isdir];
        subj_names = {find_subj_names(fsndirs).name};
        subj_names(ismember(subj_names,{'.','..'})) = [];
elseif strcmp('choose',in_subj)
        subj_names = cellstr(spm_select([1,400],'nii'));
        selected = 'yes';
else
        subj_names = cellstr(in_subj);
end
   
%%
for k = 1:length(subj_names); 
    cd(home_dir);
    subj = char(subj_names(k));
    %%
    if exist('selected','var')
        sprintf('WARNING: Do NOT CNTL+C to exist process');
        a_4dto3d(subj);
    else
        [home_dir, subj] = fileparts(subj);
        subj_folder = strcat(home_dir,filesep,subj);
        if exist('task','var')
            orig = glob(strcat('*_',task,'*nii'));
            nFiles = length(orig);
        else
            tmp = char(glob(strcat(godir,filesep,'*nii')));
            nFiles = length(tmp);
            [throw orig ext] = fileparts(tmp(1,:));
            orig = {strcat(orig,ext)};
        end
    %orig = ls(strcat('*_',task,'*nii'));    
    if nFiles < 100 ; % if the file has been split, then there are tons of nii files and this length will be crazy long
    godir = char(strcat(subj_folder));  
    orig = fullfile(godir,orig{1});
    %orig = strcat(godir,filesep,'raw',filesep,orig);
    %orig = char(strcat(godir,filesep,'raw',filesep,subj,'_',task,'*nii'))%original file  
    cd (godir)
    check = strcat(subj,'*_050.nii');
    check_4d = rdir(check);
    fourd_name = rdir(orig)%Did the file get copied?
    fourd_origfile = fourd_name.name; % old code fullfile(godir,fourd_name.name);
    fourd_orig_name = rdir(fourd_origfile);
    
    %% Check whether the file has already been split.
    if isempty(check_4d);
            fprintf('%s has not been split. Copying file.\n',subj);
        if isempty(fourd_orig_name)
           % copyfile(orig,godir)
            fprintf('Copying %s to %s.\n',orig,godir);
            fourd_name = rdir(orig)
        end
        %% Splits appropriate file
        if ~isempty(fourd_origfile);
            display('Commencing split.')
            full_fourd_name = fourd_name.name; %old code fullfile(godir,fourd_name.name)
            a_4dto3d(full_fourd_name)
            delete(full_fourd_name);
        end
        
    else fprintf('%s has been split\n', subj);
        if ~isempty(fourd_orig_name);
            delete(fourd_orig_name.name) %cleans up for future processing
        end
    end
    else
       fprintf ('%s already split.\n', subj);
    end %Too many files;already processed
    end
end 


