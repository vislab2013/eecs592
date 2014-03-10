function boxes = testmodel_par(name,model,test,suffix,imoption,poolsize)
% boxes = testmodel(name,model,test,suffix)
% Returns candidate bounding boxes after non-maximum suppression
if nargin < 5
    imoption = 1;
end

globals;

switch imoption
    case 0
        savename = [cachedir name '_boxes_' suffix];
    case 1
        savename = [cachedir name '_boxes_' suffix '_new'];
end

set(findResource(), 'ClusterSize', 12);
matlabpool('open',poolsize);
pctRunOnAll warning off

try
  load(savename);
catch
  boxes = cell(1,length(test));
  parfor i = 1:length(test)
    fprintf([name ': testing: %d/%d\n'],i,length(test));
    im = imread(test(i).im);
    switch imoption
        case 0
            box = detect_fast(im,model,model.thresh);
        case 1
            box = detect_new(im,model,model.thresh);
    end
    boxes{i} = nms(box,0.3);
  end

  if nargin < 4
    suffix = [];
  end
  save(savename, 'boxes','model');
end
