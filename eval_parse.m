clc; close all; clear;
% setting
toption = 1;
ioption = 1;
poolsize = 8;
global tname; tname = ['t' num2str(toption,'%02d') 'i' num2str(ioption,'%02d')];
% globals;
name = 'PARSE';
% --------------------
% specify model parameters
% number of mixtures for 26 parts
K = [6 6 6 6 6 6 6 6 6 6 6 6 6 6 ...
         6 6 6 6 6 6 6 6 6 6 6 6]; 
% Tree structure for 26 parts: pa(i) is the parent of part i
% This structure is implicity assumed during data preparation
% (PARSE_data.m) and evaluation (PARSE_eval_pcp)
pa = [0 1 2 3 4 5 6 3 8 9 10 11 12 13 2 15 16 17 18 15 20 21 22 23 24 25];
% Spatial resolution of HOG cell, interms of pixel width and hieght
% The PARSE dataset contains low-res people, so we use low-res parts
sbin = 4;
% --------------------
% Prepare training and testing images and part bounding boxes
% You will need to write custom *_data() functions for your own dataset
[pos neg test] = PARSE_data(name);
pos = point2box(pos,pa);
% --------------------
% % training
% model = trainmodel(name,pos,neg,K,pa,sbin);
model = trainmodel(name,pos,neg,K,pa,sbin,toption);
% --------------------
% testing phase 1
% human detection + pose estimation
suffix = num2str(K')';
model.thresh = min(model.thresh,-2);
% boxes = testmodel(name,model,test,suffix);
% new + par
boxes = testmodel_par(name,model,test,suffix,ioption,poolsize);
% --------------------
% evaluation 1: average precision of keypoints
% You will need to write your own APK evaluation code for your data structure
apk = PARSE_eval_apk(boxes,test);
meanapk = mean(apk);
fprintf('mean APK = %.1f\n',meanapk*100);
fprintf('Keypoints & Head & Shou & Elbo & Wris & Hip  & Knee & Ankle\n');
fprintf('APK       '); fprintf('& %.1f ',apk*100); fprintf('\n');
% --------------------
% testing phase 2
% pose estimation given ground truth human box
model.thresh = min(model.thresh,-2);
% boxes_gtbox = testmodel_gtbox(name,model,test,suffix);
% new + par
boxes_gtbox = testmodel_gtbox_par(name,model,test,suffix,ioption,poolsize);
% --------------------
% evaluation 2: percentage of correct keypoints
% You will need to write your own PCK evaluation code for your data structure
pck = PARSE_eval_pck(boxes_gtbox,test);
meanpck = mean(pck);
fprintf('mean PCK = %.1f\n',meanpck*100); 
fprintf('Keypoints & Head & Shou & Elbo & Wris & Hip  & Knee & Ankle\n');
fprintf('PCK       '); fprintf('& %.1f ',pck*100); fprintf('\n');
% --------------------
% visualization
if(1)
    % figure(1);
    % visualizemodel(model);
    % figure(2);
    % visualizeskeleton(model);
    % switch ioption
    %     case 0
    %         det_dir = 'result/pretr_detect_fast/';
    %         det_gt_dir = 'result/pretr_detect_gt_fast/';
    %     case 1
    %         det_dir = 'result/pretr_detect_new/';
    %         det_gt_dir = 'result/pretr_detect_gt_new/';
    % end
    det_dir = ['result/vis_' tname '/'];
    det_gt_dir = ['result/vis_gt_' tname '/'];
    makedir(det_dir);
    makedir(det_gt_dir);
    figure;
    for demoimid = 1:length(test)
        tic_print(sprintf('  %3d/%3d\n',demoimid,length(test)));
        % demoimid = 1;
        im = imread(test(demoimid).im);
        colorset = {'g','g','y','r','r','r','r','y','y','y','m','m','m','m','y','b','b','b','b','y','y','y','c','c','c','c'};
        box = boxes{demoimid};
        % show all detections
        % figure(3);
        % subplot(1,2,1); showboxes(im,box,colorset);
        % subplot(1,2,2); showskeletons(im,box,colorset,model.pa);
        clf; showboxes(im,box,colorset);
        savename = [det_dir 'img' num2str(demoimid,'%04d') '_1.pdf'];
        print(gcf,'-dpdf',savename);
        clf; showskeletons(im,box,colorset,model.pa);
        savename = [det_dir 'img' num2str(demoimid,'%04d') '_2.pdf'];
        print(gcf,'-dpdf',savename);
        % show best detection overlap with ground truth box
        box = boxes_gtbox{demoimid};
        % figure(4);
        % subplot(1,2,1); showboxes(im,box,colorset);
        % subplot(1,2,2); showskeletons(im,box,colorset,model.pa);
        clf; showboxes(im,box,colorset);
        savename = [det_gt_dir 'img' num2str(demoimid,'%04d') '_1.pdf'];
        print(gcf,'-dpdf',savename);
        clf; showskeletons(im,box,colorset,model.pa);
        savename = [det_gt_dir 'img' num2str(demoimid,'%04d') '_2.pdf'];
        print(gcf,'-dpdf',savename);
    end
    close;
end
