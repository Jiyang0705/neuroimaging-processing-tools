% ------------------
% webViewSlices_pair
% ------------------
%
% DESCRIPTION:
%   Generate a webpage to view the slices of multiple images
%
% INPUT:
%   pair1_CellArrVertical = vertical cell array containing path to base 
%   images
%
%   otherPairs_CellArrVertical = vertical cell array containing path to
%   other image counterparts. If there are more than one counterpart image,
%   put each of them horizontally. i.e. number of columns equals to
%   number of counterpart images.
%
%   outputDir = path to directory containing output
%
%   title = title of the webpage
%
%   outputFormat = 'web', 'arch', 'web&arch'
%
% OUTPUT:
%   A webpage will automatically display on screeen, or be archived as zip file.
%


function webViewSlices_pair (pair1_CellArrVertical, otherPairs_CellArrVertical, outputDir, title, outputFormat)

% special characters in title
title = strrep (title, ' ', '_');
title = strrep (title, '.', '_');

if exist ([outputDir '/' title '.html'],'file') == 2
    delete([outputDir '/' title '.html']);
end

if exist ([outputDir '/png'], 'dir') ==7
    rmdir ([outputDir '/png'], 's');
end

mkdir (outputDir, 'png');

[N_subj, N_otherPairs] = size (otherPairs_CellArrVertical);
fprintf ('webViewSlices_pair: %d counterpart/s.\n', N_otherPairs);
[Npair1,~] = size(pair1_CellArrVertical);

if (Npair1 ~= N_subj)
    error ('webViewSlices_pair: Base and overlay image cell arrays are not of the same size.');
end


%% Slice images
fprintf ('webViewSlices_pair: Slicing images ...\n');
[scriptsFolder,~,~] = fileparts(which([mfilename '.m']));% get scripts folder

pair1_pathNfilename = cell (Npair1,2);
otherPairs_pathNfilename = cell (N_subj, (N_otherPairs*2));

for i = 1:Npair1
    [pair1_Folder,pair1_Filename,~] = fileparts (pair1_CellArrVertical{i,1});
    pair1_pathNfilename{i,1} = pair1_Folder;
    pair1_Filename_parts = strsplit(pair1_Filename,'.');
    pair1_pathNfilename{i,2} = pair1_Filename_parts{1};
    
    for k = 1:N_otherPairs
        [otherPairs_Folder,otherPairs_Filename,~] = fileparts (otherPairs_CellArrVertical{i,k});
        overlayImgFilename_parts = strsplit(otherPairs_Filename,'.');
        otherPairs_pathNfilename {i,(k*2-1)} = otherPairs_Folder;
        otherPairs_pathNfilename {i,(k*2)} = overlayImgFilename_parts{1};
    end
end

parfor m = 1:Npair1
    system ([scriptsFolder '/webViewSlices_sliceBaseImg.sh ' pair1_pathNfilename{m,1} ' ' ...
                                                                  pair1_pathNfilename{m,2} ' ' ...
                                                                  outputDir ...
                                                                  ]);
                                                              
    for n = 1:N_otherPairs
            system ([scriptsFolder '/webViewSlices_sliceBaseImg.sh ' otherPairs_pathNfilename{m,(n*2-1)} ' ' ...
                                                                          otherPairs_pathNfilename{m,(n*2)} ' ' ...
                                                                          outputDir ...
                                                                          ]);
    end
end


%% generate webpage to view
%outputDir '/' title '.html
html_txt = cell ((Npair1 + N_otherPairs * N_subj + 2), 1);
html_txt{1} = ['<HTML><TITLE>' title '</TITLE><BODY BGCOLOR="#aaaaff">'];
for p = 1:Npair1
    html_txt{(2 + (p-1) * (N_otherPairs+1)), 1} = ['<a><img src="' outputDir '/png/' pair1_pathNfilename{p,2} '_Slices_merged.png" WIDTH=1000 > ' pair1_pathNfilename{p,2} '</a><br>'];
    for q = 1:N_otherPairs
        html_txt{(2 + (p-1) * (N_otherPairs+1) + q), 1} = ['<a><img src="' outputDir '/png/' otherPairs_pathNfilename{p,(q*2)} '_Slices_merged.png" WIDTH=1000 >' otherPairs_pathNfilename{p,(q*2)} '</a><br>'];
    end
end
% 	echo "" >> ${outputDir}/${title}.html
% 	echo "<a><img src=\"${outputDir}/${overlayOnBaseImg}_Slices_merged.png\" WIDTH=1000 > ${overlayOnBaseImg}</a><br>" >> ${outputDir}/${title}.html
html_txt{end,1} =  '</BODY></HTML>';

% write html to text file
fid = fopen ([outputDir '/' title '.html'], 'wt');
fprintf (fid, '%s\n', html_txt{:});
fclose(fid);


%% view
switch outputFormat
    case 'web'
        fprintf ('webViewSlices_pair: Generating webpage ...\n');
        web ([outputDir '/' title '.html'], '-new');
    case 'arch'
        fprintf ('webViewSlices_pair: Archiving ...\n');
        archive (outputDir, title);
    case 'web&arch'
        fprintf ('webViewSlices_pair: Generating webpage ...\n');
        web ([outputDir '/' title '.html'], '-new');
        fprintf ('webViewSlices_pair: Archiving ...\n');
        archive (outputDir, title);
end


fprintf('webViewSlices_pair: Done.\n');

function archive (outputDir, title)
 
    outputDir_shell = strrep (outputDir, '/', '\/');
    system (['sed -i.bak ''s/' outputDir_shell '/\./g'' ' outputDir '/' title '.html']);
    zip ([outputDir '/' title '.zip'], {'png/*.png', '*.html'}, outputDir);
    
    fprintf (['Link: ' outputDir '/' title '.zip\n']);
