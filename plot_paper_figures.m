%% plot_paper_figures.m
% Plot-only reproduction of paper Figures 2–5 (Sections 5.1–5.4).
%
% Usage:
%   cd tracking_MRI
%   plot_paper_figures
%
% Data: results/public/
%   sec51_results.mat
%   sec52_results.mat  or  mc_table_sec52.csv
%   sec53_alpha_results.mat  or  alpha_sensitivity_sec53.csv
%   sec54_tahir_results.mat  or  sec53_results.mat (legacy)

clear; clc; close all;

script_dir = fileparts(mfilename('fullpath'));
data_dir = fullfile(script_dir, 'results', 'public');
if ~exist(data_dir, 'dir')
    error('Missing folder: %s', data_dir);
end

%% ----- 作图参数（与 export_rebuttal_figures / alpha_sensitivity 对齐）-----
BOUND_E_FIG2   = 0.1;
FONT_FIG3      = 13;
GAP_YLIM_FIG3  = 100;
BOX_LW_FIG3    = 0.8;
BOX_WIDTH_FIG3 = 0.28;
GAP_XLIM_FIG3  = [0.35, 1.65];
RUNTIME_XLIM_FIG3 = [0.35, 2.65];
FIG3_LAYOUT    = 'row';

FONT_FIG4_ALPHA = struct('ax', 13, 'label', 15, 'title', 12, 'legend', 11);
SLICE_CMAP     = 'paper';
SLICE_DESAT    = 0;

FONT_FIG5_TAHIR = 11;

fprintf('Loading results from %s\n', data_dir);

%% ----- Figure 2 — Section 5.1 -----
S1 = load(fullfile(data_dir, 'sec51_results.mat'));
if isfield(S1, 'results'), R1 = S1.results; else, R1 = S1; end
need_fig2 = {'V_star', 'tau_traj', 'e_traj'};
for k = 1:numel(need_fig2)
    if ~isfield(R1, need_fig2{k})
        error('sec51_results.mat missing field: %s', need_fig2{k});
    end
end
fig2 = plot_figure2(R1.V_star, R1.tau_traj, R1.e_traj, BOUND_E_FIG2);
save_figure(fig2, fullfile(data_dir, 'fig2_sec51'));

%% ----- Figure 3 — Section 5.2 (export_rebuttal 数据) -----
[D3, summary3] = load_fig3_data(data_dir);
fig3 = plot_figure3(D3, summary3, FONT_FIG3, GAP_YLIM_FIG3, BOX_LW_FIG3, ...
    BOX_WIDTH_FIG3, GAP_XLIM_FIG3, RUNTIME_XLIM_FIG3, FIG3_LAYOUT);
save_figure(fig3, fullfile(data_dir, 'fig3_sec52'));

%% ----- Figure 4 — Section 5.3 (alpha sensitivity) -----
R53 = load_fig4_alpha_data(data_dir);
fig4 = plot_figure4_alpha(R53, FONT_FIG4_ALPHA, SLICE_CMAP, SLICE_DESAT);
save_figure(fig4, fullfile(data_dir, 'fig4_sec53'));

%% ----- Figure 5 — Section 5.4 (Tahir comparison, 原 5.3) -----
R54 = load_fig5_tahir_data(data_dir);
fig5 = plot_figure5_tahir(R54, FONT_FIG5_TAHIR);
save_figure(fig5, fullfile(data_dir, 'fig5_sec54'));

fprintf('\nDone. Figures saved under results/public/\n');
fprintf('  fig2_sec51  (Sec 5.1)\n');
fprintf('  fig3_sec52  (Sec 5.2)\n');
fprintf('  fig4_sec53  (Sec 5.3 alpha sensitivity)\n');
fprintf('  fig5_sec54  (Sec 5.4 Tahir benchmark)\n');

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
plot(k_axis, repmat(-bound_e, size(k_axis)), 'r--', 'LineWidth', lw_error, 'HandleVisibility', 'off');
xlabel('$k$', 'Interpreter', 'latex', 'FontSize', fontsize);
ylabel('$e_k$', 'Interpreter', 'latex', 'FontSize', fontsize);
xlim([0, k_axis(end)]);
ylim([-bound_e - 0.03, bound_e + 0.03]);
legend([h_e, h_theta], {'$e_k$', '$\Theta$'}, ...
    'FontSize', fontsize - 1, 'NumColumns', 2, 'Interpreter', 'latex', 'Location', 'best');
grid on; set(gca, 'Box', 'on', 'FontSize', fontsize);
end

function [D, summary] = load_fig3_data(data_dir)
mat_file = fullfile(data_dir, 'sec52_results.mat');
csv_file = fullfile(data_dir, 'mc_table_sec52.csv');
summary = struct();
if isfile(mat_file)
    S = load(mat_file);
    if isfield(S, 'data52')
        D = S.data52;
    elseif isfield(S, 'data')
        D = S.data;
    else
        D = S;
    end
    if isfield(S, 'summary52')
        summary = S.summary52;
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
summary.n_certified = height(T);
summary.gap_pct_median = median(D.gap_pct);
summary.t_relax_median = median(D.t_relax);
summary.t_de_median = median(D.t_de);
end

function fig = plot_figure3(D, summary, font_size, gap_ylim, box_lw, box_width, gap_xlim, runtime_xlim, layout)
if nargin < 6 || isempty(box_width), box_width = 0.28; end
if nargin < 7 || isempty(gap_xlim), gap_xlim = [0.35, 1.65]; end
if nargin < 8 || isempty(runtime_xlim), runtime_xlim = [0.35, 2.65]; end
if nargin < 9 || isempty(layout), layout = 'row'; end
gap = D.gap_pct(:);
has_t = ~isnan(D.t_relax) & ~isnan(D.t_de);
col_prop_fc = [0.55 0.78 0.95]; col_prop_ec = [0.12 0.35 0.62];
col_de_fc = [0.98 0.72 0.62]; col_de_ec = [0.72 0.22 0.15];
switch lower(layout)
    case {'stack', 'vertical', 'col'}
        fig_w = 3.5; fig_h = 4.0; nrows = 2; ncols = 1;
    otherwise
        fig_w = 7.0; fig_h = 2.65; nrows = 1; ncols = 2;
end
fig = figure('Color', 'w', 'Units', 'inches', ...
    'Position', [1 1 fig_w fig_h], 'PaperUnits', 'inches', ...
    'PaperSize', [fig_w fig_h], 'PaperPosition', [0 0 fig_w fig_h]);
tl = tiledlayout(fig, nrows, ncols, 'TileSpacing', 'compact', 'Padding', 'compact');

ax1 = nexttile(tl, 1);
hold(ax1, 'on');
boxplot(ax1, gap, 'Orientation', 'vertical', 'Widths', box_width, ...
    'Symbol', 'o', 'Labels', {''}, 'Whisker', 1.5);
style_boxplot(ax1, {col_prop_fc}, {col_prop_ec}, box_lw);
set(ax1, 'FontSize', font_size, 'LineWidth', 0.8, 'Box', 'on', ...
    'XTick', 1, 'XTickLabel', {''}, 'TickDir', 'out');
yline(ax1, 0, 'Color', [0.45 0.45 0.45], 'LineStyle', '--', 'LineWidth', 0.9);
ylabel(ax1, 'Relative gap (%)');
title(ax1, 'Optimality gap', 'FontWeight', 'normal');
grid(ax1, 'on');
set(ax1, 'GridAlpha', 0.22, 'MinorGridAlpha', 0.12);
med_gap = median(gap);
if gap_ylim > 0, ylim(ax1, [0, gap_ylim]); end
n_above = sum(gap > gap_ylim);
stat_lines = {sprintf('n=%d', numel(gap)), ...
    sprintf('median=%.1f%%', med_gap), ...
    sprintf('IQR=[%.1f, %.1f]%%', prctile(gap, 25), prctile(gap, 75))};
if n_above > 0 && gap_ylim > 0
    stat_lines{end+1} = sprintf('%d above %d%% (max %.0f%%)', n_above, gap_ylim, max(gap));
end
text(ax1, 0.03, 0.97, stat_lines, 'Units', 'normalized', ...
    'VerticalAlignment', 'top', 'FontSize', font_size - 0.5);
xlim(ax1, gap_xlim);
set(ax1, 'XLimMode', 'manual');

ax2 = nexttile(tl, 2);
if any(has_t)
    t_prop = D.t_relax(has_t);
    t_de = D.t_de(has_t);
    tt = [t_prop(:), t_de(:)];
    hold(ax2, 'on');
    boxplot(ax2, tt, 'Labels', {'Proposed', 'DE global'}, ...
        'Widths', box_width, 'Symbol', 'o', 'Whisker', 1.5);
    style_boxplot(ax2, {col_prop_fc, col_de_fc}, {col_prop_ec, col_de_ec}, box_lw);
    set(ax2, 'YScale', 'log', 'FontSize', font_size, 'LineWidth', 0.8, ...
        'Box', 'on', 'TickDir', 'out');
    ylabel(ax2, 'Runtime (s)');
    title(ax2, 'Runtime', 'FontWeight', 'normal');
    grid(ax2, 'on');
    set(ax2, 'GridAlpha', 0.22);
    t_relax_med = summary.t_relax_median;
    t_de_med = summary.t_de_median;
    if isempty(t_relax_med) || isnan(t_relax_med)
        t_relax_med = median(t_prop);
    end
    if isempty(t_de_med) || isnan(t_de_med)
        t_de_med = median(t_de);
    end
    text(ax2, 0.03, 0.97, {sprintf('n=%d', numel(t_prop)), ...
        sprintf('Proposed: med=%.2f s', t_relax_med), ...
        sprintf('DE: med=%.0f s', t_de_med)}, ...
        'Units', 'normalized', 'VerticalAlignment', 'top', 'FontSize', font_size - 0.5);
    xlim(ax2, runtime_xlim);
    set(ax2, 'XLimMode', 'manual');
end
end

function R = load_fig4_alpha_data(data_dir)
mat_file = fullfile(data_dir, 'sec53_alpha_results.mat');
csv_file = fullfile(data_dir, 'alpha_sensitivity_sec53.csv');
if isfile(mat_file)
    S = load(mat_file);
    if isfield(S, 'results53'), R = S.results53; else, R = S; end
    return;
end
if ~isfile(csv_file)
    error('Need sec53_alpha_results.mat or alpha_sensitivity_sec53.csv');
end
Ta = readtable(csv_file);
R.theta_list = unique(Ta.theta, 'stable').';
R.U_list = unique(Ta.U, 'stable').';
n_th = numel(R.theta_list);
n_u = numel(R.U_list);
R.alpha_star = nan(n_th, n_u);
for k = 1:height(Ta)
    it = find(abs(R.theta_list - Ta.theta(k)) < 1e-9, 1);
    iu = find(abs(R.U_list - Ta.U(k)) < 1e-9, 1);
    R.alpha_star(it, iu) = Ta.alpha_star(k);
end
R.s_horizon = 200;
end

function fig = plot_figure4_alpha(R, plot_font, slice_cmap, slice_desat)
theta_list = R.theta_list(:).';
U_list = R.U_list(:).';
alpha_mat = R.alpha_star;
n_theta = numel(theta_list);
n_U = numel(U_list);
cmap_t = discrete_line_colors(slice_cmap, n_theta, slice_desat);
cmap_u = discrete_line_colors(slice_cmap, n_U, slice_desat);
use_paper_markers = any(strcmpi(strtrim(slice_cmap), {'paper', 'pub', 'print', 'muted'}));
[U_plot, iu_ord] = sort(U_list, 'ascend');
ylo = floor(min(alpha_mat(:), [], 'omitnan') * 10) / 10 - 0.02;
yhi = ceil(max(alpha_mat(:), [], 'omitnan') * 10) / 10 + 0.02;

fig_w = 7.0; fig_h = 2.65;
fig = figure('Color', 'w', 'Units', 'inches', ...
    'Position', [1 1 fig_w fig_h], 'PaperUnits', 'inches', ...
    'PaperSize', [fig_w fig_h], 'PaperPosition', [0 0 fig_w fig_h]);

ax1 = subplot(1, 2, 1);
hold(ax1, 'on');
h_leg = gobjects(n_U, 1);
leg_u = cell(n_U, 1);
for iu = 1:n_U
    col = cmap_u(iu, :);
    h_leg(iu) = plot_slice_line(ax1, theta_list, alpha_mat(:, iu).', '-s', col, use_paper_markers);
    leg_u{iu} = sprintf('$\\bar{u} = %.1f$', U_list(iu));
end
decorate_alpha_panel(ax1, plot_font, '$\bar{e}$', '$\alpha^\star$', ...
    '$\alpha^\star$ vs. $\bar{e}$ (fixed $\bar{u}$)', h_leg, leg_u);
ylim(ax1, [ylo, yhi]);
xlim(ax1, [min(theta_list) * 0.95, max(theta_list) * 1.05]);

ax2 = subplot(1, 2, 2);
hold(ax2, 'on');
h_leg2 = gobjects(n_theta, 1);
leg_e = cell(n_theta, 1);
for it = 1:n_theta
    col = cmap_t(it, :);
    h_leg2(it) = plot_slice_line(ax2, U_plot, alpha_mat(it, iu_ord), '-o', col, use_paper_markers);
    leg_e{it} = sprintf('$\\bar{e} = %.1f$', theta_list(it));
end
decorate_alpha_panel(ax2, plot_font, '$\bar{u}$', '$\alpha^\star$', ...
    '$\alpha^\star$ vs. $\bar{u}$ (fixed $\bar{e}$)', h_leg2, leg_e);
ylim(ax2, [ylo, yhi]);
xlim(ax2, [min(U_plot) * 0.95, max(U_plot) * 1.05]);
end

function decorate_alpha_panel(ax, plot_font, xlab, ylab, tit, h_leg, leg_txt)
set(ax, 'FontSize', plot_font.ax);
xlabel(ax, xlab, 'Interpreter', 'latex', 'FontSize', plot_font.label);
ylabel(ax, ylab, 'Interpreter', 'latex', 'FontSize', plot_font.label);
title(ax, tit, 'Interpreter', 'latex', 'FontSize', plot_font.title);
grid(ax, 'on');
legend(ax, h_leg, leg_txt, 'Location', 'northwest', ...
    'FontSize', plot_font.legend, 'NumColumns', 2, 'Interpreter', 'latex');
end

function R = load_fig5_tahir_data(data_dir)
candidates = {'sec54_tahir_results.mat', 'sec53_results.mat'};
for k = 1:numel(candidates)
    f = fullfile(data_dir, candidates{k});
    if isfile(f)
        S = load(f);
        if isfield(S, 'data'), R = S.data; else, R = S; end
        return;
    end
end
error('Need sec54_tahir_results.mat (or legacy sec53_results.mat).');
end

function fig = plot_figure5_tahir(R4, font_size)
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
boxes = sort_graphics_by_x(ax, 'Box');
if isempty(boxes), return; end
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
    h = sort_graphics_by_x(ax, tag{1});
    for k = 1:numel(h)
        ec = edge_colors{min(k, numel(edge_colors))};
        set(h(k), 'Color', ec, 'LineWidth', lw);
    end
end
out = sort_graphics_by_x(ax, 'Outliers');
for k = 1:numel(out)
    ec = edge_colors{min(k, numel(edge_colors))};
    set(out(k), 'Marker', 'o', 'MarkerSize', 4, 'MarkerEdgeColor', ec, ...
        'MarkerFaceColor', [1 1 1], 'LineWidth', 0.75);
end
end

function h = sort_graphics_by_x(ax, tag)
h = findobj(ax, 'Tag', tag);
if isempty(h), return; end
xpos = arrayfun(@(o) mean(o.XData, 'omitnan'), h);
[~, ord] = sort(xpos);
h = h(ord);
end

function h = plot_slice_line(ax, x, y, ls, col, paper_style)
if nargin < 6, paper_style = false; end
if paper_style
    h = plot(ax, x, y, ls, 'Color', col, 'LineWidth', 1, 'MarkerSize', 4, ...
        'MarkerFaceColor', [1 1 1], 'MarkerEdgeColor', col);
else
    h = plot(ax, x, y, ls, 'Color', col, 'LineWidth', 1, 'MarkerSize', 4, ...
        'MarkerFaceColor', col);
end
end

function cmap = discrete_line_colors(name, n, desat_amt)
if nargin < 3, desat_amt = 0; end
n = max(n, 1);
switch lower(strtrim(name))
    case {'paper', 'pub', 'print'}
        cmap = paper_line_colors(n);
    case 'muted'
        cmap = desaturate_cmap(lines(n), desat_amt + 0.22);
    case 'lines'
        cmap = lines(n);
    otherwise
        cmap = paper_line_colors(n);
end
if desat_amt > 0 && ~any(strcmpi(strtrim(name), {'paper', 'pub', 'print', 'muted'}))
    cmap = desaturate_cmap(cmap, desat_amt);
end
end

function cmap = paper_line_colors(n)
base = [ ...
    0.12 0.35 0.62; 0.72 0.40 0.22; 0.45 0.52 0.58; 0.38 0.52 0.44; ...
    0.52 0.42 0.56; 0.58 0.48 0.38; 0.28 0.48 0.52; 0.62 0.38 0.38];
if n <= size(base, 1)
    cmap = base(1:n, :);
else
    t = linspace(1, size(base, 1), n);
    cmap = [interp1(1:8, base(:,1), t)', interp1(1:8, base(:,2), t)', ...
        interp1(1:8, base(:,3), t)'];
    cmap = max(min(cmap, 1), 0);
end
end

function rgb = desaturate_cmap(rgb, amt, gray_val)
if nargin < 3, gray_val = 0.55; end
amt = max(min(amt, 1), 0);
rgb = (1 - amt) * rgb + amt * gray_val;
rgb = max(min(rgb, 1), 0);
end
