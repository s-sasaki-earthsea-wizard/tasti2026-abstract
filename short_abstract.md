# Short Abstract (≤ 200 words) — TASTI 2026

投稿システムの short abstract 欄に**そのまま貼る**プレーンテキスト。
本文 (`abstract.tex`) の圧縮版で、数値の系列ルール
([docs/results.md](docs/results.md)) と表現上の注意
([docs/abstract_notes.md](docs/abstract_notes.md)) はすべて本文と同一。

- LaTeX コマンド・引用番号 `[n]`・図表参照は入れない (フォーム欄は素のテキスト)
- 掛け算記号は `x` (`\times` や `×` はフォームで化ける可能性がある)
- **本文 199 words** — `make shortcount` で再計測できる

---

## 貼り付け本文

Interferometric SAR (InSAR) time-series analysis is a standard tool for measuring ground deformation, but archives are growing faster than the software that consumes them. In MintPy, a widely used open-source small-baseline package, a single step - the least-squares inversion of the interferogram network, solved pixel by pixel on the CPU - accounts for 43.5% of a complete run. This work removes that bottleneck on a single consumer GPU.

A direct port of the per-pixel routine to a batched QR solver reached only 1.43x over the CPU path: the bottleneck was the shape of the problem, not the hardware. Reformulating around the normal equations reduces each tall-skinny system to a small Gram block, factorized in one batched Cholesky call in single precision using PyTorch.

Measured against the CPU path on an NVIDIA GeForce RTX 5080, a Galapagos scene (3.4 million pixels, 475 retained interferograms) fell from 6,189 s to 170 s, a 36.4x step-level speedup; five public scenes spanning four interferometric processors and two radar wavelengths accelerated by 5.3x to 93.8x, all clearing a numerical agreement gate at normalized RMS differences of order 1e-5. Inversions that took hours now finish in minutes on hardware a single research group can own.

---

## 本文 (665 words) から落としたもの / 残したもの

| 要素 | short | 理由 |
| --- | --- | --- |
| objective (43.5% ボトルネック) | **残す** | テンプレ 4 要素の 1 つ |
| methodology (1.43x → 正規方程式 + batched Cholesky) | **残す** | 「なぜ速いか」の核。1.43x を落とすと単なる「GPU 化しました」になる |
| key results (36.4x / 5.3–93.8x / RMS 1e-5) | **残す** | 速度と正しさの両方。片方だけだと主張が立たない |
| significance (数時間 → 数分、1 グループが持てる機材) | **残す** | テンプレ 4 要素の 1 つ |
| NISAR / FORMOSAT-9 の文脈 | 落とす | 語数最優先。本文とポスターで担保する |
| 44.4x (kernel-level) | 落とす | step-level 36.4x だけで足りる。2 つ並べると欄内で読み手が止まる |
| DEM 誤差補正 6.2x / 18 step 完走 | 落とす | 一般性の補強であって主張の骨格ではない |
| 非侵襲実装 (opt-in / CPU 経路不変) | 落とす | 本文 ¶2・¶4 で担保。査読者が short だけを読むわけではない |
| upstream PR #1490 | 落とす | 引用番号を使えない欄で URL を書くと欄が汚れる |
| 16.5x (S1 系列) | **入れない** | 本文と同じ理由 — 基準が 2 つあると初読者が混乱する |
| 規模依存の主張 | **入れない** | S3 の実データで成立しない (順位相関 −0.20) |

## もしフォーム側の語数カウントが厳しかったら

`make shortcount` は空白区切り (`wc -w`) の 199 words。フォームが別の数え方を
していて 200 を超えると判定された場合は、**この順に削る** (主張は壊れない):

1. `475 retained interferograms` → `475 interferograms` (−1)
2. `a single research group can own` → `a single group can own` (−1)
3. `Measured against the CPU path on an NVIDIA GeForce RTX 5080,` →
   `On an NVIDIA GeForce RTX 5080,` (−5。ただし「CPU 比」の明示が消えるので、
   本文と併読されない場合は避ける)

## 提出前チェック

- [ ] 200 words 以下 (`make shortcount`)
- [ ] 数値が [docs/results.md](docs/results.md) の系列と一致
- [ ] 本文 (`abstract.tex`) の数値を直したらここも直す
- [ ] フォームに貼った後、段落の空行が保持されているか確認
      (1 段落に潰される仕様なら、段落間を空行なしの改行に詰める)
