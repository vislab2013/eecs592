function model = trainmodel( name, pos, neg, K, pa, sbin, toption )
% toption
%   0: pre-trained model
%   1: original training
%   2: new training

if toption == 0
    load('20120515-pose-release-ver1.3/code-basic/PARSE_model.mat');
    return
end

globals;

file = [cachedir name '.log'];
delete(file);
diary(file);

% part clustering
cls = [name '_cluster_' num2str(K')'];
try
    load([cachedir cls]);
catch
    model = initmodel(pos,sbin);
    def = data_def(pos,model);
    idx = clusterparts(def,K,pa);
    save([cachedir cls],'def','idx');
end

% part training
for p = 1:length(pa)
    cls = [name '_part_' num2str(p) '_mix_' num2str(K(p))];
    try
        load([cachedir cls]);
    catch
        sneg = neg(1:min(length(neg),100));
        model = initmodel(pos,sbin);
        models = cell(1,K(p));
        for k = 1:K(p)
            spos = pos(idx{p} == k);
            for n = 1:length(spos)
                spos(n).x1 = spos(n).x1(p);
                spos(n).y1 = spos(n).y1(p);
                spos(n).x2 = spos(n).x2(p);
                spos(n).y2 = spos(n).y2(p);
            end
            models{k} = train(cls,model,spos,sneg,1,1);
        end
        model = mergemodels(models);
        save([cachedir cls],'model');
    end
end

% full model training
cls = [name '_final1_' num2str(K')'];
try
    load([cachedir cls]);
catch
    model = buildmodel(name,model,def,idx,K,pa);
    for p = 1:length(pa)
        for n = 1:length(pos)
            pos(n).mix(p) = idx{p}(n);
        end
    end
    switch toption
        case 1
            % original training
            model = train(cls,model,pos,neg,0,1);
        case 2
            % new training
            model = train_ywc(cls,model,pos,neg,0,1);
    end
    save([cachedir cls],'model');
end

% post-processing
cls = [name '_final_' num2str(K')'];
try
    load([cachedir cls]);
catch
    if isfield(pos,'mix')
        pos = rmfield(pos,'mix');
    end
    model = train(cls,model,pos,neg,0,1);
    save([cachedir cls],'model');
end

end

