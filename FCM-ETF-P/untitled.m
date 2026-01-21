clc;
clear;
load fisheriris.mat;
X = meas;  
true_labels = grp2idx(species);  
    
[d, n] = size(X);
% X = zscore(X);
% 参数设置
gamma = 0.1;
mu = 0.1;
maxIter = 50;
tol = 1e-4;
c = 3;
m = 3;
[U, V, P, R] = FCMETF_P(X', c, m, gamma, mu, maxIter, tol);

