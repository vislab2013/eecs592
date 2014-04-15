function model = train_ywc( name, model, pos, neg, warp, iter )

% set random seed
rand('state',0);

% set parameter
global trparam;
trparam = set_train_param();

len  = sparselen(model);

% initialize qp
clear global qp;
global qp;
qp.n  = 0;
trparam.nmax = 5000;
qp.x  = zeros(len,trparam.nmax);
qp.i  = zeros(5,trparam.nmax,'int32');
qp.b  = zeros(trparam.nmax,1);  % l_{ij}
qp.a  = zeros(trparam.nmax,1);  % \alpha_{ij}
qp.d  = zeros(trparam.nmax,1);
qp.sv = false(trparam.nmax,1);
qp.lb = [];

[qp.w,qp.wreg,qp.w0,qp.noneg] = model2vec(model);
qp.w    = (qp.w - qp.w0) .* qp.wreg;
qp.Cpos = trparam.C * trparam.wpos;
qp.Cneg = trparam.C;

% staring training
fprintf('start training!!!\n');
for t = 1:trparam.niter
    fprintf('iter  %3d/%3d\n',t,trparam.niter);
    %if (warp == 1)
    %    error('warp should be 1!!!\n');
    %else
    %    npos = poslatent(name, i, model, pos, trparam.overlap);
    %end
    %save('qp_init.mat','qp','npos');
    load('qp_init.mat'); qp.x = single(qp.x);
    
    % Fix positive examples as permenant support vectors
    % Initialize QP soln to a valid weight vector
    % Update QP with coordinate descent
    qp.svfix = 1:qp.n;
    qp.sv(qp.svfix) = 1;
    qp_prune_ywc();  qp.b = single(qp.b);
    qp_opt_ywc();
    
    w = qp_w();
    model = vec2model(w,model);
    interval0 = model.interval;
    model.interval = 2;
    
    % grab negative examples from negative images
    for i = 1:length(neg)
        fprintf('\n Image(%d/%d)',i,length(neg));
        im  = imread(neg(i).im);
        [box,model] = detect(im, model, -1, [], 0, i, -1);
        fprintf(' #cache+%d=%d/%d, #sv=%d, #sv>0=%d, (est)UB=%.4f, LB=%.4f',size(box,1),qp.n,nmax,sum(qp.sv),sum(qp.a>0),qp.ub,qp.lb);
        % Stop if cache is full
        if sum(qp.sv) == nmax,
            break;
        end
    end
    
end

clear global trparam qp;

end

