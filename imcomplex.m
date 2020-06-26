function imcomp = imcomplex(img)
%imcomplex(img) calculate image complexity
%img - N by M (for indexed colors) or N by M by 3 (for true colors)
%complex - is structure with fields:
%   ...
%
%with no input argument imcomplex prompts for jpeg image files (all files
%must be in the same directory)
%in this case results would be saved in comma-separated-value (CSV) file

%uigetfile({'*.jpeg;*.jpg','JPEG File'} 

if nargin == 0
    [imfile, imdir] = ...
        uigetfile({'*.bmp','BMP File'}, ...
        'Select Image Files','MultiSelect','on');
    if ~ischar(imdir)
        return
    end
    if ischar(imfile)
        imfile = {imfile};%must be cell array
    end
    imcomp = file_complex(imdir, imfile);
    return
end

%calculate complesity for the image
imcomp = complexity(img);

function imcomp = file_complex(imdir, imfile)
imcomp = struct( ...
    'Imagedirectory', imdir, ...
    'Filename', imfile, ...
    'FileSize', [], ...
    'Compression', [], ...
    'Width', [], ...
    'Height', [], ...
    'BitDepth', [], ...
    'ColorType', '', ...
    'SpatialInfo', [], ...
    'Intensity', [], ...
    'Shades', []);
%create CSV file
out_csv = fopen(fullfile(imdir, 'Complexity.csv'), 'w');
%write CSV header
fprintf(out_csv, 'File Name, File Size, Image Width, Image Height, Color Type, Bit Depth, Compression, Spatial Information, Mean Intensity, Shades\n');
for fi = 1:length(imfile)
    image_file = fullfile(imdir, imfile{fi});
    file_info = imfinfo(image_file);
    img = imread(image_file, 'bmp'); % EK had jpg
    imc = complexity(img);
    %copy fields
    imcomp(fi).FileSize = file_info.FileSize;
    imcomp(fi).Width = file_info.Width;
    imcomp(fi).Height = file_info.Height;
    imcomp(fi).BitDepth = file_info.BitDepth;
    imcomp(fi).Compression = ...
        imcomp(fi).FileSize * 24 / ... %8 bits per byte per r-g-b
        (imcomp(fi).Width * imcomp(fi).Height * imcomp(fi).BitDepth);
    imcomp(fi).ColorType = file_info.ColorType;
    imcomp(fi).SpatialInfo = imc.SpatialInfo;
    imcomp(fi).Intensity = imc.Intensity;
    imcomp(fi).Shades = imc.Shades;
    fprintf(out_csv, '%s, %d, %d, %d, %s, %d, %f, %f, %f, %f\n', ...
        imcomp(fi).Filename, ...
        imcomp(fi).FileSize, ...        
        imcomp(fi).Width, ...
        imcomp(fi).Height, ...
        imcomp(fi).ColorType, ...
        imcomp(fi).BitDepth, ...
        imcomp(fi).Compression, ...
        imcomp(fi).SpatialInfo, ...
        imcomp(fi).Intensity, ...
        imcomp(fi).Shades);
end
fclose(out_csv);

function imcomp = complexity(img)
img = imflat(img);%convert to gray scale
imcomp = struct(...
    'Width', size(img,2), ...
    'Height', size(img,1), ...
    'SpatialInfo', spatial_info(img), ...
    'Intensity', mean(img(:)), ...
    'Shades', std(img(:)));

function img = imflat(img)
%avarage intensity of red/green/blue
img = mean(img,3);

function sinfo = spatial_info(img)
%spatial information (edge energy)
k = sobel;
vedge = conv2(img,k,'same');%vertiacl edges
gedge = conv2(img,k','same');%horizontal edges
sinfo = mean(sqrt(vedge(:).^2 + gedge(:).^2));

function k = sobel
%k is 3 by 3 sobel kernel
k = [
    -1 0 1
    -2 0 2
    -1 0 1
    ];
