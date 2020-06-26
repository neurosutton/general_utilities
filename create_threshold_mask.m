function [out_masks] = create_threshold_mask(input_files)

if ~iscell(input_files)
  [n_rows,~] = size(input_files);
  rowDist = ones(n_rows,1);
  input_files = mat2cell(input_files, rowDist); %Split row by row, into a cell array
end


out_masks = [];
for f=1:length(input_files)
  clear matlabbatch;
  spm_jobman('initcfg');
  [outdir, basename] = fileparts(input_files{f});

  %Find 80% of the max probability
  %Dynamic definition because the participants vary greatly on the probability values for WM or CSF normalization
  volume = spm_vol(input_files{f});
  matrix = spm_read_vols(volume);
  threshold = .7*max(matrix(:));

  fprintf('%s thresholded at %d',basename,threshold)

  matlabbatch{1}.spm.util.imcalc.input = {strcat(input_files{f},',1')}; %SPM requires ,1 to load image
  matlabbatch{1}.spm.util.imcalc.output = strcat('thresh_',basename);
  matlabbatch{1}.spm.util.imcalc.outdir = {outdir};
  matlabbatch{1}.spm.util.imcalc.expression = strcat('i1 >', num2str(threshold));
  matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
  matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
  matlabbatch{1}.spm.util.imcalc.options.mask = 0;
  matlabbatch{1}.spm.util.imcalc.options.interp = 1;
  matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
  spm_jobman('run',matlabbatch);
  out_masks = [out_masks;fullfile(outdir,strcat('thresh_',basename,'.nii'))];
end
