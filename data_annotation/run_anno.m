% 'lank', 'lkne', 'lhip', 'rhip', 'rkne', 'rank', 'lwr', 'lelb', 'lsho', 'rsho', 'relb', 'rwr', 'hbot', 'htop'
clear;

imdir   = 'data_collection/processed/';
annodir = 'data_annotation/annotation/';
if ~exist(annodir,'dir')
    mkdir(annodir);
end

num_pt  = 14;

ext  = '.jpg';
list = dir([imdir '*' ext]);

ex_im = imread('20120515-pose-release-ver1.3/code-full/PARSE/im0001.jpg');
ex_pt = load('20120515-pose-release-ver1.3/code-full/PARSE/labels.mat');
ex_pt = ex_pt.ptsAll(:,:,1);

figure;
subplot(121); imshow(ex_im); hold on;
for i = 1:length(list)
    fprintf('  %3d/%3d\n',i,length(list));
    savename = [annodir list(i).name(1:end-4) '.mat'];
    if exist(savename,'file')
        continue;
    end
    
    pts = zeros(num_pt,2);
    im  = imread([imdir list(i).name]);
    % clf;
    if exist('han','var');
        set(han, 'Visible', 'off');
    end
    subplot(122); han = imshow(im); hold on;
    for p = 1:size(pts,1)
        subplot(121);
        if exist('hpt_ex','var')
            set(hpt_ex, 'Visible', 'off');
        end
        hpt_ex = plot(ex_pt(p,1),ex_pt(p,2),'ro','MarkerFaceColor','r','MarkerSize',10);
        
        subplot(122);
        [pts(p,1),pts(p,2)] = ginput(1);
        hpt_an = plot(pts(p,1),pts(p,2),'go','MarkerFaceColor','g','MarkerSize',10);
    end
    save(savename,'pts');
end
close;