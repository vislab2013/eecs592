function model = train_ywc( name, model, pos, neg, warp, iter )

% set random seed
rand('state',0);

% set parameter
global trparam;
trparam = set_train_param();

len  = sparselen(model);

% initialize qp
clear gp;
global qp;
qp.n  = 0;
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
for i = 1:trparam.niter
    fprintf('iter  %3d/%3d\n',i,trparam.niter);
    if (warp == 1)
        error('warp should be 1!!!\n');
    else
        npos = poslatent(name, i, model, pos, trparam.overlap);
    end
end

clear global trparam qp;

end

