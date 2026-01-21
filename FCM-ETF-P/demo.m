clear; clc;

fprintf('=== FCM-ETF 在鸢尾花数据集上的测试 ===\n');
load fisheriris.mat;
X = meas;  
true_labels = grp2idx(species);  
    

% X = zscore(X);

% 参数设置
gamma = 0.1;
mu = 1;
maxIter = 500;
tol = 1e-6;
c = 3;
m = 3;
cluster_n = 3;

optionsFCM = [2, 50, 1e-5, 0];
[~, UFCM, ~] = fcm(X, cluster_n, optionsFCM);
% 运行算法
[U, V, P, R, obj] = FCMETF_P(X', c, m, gamma, mu, maxIter, tol,UFCM);

% 评估聚类结果
[~, predicted_labels] = max(U, [], 2);
    
% 计算聚类准确率 
    
result = Clustering8Measure(true_labels, predicted_labels);
fprintf('聚类准确率: %.2f%%\n', result(1) * 100);
fprintf('NMI准确率: %.2f%%\n', result(2) * 100);


