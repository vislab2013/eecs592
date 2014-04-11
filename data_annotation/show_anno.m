
% annotation
pa = [0 1 2 3 4 5 6 3 8 9 10 11 12 13 2 15 16 17 18 15 20 21 22 23 24 25];

load PARSE/labels.mat;
posims = 'PARSE/im%.4d.jpg';
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

for i = 1:numpos
    pos = point2box(pos(i),pa);
    box = [pos.x1 pos.y1 pos.x2 pos.y2];
    box = reshape(box',[],1)';
    im  = imread(pos(i).im);
    subplot(1,2,1); showboxes(im,box,colorset);
    subplot(1,2,2); showskeletons(im,box,colorset,pa);
end