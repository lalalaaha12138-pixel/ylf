function [U, V, P, R, obj] = FCMETF_P(X, c, m, gamma, mu, maxIter, tol,UFCM)
    % ===========输入==========：
    %X : 样本矩阵
    %c : 簇数
    %m : m < d; 降维后的维数
    %gamma mu 超参数
    %maxIter 迭代数
    %tol 容忍度
    
    
    % ===========输出==========
    %U 隶属度矩阵 n x c
    %V 聚类中心   d x c
    %P 降维矩阵   m x d
    %R 旋转矩阵   m x c
    %obj 模型目标值

    [d,n] = size(X);
    % rng(4);
    % ===========初始化========
    U = rand(n, c);
    U = U ./ sum(U, 2); % ensure row sums to 1
    % U = UFCM';
    % 
    % V: d x c, 
    ind = randperm(n, c);
    V = X(: , ind);
    
    % P: d x m
    
    P = eye(d,m);
    % [P, ~] = qr(P, 0);
    
    % R: m x c
    % R = rand(m, c);
    % [R, ~] = qr(R, 0);
    % R = R(:, 1:c); 
    R = eye(m,c);
    
    % Lambda: c x c 
    Lambda = eye(c); % initial
    
    % E
    E = sqrt(c/(c-1)) * (eye(c) - 1/c * ones(c));
    
    
    %============更新迭代======
    
    obj = zeros(maxIter, 1);




    for i = 1 : maxIter 
        %============更新V====== 
    
        D = diag(sum(U, 1)); % c x c
        S = P' * X * U; % m x c 
        % 分子: (S + μ R E Λ)
        % R E Λ = m x c
        numerator = S + mu * R * E * Lambda; % m x c
        % 分母: (D + μ I_c)^{-1}
        denominator = inv(D + mu * eye(c)); % c x c
        V = P * (numerator * denominator);
    
        %============更新R======
    
        M = P' * V; % m x c
        N = E * Lambda; % c x c
        MN = M * N';
        [Uq, ~, Vq] = svd(MN, 'econ');
        R = Uq * Vq';
    
        %============更新Lambda=
    
        M = P' * V; % m x c
        Q = R * E;  % m x c
        lambda = zeros(c, 1);
        for j = 1:c
            qj = Q(:, j);
            mj = M(:, j);
            num = qj' * mj;
            den = qj' * qj;
            if den > 0
                lambda(j) = max(0, num / den);
            else
                lambda(j) = 0;
            end
        end
        Lambda = diag(lambda);
    
        %============更新P======

        A = X * X' - X * U * V' - V * U' * X' + V * D * V' + mu * (V * V');
        B = mu * V * Lambda * E' * R';
        P = gpicode(A, B, P);

        %============更新U======

        distX = EuDist2((P'*X)',(P'*V)',0);      %这里指距离的平方
      
        for iii = 1 : 1:n
            vi = -1*distX(iii,:)/(2* gamma);
            U(iii,:) = EProjSimplex(vi);
        end

        %============obj========
        
        J1 = 0;
        for ii = 1:n
            for j = 1:c
                diff = P' * (X(:, ii) - V(:, j));
                J1 = J1 + U(ii, j) * (diff' * diff);
            end
        end
        J2 = gamma * norm(U, 'fro')^2;
        J3 = mu * norm(P' * V - R * E * Lambda, 'fro')^2;
        obj(i) = J1 + J2 + J3;
    
        % 显示进度
        if mod(i, 10) == 0
            fprintf('Iteration %d, Objective = %.6f\n', i, obj(i));
        end
    
        % 检查收敛
        % if i > 1 && abs(obj(i) - obj(i-1)) < tol * abs(obj(i-1))
        if i > 1 && abs(obj(i) - obj(i-1)) < tol

            fprintf('Converged at iteration %d\n', i);
            obj = obj(1:i);
            break;
        end
    end

    if i == maxIter
        obj = obj(1:i);
        fprintf('Reached maximum iterations: %d\n', maxIter);
    end
end


