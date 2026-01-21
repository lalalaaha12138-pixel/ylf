clc;clear;
% 创建模拟数据用于演示
load fisheriris;  % 加载Iris数据集
data = meas';
n = size(data, 2);  % 样本数 = 150
c = 3;  % 聚类数

% 随机生成隶属度矩阵用于演示（实际应用时替换为你的FCM结果）
% U = rand(c, n);
% U = U ./ sum(U, 1);  % 归一化，使每列和为1

% load U.mat
% U = U';

optionsFCM = [2, 50, 1e-5, 0];
[VFCM, U, obj_fcn] = fcm(data, 3, optionsFCM);

% 绘制隶属度矩阵
figure;
imagesc(1:n, 1:c, U);
colorbar;

% 设置坐标轴标签
xlabel('Pattern No.', 'FontSize', 12);
ylabel('Cluster No.', 'FontSize', 12);


% 设置坐标轴方向
axis xy;  % 确保坐标原点在左下角
