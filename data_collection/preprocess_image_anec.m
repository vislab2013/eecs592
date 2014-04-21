%% rename
clear;

imdir = 'raw_anec/';
EXT   = {'.JPG','.jpg'};

opdir = 'raw_rename_anec/';
if ~exist(opdir,'dir')
    mkdir(opdir);
end

cnt = 1;
for e = 1:length(EXT)
    ext = EXT{e};
    list  = dir([imdir '*' ext]);
    for i = 1:length(list)
        fprintf('  %3d/%3d\n',i,length(list));
        im = imread([imdir list(i).name]);
        savename = [opdir 'im' num2str(cnt,'%04d'),'.jpg'];
        imwrite(im,savename,'jpg');
        cnt = cnt + 1;
    end
end

%%
% rotate_id = [5 6 9 10 12 16 20 21 23 24 25 26 27 29 30 34 36 37 38 39 40 ...
%     41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 58 59 60 61 63];
rotate_id = [1 2 3 4];

max_length = [480 480];

imdir = 'raw_rename_anec/';
ext   = '.jpg';
list  = dir([imdir '*' ext]);

savedir = 'processed_anec/';
if ~exist(savedir,'dir')
    mkdir(savedir);
end

for i = 1:length(list)
    fprintf('  %3d/%3d\n',i,length(list));
    im = imread([imdir list(i).name]);
    [rr,cc,ch] = size(im);
    
    % rotate image
    if find(rotate_id == i)
        tim = uint8(zeros(cc,rr,ch));
        for j = 1:ch
            tim(:,:,j) = im(:,:,j)';
            tim(:,:,j) = tim(:,end:-1:1,j);
        end
        im = tim;
    end
    [rr,cc,ch] = size(im);
    
    % resize image
    [mm,ii] = max([rr,cc]);
    if mm > max_length(ii)
        switch ii
            case 1
                im = imresize(im,[max_length(1),NaN]);
            case 2
                im = imresize(im,[NaN,max_length(1)]);
        end
    end
 
    savename = [savedir 'im' num2str(i,'%04d'),'.jpg'];
    imwrite(im,savename,'jpg');
end

