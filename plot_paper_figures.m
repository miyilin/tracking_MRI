%% plot_paper_figures.m
% Display paper Figures 2–4 from bundled numerical results (plot-only, no solvers).
%
% Usage:
%   cd tracking_MRI
%   plot_paper_figures
%
% Requires: MATLAB only (Statistics Toolbox for boxplot in Fig. 3).
% Data: results/public/sec51_results.mat, sec52_results.mat (or mc_table_sec52.csv),
%       sec53_results.mat

clear; clc; close all;

script_dir = fileparts(mfilename('fullpath'));
data_dir = fullfile(script_dir, 'results', 'public');
if ~exist(data_dir, 'dir')
    error('Missing folder: %s', data_dir);
end

BOUND_E_FIG2 = 0.1;
GAP_YLIM_FIG3 = 100;
FONT_FIG3 = 9;
BOX_LW_FIG3 = 0.8;
FONT_FIG4 = 11;

fprintf('Loading results from %s\n', data_dir);

%% ----- Figure 2 (Section 5.1) -----
S1 = load(fullfile(data_dir, 'sec51_results.mat'));
if isfield(S1, 'results')
    R1 = S1.results;
else
    R1 = S1;
end
need_fig2 = {'V_star', 'tau_traj', 'e_traj'};
for k = 1:numel(need_fig2)
    if ~isfield(R1, need_fig2{k})
        error('sec51_results.mat missing field: %s', need_fig2{k});
    end
end

fig2 = plot_figure2(R1.V_star, R1.tau_traj, R1.e_traj, BOUND_E_FIG2);
save_figure(fig2, fullfile(data_dir, 'fig2_sec51'));

%% ----- Figure 3 (Section 5.2) -----
fig3_data = load_fig3_data(data_dir);
summary3 = fig3_summary(fig3_data);
fig3 = plot_figure3(fig3_data, summary3, FONT_FIG3, GAP_YLIM_FIG3, BOX_LW_FIG3);
save_figure(fig3, fullfile(data_dir, 'fig3_sec52'));

%% ----- Figure 4 (Section 5.3) -----
S4 = load(fullfile(data_dir, 'sec53_results.mat'));
if isfield(S4, 'data')
    R4 = S4.data;
else
    R4 = S4;
end
fig4 = plot_figure4(R4, FONT_FIG4);
save_figure(fig4, fullfile(data_dir, 'fig4_sec53'));

fprintf('\nDone. Figures saved under results/public/\n');
fprintf('  fig2_sec51.pdf / .png\n');
fprintf('  fig3_sec52.pdf / .png\n');
fprintf('  fig4_sec53.pdf / .png\n');

%% ===================== local functions =====================

function save_figure(fig, basepath)
exportgraphics(fig, [basepath '.pdf'], 'ContentType', 'vector', 'BackgroundColor', 'white');
exportgraphics(fig, [basepath '.png'], 'Resolution', 300, 'BackgroundColor', 'white');
fprintf('Saved %s.[pdf/png]\n', basepath);
end

function fig = plot_figure2(V_star, tau_traj, e_traj, bound_e)
num_points = 1000;
theta = linspace(0, 2*pi, num_points);
theta = theta(1:end-1);
ellipse_points = zeros(2, numel(theta));
for i = 1:numel(theta)
    u = [cos(theta(i)); sin(theta(i))];
    r = 1 / sqrt(u' * (V_star^(-2)) * u);
    ellipse_points(:, i) = r * u;
end

fontsize = 14;
lw_ellipse = 1.5;
lw_traj = 1.0;
lw_error = 1.5;
edge_color = [0.25 0.35 0.25];

fig = figure('Color', 'w', 'Units', 'inches', 'Position', [1 1 7 3]);

subplot(1, 2, 1);
hold on;
if exist('Polyhedron', 'class')
    Gamma_star = Polyhedron(ellipse_points');
    h_gamma = Gamma_star.plot('Color', [0.84 0.91 0.85], 'alpha', 0.8);
    set(h_gamma, 'EdgeColor', edge_color, 'LineWidth', lw_ellipse);
else
    h_gamma = patch(ellipse_points(1,:), ellipse_points(2,:), [0.84 0.91 0.85], ...
        'FaceAlpha', 0.8, 'EdgeColor', edge_color, 'LineWidth', lw_ellipse);
end
h_tau = plot(tau_traj(1,:), tau_traj(2,:), 'Color', [0 0.5 0], 'LineWidth', lw_traj);
xlim([-1.5, 1.5]); ylim([-1.5, 1.5]);
xlabel('$\tau_k(1)$', 'Interpreter', 'latex', 'FontSize', fontsize);
ylabel('$\tau_k(2)$', 'Interpreter', 'latex', 'FontSize', fontsize);
legend([h_gamma(1), h_tau], {'$\bar{\Gamma}(V^\star)$', '$\tau_k$'}, ...
    'FontSize', fontsize - 1, 'NumColumns', 2, 'Interpreter', 'latex', 'Location', 'best');
grid on; set(gca, 'Box', 'on', 'FontSize', fontsize);

subplot(1, 2, 2);
k_axis = 0:(numel(e_traj) - 1);
hold on;
h_e = plot(k_axis, e_traj, 'Color', [0.2 0.45 0.75], 'LineWidth', lw_error);
h_theta = plot(k_axis, repmat(bound_e, size(k_axis)), 'r--', 'LineWidth', lw_error);
plot(k_axis, repmat(-bound_e, size(k_axis)), 'r--', 'LineWidth', lw_error, ...
    'HandleVisibility', 'off');
xlabel('$k$', 'Interpreter', 'latex', 'FontSize', fontsize);
ylabel('$e_k$', 'Interpreter', 'latex', 'FontSize', fontsize);
xlim([0, k_axis(end)]);
ylim([-bound_e - 0.03, bound_e + 0.03]);
legend([h_e, h_theta], {'$e_k$', '$\Theta$'}, ...
    'FontSize', fontsize - 1, 'NumColumns', 2, 'Interpreter', 'latex', 'Location', 'best');
grid on; set(gca, 'Box', 'on', 'FontSize', fontsize);
end

function D = load_fig3_data(data_dir)
mat_file = fullfile(data_dir, 'sec52_results.mat');
csv_file = fullfile(data_dir, 'mc_table_sec52.csv');
if isfile(mat_file)
    S = load(mat_file);
    if isfield(S, 'data')
        D = S.data;
    else
        D = S;
    end
    return;
end
if ~isfile(csv_file)
    error('Need sec52_results.mat or mc_table_sec52.csv in results/public/.');
end
T = readtable(csv_file);
D = struct();
D.gap_pct = T.gap_pct(:);
D.t_relax = T.t_relax(:);
D.t_de = T.t_de(:);
D.n_systems = height(T);
D.source = 'mc_table_sec52.csv';
end

function summary = fig3_summary(D)
summary = struct();
summary.n_certified = numel(D.gap_pct);
summary.gap_pct_median = median(D.gap_pct);
summary.t_relax_median = median(D.t_relax);
summary.t_de_median = median(D.t_de);
end

function fig = plot_figure3(D, summary, font_size, gap_ylim, box_lw)
gap = D.gap_pct(:);
has_t = ~isnan(D.t_relax) & ~isnan(D.t_de);

col_prop_fc = [0.55 0.78 0.95]; col_prop_ec = [0.12 0.35 0.62];
col_de_fc = [0.98 0.72 0.62]; col_de_ec = [0.72 0.22 0.15];

fig_w = 3.5; fig_h = 4.0;
fig = figure('Color', 'w', 'Units', 'inches', ...
    'Position', [1 1 fig_w fig_h], 'PaperUnits', 'inches', ...
    'PaperSize', [fig_w fig_h], 'PaperPosition', [0 0 fig_w fig_h]);
tl = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

ax1 = nexttile(tl, 1);
hold(ax1, 'on');
boxplot(ax1, gap, 'Orientation', 'vertical', 'Widths', 0.48, ...
    'Symbol', 'o', 'Labels', {''}, 'Whisker', 1.5);
style_boxplot(ax1, {col_prop_fc}, {col_prop_ec}, box_lw);
set(ax1, 'FontSize', font_size, 'LineWidth', 0.8, 'Box', 'on', 'XTick', 1, 'XTickLabel', {''});
xlim(ax1, [0.52 1.48]);
yline(ax1, 0, 'Color', [0.45 0.45 0.45], 'LineStyle', '--', 'LineWidth', 0.9);
ylabel(ax1, 'Relative gap (%)');
title(ax1, 'Optimality gap', 'FontWeight', 'normal');
grid(ax1, 'on');
if gap_ylim > 0, ylim(ax1, [0, gap_ylim]); end
text(ax1, 0.03, 0.97, {sprintf('n=%d', numel(gap)), ...
    sprintf('median=%.1f%%', summary.gap_pct_median), ...
    sprintf('IQR=[%.1f, %.1f]%%', prctile(gap,25), prctile(gap,75))}, ...
    'Units', 'normalized', 'VerticalAlignment', 'top', 'FontSize', font_size - 0.5);

ax2 = nexttile(tl, 2);
if any(has_t)
    t_prop = D.t_relax(has_t);
    t_de = D.t_de(has_t);
    tt = [t_prop(:), t_de(:)];   % N x 2 (columns = groups)
    hold(ax2, 'on');
    boxplot(ax2, tt, 'Labels', {'Proposed', 'DE global'}, ...
        'Widths', 0.52, 'Symbol', 'o', 'Whisker', 1.5);
    style_boxplot(ax2, {col_prop_fc, col_de_fc}, {col_prop_ec, col_de_ec}, box_lw);
    set(ax2, 'YScale', 'log', 'FontSize', font_size, 'LineWidth', 0.8, 'Box', 'on');
    ylabel(ax2, 'Runtime (s)');
    title(ax2, 'Runtime', 'FontWeight', 'normal');
    grid(ax2, 'on');
    text(ax2, 0.03, 0.97, {sprintf('n=%d', sum(has_t)), ...
        sprintf('Proposed: med=%.0f s', summary.t_relax_median), ...
        sprintf('DE: med=%.0f s', summary.t_de_median)}, ...
        'Units', 'normalized', 'VerticalAlignment', 'top', 'FontSize', font_size - 0.5);
end
end

function fig = plot_figure4(R4, font_size)
rho_record = R4.rho_record;
volume_record = R4.volume_record;
solve_time_record = R4.solve_time_record;
n_ex = size(rho_record, 2);
vol_ratio = volume_record(2, :) ./ max(volume_record(1, :), eps);

fig = figure('Color', 'w', 'Units', 'inches', 'Position', [1 1 7 5]);

subplot(2, 2, [1, 2]);
hold on;
plot(rho_record(1, :), 'Color', [0.2 0.45 0.75], 'LineWidth', 1.2);
plot(rho_record(2, :), 'Color', [0.85 0.45 0.15], 'LineWidth', 1.2);
yline(1, 'r--', 'LineWidth', 1.0);
xlim([1, n_ex]); ylim([0, 1.1]);
xlabel('Ex.\#', 'Interpreter', 'latex', 'FontSize', font_size);
ylabel('Spectral radius', 'FontSize', font_size);
legend([], {'$\rho(\bar{A}+\bar{B}K_{prop})$', '$\rho(\bar{A}+\bar{B}K_{lcRPI})$'}, ...
    'FontSize', font_size - 1, 'NumColumns', 2, 'Interpreter', 'latex', 'Location', 'best');
grid on; set(gca, 'Box', 'on', 'FontSize', font_size);

subplot(2, 2, 3);
plot(vol_ratio, 'Color', [0.2 0.45 0.75], 'LineWidth', 1.2);
xlim([1, n_ex]); set(gca, 'YScale', 'log');
yticks([1e-5, 1e-2, 1, 10, 100]);
xlabel('Ex.\#', 'Interpreter', 'latex', 'FontSize', font_size);
ylabel('vol($\bar{\Gamma}_{lcRPI}$)/vol($\bar{\Gamma}_{prop}$)', ...
    'Interpreter', 'latex', 'FontSize', font_size);
grid on; set(gca, 'Box', 'on', 'FontSize', font_size);

subplot(2, 2, 4);
hold on;
plot(solve_time_record(1, :), 'Color', [0.2 0.45 0.75], 'LineWidth', 1.2);
plot(solve_time_record(2, :), 'Color', [0.85 0.45 0.15], 'LineWidth', 1.2);
xlim([1, n_ex]); ylim([0, 10]); set(gca, 'YScale', 'log');
yticks(unique([yticks, 10]));
xlabel('Ex.\#', 'Interpreter', 'latex', 'FontSize', font_size);
ylabel('Time [s]', 'FontSize', font_size);
legend([], {'$t_{prop}$', '$t_{lcRPI}$'}, ...
    'FontSize', font_size - 1, 'NumColumns', 2, 'Interpreter', 'latex', 'Location', 'best');
grid on; set(gca, 'Box', 'on', 'FontSize', font_size);
end

function style_boxplot(ax, face_colors, edge_colors, lw)
if nargin < 4 || isempty(lw), lw = 1.0; end
boxes = findobj(ax, 'Tag', 'Box');
if isempty(boxes), return; end
xpos = arrayfun(@(o) mean(o.XData, 'omitnan'), boxes);
[~, ord] = sort(xpos);
boxes = boxes(ord);
for k = 1:numel(boxes)
    fc = face_colors{min(k, numel(face_colors))};
    ec = edge_colors{min(k, numel(edge_colors))};
    xd = boxes(k).XData; yd = boxes(k).YData;
    if ~isempty(xd) && ~isempty(yd)
        p = patch(ax, xd, yd, fc, 'FaceColor', fc, 'FaceAlpha', 0.45, ...
            'EdgeColor', ec, 'LineWidth', lw, 'HandleVisibility', 'off');
        uistack(p, 'bottom');
    end
    set(boxes(k), 'Visible', 'off');
end
for tag = {'Median', 'Upper Whisker', 'Lower Whisker', 'Upper Adjacent Value', 'Lower Adjacent Value'}
    h = findobj(ax, 'Tag', tag{1});
    if isempty(h), continue; end
    xpos = arrayfun(@(o) mean(o.XData, 'omitnan'), h);
    [~, ord] = sort(xpos);
    h = h(ord);
    for k = 1:numel(h)
        ec = edge_colors{min(k, numel(edge_colors))};
        set(h(k), 'Color', ec, 'LineWidth', lw);
    end
end
out = findobj(ax, 'Tag', 'Outliers');
for k = 1:numel(out)
    ec = edge_colors{min(k, numel(edge_colors))};
    set(out(k), 'Marker', 'o', 'MarkerSize', 4, 'MarkerEdgeColor', ec, ...
        'MarkerFaceColor', [1 1 1], 'LineWidth', 0.75);
end
end
