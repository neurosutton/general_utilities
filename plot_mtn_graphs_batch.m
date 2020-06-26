function plot_mtn_graphs_batch(input_files)

% Recreates and saves regression parameter plots similar to SPM's depiction
% Requires MATLAB2019a or higher

% Feb 2020
% Brianne Sutton, PhD

disp('Printing plot of regresssors')
if ~exist('input_files','var')
    input_files = spm_select; %select the rp*.txt file
end

cmap = [1 0 0
    0 1 0
    0 0 1
    1 0 0
    0 1 0
    0 0 1];


for f=1:size(input_files,1)
    [subj_dir, rp_filename, ~] = fileparts(input_files(f,:));
    rp =spm_load(input_files(f,:));
    figure;
    
    %% Translation
    subplot(2,1,1);plot(rp(:,1:3));
    title(rp_filename);
    ylabel('mm');
    colororder(gca, cmap);
    legend({'X','Y','Z'},'location','eastoutside');
    set(gca,'xlim',[0 size(rp,1)+1]);   
%    set(gca, 'ylim', scale_ymm);

    %% Rotation
    subplot(2,1,2);plot(rp(:,4:6)*180/pi);
%    set(gca, 'ylim', scale_ydg);
    ylabel('degrees');
    xlabel('Volumes');
    colororder(gca, cmap);
    legend({'Pitch','Roll','Yaw'},'location','eastoutside');
    set(gca,'xlim',[0 size(rp,1)+1]);
    saveas(gca, fullfile(subj_dir, strcat('plot_', rp_filename, '.pdf')));
    close(gcf);
end
disp('Done.')
