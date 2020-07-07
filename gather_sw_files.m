function [scan_files] = gather_sw_files(subj_pth,taskArray)
% Purpose: Make a list of smoothed files available to wrapper scripts

  prefix = 'sw';
  for t = 1: length(taskArray)
    locateImg = [subj_pth,filesep,taskArray{t},'*',filesep,[prefix,'*.nii']];
    if isempty(locateImg)
      disp('Double check the prefix for locating the scans')
    else
      imgFiles = rdir(locateImg); %depends on this added functionality
      findShort = cellfun(@(x) numel(x), {imgFiles.name}); % in case there are multiple processing pipelines completed on the same brain
      imgNames = imgFiles(findShort == min(findShort));

      if length(imgNames) > 1 %The ANALYZE and 3D NII condition
        nVols = length(imgNames);
        tmp_sw_files = cell(1,nVols);

        for iOF = 1: nVols
          tmp_sw_files{1,iOF} = imgNames(iOF).name;
        end
      elseif length(spm_vol(imgNames.name))>1 % The 4D NIFTI condition
        nVols = spm_vol(imgNames.name);
        nVols = length(nVols);
        tmp_sw_files = cell(1,nVols);

        for iOF = 1: nVols
          tmp_sw_files{1,iOF} =char(strcat(imgNames.name,',', int2str(iOF)));
        end
      end
      sw_files{t,1} = strcat(tmp_sw_files,',1');
    end

    %% Clean the file list
    for sw = 1: length(sw_files);
      dropIx = []; %cleaning step
      for w = 1:numel(sw_files{sw,1})
        meanImg = [prefix,'mean'];
        drop = strfind(sw_files{sw,1}(w),meanImg); % check each cell to see if it is a mean img
        if ~isempty(drop{1,1})
          dropIx = [dropIx w];
        end
      end
      sw_files{sw,1}(dropIx) = []; %removes any entries fitting the exclusion criteria for that scan series
    end
    scan_files = sw_files{:}';
  end
