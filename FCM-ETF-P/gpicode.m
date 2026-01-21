function P = gpicode(A, B, P_init)
    % Generalized Power Iteration for solving min_{P'P=I} tr(P' A P - 2 P' B)
    % Input: 
    %   A: symmetric matrix d x d
    %   B: matrix d x m
    %   P_init: initial orthogonal matrix d x m
    % Output:
    %   P: optimal orthogonal matrix
    
    maxIterGPI = 100;
    tolGPI = 1e-6;
    
    d = size(A, 1);
    m = size(P_init, 2);
    P = P_init;
    
    % Compute alpha such that alpha*I - A is positive definite
    alpha = eigs(A, 1, 'lm') + 1e-6;
    A_tilde = alpha * eye(d) - A;
    
    for iter = 1:maxIterGPI
        M = 2 * A_tilde * P + 2 * B;
        [U, ~, V] = svd(M, 'econ');
        P_new = U * V';
        
        if norm(P_new - P, 'fro') < tolGPI
            break;
        end
        P = P_new;
    end
end