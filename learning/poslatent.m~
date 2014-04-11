% get positive examples using latent detections
% we create virtual examples by flipping each image left to right
function numpositives = poslatent(name, t, model, pos, overlap)
  
numpos = length(pos);
numpositives = zeros(length(model.components), 1);
minsize = prod(model.maxsize*model.sbin);
  
for i = 1:numpos
    fprintf('%s: iter %d: latent positive: %d/%d\n', name, t, i, numpos);
    % skip small examples
    bbox.xy = [pos(i).x1 pos(i).y1 pos(i).x2 pos(i).y2];
    if isfield(pos,'mix')
        bbox.m = pos(i).mix;
    end
    area = (bbox.xy(:,3)-bbox.xy(:,1)+1).*(bbox.xy(:,4)-bbox.xy(:,2)+1);
    if any(area < minsize)
        continue;
    end
    
    % get example
    im = imread(pos(i).im);
    [im, bbox] = croppos(im, bbox);
    box = detect(im, model, 0, bbox, overlap, i, 1);
    if ~isempty(box),
        fprintf(' (comp=%d,sc=%.3f)\n',box(1,end-1),box(1,end));
        c = box(1,end-1);
        numpositives(c) = numpositives(c)+1;
    end
end