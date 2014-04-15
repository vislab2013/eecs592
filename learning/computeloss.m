function loss = computeloss(slack,eqid)
% Zero-out scores that aren't the greatest violated constraint for an id
% eqid(i) = 1 if x(i) and x(i-1) are from the same id
% eqid(1) = 0
% v is the best value in the current block
% i is a ptr to v
% j is a ptr to the example we are considering

err = logical(zeros(size(eqid)));
for j = 1:length(err),
    % Are we at a new id?
    % If so, update i,v
    if eqid(j) == 0,
        i = j;
        v = slack(i);
        if v > 0,
            err(i) = 1;
        else
            v = 0;
        end
        % Are we at a new best in this set of ids?
        % If so, update i,v and zero out previous best
    elseif slack(j) > v
        err(i) = 0;
        i = j;
        v = slack(i);
        err(i) = 1;
    end
end

loss = sum(slack(err));