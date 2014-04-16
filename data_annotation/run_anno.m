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
%% combine annotation
annodir = 'data_annotation/annotation/';
list = dir([annodir '*.mat']);
ptsAll = zeros(14,2,length(list));
for i = 1:length(list)
    anno = load([annodir list(i).name]);
    ptsAll(:,:,i) = anno.pts;
end
anno_parse = load('20120515-pose-release-ver1.3/code-full/PARSE/labels.mat');
segmentTypes = anno_parse.segmentTypes;
save('data_annotation/labels.mat','ptsAll','segmentTypes');
%% visualization
pa = [0 1 2 3 4 5 6 3 8 9 10 11 12 13 2 15 16 17 18 15 20 21 22 23 24 25];
trainfrs_pos = 1:70;

load data_annotation/labels.mat;
posims = 'data_collection/processed/im%.4d.jpg';
pos = [];
numpos = 0;
for fr = trainfrs_pos
    numpos = numpos + 1;
    pos(numpos).im = sprintf(posims,fr);
    pos(numpos).point = ptsAll(:,:,fr);
end

% interpolation
I = [1  2  3  4   4   5  6   6   7  8   8   9   9   10 11  11  12 13  13  14 ...
    15 16  16  17 18  18  19 20  20  21  21  22 23  23  24 25  25  26];
J = [14 13 9  9   8   8  8   7   7  9   3   9   3   3  3   2   2  2   1   1 ...
    10 10  11  11 11  12  12 10  4   10  4   4  4   5   5  5   6   6];
A = [1  1  1  1/2 1/2 1  1/2 1/2 1  2/3 1/3 1/3 2/3 1  1/2 1/2 1  1/2 1/2 1 ...
    1  1/2 1/2 1  1/2 1/2 1  2/3 1/3 1/3 2/3 1  1/2 1/2 1  1/2 1/2 1];
Trans = full(sparse(I,J,A,26,14));

for n = 1:length(pos)
    pos(n).point = Trans * pos(n).point; % linear combination
end

% visualization
colorset = {'g','g','y','r','r','r','r','y','y','y','m','m','m','m','y','b','b','b','b','y','y','y','c','c','c','c'};

savedir = 'data_annotation/anno_vis/';
if ~exist(savedir,'dir')
    mkdir(savedir);
end

figure;
for i = 1:numpos
    fprintf(' %3d/%3d\n',i,numpos);
    tpos = point2box(pos(i),pa);
    box = [tpos.x1 tpos.y1 tpos.x2 tpos.y2];
    box = reshape(box',[],1)';
    im  = imread(pos(i).im);
    clf;
    showboxes(im,box,colorset);
    savename = [savedir 'anno' num2str(i,'%04d') '_box.pdf'];
    print(gcf,'-dpdf',savename);
    clf
    showskeletons(im,box,colorset,pa);
    savename = [savedir 'anno' num2str(i,'%04d') '_stick.pdf'];
    print(gcf,'-dpdf',savename);
    %subplot(1,2,1); showboxes(im,box,colorset);
    %subplot(1,2,2); showskeletons(im,box,colorset,pa);
    %pause
end
close;