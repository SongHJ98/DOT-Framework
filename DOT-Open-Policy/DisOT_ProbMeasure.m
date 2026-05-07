
function [gbest_val, history, pb_M_sum] = DisOT_ProbMeasure(func_num, Particle_Number, num_Dims, max_iterations, MaxFES, fhd, VRmin, VRmax, SH_max_runs, lam, Threshold, skip,varargin)

fbias=[100, 200, 300, 400, 500,...
   600, 700, 800, 900, 1000,...
   1100,1200,1300,1400,1500,...
   1600,1700,1800,1900,2000,...
   2100,2200,2300,2400,2500,...
   2600,2700,2800,2900,3000 ];

ps = Particle_Number;
Dim = num_Dims;
FES = 0;
Xmin = VRmin;
Xmax = VRmax;
if length(VRmin) == 1
    VRmin = repmat(VRmin, 1, Dim);
    VRmax = repmat(VRmax, 1, Dim);
end   
lu = [VRmin; VRmax];
pos = repmat(lu(1, :), ps, 1) + rand(ps, Dim) .* (repmat(lu(2, :) - lu(1, :), ps, 1));

pbest = pos;
fit = (feval(fhd, pos',varargin{:})-fbias(func_num))';
pbest_val = fit;
FES = FES + ps;

[gbest_val, gb_idx] = min(fit);     % 找到全局最优值
gbest = pbest(gb_idx, :);           % 对应的全局最优位置
Pmean = mean(pos);

history = zeros(max_iterations, 1);
sub = 1;
gap = ps / sub; 

for iter = 1:max_iterations % 主迭代过程
    if FES >= MaxFES
        break;
    end
    pre_pbest = pbest;
    Threshold = Threshold*0.997;

    pb_M = pdist2(pbest, pbest, 'euclidean');
    pb_M_sum(iter) = mean(mean(pb_M));
    if iter < 20  % 函数空间采样
        pos = repmat(lu(1, :), ps, 1) + rand(ps, Dim) .* (repmat(lu(2, :) - lu(1, :), ps, 1));
        fit = (feval(fhd, pos',varargin{:})-fbias(func_num))';
        improved = (pbest_val > fit); 
        temp = repmat(improved, 1, Dim);  
        pbest = temp.* pos + (1-temp).* pbest;
        pbest_val = improved.*fit + (1-improved).* pbest_val; 
        [gbest_val, gb_idx] = min(pbest_val); 
        gbest = pbest(gb_idx, :);  
        continue
    else  % 更新迭代
          lu(1,:) = min(pbest);
          lu(2,:) = max(pbest);
          indices = randperm(ps*Dim, skip);     % 240 1400 4800    
          M = (rand(ps, Dim)-0.5).*(lu(2, :) - lu(1, :));
          M(indices) = 0; 
          Tar_Gro = gbest + M; 
          temp_p = pbest + (rand(ps, Dim)-0.5).*Threshold*0.5;
          Tar_Gro(indices) = temp_p(indices);

    end

    %% 更新迭代
    for i = 1:sub
        temp_pbest = pre_pbest(((i-1)*gap+1):i*gap, 1:end);   
        temp_pbest_val =  pbest_val(((i-1)*gap+1):i*gap, end);   
      
        Sou_mixingCoefficients = 1 - rescale(temp_pbest_val, 0 ,1);
        Sou_mixingCoefficients = Sou_mixingCoefficients/(sum(Sou_mixingCoefficients));
     
        Tar_mixingCoefficients = rand(ps, 1);
        Tar_mixingCoefficients = Tar_mixingCoefficients/(sum(Tar_mixingCoefficients));

        Cost = pdist2(temp_pbest, Tar_Gro, 'squaredeuclidean');
      
        [T, sinkhorn_distance] = Sinkhorn_OTcomputing(Cost, Sou_mixingCoefficients, Tar_mixingCoefficients, lam, SH_max_runs);
        T = T + 1e-10;
        diag_T = diag(T*ones(size(Tar_mixingCoefficients,1),1));
        temp_pos = diag_T\T*Tar_Gro;
        pos(((i-1)*gap+1):i*gap, :) = temp_pos;
    end
    pos = (pos>VRmax).*VRmax + (pos<=VRmax).*pos; 
    pos = (pos<VRmin).*VRmin + (pos>=VRmin).*pos;
    fit = (feval(fhd, pos',varargin{:})-fbias(func_num))';
    

    for i = 1:sub
            TEMP_val = [pbest_val(((i-1)*gap+1):i*gap, 1); fit(((i-1)*gap+1):i*gap, 1)];
            TEMP = [pbest(((i-1)*gap+1):i*gap, :); pos(((i-1)*gap+1):i*gap, :)];   
            [Re_TEMP, Re_TEMP_val] = Threshold_process(TEMP, Threshold, TEMP_val, gap, pbest(((i-1)*gap+1):i*gap, :), pbest_val(((i-1)*gap+1):i*gap, 1));
            [Re_TEMP_val, index] = sort(Re_TEMP_val);
            Re_TEMP = Re_TEMP(index, :);
            pbest(((i-1)*gap+1):i*gap, :) = Re_TEMP(1:gap,:);
            pbest_val(((i-1)*gap+1):i*gap, 1) = Re_TEMP_val(1:gap,:);
    end
    [gbest_val, gb_idx] = min(pbest_val); 
    gbest = pbest(gb_idx, :);
    history(iter) = gbest_val;
    FES = FES + ps;

    dim = mod(iter, max_iterations);
      if  iter == 1 || dim == 0
        % 计算Wasserstein距离
        % mean_Pre = mean(pre_pbest);
        % cov_Pre  = cov(pre_pbest);
        % mean_Pos = mean(pos);
        % cov_Pos  = cov(pos);
        fprintf('迭代 %d: 全局最优值 = %.3f, SH距离 = %.3f, pb_dis = %.3f ,move = %.3f\n', iter, gbest_val, sinkhorn_distance, norm(pre_pbest - pbest), norm(pre_pbest - pos));
        pb_means = mean(pb_M)
      end 
end
end

function [RePos, ReFitValues] = Threshold_process(Pos, a, fit_values, gap, pbest, pbest_val)
    % a: 阈值 
    N = size(Pos, 1); 
    M = pdist2(Pos, Pos, 'euclidean');
    m = gap;
    retained_indices = 1;
    count = 1;
    while length(retained_indices) < m
        retained_indices = 1:N;
        for i = 1:N
            for j = i+1:N
                if M(i,j) < a
                    if fit_values(i) > fit_values(j)
                        retained_indices(retained_indices == i) = [];
                    else
                        retained_indices(retained_indices == j) = [];
                    end
                end
            end
        end

        if  4 < count
            RePos = pbest;
            ReFitValues = pbest_val;     
            return
        end
        if length(retained_indices) < m
            a = a * 0.8; 
        end
        count = count + 1;
    end   
    % 根据保留的索引生成处理后的元素矩阵
    RePos = Pos(retained_indices, :);
    ReFitValues = fit_values(retained_indices);
end
