# ベンチマーク結果の正典 — abstract に載せる数字はここから引く

計測の実体は sibling repo
[mintpy-benchmark](https://github.com/s-sasaki-earthsea-wizard/mintpy-benchmark)
(report は commit SHA 固定 permalink)。abstract・スライド・ポスターに数字を
書くときは**必ずこの doc の表と系列名で照合**すること。

## ⚠️ 最重要: 数字の系列を混ぜない

speedup には**測定条件の違う 3 系列**があり、混ぜると誤りになる:

| 系列 | 比較 | 条件 | 代表値 |
| --- | --- | --- | --- |
| **S1: solver 対決** | GPU QR (lstsq) vs GPU Cholesky | Fernandina, SSD, 3-shot mean | **16.50×** (internal) |
| **S2: CPU 置き換え** | CPU lstsq vs GPU Cholesky | Galapagos, 条件統一計測 | **44.4×** internal / **36.4×** step wall |
| **S3: 5 シーン E2E** | CPU vs torch (end-to-end 実行から step wall 抽出) | warm SSD, `/usr/bin/time -v` | **5.32〜93.77×** |

- **16.5× を「CPU 比」と書くのは誤り** (過去に一度取り違えて撤回した前科あり)。
  16.5× は「アルゴリズム置換 (QR→Cholesky) の寄与」を同一 GPU で分離した数字。
- S2 の 44.4× は「GPU 化 + バッチ化 + アルゴリズム変更」の 3 効果込み。
- S3 は E2E 実行からの抽出で S1/S2 と測定方法が違う。**規模依存の議論
  (5〜94× のレンジ) は S3 の表だけで閉じる**こと。
- 「小シーン 16.5× → 大シーン 44.4× と伸びる」という異系列連結も**禁止**。

## S1: 同一 GPU での QR vs Cholesky (Fernandina)

出典: mintpy-benchmark `report_solver_comparison.md` @ `0682c4c`

| Metric | GPU lstsq (QR/gels) | GPU Cholesky | ratio |
| --- | ---: | ---: | ---: |
| internal (ソルブ中核) | 228.17 s | **13.83 s** | **16.50×** |
| step wall | 275.07 s | 61.34 s | 4.49× |
| kernel launches / chunk | 3,841,835 | **57** | **67,400×** |
| kernel time / chunk | 10.41 s | 24.20 ms | 430× |
| 正規化 RMS max (相互差) | — | — | **1.19e-5** |

- abstract の "16.5×" と "3.8M → 57 kernel launches" はこの表。
- RMS 1.19e-5 は**条件数二乗の代償だけ**を分離した実測
  ([numerical_method.md](numerical_method.md) §3)。

## S2: CPU 経路との比較 (Galapagos 大シーン)

出典: mintpy-benchmark `report_large_scene.md` @ `019ceba`

| シーン | ピクセル × ifgs | CPU (lstsq) | GPU (Cholesky) | internal | step wall |
| --- | --- | ---: | ---: | ---: | ---: |
| GalapagosSenDT128 | 3.4M × 475 kept | 6,189 s | **170.06 s** | **44.4×** | **36.4×** |

- internal = ソルブ中核 / step wall = ステップ全体 (I/O 込み)。差は I/O・転送。
- 絶対 RMS max ~16 µm (CPU 参照比) — 欲しい変位 (mm 級) より桁違いに小さい。
- Max RSS 3.73 → 5.80 GiB、VRAM peak 7.6/16 GiB (48%)。

## S3: 5 シーン end-to-end 検証 (「偶然ではない」の裏付け)

出典: [`report_end_to_end_bench.md` @ 0fbf71b](https://github.com/s-sasaki-earthsea-wizard/mintpy-benchmark/blob/0fbf71b/reports/report_end_to_end_bench.md)
/ [PR #1490 フォローアップコメント](https://github.com/insarlab/MintPy/pull/1490)
(2026-05-19 投稿) として公開済み。

| シーン | 処理系 / センサ | px | ifgs (K) | dates (D) | cpu | torch | speedup |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| FernandinaSenDT128 | ISCE2 / S1 (C) | 270 k | 288 | 98 | 645.12 s | 6.88 s | **93.77×** |
| GalapagosSenDT128 | ISCE2 / S1 (C) | 3.40 M | 490 | 98 | 2976.72 s | 79.40 s | **37.49×** |
| SanFranBaySenD42 | GMTSAR / S1 (C) | 326 k | 1297 | 333 | 1080.38 s | 17.42 s | **62.02×** |
| KujuAlosAT422F650 | ROI_PAC / ALOS-1 (L) | 226 k | 167 | 24 | 31.01 s | 4.53 s | **6.85×** |
| SanFranSenDT42 | ARIA / S1 (C) | 1.04 M | 505 | 114 | 58.85 s | 11.07 s | **5.32×** |

- **4 処理系 × 2 波長 × 全て Zenodo 公開データ** — abstract の "five-scene
  benchmark spanning four interferometric processors and two radar wavelengths"
  はこの表。この表で主張できるのは **external validity (どの条件でも一貫して速い)**
  であって、**規模依存ではない** (下記)。

### ⚠️ 規模依存は S3 では主張できない (2026-08-06 訂正)

以前ここには「レンジは per-pixel solve コスト ($\propto K D^2$) で構造的に決まる。
Kuju が床、SanFranBay が天井」と書いてあったが、**同じ表の実データと矛盾していた**。
床は SanFranSen の 5.32×、天井は Fernandina の 93.77× が正しい。

speedup と問題規模には相関がない (Spearman 順位相関):

| 規模指標 | speedup との順位相関 |
| --- | ---: |
| ピクセル数 | **−0.20** |
| per-pixel 演算密度 $KP^2 + P^3/3$ | **+0.00** |
| 総演算量 (px × per-pixel) | **+0.20** |

表の中に反例が並んでいる:

- 最小級の **Fernandina (270 k px) が最速の 93.77×**
- 最大の **Galapagos (3.40 M px) は 37.49×** — 最速ではない
- Fernandina の 4 倍の規模の **SanFranSen (1.04 M px) が最遅の 5.32×**

→ 「規模が大きいほど恩恵が大きい」と書くと**同じ表に否定される**。抄録・ポスター
いずれでもこの主張はしないこと。

**壊れているのは CPU 側ベースラインのばらつき**。GPU 時間は総演算量に対してほぼ単調
(0.02 / 0.81 / 7.21 / 16.71 / 50.58 TFLOP → 4.53 / 6.88 / 11.07 / 17.42 / 79.40 s) だが、
CPU 時間は SanFranSen (7.21 TFLOP) が 58.85 s、Fernandina (0.81 TFLOP) が 645.12 s —
**9 倍の仕事量を 1/11 の時間で**終えている。処理系ごとの有効ピクセル数 (マスク) や
データレイアウトの差が疑わしいが、未検証。

- **規模依存を主張したいときは S2 を使う** (Galapagos 同一シーンの条件統一計測、
  36.4× / 44.4×)。大規模シーンでの効きはこちらで担保できる。
- 参考: 姉妹 repo `vrc-insar-batched-cholesky-LT` のスライドが「行列が大きいほど
  効果は顕著」と言えているのは、5 シーンのうち **3 つ (Kuju / Galapagos / SanFranBay)
  だけを D 昇順に並べている**ため。Fernandina と SanFranSen を外すと単調に見える。
  LT での見せ方であって、**5 シーン全部を出す抄録では使えない**。
- **数値一致**: float32 round-off gate (rms/|cpu|.max < 1e-5) を、ユーザーが
  見る**最終成果物** (velocity.h5・geocoded 出力) で **5/5 通過**。
- 但し書き: Kuju / SanFranSen の 2 シーンはレーダー座標の**中間生成物**で
  rms/scale 1〜7% の発散があるが、near-rank-deficient ピクセル (CPU lstsq の
  最小ノルム解 vs `cholesky_ex` ゼロ埋めの差) に限局し、`maskTempCoh.h5` が
  捨てる領域。Kuju の geocoded velocity はマスク後 **1.38e-7** で通過。
  → 突っ込まれたら「発散が出た場所は品質マスクが先に棄却する場所」と答える。

Zenodo: Fernandina [3952953](https://zenodo.org/records/3952953) /
Galapagos [4743058](https://zenodo.org/records/4743058) /
SanFranBay [15814132](https://zenodo.org/records/15814132) /
Kuju [3952917](https://zenodo.org/records/3952917) /
SanFranSen [4265413](https://zenodo.org/records/4265413)

## 同じコアの再利用 — `correct_topography` (DEM 残差推定)

出典: mintpy-benchmark `bench/correct-topography-cpu-vs-torch` ブランチの
2 シーン report (HEAD `b4047b0`)

| ステップ | 未知数 | Galapagos CPU | GPU | speedup | 数値 (rms/scale) |
| --- | ---: | ---: | ---: | ---: | --- |
| `correct_topography` | P=4 | 163.83 s | 26.66 s | **6.15×** | delta_z 7.10e-7 / ts_cor 2.08e-8 / ts_res 4.44e-7 |

- 44× に届かないのは per-pixel flops 密度 ~1/1000 で framework overhead 律速
  のため (天井 ~10×) → [numerical_method.md](numerical_method.md) §5。
- abstract では「同じ正規方程式コアが設計行列の差し替えだけで別ステップにも
  適用できた」= 一般性の主張として使う。

## その他 abstract で使っている事実

| 主張 | 出典 |
| --- | --- |
| `invert_network` が baseline の 43.5% を占有 | mintpy-benchmark `report_baseline.md` |
| GPU batched QR (Phase 1) は CPU 比 1.43× 止まり | `report_torch.md` + `report_profile.md` @ `cea7573` |
| 全 18 step の smallbaselineApp が solver=torch で完走 | fork Wiki "GPU Quick Start" + PR #1490 記載の E2E 実測 |
| ハードウェア: RTX 5080 16 GB (コンシューマ) | 全 report 共通の環境欄 |

## permalink 方針

sibling repo (mintpy-benchmark) は将来 private 化の可能性があるため、
**abstract 本文には数値を焼き込み、リンクは張らない** (references は文献のみ)。
発表スライド段階でも commit-pin permalink を補助的に添えるに留める
(upstream PR #1490 で採った Option C と同じ)。
