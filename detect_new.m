function boxes = detect_new(im, model, thresh)
% new implementation of detect

% feature extraction
pyra     = featpyramid(im, model);
interval = model.interval;
levels   = 1:length(pyra.feat);

% Cache various statistics derived from model
[components,filters,resp] = modelcomponents(model,pyra);
boxes = zeros(10000,length(components{1})*4+2);
cnt   = 0;

assert(length(components) == 1);
comp = 1;
for l = 1:length(levels)
    rlevel = levels(l);
    % part detection
    parts = components{1};
    numparts = length(parts);
    for k = 1:numparts
        level = rlevel-parts(k).scale * interval;
        fid   = parts(k).filterid;
        if isempty(resp{level})
            % apply part filters
            resp_li       = cell(1,length(filters));
            [sp1,sp2,sp3] = size(pyra.feat{level});
            for fi = 1:length(filters)
                [sf1,sf2,~] = size(filters{fi});
                ffilter = zeros(sp1-sf1+1,sp2-sf2+1);
                for si = 1:sp3
                    ffilter = ffilter+filter2(filters{fi}(:,:,si),pyra.feat{level}(:,:,si),'valid');
                end
                resp_li{fi} = ffilter;
            end
            resp{level} = resp_li;
        end
        for i = 1:length(fid)
            parts(k).score(:,:,i) = resp{level}{fid(i)};
        end
        parts(k).level = level;
    end
    
    % message passing
    % figure;
    for k = numparts:-1:2
        child  = parts(k);
        parent = parts(parts(k).parent);
        numfiltC = length(child.filterid);
        [sc_y,sc_x,~] = size(child.score);
        numfiltP = length(parent.filterid);
        [sp_y,sp_x,~] = size(parent.score);
        assert(sc_x == sp_x);
        assert(sc_y == sp_y);
        
        SC  = zeros(sc_y,sc_x,numfiltC);
        IxC = zeros(sc_y,sc_x,numfiltC);
        IyC = zeros(sc_y,sc_x,numfiltC);
        for t = 1:numfiltC
            w     = -child.w(:,t);
            dx    = child.startx(t);
            dy    = child.starty(t);
            tSC   = child.score(:,:,t);
            [X,Y] = meshgrid(1:sc_x,1:sc_y);
            for tx = 1:sc_x
                for ty = 1:sc_y
                    tX = X - tx;
                    tY = Y - ty;
                    tdef = w(1) * (tX-dx).^2 + w(2) * (tX-dx) + w(3) * (tY-dy).^2 + w(4) * (tY-dy);
                    tall  = tdef + tSC;
                    [vv,ii] = max(tall(:));
                    SC(ty,tx,t) = vv;
                    [IyC(ty,tx,t),IxC(ty,tx,t)] = ind2sub([sc_y,sc_x],ii);
                end
            end
        end
        
        msg = zeros(sp_y,sp_x,numfiltP);
        IxP = zeros(sp_y,sp_x,numfiltP);
        IyP = zeros(sp_y,sp_x,numfiltP);
        IkP = zeros(sp_y,sp_x,numfiltP);
        for t = 1:numfiltP
            b = child.b(1,t,:);
            [msg(:,:,t),IkP(:,:,t)] = max(SC + repmat(b,sp_y,sp_x),[],3);
            i0 = reshape(1:sp_x*sp_y,sp_y,sp_x) + (sp_y*sp_x) * (IkP(:,:,t) - 1);
            IxP(:,:,t) = IxC(i0);
            IyP(:,:,t) = IyC(i0);
        end
        
        % clf;
        % subplot(121); imagesc(parts(parts(k).parent).score(:,:,1));
        parts(parts(k).parent).score = parts(parts(k).parent).score + msg;
        parts(k).Ix                  = IxP;
        parts(k).Iy                  = IyP;
        parts(k).Ik                  = IkP;
        % subplot(122); imagesc(parts(parts(k).parent).score(:,:,1));
        % pause;
    end
    
    % Add bias to root score
    parts(1).score = parts(1).score + parts(1).b;
    
    % find optimized solution
    [rscore Ik]    = max(parts(1).score,[],3);

    % Walk back down tree following pointers
    [Y,X] = find(rscore >= thresh);
    if length(X) > 1,
      I   = (X-1)*size(rscore,1) + Y;
      box = backtrack(X,Y,Ik(I),parts,pyra);
      i   = cnt+1:cnt+length(I);
      boxes(i,:) = [box repmat(comp,length(I),1) rscore(I)];
      cnt = i(end);
    end
end

boxes = boxes(1:cnt,:);

end

