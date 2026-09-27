# Paper figures — supplementary numerical results

This repository provides **plot-only** scripts and **frozen numerical results** for Figures 2–4 in the error-bounded tracking paper (Sections 5.1–5.3).

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
| `fig3_sec52.pdf` / `.png` | Section 5.2 — Monte Carlo gap & runtime |
| `fig4_sec53.pdf` / `.png` | Section 5.3 — Tahir (2010) comparison |

## Bundled data (`results/public/`)

| File | Description |
|------|-------------|
| `sec51_results.mat` | Figure 2 trajectories & `V*` |
| `sec53_results.mat` | Figure 4 `rho`, volumes, runtimes (27 systems) |
| `mc_table_sec52.csv` | Figure 3 per-system table (30 systems) |
| `mc_summary_sec52.txt` | Figure 3 summary statistics |
| `fig2_sec51.pdf`, `fig3_sec52.pdf`, `fig4_sec53.pdf` | Reference PDFs from the manuscript run |

Figure 3 is read from `sec52_results.mat` if present; otherwise from `mc_table_sec52.csv`.

## Repository layout

```
tracking_MRI/
├── README.md
├── plot_paper_figures.m      ← only script needed
└── results/public/
    ├── sec51_results.mat
    ├── sec53_results.mat
    ├── mc_table_sec52.csv
    └── fig*.pdf / fig*.png   (optional reference copies)
```

## License

Add a license on GitHub if desired (e.g. MIT for the plotting script; data files may use the same or CC-BY-4.0). This does **not** grant rights to third-party tools used in the original offline experiments (MATLAB, MOSEK, etc.).

## Citation

If you use these results, please cite the corresponding paper ( citation TBD ).
