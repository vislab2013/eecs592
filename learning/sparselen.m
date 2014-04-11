% Computes expected number of nonzeros in sparse feature vector 
function len = sparselen(model)

numblocks = 0;
for c = 1:length(model.components)
    feat = zeros(model.len,1);
    for p = model.components{c},
        % biases
        if ~isempty(p.biasid)
            x = model.bias(p.biasid(1));
            i1 = x.i;
            i2 = i1 + numel(x.w) - 1;
            feat(i1:i2) = 1;
            numblocks = numblocks + 1;
        end
        % HOG feature (filter coefficients)
        if ~isempty(p.filterid)
            x  = model.filters(p.filterid(1));
            i1 = x.i;
            i2 = i1 + numel(x.w) - 1;
            feat(i1:i2) = 1;
            numblocks = numblocks + 1;
        end
        % deformation feature
        if ~isempty(p.defid)
            x  = model.defs(p.defid(1));
            i1 = x.i;
            i2 = i1 + numel(x.w) - 1;
            feat(i1:i2) = 1;
            numblocks = numblocks + 1;
        end
    end
    
    % Number of entries needed to encode a block-sparse representation
    %   1 + numberofblocks*2 + #nonzeronumbers
    len = 1 + numblocks*2 + sum(feat);
end