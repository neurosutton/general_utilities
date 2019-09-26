files = spm_select; %select the rp*.txt file
for f=1:size(files,2)
    fprintf(files(f,:));
    rp =spm_load(files(f,:));
    figure;
    subplot(2,1,1);plot(rp(:,1:3));
    set(gca,'xlim',[0 size(rp,1)+1]);
    subplot(2,1,2);plot(rp(:,4:6));
    set(gca,'xlim',[0 size(rp,1)+1]);
end