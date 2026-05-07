
function [P, dist] = compute_optimal_transport(Cost, mu_0, mu_1, lam, max_runs)
    % Inputs:
    %     M : cost matrix (n x m)
    %     mu_0 : vector of marginals (n, )
    %     mu_1 : vector of marginals (m, )
    %     lam : strength of the entropic regularization
    %     epsilon : convergence parameter
    %     Outputs:
    %     P : optimal transport matrix (n x m)
    %     dist : Sinkhorn distance

    % Both rows and columns are adjusted during iterations
    epsilon=1e-8;
    [n, m] = size(Cost);

    Cost = normalize(Cost,"norm");

    K = exp(-Cost / lam);
    u = ones(n,1);
    v = ones(m,1);
    for k = 1:max_runs
        u = mu_0 ./ (K * v); 
        v = mu_1 ./ (K'* u); 

    end 
    P = (diag(u) * K) * diag(v);
    dist = sqrt(sum(sum(P .* Cost)));


