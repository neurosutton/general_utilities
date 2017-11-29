function [cwd, pth_subjdirs] = file_selector(subjs)
disp('Welcome to the automatic file finder. Select your player!');
%% Finds the top level of study
if nargin < 1
    disp('Begin with the root directory of the study.');
    cwd = spm_select(1,'dir','Select root directory for studies',...
        '',pwd);
    if isempty(cwd)
        disp('Exiting');
        return
    end
    
    cd(cwd);
    disp('Choose your vic..., er, um, participant(s).');
    pth_subjdirs = cellstr(spm_select([1,Inf],'dir','Select subject directories to process','',pwd));
else
    cwd = fullfile(pwd);
    check = textscan(cwd,'%s','Delimiter','/');
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
end