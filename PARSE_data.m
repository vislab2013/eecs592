function [pos neg test] = PARSE_data(name,toption,ioption)
% this function is very dataset specific, you need to modify the code if
% you want to apply the pose algorithm on some other dataset

% it converts the various data format of different dataset into unique
% format for pose detection
% the unique format for pose detection contains below data structure
%   pos:
%     pos(i).im: filename for the image containing i-th human
%     pos(i).point: pose keypoints for the i-th human
%   neg:
%     neg(i).im: filename for the image contraining no human
%   test:
%     test(i).im: filename for i-th testing image
% This function also prepares flipped images and slightly rotated images for training.

globals;

cls = [name '_data'];
try
    load([cachedir cls]);
catch
    switch toption
        case {0,1,2}
            trainfrs_pos = {1:100}; % training frames for positive
            testfrs_pos  = 101:305; % testing frames for positive
            trainfrs_neg = 615:1832; % training frames for negative
            annofile     = {'20120515-pose-release-ver1.3/code-full/PARSE/labels.mat'};
            posims       = {'20120515-pose-release-ver1.3/code-full/PARSE/im%.4d.jpg'};
        case {7,8}
            if toption == 7
                trainfrs_pos = {1:2:100}; % training frames for positive
                testfrs_pos  = 101:305; % testing frames for positive
                trainfrs_neg = 615:1832; % training frames for negative
                annofile     = {'20120515-pose-release-ver1.3/code-full/PARSE/labels.mat'};
                posims       = {'20120515-pose-release-ver1.3/code-full/PARSE/im%.4d.jpg'};
            end
            if toption == 8
                trainfrs_pos = {round(1:1.25:100)}; % training frames for positive
                testfrs_pos  = 101:305; % testing frames for positive
                trainfrs_neg = 615:1832; % training frames for negative
                annofile     = {'20120515-pose-release-ver1.3/code-full/PARSE/labels.mat'};
                posims       = {'20120515-pose-release-ver1.3/code-full/PARSE/im%.4d.jpg'};
            end
        case {11,12}
            trainfrs_pos = {1:70};
            testfrs_pos  = 101:305;
            trainfrs_neg = 615:1832;
            annofile     = {'data_annotation/labels.mat'};
            posims       = {'data_collection/processed/im%.4d.jpg'};
        case {13,14}
            trainfrs_pos = {1:100 1:70};
            testfrs_pos  = 101:305;
            trainfrs_neg = 615:1832;
            annofile     = {'20120515-pose-release-ver1.3/code-full/PARSE/labels.mat' 'data_annotation/labels.mat'};
            posims       = {'20120515-pose-release-ver1.3/code-full/PARSE/im%.4d.jpg' 'data_collection/processed/im%.4d.jpg'};
    end
    
    pos = [];
    numpos = 0;
    for dd = 1:length(trainfrs_pos)
        % -------------------
        % grab positive annotation and image information
        load(annofile{dd});
        for fr = trainfrs_pos{dd}
            numpos = numpos + 1;
            pos(numpos).im = sprintf(posims{dd},fr);
            pos(numpos).point = ptsAll(:,:,fr);
        end
    end
    
    % -------------------
    % rotate positive images by a small amount of degree
    degree = [-15 -7.5 7.5 15];
    posims_rotate = [cachedir 'imrotate/im%.4d_%d.jpg'];
    for n = 1:length(pos)
        im = imread(pos(n).im);
        for i = 1:length(degree)
            imwrite(imrotate(im,degree(i)),sprintf(posims_rotate,n,i));
        end
    end
    
    for n = 1:length(pos)
        im = imread(pos(n).im);
        for i = 1:length(degree)
            numpos = numpos + 1;
            pos(numpos).im = sprintf(posims_rotate,n,i);
            pos(numpos).point = map_rotate_points(pos(n).point,im,degree(i),'ori2new');
        end
    end
    
    % -------------------
    % flip positive training images
    posims_flip = [cachedir 'imflip/im%.4d.jpg'];
    for n = 1:length(pos)
        im = imread(pos(n).im);
        imwrite(im(:,end:-1:1,:),sprintf(posims_flip,n));
    end
    
    % -------------------
    % flip labels for the flipped positive training images
    % mirror property for the keypoint, please check your annotation for your own dataset
    mirror = [6 5 4 3 2 1 12 11 10 9 8 7 13 14];
    for n = 1:length(pos)
        im = imread(pos(n).im);
        width = size(im,2);
        numpos = numpos + 1;
        pos(numpos).im = sprintf(posims_flip,n);
        pos(numpos).point(mirror,1) = width - pos(n).point(:,1) + 1;
        pos(numpos).point(mirror,2) = pos(n).point(:,2);
    end
    
    % -------------------
    % create ground truth keypoints for model training
    % We augment the original 14 joint positions with midpoints of joints,
    % defining a total of 26 keypoints
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
    
    % -------------------
    % grab neagtive image information
    negims = '20120515-pose-release-ver1.3/code-full/INRIA/%.5d.jpg';
    neg = [];
    numneg = 0;
    for fr = trainfrs_neg
        numneg = numneg + 1;
        neg(numneg).im = sprintf(negims,fr);
    end
    
    % -------------------
    % grab testing image information
    if (toption == 11 || toption == 12) && (ioption == 10 || ioption == 11)
        error('training and test on the same dataset (new dataset) ...\n');
    end
    
    switch ioption
        case {0,1}
            testims = '20120515-pose-release-ver1.3/code-full/PARSE/im%.4d.jpg';
            load '20120515-pose-release-ver1.3/code-full/PARSE/labels.mat';
            test = [];
            numtest = 0;
            for fr = testfrs_pos
                numtest = numtest + 1;
                test(numtest).im = sprintf(testims,fr);
                test(numtest).point = ptsAll(:,:,fr);
            end
        case {10,11,20,21}
            if ioption==10 || ioption==11
                load data_annotation/labels.mat;
                testims = 'data_collection/processed/im%.4d.jpg';
                testfrs_pos = 1:70;
            end
            if ioption==20 || ioption==21
                ptsAll = zeros(14,2,7);  % no annotation
                testims = 'data_collection/processed_anec/im%.4d.jpg';
                testfrs_pos = 1:7;
            end
            test = [];
            numtest = 0;
            for fr = testfrs_pos
                numtest = numtest + 1;
                test(numtest).im = sprintf(testims,fr);
                test(numtest).point = ptsAll(:,:,fr);
            end
    end
    save([cachedir cls],'pos','neg','test');
end
