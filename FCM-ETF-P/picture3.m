%% FCM聚类在Iris数据集上的三维可视化
clear; close all; clc;

%% 1. 加载和准备数据
load fisheriris;  % 加载Iris数据集
X = meas;        % 150x4的特征矩阵
trueLabels = species;  % 真实标签

% 将文本标签转换为数值
[~, ~, trueLabels_num] = unique(trueLabels);  % 1:Setosa, 2:Versicolor, 3:Virginica

%% 2. 执行FCM聚类
numClusters = 3;
% options = [2.0, 100, 1e-5, 0];  % [指数, 最大迭代次数, 最小改进, 显示信息]
% [centers, U] = fcm(X, numClusters, options);
load("U.mat");
U = U';
% 将隶属度矩阵转换为硬分类
[~, fcmLabels] = max(U);

%% 3. PCA降维到3D用于可视化
% [coeff, score, ~, ~, explained] = pca(X);
% X_3D = score(:, 1:3);  % 前三个主成分
% 
% % 将聚类中心投影到3D空间
% centers_3D = (centers - mean(X)) * coeff(:, 1:3);
load("P.mat");
load("X.mat");
load("V.mat");
X_3D = P' * X';
X_3D = X_3D';
centers_3D = P' * V;
%% 4. 计算错误分类点（简化版，不需要munkres）
% 简单的标签映射：将每个聚类映射到其样本中最多的真实类别
matching = zeros(1, numClusters);
usedCategories = false(1, numClusters);

for k = 1:numClusters
    % 找出该聚类中所有样本的真实类别
    clusterSamples = trueLabels_num(fcmLabels == k);
    if ~isempty(clusterSamples)
        % 找出出现最多的类别
        [counts, categories] = groupcounts(clusterSamples);
        [~, idx] = max(counts);
        mostCommon = categories(idx);
        
        % 如果该类别还未被使用，则使用它
        if ~usedCategories(mostCommon)
            matching(k) = mostCommon;
            usedCategories(mostCommon) = true;
        else
            % 如果已被使用，选择下一个未使用的类别
            unused = find(~usedCategories, 1);
            matching(k) = unused;
            usedCategories(unused) = true;
        end
    else
        % 如果聚类为空，使用下一个未使用的类别
        unused = find(~usedCategories, 1);
        matching(k) = unused;
        usedCategories(unused) = true;
    end
end

% 重新映射聚类标签
fcmLabels_mapped = zeros(size(fcmLabels));
for i = 1:numClusters
    fcmLabels_mapped(fcmLabels == i) = matching(i);
end

% 识别错误分类点
wrongClassIndices = find(fcmLabels_mapped ~= trueLabels_num');

%% 5. 创建3D图形
figure('Position', [100, 100, 900, 700], 'Color', 'white');

% 定义颜色和标记
colors = [0.2, 0.6, 0.9;      % Cluster 1 - 蓝色
          0.9, 0.4, 0.2;      % Cluster 2 - 橙色
          0.3, 0.7, 0.3];     % Cluster 3 - 绿色

markers = {'o', 's', '^'};    % 不同形状的标记
markerSize = 70;
wrongMarkerSize = 100;

% 绘制每个簇的数据点
for i = 1:numClusters
    clusterIndices = (fcmLabels_mapped == i);
    
    % 绘制正确分类的点
    correctIndices = clusterIndices & ~ismember(1:length(clusterIndices), wrongClassIndices);
    if any(correctIndices)
        scatter3(X_3D(correctIndices, 1), X_3D(correctIndices, 2), ...
                 X_3D(correctIndices, 3), markerSize, colors(i, :), ...
                 markers{i}, 'filled', 'DisplayName', sprintf('Cluster%d (Projected data)', i));
    end
    hold on;
end

% 绘制错误分类的点
if ~isempty(wrongClassIndices)
    scatter3(X_3D(wrongClassIndices, 1), X_3D(wrongClassIndices, 2), ...
             X_3D(wrongClassIndices, 3), wrongMarkerSize, [0, 0, 0], ...
             'x', 'LineWidth', 2, 'DisplayName', 'Wrong Classification');
end

% 绘制聚类原型
for i = 1:numClusters
    scatter3(centers_3D(1, i), centers_3D(2, i), centers_3D(3, i), ...
             200, colors(i, :), 'd', 'LineWidth', 2, ...
             'MarkerEdgeColor', 'r', 'DisplayName', sprintf('Projected Prototype %d', i));
end

%% 6. 图形美化
xlabel('1', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('2', 'FontSize', 12, 'FontWeight', 'bold');
zlabel('3', 'FontSize', 12, 'FontWeight', 'bold');

view(160, 20);



legend('Location', 'best', 'FontSize', 10);

%% 7. 计算并显示聚类性能
accuracy = 1 - length(wrongClassIndices)/length(trueLabels_num);
fprintf('FCM聚类结果:\n');
fprintf('正确分类数: %d\n', length(trueLabels_num) - length(wrongClassIndices));
fprintf('错误分类数: %d\n', length(wrongClassIndices));
fprintf('准确率: %.2f%%\n', accuracy * 100);