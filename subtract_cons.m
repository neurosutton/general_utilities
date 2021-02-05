set_spm 8

group1  = spm_select([1,400],'nii','Select first group');
group1_size = size(group1);
group1_numb = group1_size(1);
group1_length = group1_size(2);
group2  = spm_select([group1_numb,group1_numb],'nii','Select second group' );
newExt = '_FastedMinusFed';
newExt = '_baselineMinusPost';

for sub=1:group1_numb
    [pth file ext] = fileparts(group1(sub,:));
    outputfile=fullfile(pth, [file newExt ext]);
    file1=fullfile(pth,[file ext]);
    [pth file ext] = fileparts(group2(sub,:));
    file2=fullfile(pth,[file ext]);
    subindex=strvcat(file1, file2);
    spm_imcalc_ui(subindex,outputfile,'(i1-i2)');
end
