imdir = '../20120515-pose-release-ver1.3/code-full/PARSE/';
list = dir([imdir '*.jpg']);

R = zeros(length(list),1);
for i = 1:length(list)
    im = imread([imdir list(i).name]);
    [rr,cc,~] = size(im);
    R(i) = rr/cc;
end

[~,ii] = sort(R,'descend');
I1 = uint8(zeros(0,1980));
I2 = uint8(zeros(0,1980));
I3 = uint8(zeros(0,1980));
for i = 1:13
    IM1 = uint8(zeros(100,0));
    IM2 = uint8(zeros(100,0));
    IM3 = uint8(zeros(100,0));
    for j = 1:23
        id = ii(13 * (j-1) + i);
        im = imread([imdir list(id).name]);
        im = imresize(im,[100 NaN]);
        IM1 = [IM1 im(:,:,1)];
        IM2 = [IM2 im(:,:,2)];
        IM3 = [IM3 im(:,:,3)];
    end
    %size(IM1)
    I1 = [I1;imresize(IM1,[NaN 1980])];
    I2 = [I2;imresize(IM2,[NaN 1980])];
    I3 = [I3;imresize(IM3,[NaN 1980])];
end
IM = uint8(zeros([size(I1),3]));
IM(:,:,1) = I1;
IM(:,:,2) = I2;
IM(:,:,3) = I3;

figure; imshow(IM);
imwrite(IM,'concat_parse.jpg','jpg');