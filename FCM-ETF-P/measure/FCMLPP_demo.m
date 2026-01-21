   clear;
   clc;

   data = textread('iris\data.txt');
   gnd = textread('iris\gnd.txt');
   X = data;        

   cluster_n = length(unique(gnd));          %类数    
   maxStep = 50;            %最大迭代次数
   conCriterion = 0.01;     %迭代终止条件
   NeighborK = 10;           %LLE中邻域数目   

%------- construciton method 3    PR 文章所用
   options = [];
   options.k = 10;
   options.NeighborMode = 'KNN';
   W = Wconstruct_NPE(options, X);     
   W = BuildAdjacency(W);    

% ------------------ LPFCM clustering (LPFCM)--------------------  
    optionsFCM = [2, 50, 1e-5, 0];
    [VFCM, UFCM, obj_fcn] = fcm(X, cluster_n, optionsFCM);   %此处求得的U为cluster_n*n  
     
    GammaRegion = [10^-5,10^-4,10^-3,10^-2,10^-1,10^0,10^1,10^2];
    MuRegion = [10^-3,10^-2,10^-1,10^0,10^1,10^2,10^3];

    Circ = 1;
    FAccJLFP = 0;
    for ProK = 2:1:size(X,2)
        for gi=1:1:length(GammaRegion)
            Pgamma = GammaRegion( gi );
            for mi=1:1:length(MuRegion);
                Pmu = MuRegion( mi );
                
                [P V U steps obj] = FCMLPP(X,W,UFCM,ProK,cluster_n, Pgamma,Pmu,maxStep,conCriterion);

                FUJLFP = U';
                [TempMax, grpsJLFP]=max(FUJLFP);
                ACCindexTemp= ACC2(gnd, grpsJLFP, cluster_n);
                NMIindexTemp = NMI(gnd, grpsJLFP);
               % RIindexTemp = RI(gnd, grpsJLFP, length(gnd));                
                ComResultJLFP(Circ,:) = [ProK, Pgamma, Pmu, ACCindexTemp, NMIindexTemp];
                
                if FAccJLFP < ACCindexTemp
                   ACCindexJLFP = ACCindexTemp;
                   NMIindexJLFP = NMIindexTemp;
                 %  RIindexJLFP = RIindexTemp;
                   FAccJLFP = ACCindexTemp;
                   ProKJLFP = ProK;
                   PgammaJLFP = Pgamma;
                   PmuJLFP = Pmu;
                end
                Circ = Circ + 1;
                fprintf('ID: %f, ProK = %f, PGamma = %f, PMu = %f, ACC = %f, NMI = %f, Steps = %f\n', Circ, ProK, Pgamma, Pmu,ACCindexTemp,NMIindexTemp, steps );                
            end
        end
    end
    fprintf('FCMLPP Clustering: ProK = %f, PGamma = %f, PMu = %f, ACC = %f, NMI = %f, Steps = %f\n',ProKJLFP, PgammaJLFP, PmuJLFP, ACCindexJLFP,NMIindexJLFP, steps ); 
 % %------------------end LPFCM clustering-------------------- 
