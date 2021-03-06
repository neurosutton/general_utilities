function acpc_autodetect(images)
% Purpose: Find the rough estimate of AC-PC, en batch
% Purpose2: Specifically crafted to try with the ABCD dataset
% Date: 03.22.18
% Author: Brianne Sutton, PhD
% This script tries to set AC-PC with 2 steps.
% 1. Set origin to center (utilizing a script by F. Yamashita)
% 2. Use spm_affreg per Carlton Chu's adaptation of Ashburner's spm8
% scripts.

%% Validation
% 1) Set the origin to a way-off place and re-oriented the subject's
%  images per the SPM12b GUI.
% 2) Ran the script.
% 3)

set_spm % custom script, which cleans up the path to include spm12 calls only
spmDir=fileparts(which('spm'));
if isempty(which('cfg_getfile'))
    disp('Updating path')
    addpath([spmDir,filesep, 'matlabbatch']);
    addpath([spmDir,filesep, 'toolbox/OldNorm']);
end

%% Select images
if ~exist('images','var')
    imglist=spm_select([1,Inf],'image','Choose MRI you want to set AC-PC');
else
    if isdir(images)
        disp('Reorienting the whole study.')
        imglist = glob(strcat(images, filesep, '*/*/*nii'));
    else
        imglist = cellstr(images);
    end
end

%% Set the origin to the center of the image
% This part is written by Fumio Yamashita.
for i=1:size(imglist,1)
    img = char(strrep(deblank(imglist(i,:)),",1",""))
    [subjDir subjImg ext] = fileparts(img);
    touchFile = [subjDir, filesep, 'touch_acpc.txt'];

    %% Decide what kind of scan is being processed
    [projDir scan_type] = fileparts(subjDir);
    substring = {'t1','anat'};
    if contains(lower(scan_type), substring) || contains(lower(subjImg), substring)
        anatPath = 'yes';
        template=[spmDir filesep 'canonical/avg152T1.nii'];
    else
        epiPath = 'yes';
        template=[spmDir filesep 'canonical/EPI.nii']; %avg152T2
    end

    standardTemplate=spm_vol(template);
    checkList = [];
    cd (subjDir)

    %% Reassign the center of the FOV as the ACPC, then adjust for average displacement per MR recording site.
    if ~exist (touchFile, 'file') && exist ('anatPath','var')
        %         copyfile(img, [trial,subjImg, ext]);
        %         cImg = [subjDir, filesep, trial,subjImg, ext];
        cImg = [subjDir, filesep, subjImg, ext];
        %qImg = [subjDir, filesep, 'q', subjImg, ext];
        inputImg =spm_vol(cImg);
        oldmat = strcat(subjDir,filesep, subjImg, '.mat');
        if exist(oldmat, 'file') %eliminates previous re-orientations that may not be overwritten, but rather multiplied
            delete(oldmat);
        end

        if isnan(inputImg(1).mat)
            fclose(fopen('unable2process.txt','w'));
        else
            switch inputImg(1).dim(1)
                case 108
                    update_hdr(inputImg(1),  2, -8); % [104.5, 130, 120]
                case 256
                    update_hdr(inputImg(1), 0, 2); %works for AMC scans
                case 64
                    update_hdr(inputImg(1), 0, 6); % AMC IR_EPI
                case 208
                    update_hdr(inputImg(1),  0 ,0); %[104.5, 128, 128]
                    %This site seems to be quite unpredicatable. Consider manual
                    %ACPC alaignment
                    checkList = [checkList, img];
                case 90
                    update_hdr(inputImg(1), 10, 0);
                case 96
                    update_hdr(inputImg(1), 10, 0);
                case  176
                    update_hdr(inputImg(1), 15, 5); %[88, 143, 133]
                case  225
                    update_hdr(inputImg(1), 8, 18); %[113, 136, 146]
                otherwise
                    fprintf('New dimension to consider: %s; Dim: %d\n>>> Approximating center of FOV <<<\n', subjImg, inputImg(1).dim(1));
                    update_hdr(inputImg(1),  0 ,0);
            end
            if ~isnan(inputImg(1).mat)
                %inputImg = spm_vol(newName); % defined in update_hdr as "q" image
                update_hdr_coreg(inputImg(1), standardTemplate); %Didn't seem to be a beneficial step for all sites, initially, so kept as a separate function.
                disp('');
            end
        end

    elseif ~exist (touchFile, 'file') && exist ('epiPath','var')
        imgs = [subjDir, filesep, subjImg, ext];
        imgList = spm_vol(imgs);
        if isnan(imgList(1).mat)
            fclose(fopen('unable2process.txt','w'));
        else
            switch imgList(1).dim(1)
                case 108
                    update_hdr(imgList(1),  2, -8); % [104.5, 130, 120]
                case 256
                    update_hdr(imgList(1), 2, 30); %works for AMC scans
                case 208
                    update_hdr(imgList(1),  0 ,0); %[104.5, 128, 128]
                    %This site seems to be quite unpredicatable. Consider manual
                %ACPC alaignment
                case 64
                    update_hdr(imgList(1),  0 ,0);
                case 90
                    update_hdr(imgList(1), 10, 0);
                case 96
                    update_hdr(imgList(1), 10, 0);
                case 176
                    update_hdr(imgList, 15, 5); %[88, 143, 133]
                case 225
                    update_hdr(imgList(1), 8, 18); %[113, 136, 146]
                otherwise
                    fprintf('New dimension to consider: %s; Dim: %d\n>>> Approximating center of FOV <<<\n', subjImg, imgList(1).dim(1));
                    update_hdr(imgList(1),  0 ,0);
            end

            %update_hdr(imgList(1), 2,-3);
            [newMat] =update_hdr_coreg(imgList(1), standardTemplate, 'none');
            fprintf('May take awhile... %d volumes\n\n', length(imgList));

            for i = 2:length(imgList)
                num=int2str(i);
                spm_get_space(char(strcat(imgList(1).fname,",",num)), newMat); %Must include the index via the strcat or the mat is only applied to the first image
            end
        end

    else
        fprintf('%s was aligned\n', subjImg);
    end
    %save(strcat(projDir,filesep,'check_acpc_alignment.txt'));
end

function [newMat] = update_hdr (inputImg, corrFactor1, corrFactor2)
vs = inputImg.mat\eye(4); %throw away line just to define vs?
vs(1:3,4) = (inputImg.dim+1)/2;
vs(2,4) = vs(2,4)  + corrFactor1; % TRANSLATION X
vs(3,4) = vs(3,4) + corrFactor2; %the origin was too low  %TRANSLATION Up/down
if isnan(vs)
    fclose(fopen('bad_centering.txt','w'));
else
    [sDir name ext] = fileparts(inputImg.fname);
    disp('Centered origin defined by:')
    newMat = inv(vs) %inv has to be there or the neg values leave the coreg with no mutual information
    spm_get_space(inputImg.fname, newMat);

    % %% If you want to save the in-between step
    % % Note: add newName as an output
    % newName = strcat(sDir, filesep,'q', strcat(name,ext));
    % Y = spm_read_vols(inputImg);
    % inputImg.fname = newName;
    % inputImg.mat = newMat;
    % spm_write_vol(inputImg, Y);
end

function [newMat] = update_hdr_coreg (inputImg,standardTemplate,smooth)
flags.regtype='subj'; % seems to be better than rigid or MNI
if ~exist('smooth', 'var')
    fprintf('Smoothing and finding affine matrix; Dim1 = %d\n', inputImg.dim(1));
    spm_smooth(inputImg,'temp.nii',[10 10 10]);
    vol2manipulate=spm_vol('temp.nii');
else
    fprintf('Finding affine matrix; Dim1 = %d\n', inputImg.dim(1));
    vol2manipulate= inputImg;
end
[M,scal] = spm_affreg(standardTemplate,vol2manipulate(1),flags);

% %% Chu's original. Definitely needed if flag is mni; may not be needed if flag is rigid
% M3=M(1:3,1:3);
% [u s v]=svd(M3);
% M3=u*v';
% M(1:3,1:3)=M3;
% % newMat = M

%% Translated from Ashburner's suggestion; is the same as Chu's method, if voxels are 1x1x1
coregMatrix = M;
Affine = coregMatrix(1:3,1:3);
Zlocation = sqrtm(Affine*Affine');
rotation = Zlocation\Affine;
Zlocation = [Zlocation [0 0 0]' ; 0 0 0 1];
rotation = [rotation [0 0 0]' ; 0 0 0 1];
translation = (Zlocation*rotation)\coregMatrix;
M = rotation*translation;

Y = spm_read_vols(inputImg);
[sDir name ext] = fileparts(inputImg.fname);
% newName = strcat(sDir, filesep,'p', strcat(name,ext));
% inputImg.fname = newName;
inputImg.mat = M*inputImg.mat;
newMat = inputImg.mat
if isnan(newMat)
    fclose(fopen('bad_coreg.txt','w'));
    return
else
    spm_write_vol(inputImg, Y);
    fprintf('>Creating shifted matrix:%s\n', inputImg.fname);
    if exist('temp.nii','file')
        delete('temp.nii');
    end
    %fclose(fopen('touch_acpc.txt', 'w'));
end
