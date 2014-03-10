function boxes = testmodel(name,model,test,suffix,imoption)
% boxes = testmodel(name,model,test,suffix)
% Returns candidate bounding boxes after non-maximum suppression
if nargin < 5
    imoption = 1;
end

globals;

try
  load([cachedir name '_boxes_' suffix]);
catch
  boxes = cell(1,length(test));
  for i = 1:length(test)
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
  switch imoption
      case 0
          save([cachedir name '_boxes_' suffix], 'boxes','model');
      case 1
          save([cachedir name '_boxes_' suffix '_new'], 'boxes','model');
  end
end
