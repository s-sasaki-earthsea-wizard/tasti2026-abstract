# TASTI 2026 Extended Abstract — GPU-Accelerated InSAR Time-Series Analysis

Extended abstract for [TASTI 2026](https://tasti2026.conf.tw/) (Taiwan International
Assembly of Space Science, Technology, and Industry; 8–11 November 2026, Tainan, Taiwan),
presenting the PyTorch-based GPU solver contributed to
[MintPy](https://github.com/insarlab/MintPy) via
[insarlab/MintPy#1490](https://github.com/insarlab/MintPy/pull/1490).

This is a sibling repository of
[s-sasaki-earthsea-wizard/MintPy](https://github.com/s-sasaki-earthsea-wizard/MintPy)
(the development fork) and
[mintpy-benchmark](https://github.com/s-sasaki-earthsea-wizard/mintpy-benchmark)
(benchmark harness and reports).

## Layout

| Path | Purpose |
|---|---|
| `abstract.tex` | Extended abstract draft (300–800 words required) |
| `tasti2026.sty` | LaTeX style reproducing the official docx/PDF template formatting |
| `template/` | Official template PDF (reference copy) |
| `Makefile` | `make` / `make wordcount` / `make clean` |
| `HANDOVER.md` | Session handover notes (Japanese) |

## Build

Requires TeX Live with `latexmk` and the `newtx` font packages:

```bash
sudo apt-get install texlive-latex-extra texlive-fonts-extra latexmk
make
```

The style targets pdfLaTeX with `newtxtext`/`newtxmath` (Times-compatible metrics).
If the genuine Times New Roman face is required, see the note in `tasti2026.sty`
for the XeLaTeX/`fontspec` variant.

## Key dates

- Abstract submission deadline: **15 August 2026** (PDF upload, ≤ 10 MB)
- Conference: 8–11 November 2026, International Convention Center, Tainan, Taiwan
