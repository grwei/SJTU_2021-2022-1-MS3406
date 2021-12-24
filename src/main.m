%% main.m
% author: 危国锐(313017602@qq.com)
% created: 2021-12-23
% last modified:

%% 环境配置

clc; clear; close all;
addpath(genpath('../data'));

%% 读取数据

num_X = 111;
num_Y = 132;

numFiles = 200;
startRow = 2;
endRow = inf;
myData = zeros(num_X * num_Y,4,numFiles);

for fileNum = 1:numFiles
    fileName = sprintf('%05d.dat',fileNum);
    myData(:,:,fileNum) = importfile(fileName,[startRow,endRow]);
end

x = myData(1:num_X,1,1);
y = zeros(num_Y + 1,1); % 补充边界：y = 0
y(1:num_Y) = myData(1:num_X:end,2);

%% 

u = zeros(num_Y+1,num_X); % 补充 B.C.: U,V = 0 at y = 0
v = u;
delta_idx = zeros(num_X,1); % 边界层顶的索引
delta = delta_idx; % 边界层厚度
delta_dsp = delta; % 位移厚度
delta_mom = delta; % 动量厚度

% 取时间平均
data_avg = mean(myData,3); % "X(mm)", "Y(mm)", "U(m/s)", "V(m/s)"

% 逐 x = x0 读 U-y profile
for x0_idx = 1:num_X
    u(1:num_Y,x0_idx) = data_avg(x0_idx:num_X:end,3);
    v(1:num_Y,x0_idx) = data_avg(x0_idx:num_X:end,4);
end

% 边界层外流速
U = max(u,[],1);
V = max(v,[],1);

% 边界层厚度
for x0_idx = 1:num_X
    delta_idx_c = find(u(:,x0_idx) > 0.99 * U(x0_idx),6,"last"); % 边界层厚度定义：从壁面起，第 N 个 U 超过阈值的 y；且将该点归入边界层外
    delta_idx(x0_idx) = delta_idx_c(1);
    delta(x0_idx) = y(delta_idx(x0_idx));
    y_BL = y(delta_idx(x0_idx):end); % 边界层内的 y
    u_BL = u(delta_idx(x0_idx):end,x0_idx); % 边界层内的 u
    delta_dsp(x0_idx) = -trapz(y_BL,U(x0_idx) - u_BL) / U(x0_idx);
    delta_mom(x0_idx) = -trapz(y_BL,u_BL .* (U(x0_idx) - u_BL)) / U(x0_idx)^2;
end

% 用过原点的多项式拟合速度剖面
% cftool;
% 集合所有边界层内数据点
u_U_BL = zeros(num_X * (num_Y+1) - sum(delta_idx),1);
y_delta_BL = u_U_BL;
cnt = 0;
for i = 1:num_X
    u_U_BL(cnt+1:cnt+num_Y+1-delta_idx(i)) = u(delta_idx(i)+1:end,i) / U(i);
    y_delta_BL(cnt+1:cnt+num_Y+1-delta_idx(i)) = y(delta_idx(i)+1:end) / delta(i);
    cnt = cnt + num_Y + 1 - delta_idx(i);
end
[fitresult, gof] = Rational_N2D2(y_delta_BL, u_U_BL);
exportgraphics(gca,'../doc/fig/u+_y+_fit.emf','BackgroundColor','none','ContentType','auto','Resolution',800);

% 动量积分方程
q_mom = integral(@(x) (fitresult(x) .* (1 - fitresult(x))).',0,1); % 动量厚度 = q_mom * 边界层厚度
q_dsp = integral(@(x) ((1 - fitresult(x))).',0,1); % 位移厚度 = q_dsq * 边界层厚度
q_tau = differentiate(fitresult, 0); % 壁面切应力 = fx * 动力粘度 * 边界层外势流速度 / 边界层厚度

% 结果
coeff_delta = sqrt(2 * q_tau / q_mom); % 边界层厚度 / x = coeff_delta * (Re_x)^(-1/2)
coeff_mom = sqrt(2 * q_mom * q_tau); % 动量厚度 / x = coeff_mom * (Re_x)^(-1/2)
coeff_dsp = q_dsp * sqrt(2 * q_tau / q_mom); % 位移厚度 / x = coeff_dsp * (Re_x)^(-1/2)
coeff_tau = coeff_mom; % 壁面切应力 / (\rho U^2 / 2) = coeff_tau * (Re_x)^(-1/2)

%% figure

%% 速度剖面

%
figure('Name','u-y profile')
plot(u,y)
ax = gca; % current axes
ax.FontSize = 12;
ax.FontName = 'Times New Roman';
xlabel("\fontname{Times New Roman} \fontsize{12} \it u \rm (m/s)")
ylabel("\fontname{Times New Roman} \fontsize{12} \it y \rm (mm)")
title(sprintf("\\fontname{Times New Roman} \\fontsize{12} \\it u-y \\rm \\bf profile of all \\rm \\it x"))
exportgraphics(ax,'../doc/fig/u-y.emf','BackgroundColor','none','ContentType','auto','Resolution',800);

%% 边界层厚度

figure('Name','delta')
plot(x,[delta,delta_dsp,delta_mom]);
ax = gca; % current axes
ax.FontSize = 12;
ax.FontName = 'Times New Roman';
xlabel("\fontname{Times New Roman} \fontsize{12} \it x \rm (mm)")
ylabel("\fontname{Times New Roman} \fontsize{12} \it \delta \rm (mm)")
title(sprintf("\\fontname{Times New Roman} \\fontsize{12} \\bf boundary layer thickness"))
legend('boundary layer thickness','displacement thickness','momentum thickness')
legend('boxoff')
legend('Location','best')
exportgraphics(ax,'../doc/fig/delta.emf','BackgroundColor','none','ContentType','auto','Resolution',800);
