function [P ,V, U ,steps ] = FCMLPP(X,W,InitU, ProK,cluster_n, Pgamma,Pmu,maxStep,conCriterion)
%% FCM based on LPP
% X:数据集， n*m，行向量形式
% W:由LLE导出的相似度矩阵
% ProK：选择的特征数目
%Pgamma，Pmu：参数
% maxStep：最大迭代步数
% conCriterion ：收敛条件
%P: m*ProK;
%V cluster_n*m  行向量
%U n*cluster_n  行向量

%%--------------------begin------------------------------------------------
data_n = size(X,1);
dim_n = size(X,2);
options = [2, 50, 1e-5, 0];

U = InitU';

P = eye(dim_n,ProK);

V = rand(cluster_n, dim_n);
steps=0;
converged=false;

while ~converged && steps<=maxStep
     
    steps=steps+1;       
    
    V_Old = V;
   
    %%%%（求V ）
    if length( find( sum(U) == 0 ) ) > 0
       V = X'*U./(( ones(size(X, 2), 1)*(sum(U)+eps) ));
    else
       V = X'*U./(( ones(size(X, 2), 1)*sum(U) ));  
    end    
    V = V';   %转为行向量  cluster_n*dim_n      
  
    %%%%（求P ）
    D = diag( sum(U) );
    
    Ls0 = diag(sum(W'+W)/2);
    Ls = Ls0 - (W'+W)/2;

    AA = X'*X - (X'*U*V + V'*U'*X) + V'*D*V + Pmu*X'*Ls*X;
    [eigvector eigvalue] = eig(AA);

    eigvalue = diag(eigvalue);            %%从小到大排列
    [junk, index] = sort(eigvalue);       %升序
    eigvalue = eigvalue(index);
    eigvector = eigvector(:, index);
    
    if ProK < length(eigvalue)           
       eigvalue = eigvalue(1:ProK);
       eigvector = eigvector(:, 1:ProK);
    end
    P = eigvector;
    
    nsmp=size(P,2);   %dim_n*ProK  
    for i=1:nsmp
       P(:,i)=P(:,i)/norm(P(:,i),2);
    end   

    %%%%（求Uik）        
     distX = EuDist2((X*P),(V*P),0);      %这里指距离的平方
      
    for i=1:1:data_n
        vi = -1*distX(i,:)/(2*P gamma);
        U(i,:) = EProjSimplex(vi);
    end         

    %%%% 计算obj
    obj(steps,1) = trace(P'*X'*X*P)-2*trace(P'*X'*U*V*P) + trace(P'*V'*D*V*P) + Pgamma*norm(U,2) + Pmu*trace(P'*X'*Ls*X*P);
    obj(steps,2) =  trace(P'*X'*X*P)-2*trace(P'*X'*U*V*P) + trace(P'*V'*D*V*P);
    obj(steps,3) = Pgamma*norm(U,2);
    obj(steps,4) = Pmu*trace(P'*X'*Ls*X*P);
    
    %if convergent?
    nsmp=size(V,1);   
    for i=1:nsmp
       ErrorV(i) = norm( V(i,:)-V_Old(i,:), 2);
    end 
    criterion = max( ErrorV );
    if criterion < conCriterion
        converged=true;
    end       
end 
%%--------------------end--------------------------------------------------