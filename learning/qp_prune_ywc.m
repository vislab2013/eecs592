function qp_prune_ywc( )

global qp;

% if cache is full of support vectors, only keep non-zero (and fixed) ones
if all(qp.sv),
  qp.sv = qp.a > 0;
  qp.sv(qp.svfix) = 1;
end

I = find(qp.sv);
n = length(I);
assert(n > 0);

d = length(qp.w);

% re-compute l and w
qp.l = 0;
qp.w = zeros(size(qp.w));
for j = 1:n
    i = I(j);
    qp.x(:,j) = qp.x(:,i);
    qp.i(:,j) = qp.i(:,i);
    qp.b(j)   = qp.b(i);
    qp.d(j)   = qp.d(i);
    qp.a(j)   = qp.a(i);
    qp.sv(j)  = qp.sv(i);
    qp.l      = qp.l + double(qp.b(j) * qp.a(j));
    qp.w      = qp.w + sparse2dense(qp.x(:,j),d) * qp.a(j);
end

qp.n            = n;
qp.x(:,n+1:end) = zeros(size(qp.x(:,n+1:end)));
qp.i(:,n+1:end) = zeros(size(qp.i(:,n+1:end)));
qp.b(n+1:end)   = 0;
qp.d(n+1:end)   = 0;
qp.a(n+1:end)   = 0;
qp.sv(n+1:end)  = 0;
assert(all(qp.sv(1:n)==1));

qp.w(qp.noneg) = max(qp.w(qp.noneg),0);
qp.lb          = -(0.5)*dot(qp.w,qp.w) + qp.l;

fprintf(' Pruned to %d/%d with lb = %.4f\n',length(I),length(qp.a),qp.lb);

end

