function qp_onepass_ywc( )
% Perform one pass through current set of support vectors
%   Ci: \alpha_i in Ramanan's paper
%   G : g_{ij} in Ramanan's paper

global qp;

MEX = true;
%MEX = false;

d   = length(qp.w);
C   = 1;
eps = 1e-12;

% Randomly permute the dual variable indices
I = find(qp.sv);
I = I(randperm(length(I)));
assert(~isempty(I));

% Verify no sharing hypothesis
[si,J] = sortrows(qp.i(:,I)');
si = si';
eqid = [0 all(si(:,2:end) == si(:,1:end-1),1)];
if any(eqid)
    pause;
end

if MEX
    loss = qp_onepass_sparse_ywc(qp.x,qp.i,qp.b,qp.d,qp.a,qp.w,qp.noneg,qp.sv,qp.l,1,I);
else
    n   = length(I);
    idC = zeros(n,1);
    idP = zeros(n,1);
    idI = zeros(n,1);
    err = zeros(n,1);
    num = 1;
    
    % Go through sorted list to compute
    % idP(i) = pointer to idC associated with I(i)
    % idC(i) = sum of alpha values with same id
    % idI(i) = pointer to some example with the same id as I(i)
    [~,sI] = sortrows(qp.i(:,I)');
    sI     = sI';
    i0     = I(sI(1));
    for j = sI
        i1 = I(j);
        % Increment counter if we at new id
        if any(qp.i(:,i1) ~= qp.i(:,i0)),
            num = num + 1;
        end
        idP(j)   = num;
        idC(num) = idC(num) + qp.a(i1);
        i0 = i1;
        % Save i1 to idI(num) if qp.a(i1) can be decreased
        if qp.a(i1) > 0,
            idI(num) = i1;
        end
    end
    assert(all(idC >= 0 & idC <= C));
    
    for t = 1:n
        i = I(t);
        j = idP(t);
        x = sparse2dense(qp.x(:,i),d);
        % % The following two lines are useful for violations of
        % % 0<=Ai<=C and Ai<=Ci<=C due to precision issues
        % qp.a(i) = max( min( qp.a(i), C ), 0 );
        % Ci      = max( min( idC(j), C ), qp.a(i) );
        Ci = idC(j);
        G  = double(qp.b(i)) - dot(qp.w,x);
        PG = G;
        
        % Can not update \alpha_{ij}: Skip the current data point
        if ((qp.a(i) == 0 && G <= 0) || (Ci >= C && G >= 0))
            PG = 0;
        end
        
        % Update error
        if (G > err(j))
            err(j) = G;
        end
        
        % Update support vector flag
        if (qp.a(i) == 0 && G < 0)
            qp.sv(i) = false;
        end
        
        if (Ci >= C && G > eps && qp.a(i) < C && idI(j) ~= i && idI(j) > 0)
            % Pick another dual variable with same i
            i2 = idI(j);
            x2 = sparse2dense(qp.x(:,i2),d);
            
            % g' = g_{ij} - g_{ik} in Ramanan's paper
            Gp = G - (double(qp.b(i2)) - dot(qp.w,x2));
            
            % Update support vector flag
            if (qp.a(i) == 0 && Gp < 0)
                Gp = 0;
                qp.sv(i) = false;
            end
            
            % Check if we'd like to increase alpha but
            % a) linear constraint is active (sum of alphas with this id == C)
            % b) we've encountered another constraint with this id that we can decrease
            if (abs(Gp) > eps)
                % Update qp.a(i) and qp.a(i2)
                Hp = qp.d(i) + qp.d(i2) - 2*dot(x,x2);
                da = Gp / Hp;
                % Clip da to box constraints
                % da > 0: a(i) = min(a(i)+da,C),  a(i2) = max(a(i2)-da,0);
                % da < 0: a(i) = max(a(i)+da,0),  a(i2) = min(a(i2)-da,C);
                if (da > 0)
                    da = min ( min ( da, C-qp.a(i) ), qp.a(i2) );
                else
                    da = max ( max ( da, -qp.a(i) ), qp.a(i2)-C );
                end
                qp.a(i)  = qp.a(i)  + da;
                qp.a(i2) = qp.a(i2) - da;
                assert(qp.a(i)  >= 0 && qp.a(i)  <= C);
                assert(qp.a(i2) >= 0 && qp.a(i2) <= C);
                
                % Update qp.l
                qp.l = qp.l + da * (double(qp.b(i)) - double(qp.b(i2)));
                
                % Update qp.w and qp.noneg
                qp.w = qp.w + da * (x-x2);
                qp.w(qp.noneg) = max(qp.w(qp.noneg),0);
            end
        elseif (abs(PG) > eps)
            % Update qp.a(i)
            da      = min ( max ( G/qp.d(i), -qp.a(i) ), C - Ci);
            qp.a(i) = qp.a(i) + da;
            assert(qp.a(i) >= 0 && qp.a(i) <= C);
            
            % Update qp.l
            qp.l = qp.l + da * double(qp.b(i));
            
            % Update \alpha_i
            idC(j) = min ( max ( Ci + da, 0 ), C);
            assert(idC(j) >= 0 && idC(j) <= C);
            
            % Update qp.w and qp.noneg
            qp.w = qp.w + da * x;
            qp.w(qp.noneg) = max(qp.w(qp.noneg),0);
        end
        % Record example if it can be used to satisfy a future linear constraint
        if (qp.a(i) > 0)
            idI(j) = i;
        end
    end
    % Compute total error
    loss = sum(err);
end

qp_refresh();

% Update objective
qp.sv(qp.svfix) = 1;
qp.lb_old       = qp.lb;
qp.lb           = -(0.5)*dot(qp.w,qp.w) + qp.l;
qp.ub           = 0.5*dot(qp.w,qp.w) + loss;
assert(all(qp.w(qp.noneg) >= 0));
assert(all(qp.a(1:qp.n) >= 0));
assert(all(qp.a(1:qp.n) <= C));

end

