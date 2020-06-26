function [pth_taskdirs, taskArray] = file_selector_task(pth_subjdirs, taskArray)

% Finds the top level of study
pth_taskdirs = struct(); %Initalize structure for speed
rawDir = '';
switch nargin
    case 2 %Given number and names of tasks and subjs
        for t = 1: length(taskArray)
            task = char(taskArray(t));
            pth_taskdirs(t).fileDirs = repmat({''},1,length(pth_subjdirs)); %preallocation for possible number of matches
            pth_taskdirs(t).task = task;
            for s = 1:length(pth_subjdirs)
                subjName = textscan(pth_subjdirs{s},'%s','Delimiter','/'); %split the file path
                sIx = strfind(subjName{1,1}, task); %figure out where the relative path should end, regardless of ancillary deeper directories
                sIx = find(~cellfun('isempty',sIx)==1);
                if isempty(sIx) % i.e., isn't identifying other tasks...
                  subjName = subjName{1,1}(2:end);
                  subj = subjName{end};
                else
                  subjName = subjName{1,1}(2:sIx-1);
                  subj = subjName{end-1};
                end
                subjPath = strtrim(sprintf('/%s',subjName{:}));

                    tmp = rdir(char(strcat(subjPath,filesep,task,filesep,'*.nii'))); %rdir is a recursive dir routine available through MATLAB's site. much like ls in linux
                    if isempty(tmp()); %check alternate dir structure
                        tmp = rdir(char(strcat(subjPath,filesep,task,filesep,'*/*.nii')));
                    end

                    if ~isempty(tmp())
                        matchName = textscan(tmp(1,1).name,'%s','Delimiter','/');
                        mNix = strfind(matchName{:},subj);
                        mNix = find((cellfun(@(x) ~isempty(x), mNix)),1);
                        taskDir = fullfile(filesep,matchName{1,1}{1:mNix+1});
                        rIx = strfind(matchName{:},'.nii');
                        rIx= find((cellfun(@(x) ~isempty(x),rIx)),1,'last')-1;
                        rawDir = matchName{1,1}{rIx};
                        pth_taskdirs(t).fileDirs{s} = taskDir; %output path to task dir for each subj
                    end
            end
            pth_taskdirs(t).rawDir = rawDir;

        end

    otherwise %Generates task and subj list through selection in the GUI.
        disp('And what are we analyzing today?');
        if nargin < 1
            [tmpSubjs,sts] = spm_select([1,Inf],'dir','Select subject directories to process','',pwd);
            if sts == 0
              return
            end
            tmpSubjs = cellstr(tmpSubjs)
        else
            tmpSubjs = pth_subjdirs;
        end
        if isempty(tmpSubjs{1,1})
            disp('No one selected. Exiting')
            return
        else
            subjName = textscan(tmpSubjs{1,1},'%s','Delimiter','/');
            firstSubj = subjName{1,1}{end}; %for indexing to locate folder names
            cd(tmpSubjs{1,1});
            taskTmp = cellstr(spm_select([1,Inf],'dir','Select task directories to process','',pwd));

            if isempty(taskTmp)
                disp('No one selected. Exiting')
                return
            else
                % explore the dir structure for the selected studies
                for tt = 1:length(taskTmp)
                    taskName = textscan(taskTmp{tt}, '%s','Delimiter','/');
                    taskIx = strfind(taskName{:},firstSubj); %finds the location of the match
                    ix=find(~cellfun(@isempty,taskIx))+1; % the task directory is under the subject (+1)
                    if ix > 1; %located a subject name match
                        taskArray{tt} = taskName{1,1}{ix}; %builds the output taskArray with previously unknown task names
                        task = taskName{1,1}{ix};
                        fprintf('\nTask:%s\n',task);
                        pth_taskdirs(tt).fileDirs = repmat({''},length(tmpSubjs),1); %preallocate
                        pth_taskdirs(tt).task = task;

                        for ss = 1:length(tmpSubjs);
                            subj = textscan(tmpSubjs{ss},'%s','Delimiter','/');
                            subj = subj{1,1}{end};
                            fprintf('Searching %s\n', subj);
                            niiFile = strcat(tmpSubjs{ss},filesep,task,filesep,'*.nii');
                            tmp = rdir(niiFile);

                            if isempty(tmp);
                                disp('Checking another level')
                                tmp = rdir(strcat(tmpSubjs{ss},filesep,task,filesep,'*/*.nii'));
                            end

                            if ~isempty(tmp);
                                matchName = textscan(tmp(1,1).name,'%s','Delimiter','/');
                                mNix = strfind(matchName{:},subj);
                                mNix = find((cellfun(@(x) ~isempty(x), mNix)),1);
                                taskDir = fullfile(filesep,matchName{1,1}{1:mNix+1});
                                rIx = strfind(matchName{:},'.nii');
                                rIx= find((cellfun(@(x) ~isempty(x),rIx)),1,'last')-1;
                                rawDir = matchName{1,1}{rIx};
                                pth_taskdirs(tt).fileDirs{ss,1} = taskDir;
                            else
                                disp('Have you converted to nifti?');
                            end
                        end
                    else
                        disp('Did not match with subject name...')
                    end
                    pth_taskdirs(tt).rawDir = rawDir;
                end
            end
        end
end
