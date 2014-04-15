function qp_prune_ywc( )

global qp;

I = find(qp.sv);

d = length(qp.w);

qp.l = 0;
qp.w = zeros(size(qp.w));  % reset w
for j = 1:length(I)
    i = I(j);
    % for the following, we can use index j rather than i once pruned
    qp.l = qp.l + qp.b(i) * qp.a(i);
    qp.w = qp.w + sparse2dense(qp.x(:,i),d) * qp.a(i);
end

qp.lb = -(0.5)*dot(qp.w,qp.w) + qp.l;

fprintf(' Pruned to %d/%d with lb = %.4f\n',length(I),length(qp.a),qp.lb);

end

