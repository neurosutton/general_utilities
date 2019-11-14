function [spm_home, template_home] = update_script_paths(tool_dir, spm_ver)
if ~exist('tool_dir','var')
    try
      which('file_selector_task');
      tool_dir = fileparts(fileparts(which('file_selector_task')));
      addpath(tool_dir);
    catch
        disp('Path not well-defined')
    end
end

addpath([tool_dir filesep 'general_utilities']);
addpath([tool_dir filesep 'fmri_processing_utilities']);
addpath([tool_dir filesep 'asl_utilities']);

if exist('spm_ver','var') && contains(string(spm_ver),'8')
    set_spm('8');
    spm_home=fileparts(which('spm'));
    addpath([spm_home,filesep, 'matlabbatch']);
elseif isempty(which ('spm')) || ~strcmp(spm('ver'), 'SPM12');
    set_spm ('12');
    spm_home=fileparts(which('spm'));
    addpath([spm_home,filesep, 'matlabbatch']);
end
spm_home=fileparts(which('spm'));
template_home = [spm_home, filesep, 'tpm'];

end
