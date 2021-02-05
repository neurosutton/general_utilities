function plot_mtn_graphs(files)
% Use this function to plot a single, non-saved version of the motion plots.
% Use plot_mtn_graphs_batch to plot and save motion graphs for a subset or entire study.
%
% BMS

if ~exist('files','var')
    files = spm_select; %select the rp*.txt file
end

for f=1:size(files,2)
    fprintf(files(f,:));
    [subj_dir, rp_filename] = fileparts(strtrim(files(f,:)));
    rp =spm_load(strtrim(files(f,:)));
    figure;
    subplot(2,1,1);plot(rp(:,1:3));
    set(gca,'xlim',[0 size(rp,1)+1]);
    subplot(2,1,2);plot(rp(:,4:6));
    set(gca,'xlim',[0 size(rp,1)+1]);
end