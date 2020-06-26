function f = plot_ovrly_imgs(tmplt, ovrly)

spm('defaults','FMRI');

if ~exist('tmplt','var')
    tmplt = spm_select(1,'nii','Specify background image');
    ovrly = spm_select(1,'nii','Specify ovrly image');
end

if ischar(tmplt) || ischar(ovrly)
    try
        V = spm_vol(tmplt);
        tmplt_img = spm_read_vols(V);
        V = spm_vol(ovrly);
        ovrly_img = spm_read_vols(V);
    catch ME
        rethrow(ME);
    end
    % Check that the images have the same dimensions
    if ~isequal(size(tmplt_img), size(ovrly_img));
        % Load any existing resliced files that may already exist
        [ovrly_img_dir, ovrly_img_name, ext] = fileparts(ovrly);
        prefix = 'r';
        resliced_img_name = fullfile(ovrly_img_dir,[prefix ovrly_img_name ext]);
        % See if that resliced image is in the correct space/dimension
        % to avoid extra computational time
        if exist(resliced_img_name,'file') 
            resliced_img = spm_read_vols(spm_vol(resliced_img_name));
            if ~isequal(size(tmplt_img), size(resliced_img))
                reslice_imgs(tmplt_name,ovrly_img_name, prefix);
            end
        else
            reslice_imgs(tmplt_name,ovrly_img_name, prefix);
        end
    end
end

f = figure;
spm_image('image', tmplt, [0.05 0.05 0.9 0.9]);
spm_image('addimage',1,ovrly);
close(f);