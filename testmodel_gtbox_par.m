function boxes = testmodel_gtbox_par(name,model,test,suffix,ioption,poolsize)
% boxes = testmodel_gtbox(name,model,test,suffix)
% Returns highest scoring pose that sufficiently overlaps a detection window
% 1) Construct ground-truth bounding box
% 2) Compute all candidates that sufficiently overlap it
% 3) Return highest scoring one  
if nargin < 5
    ioption = 1;
end
if nargin < 6
    poolsize = 12;
end

globals;

switch ioption
    case {0,10,20}
        savename = [cachedir name '_boxes_gtbox_' suffix];
    case {1,11,21}
        savename = [cachedir name '_boxes_gtbox_' suffix '_new'];
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
    switch ioption
        case {0,10,20}
            box = detect_fast(im,model,model.thresh);
        case {1,11,21}
            box = detect_new(im,model,model.thresh);
    end
    x = test(i).point(:,1);
    y = test(i).point(:,2);
    gtbox = [min(x) min(y) max(x) max(y)];
    boxes{i} = bestoverlap(box,gtbox,0.3);
  end

  if nargin < 4 
    suffix = [];
  end
  save(savename, 'boxes','model');
end

matlabpool close
