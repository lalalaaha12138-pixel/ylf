function test()
% test iris
    fprintf('=== FCM-ETF 在鸢尾花数据集上的测试 ===\n');
    load fisheriris.mat;
    X = meas;  
    true_labels = grp2idx(species);  
    
    [n, d] = size(X);
    X = zscore(X);
    % X_normalized = preprocess_data(X,'zscore_sphere');
    
    % fprintf('数据集信息: %d 个样本, %d 维特征, %d 个类别\n', n, d, c);
    %TEST 此处显示有关此函数的摘要
     % 算法参数
    c = 3;          % 聚类数
    m = 2.0;        % 模糊指数
    lambda =0;   % 正则化参数
    max_iter = 100; % 最大迭代次数
    tol = 1e-6;     % 收敛容忍度


    % 运行 FCM-ETF 算法
    tic;
    [U, V, R, ~] = fcm_etf_aligned(X, c, m, lambda, max_iter, tol);
    runtime = toc;
    
    fprintf('算法运行时间: %.2f 秒\n', runtime);
    
    % 评估聚类结果
    [~, predicted_labels] = max(U, [], 2);
    
    % 计算聚类准确率 
    
    result = Clustering8Measure(true_labels, predicted_labels);
    fprintf('聚类准确率: %.2f%%\n', result(1) * 100);
    
    % 绘制结果
    % plot_clustering_results(X_normalized, U, V, R, init_etf(c));
end

