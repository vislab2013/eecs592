function qp_opt_ywc( )
% Optimize qp by iterating through the dataset until the difference between
% UB and LB is below tol.

global trparam;
global qp;

% qp_refresh();

I = 1:qp.n;
[si,J] = sortrows(qp.i(:,I)');
si = si';
eqid = [0 all(si(:,2:end) == si(:,1:end-1),1)];

% compute current LB and UB
slack = qp.b(I) - score(qp.w,single(qp.x),I);
loss  = computeloss(slack(J),eqid);
ub    = 0.5*dot(qp.w,qp.w) + loss;
lb    = qp.lb;
%qp.sv
fprintf('LB=%.4f, UB=%.4f\n',lb,ub);

for i = 1:trparam.qp_iter
    %qp_onepass_ywc();
    qp_one();
    fprintf('.');
    if mod(i,200) == 0
        fprintf('\n');
    end
    lb     = qp.lb; LB(i) = lb;
    ub_est = qp.ub; UB(i) = ub_est;
    assert(lb > 0);
    %assert(ub_est > lb);
    if ub_est - lb < trparam.qp_tol * ub_est
        slack = qp.b(I) - score(qp.w,single(qp.x),I);
        loss  = computeloss(slack(J),eqid);
        ub    = 0.5*dot(qp.w,qp.w) + loss;
        if ub - lb < trparam.qp_tol * ub
            break
        end
        %qp.sv
    end
end

fprintf('stop at iter %d\n',i);
fprintf('LB=%.4f, UB=%.4f\n',lb,ub);

end

