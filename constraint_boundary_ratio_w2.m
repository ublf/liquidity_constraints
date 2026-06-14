clear
close all

% パラメーター
Y = 30; 
r = 1.025 ^ Y - 1;
gamma = 2; 
w1 = 100;

% グリッド（ratio と w2 の2次元グリッドを作成）
ratio_grid = linspace(0.05, 20, 100); 
w2_grid = linspace(50, 150, 100);
[Ratio, W2] = meshgrid(ratio_grid, w2_grid);

R0_val = zeros(size(Ratio)); 

% 各グリッドポイントでの計算
for i = 1:size(Ratio, 1)
    for j = 1:size(Ratio, 2)
        ratio = Ratio(i, j);
        w2 = W2(i, j);
        rho = r / ratio;
        X = (1+r)/(1+rho);

        % 貯蓄 a=0 のときのオイラー方程式の残差関数 R(0) の値
        % R(0) < 0 が貯蓄0の領域なので、境界は R(0) = 0 の部分
        R0_val(i,j) = X * (w1 / w2)^gamma - 1;
    end
end

% グラフの描画
figure;
% R(0) = 0 の等高線を引くことで境界線を描画
contour(W2, Ratio, R0_val, [0 0], 'LineWidth', 2, 'Color', 'r');

xlabel('w_2 (2期の所得)');
ylabel('ratio = r / rho');
title('制約ありで貯蓄が0になる境界線');
grid on;