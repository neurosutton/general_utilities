function set_spm(ver)
%set_spm X OR set_spm(X), where X is spm version (8 or 12)
%sets up path for the specified spm version
%Copyleft 2016, eugene.kronberg@ucdenver.edu
%Revised 2017, brianne.mohl@ucdenver.edu

%convert ver to double if called as set_spm X
if ~exist('ver','var')
    ver = '12b';
elseif isnumeric(ver)
    ver = num2str(ver)
end

%if spm is on the path - remove all spm directories from the path
p = fileparts(which('spm'));
if ~isempty(p)
    rm_spm_path(p);
end

switch ver
    case '8'
        addpath('/usr/local/MATLAB/tools/spm8');
    case '12'
        addpath('/usr/local/MATLAB/tools/spm12');
    case '12b'
        addpath('/usr/local/MATLAB/tools/spm12b');
    otherwise
        error('SPM version must be 8, 12, 12b')
end

function rm_spm_path(p)
%remove all directories from the path which start with p
n = length(p);
z = path;
while true
    [t,r] = strtok(z,':');
    if length(t) >= n && strcmp(t(1:n),p)
        rmpath(t);
    end
    if isempty(r)
        break
    else
        %skip first ':'
        z = r(2:end);
    end
end
