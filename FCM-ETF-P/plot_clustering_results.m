function plot_clustering_results(X, U, V, R, E)
    % 绘制聚类结果 (适用于 2D 或 3D 数据)
    [d, ~] = size(X');
    % if d > 3
    %     fprintf('数据维度 %d > 3，无法可视化\n', d);
    %     return; %我还以为没return这个功能
    % end
    
    % 硬聚类标签
    [~, labels] = max(U, [], 2);
    
    figure;
    
    if d == 2
        % 2D 散点图
        scatter(X(:,1), X(:,2), 50, labels, 'filled');
        hold on;
        
        % 绘制聚类原型
        scatter(V(1,:), V(2,:), 200, 'k', 'x', 'LineWidth', 3);
        
        % 绘制 ETF 框架点 (旋转后)
        etf_points = R * E;
        scatter(etf_points(1,:), etf_points(2,:), 200, 'r', 's', 'filled');
        
        legend('数据点', '聚类原型', 'ETF点', 'Location', 'best');
        title('FCM-ETF 聚类结果 (2D)');
        grid on;
        
    else 
        % 3D 散点图
        scatter3(X(:,1), X(:,2), X(:,3), 50, labels, 'filled');
        hold on;
        
        % 绘制聚类原型
        scatter3(V(1,:), V(2,:), V(3,:), 200, 'k', 'x', 'LineWidth', 3);
        
        % 绘制 ETF 框架点 (旋转后)
        etf_points = R * E;
        scatter3(etf_points(1,:), etf_points(2,:), etf_points(3,:), 200, 'r', 's', 'filled');
        
        legend('数据点', '聚类原型', 'ETF点', 'Location', 'best');
        title('FCM-ETF 聚类结果 (3D)');
        grid on;
    end
    
    xlabel('特征 1');
    ylabel('特征 2');
    if d == 3
        zlabel('特征 3');
    end
end