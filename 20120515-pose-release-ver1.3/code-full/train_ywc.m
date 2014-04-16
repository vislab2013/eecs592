function model = train_ywc( name, model, pos, neg, warp, iter )

% compile
if ~exist('learning/qp_onepass_sparse_ywc.mexa64','file')
    cd 'learning/'
    mex -O -largeArrayDims qp_onepass_sparse_ywc.cc
    cd ..
end

% set random seed
rand('state',0);

% set parameter
global trparam;
trparam = set_train_param();

if nargin < 6
    iter = trparam.iter;
end

len  = sparselen(model);

% initialize qp
clear global qp;
global qp;
qp.n  = 0;
% trparam.nmax = 5000;
qp.x  = zeros(len,trparam.nmax,'single');
qp.i  = zeros(5,trparam.nmax,'int32');
qp.b  = zeros(trparam.nmax,1,'single');
qp.a  = zeros(trparam.nmax,1,'double');
qp.d  = zeros(trparam.nmax,1,'double');
qp.sv = false(trparam.nmax,1);
qp.lb = [];

[qp.w,qp.wreg,qp.w0,qp.noneg] = model2vec(model);
qp.w    = (qp.w - qp.w0) .* qp.wreg;
qp.Cpos = trparam.C * trparam.wpos;
qp.Cneg = trparam.C;

% staring training
fprintf('start training!!!\n');
for t = 1:iter
    fprintf('iter  %3d/%3d\n',t,trparam.niter);
    if (warp == 1)
       error('warp should be 1!!!\n');
    else
       npos = poslatent(name, t, model, pos, trparam.overlap);
    end
    %save('qp_init.mat','qp','npos');
    %load('qp_init.mat'); qp.x = single(qp.x);
    %save('qp_init_full.mat','qp','npos','-v7.3');
    
    % Fix positive examples as permenant support vectors
    % Initialize QP soln to a valid weight vector
    % Update QP with coordinate descent
    qp.svfix = 1:qp.n;
    qp.sv(qp.svfix) = 1;
    qp_prune_ywc(); %qp.b = single(qp.b);
    qp_opt_ywc();
    
    model = vec2model(qp_w(),model);
    interval0 = model.interval;
    model.interval = 2;
    
    % grab negative examples from negative images
    for i = 1:length(neg)
        fprintf('\n Image(%d/%d)',i,length(neg));
        im  = imread(neg(i).im);
        [box,model] = detect_ywc(im, model, -1, [], 0, i, -1);
        fprintf(' #cache+%d=%d/%d, #sv=%d, #sv>0=%d, (est)UB=%.4f, LB=%.4f', ...
            size(box,1),qp.n,trparam.nmax,sum(qp.sv),sum(qp.a>0),qp.ub,qp.lb);
        % Stop if cache is full
        if sum(qp.sv) == trparam.nmax,
            break;
        end
    end
    %save('qp_neg_full.mat','qp','model','-v7.3');
    %load('qp_neg_full.mat');
    
    % One final pass of optimization
    qp_opt_ywc();
    model = vec2model(qp_w(),model);
    
    fprintf('\nDONE iter: %d/%d #sv=%d/%d, LB=%.4f\n', ...
        t,iter,sum(qp.sv),trparam.nmax,qp.lb);
    
    % Compute minimum score on positive example (with raw, unscaled features)
    r = sort(qp_scorepos());
    model.thresh   = r(ceil(length(r)*.05));
    model.lb = qp.lb;
    model.ub = qp.ub;
    model.interval = interval0;
    % visualizemodel(model);
    % cache model
    % save([cachedir name '_model_' num2str(t)], 'model');
end

fprintf('qp.x size = [%d %d]\n',size(qp.x));
clear global trparam qp;

end

