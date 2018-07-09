function [cwd, pth_subjdirs, subjList] = file_selector(subjs)

disp('Welcome to the automatic file finder. Selecting your player!');
%% Finds the top level of study
if nargin < 1
    disp('Begin with the root directory of the study.');
    [cwd,sts] = spm_select(1,'dir','Select root directory for studies',...
        '',pwd);
        if sts == 0
          return
        end
    if isempty(cwd)
        disp('Exiting');
        return
    end

    cd(cwd);
    disp('Choose your vic..., er, um, participant(s).');
    [pth_subjdirs,sts] = cellstr(spm_select([1,Inf],'dir','Select subject directories to process','',pwd));
    if sts == 0
      return
    end    
    pth_subjdirs = unique(pth_subjdirs);
    %% Create list of subjects (without duplicates)
    for tt=1:length(pth_subjdirs)
        tmp = textscan(pth_subjdirs{tt},'%s','Delimiter',filesep);
        subjList{tt} = tmp{1,1}{end};
        pth_subjdirs{tt} = strcat(filesep,fullfile(tmp{1,1}{1:end})); %otherwise loops through the subject multiple times
    end
         pth_subjdirs = unique(pth_subjdirs);
else
    cwd = strip(glob([pwd,filesep,'*',subjs]),'right',filesep);
    if isempty(cwd);
        try strfind(pwd,subjs);
            cwd = strip(glob(pwd),'right',filesep);
        catch
            disp('Could not identify the correct directory')
        end
    end
    check = textscan(cwd{1,1},'%s','Delimiter','/');
    ix = strfind(check{1,1},subjs(1:3));
    ix = ~cellfun('isempty',ix);

    if sum(ix) == 0
        pth_subjdirs = cellstr(fullfile(cwd,subjs));
        try isdir(pth_subjdirs{1,1});
        catch
            disp('Did not find subject directory');
            fprintf('%s\n',pth_subjdirs{1,1});
        end
    end

    if sum(ix) > 0;
        ix = find(ix==1);
        ix = (max(ix)); %finds the last instance
        cwd = check{1,1}(2:ix);
        cwd = strtrim(sprintf('/%s',cwd{:}));

        cd(cwd)
        find_subj = dir(cwd);
        fsdir = [find_subj(:).isdir];
        subjs = {find_subj(fsdir).name};
        subjs(ismember(subjs,{'.','..','art_config_files','dicom'})) = []; %"Erase the "results" folders from search
        tmp = strfind(subjs,'results');
        subjs = subjs(find(cellfun(@isempty,tmp)));

        pth_subjdirs = cellfun(@(p) [strcat(cwd,filesep,p)],subjs, 'uni',false);
    end
     pth_subjdirs = unique(pth_subjdirs);
    %% Create list of subjects (without duplicates)
    for tt=1:length(pth_subjdirs)
        tmp = textscan(pth_subjdirs{tt},'%s','Delimiter',filesep);
        subjList{tt} = tmp{1,1}{end-1};
        pth_subjdirs{tt} = strcat(filesep,fullfile(tmp{1,1}{1:end-1})); %otherwise loops through the subject multiple times
    end
         pth_subjdirs = unique(pth_subjdirs);
end
