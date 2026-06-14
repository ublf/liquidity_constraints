clear 
close all

% パラメーター
Y = 30; 
Beta = 0.985 ^ Y; 
r = 1.025 ^ Y - 1; 
gamma = 2; 
w2 = 100;

% グリッド
w1_grid = linspace(0, 200, 1000); 
a_nonlim_grid = zeros(size(w1_grid));  
a_lim_grid = zeros(size(w1_grid)); 

for i = 1:length(w1_grid)
    w1 = w1_grid(i);
    
    % オイラー方程式の残差関数
    R = @(a) (Beta * (1+r) ./ ((w2 + (1+r) * a) .^ gamma)) ./ (1 ./ ((w1 - a) .^ gamma)) - 1;
    
    % 境界の設定
    borrowing_limit = -w2 / (1+r) + 1e-5; 
    upper_limit = w1 - 1e-5;
    
    % 流動性制約なし（借入可)
    % 上限＞下限、符号が反転しているかを確認（Rは単調減少関数より、これで範囲内にゼロ点があるかがわかる。）
    if borrowing_limit < upper_limit && R(borrowing_limit) * R(upper_limit) < 0 % &&はかつ
        a_nonlim_grid(i) = fzero(R, [borrowing_limit, upper_limit]); % ゼロ点を見つけて格納
    else
        a_nonlim_grid(i) = NaN; % 条件を満たさない場合（ゼロ点が範囲内に存在しない場合は格納しない。）
    end
    
    % 流動性制約あり（借入不可)（a >= 0）

    if R(0) < 0 % R(0) < 0なら、ゼロ点はa<0の範囲に存在（借り入れを必要としている状態。）
        a_lim_grid(i) = 0;
    % 0 < upper_limit、R(0) と R(upper_limit)が異符号の場合、0<a<upper_limitの範囲にゼロ点がある
    else 
        if 0 < upper_limit && R(0) * R(upper_limit) < 0 
            a_lim_grid(i) = fzero(R, [0, upper_limit]);
        else
            a_lim_grid(i) = NaN; % 条件を満たさない場合（ゼロ点が範囲内に存在しない場合）は格納しない。
        end
    end
end

% グラフの描画
figure;
plot(w1_grid, a_nonlim_grid, '--', 'LineWidth', 2, 'Color', 'r'); hold on;
plot(w1_grid, a_lim_grid, '-', 'LineWidth', 2, 'Color', 'b'); 
xline(100, '--k', 'LineWidth', 1.5, 'HandleVisibility', 'off');
xlabel('若年期の富 (w1)');
ylabel('最適な貯蓄 (a)');
title('制約なしの場合と流動性制約ありの場合');
legend('制約なし (借入可)', '制約あり (借入不可)', 'Location', 'NorthWest');
grid on;
