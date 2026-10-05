# Paper figures — supplementary numerical results

This repository provides **plot-only** scripts and **frozen numerical results** for Figures 2–5 in the error-bounded tracking paper (Sections 5.1–5.4).

> **Note:** Full simulation / solver code is **not** included here (patent pending). Reviewers and readers can reproduce the **figures** from the bundled data below.

## Requirements

- MATLAB (R2019b or later recommended)
- Statistics Toolbox (for `boxplot` in Figure 3)
- Optional: MPT Toolbox (Figure 2; falls back to `patch` if absent)
- **No** YALMIP / SDPT3 / MOSEK / SeDuMi needed for this repository

## Quick start

```matlab
cd tracking_MRI
plot_paper_figures
```

Outputs (regenerated under `results/public/`):

| File | Content |
|------|---------|
| `fig2_sec51.pdf` / `.png` | Section 5.1 — MRI set & tracking error |
| `fig3_sec52.pdf` / `.png` | Section 5.2 — Monte Carlo gap & runtime (100 systems) |
| `fig4_sec53.pdf` / `.png` | Section 5.3 — LMI optimal $\alpha^\star$ vs. $\bar{e}$, $\bar{u}$ |
| `fig5_sec54.pdf` / `.png` | Section 5.4 — Tahir (2010) comparison (formerly Sec. 5.3) |

## Bundled data (`results/public/`)

| File | Description |
|------|-------------|
| `sec51_results.mat` | Figure 2 trajectories & `V*` |
| `sec52_results.mat` | Figure 3 structured data + summary (preferred) |
| `mc_table_sec52.csv` | Figure 3 per-system table (fallback) |
| `mc_summary_sec52.txt` | Figure 3 summary statistics |
| `sec53_alpha_results.mat` | Figure 4 $\alpha^\star(\bar{e},\bar{u})$ grid |
| `alpha_sensitivity_sec53.csv` | Figure 4 CSV fallback |
| `sec54_tahir_results.mat` | Figure 5 `rho`, volumes, runtimes (27 systems) |
| `sec53_results.mat` | Legacy alias for Tahir data (still supported) |

Figure 3 prefers `sec52_results.mat`; otherwise reads `mc_table_sec52.csv`.  
Figure 4 prefers `sec53_alpha_results.mat`; otherwise reads `alpha_sensitivity_sec53.csv`.


## Repository layout

```
tracking_MRI/
├── README.md
├── plot_paper_figures.m      ← only script needed
└── results/public/
    ├── sec51_results.mat
    ├── sec52_results.mat
    ├── sec53_alpha_results.mat
    ├── sec54_tahir_results.mat
    ├── mc_table_sec52.csv
    └── fig*.pdf / fig*.png   (optional reference copies)
```

## License

Add a license on GitHub if desired (e.g. MIT for the plotting script; data files may use the same or CC-BY-4.0). This does **not** grant rights to third-party tools used in the original offline experiments (MATLAB, MOSEK, etc.).

## Citation

If you use these results, please cite the corresponding paper (citation TBD).
