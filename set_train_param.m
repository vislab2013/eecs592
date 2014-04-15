function param = set_train_param( )

param.niter   = 1;
param.C       = 0.002;
param.wpos    = 2;
param.overlap = 0.6;

param.nmax    = 1e5;

param.qp_iter = 1000;
param.qp_tol  = 0.05;

end

