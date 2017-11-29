function [spm_home, template_home] = update_script_paths(tool_dir)
if ~exist('tool_dir','var')
    try
        tool_dir = fileparts(fileparts(which('file_selector_task')));
    catch
        disp('Path not well-defined')
    end
end

addpath(tool_dir);
addpath([tool_dir filesep 'general_utilities']);
addpath([tool_dir filesep 'fmri_processing_utilities']);
addpath([tool_dir filesep 'asl_utilities']);

if isempty(which ('spm')) || ~strcmp(spm('ver'), 'SPM12b');
    set_spm ('12b');
    spm_home=fileparts(which('spm'));
    addpath([spm_home,filesep, 'matlabbatch']);
end
spm_home=fileparts(which('spm'));
template_home = [spm_home, filesep, 'tpm'];

end