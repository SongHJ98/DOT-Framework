clc;
clear;
close all;

dimensions = [2, 10, 30, 50, 100];
Particle_number = [30 30 50 100 200];
Max_iteration = [2500, 3500, 6000, 8000, 10000];
ThreShold = [100 250 450 550 650]; 
Skip = [0 240 1400 4800 19800]; 
SH_max_runs = 50; lam = 0.0015;  
Xmin=-100;
Xmax=100;
str = "DOT";

folderPath = 'Test_Figures'; 
if ~exist(folderPath, 'dir')
    mkdir(folderPath); 
end
fhd=str2func('cec17_func');
funset=1:30;
runtimes = 30;
tes = 3;
dim = dimensions(tes);
MaxFES = dim * 10000;
if tes == 1
    funset=1:28;
    funset(funset >= 10 & funset <= 20) = [];
end
particle_number = Particle_number(tes);
max_iteration = Max_iteration(tes);
Threshold = ThreShold(tes); % 100 250 450 550 650
skip = Skip(tes);
%%  
for fun=1:length(funset)
    func_num=funset(fun);
    suc_times = 0; 
    % if func_num > 21
    %      continue
    % end
%     if func_num <= 20
%          continue
%     end
    fesusage=0;
    count=0;
    %% 对不同维度的CEC2017函数进行优化
    for runs=1:runtimes
        fprintf('第%d轮运行，正在优化 %d 维的 CEC Function %d ... ...\n', runs, dim, func_num);
       
        [gbest_val, history, pb_M_sum] = DisOT_ProbMeasure(func_num, particle_number, dim, max_iteration, MaxFES, fhd, Xmin, Xmax, SH_max_runs, lam, Threshold,skip,func_num);

    
        filename = sprintf('fig_without_OT%dD.emf', dim); 
        fullFilePath = fullfile(folderPath, filename);

        fbest(runs ,func_num)=gbest_val;
    end

    % 下面为计算和输出在设定求解精度条件下的成功率、所需评价次数以及运行时间
    SR(1,func_num) = suc_times/runtimes;
    if suc_times>0
        FEs(1,func_num) = fesusage/suc_times;  % 满足精度的多次运行所消耗的平均 fes。未考虑不满足精度的运行
        SP (1,func_num) = fes_max*(1-SR(1,func_num))/SR(1,func_num) + FEs(1,func_num); % 综合评价了算法的性能：既考虑成功的，也考虑未成功的
    %   tu(1,func_num) = timeusage/suc_times;
    else
        FEs(1,func_num) = -1;  % 满足精度的多次运行所消耗的平均 fes。未考虑不满足精度的运行
        SP (1,func_num) = -1; % 综合评价了算法的性能：既考虑成功的，也考虑未成功的
    %   u(1,func_num) = -1;
    end
    dis_mean =  mean(pb_M_sum(:,1));
    dis_std =  std(pb_M_sum(:,1));
    f_mean = mean(fbest(:,func_num));
    f_std  = std(fbest(:,func_num));
    f_SR   = SR(1,func_num);
    
    fprintf('\nFunction F%d :\nAvg. fitness = %1.2e(%1.2e), Avg. dis = %1.2e(%1.2e)\n\n',func_num, f_mean, f_std, dis_mean, dis_std);    
    fprintf(' -------------------------------------------------- \n');

    %% 保存数据到 Excel
    filename = sprintf('DOT_CEC2017_res_%dD05_Func1_17_%dRun.xlsx', dim, runtimes); 
    data_to_save = [func_num, f_mean, f_std, dis_mean, dis_std, f_SR];
    header = {'Func Num', 'Mean', 'Std Dev', 'Dis_mean', 'Std Dis', 'Time'};
    if func_num == 1
        % 在第一次写入时，写入标题和数据
        xlswrite(filename, header, 'Sheet1', 'A1');
        xlswrite(filename, data_to_save, 'Sheet1', 'A2');
    else
        % 追加其他功能的数据
        xlswrite(filename, data_to_save, 'Sheet1', ['A' num2str(func_num + 1)]);
    end

    folderPath = sprintf('%s_%d_Data', str, dim); % 您要保存图形的文件夹名称
    if ~exist(folderPath, 'dir')
        mkdir(folderPath); % 如果文件夹不存在，则创建文件夹
    end
    for i=1:runtimes
        mat_filename = sprintf('%s\\%s_CEC2017_F%d_D%d_%d.mat', folderPath, str, fun, dim, i);
        res = fbest(i, fun);
        save(mat_filename,'res')
    end
end  




