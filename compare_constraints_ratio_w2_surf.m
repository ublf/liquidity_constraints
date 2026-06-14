clear
close all

% パラメーター
Y = 30; 
r = 1.025 ^ Y - 1;
gamma = 2; 
w1 = 100;

% グリッド（ratio と w2 の2次元グリッドを作成）
ratio_grid = linspace(0.2, 5.0, 100); 
w2_grid = linspace(70, 130, 100);
[Ratio, W2] = meshgrid(ratio_grid, w2_grid);

A_nonlim = zeros(size(Ratio));  
A_lim = zeros(size(Ratio)); 

% 各グリッドポイントでの計算
for i = 1:size(Ratio, 1)
    for j = 1:size(Ratio, 2)
        ratio = Ratio(i, j);
        w2 = W2(i, j);
        rho = r / ratio;
        X = (1+r)/(1+rho);

        % オイラー方程式の残差関数
        R = @(a) (X ./ ((w2 + (1+r) * a) .^ gamma)) ./ (1 ./ ((w1 - a) .^ gamma)) - 1;

        % 境界の設定
        borrowing_limit = -w2 / (1+r) + 1e-5; 
        upper_limit = w1 - 1e-5;

        % 流動性制約なし（借入可)
        if borrowing_limit < upper_limit && R(borrowing_limit) * R(upper_limit) < 0 
            A_nonlim(i,j) = fzero(R, [borrowing_limit, upper_limit]); 
        else
            A_nonlim(i,j) = NaN; 
        end

        % 流動性制約あり（借入不可)（a >= 0）
        if R(0) < 0 
            A_lim(i,j) = 0;
        else 
            if 0 < upper_limit && R(0) * R(upper_limit) < 0 
                A_lim(i,j) = fzero(R, [0, upper_limit]);
            else
                A_lim(i,j) = NaN; 
            end
        end
    end
end

% グラフの描画
figure;
% 制約なしを赤色の曲面で描画
surf(Ratio, W2, A_nonlim, 'FaceColor', 'r', 'FaceAlpha', 0.5, 'EdgeColor', 'none'); 
hold on;
% 制約ありを青色の曲面で描画
surf(Ratio, W2, A_lim, 'FaceColor', 'b', 'FaceAlpha', 0.5, 'EdgeColor', 'none'); 

xlabel('ratio = r / rho');
ylabel('w_2 (2期の所得)');
zlabel('最適な貯蓄 (a)');
title('ratio と w_2 の変動に対する最適貯蓄の変化');
legend('制約なし (借入可)', '制約あり (借入不可)', 'Location', 'NorthWest');
grid on;
view(135, 30); % 見やすい角度に視点を調整