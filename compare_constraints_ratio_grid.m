clear
close all
% パラメーター
Y = 30; 
r = 1.025 ^ Y - 1;
gamma = 2; 
w1 = 100;
w2 = 110;

% グリッド
% ratio = r / rho とする。
ratio_grid = linspace(0.2, 5.0, 1000); 
a_nonlim_grid = zeros(size(ratio_grid));  
a_lim_grid = zeros(size(ratio_grid)); 

for i = 1:length(ratio_grid)
    ratio = ratio_grid(i);
    rho = r / ratio;
    X = (1+r)/(1+rho);
    
    % オイラー方程式の残差関数
    R = @(a) (X ./ ((w2 + (1+r) * a) .^ gamma)) ./ (1 ./ ((w1 - a) .^ gamma)) - 1;
    
    % 境界の設定
    borrowing_limit = -w2 / (1+r) + 1e-5; 
    upper_limit = w1 - 1e-5;
    
    % 流動性制約なし（借入可)
    if borrowing_limit < upper_limit && R(borrowing_limit) * R(upper_limit) < 0 
        a_nonlim_grid(i) = fzero(R, [borrowing_limit, upper_limit]); 
    else
        a_nonlim_grid(i) = NaN; 
    end
    
    % 流動性制約あり（借入不可)（a >= 0）
    if R(0) < 0 
        a_lim_grid(i) = 0;
    else 
        if 0 < upper_limit && R(0) * R(upper_limit) < 0 
            a_lim_grid(i) = fzero(R, [0, upper_limit]);
        else
            a_lim_grid(i) = NaN; 
        end
    end
end

% グラフの描画
figure;
plot(ratio_grid, a_nonlim_grid, '--', 'LineWidth', 2, 'Color', 'r'); hold on;
plot(ratio_grid, a_lim_grid, '-', 'LineWidth', 2, 'Color', 'b'); 
xlabel('ratio = r / rho');
ylabel('最適な貯蓄 (a)');
title('利子率と時間選好率の比の変動に対する最適貯蓄の変化 ');
legend('制約なし (借入可)', '制約あり (借入不可)', 'Location', 'NorthWest');
grid on;