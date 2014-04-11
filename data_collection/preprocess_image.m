clear;

rotate_id = [1 2];

max_length = [480 480];

imdir = 'raw/';
ext   = '.JPG';
list  = dir([imdir '*' ext]);

savedir = 'processed/';
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

