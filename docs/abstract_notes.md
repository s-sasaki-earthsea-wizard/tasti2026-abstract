# Abstract 執筆ノート — 主張→出典対応、表現上の注意、判断の記録

`abstract.tex` の現ドラフト (**本文 665 words** / 2 ページ / 図 1 + 表 1) を
推敲・更新するときの作業基準。数値を触るときは必ず
[results.md](results.md) の系列混同禁止事項を先に読むこと。

## 核心メッセージ (1 文)

> InSAR 時系列解析の最重ステップを正規方程式 + batched Cholesky で GPU 化し、
> **コンシューマ GPU 1 枚**で 5〜94× の高速化と数値一致 gate 通過を両立、
> NISAR 時代のデータ量に耐える処理を「クラスタなしで」手が届くものにした。

TASTI の聴衆 (宇宙科学・衛星技術・産業) に合わせて **NISAR / rapid response /
democratization** を前面に、条件数の数理は裏方に
([project_overview.md](project_overview.md) 参照)。

## 現在の構成 (2026-08-06 確定)

| ¶ | 役割 | 内容 | 図表 |
| --- | --- | --- | --- |
| 1 | Objective | NISAR でデータ増 → `invert_network` が 43.5% → 設計目標 (opt-in / クラスタ不要 / CPU 挙動不変) | — |
| 2 | Methodology | **GPU 移植のみでは CPU 比 1.43×** → 正規方程式 + batched Cholesky (QR 因子は作らない) → 非侵襲実装 → DEM 誤差補正に再利用 | **Fig. 1** |
| 3a | **Speedup.** (ランイン見出し) | Galapagos 36.4× / 44.4×、5 シーン 5.3–93.8×、DEM 6.2×、18 step 完走 | **Table 1** |
| 3b | **Numerical validation.** (ランイン見出し) | gate 5/5、RMS ~1e-5 = float32 round-off、絶対差 ~16 µm | — |
| 4 | Conclusion + Significance | 桁の振り返り → rapid response / 国土規模監視 → FORMOSAT-9 [6] → 参入障壁 → upstream [7] | — |

テンプレは objective / methodology / key results / significance の 4 要素を
明示的に要求する。**¶4 を「振り返り」だけにすると significance を落とす**ので、
「だから何が可能になるか」まで必ず書くこと。

## 段落ごとの主張 → 出典対応表

### ¶1 Objective

| 主張 | 出典 / 裏付け |
| --- | --- |
| Sentinel-1 / NISAR でデータ量が処理能力を超えて伸びる | 一般論 + [compute_scale.md](compute_scale.md) の $D^3$ スケーリング |
| MintPy は最普及級の OSS SBAS ツール | Yunjun+ 2019 (ref [2]) |
| 網逆解析が smallbaselineApp の 43.5% | [results.md](results.md) 末尾表 (`report_baseline.md`) |
| 目標: opt-in / CPU 挙動不変 / クラスタ不要 | PR #1490 設計 ([numerical_method.md](numerical_method.md) §4) |

### ¶2 Methodology

| 主張 | 出典 |
| --- | --- |
| **GPU batched QR への単純移植は CPU 比 1.43× 止まり** | [results.md](results.md) 「その他」表 (`report_torch.md` + `report_profile.md` @ `cea7573`) |
| per-pixel WLS → 正規方程式 + batched Cholesky (float32) | [numerical_method.md](numerical_method.md) §1, §3 |
| 同一 GPU で solver 置換 → solve kernel 16.5× | **S1 系列** ([results.md](results.md) S1 表) |
| 単一 cfg key で opt-in、CPU 経路 byte-for-byte 不変 | 同 §4 |
| DEM-error correction への同一設計適用 | [results.md](results.md) `correct_topography` 節 |

### ¶3a Speedup

| 主張 | 系列 | 出典 |
| --- | --- | --- |
| Galapagos 3.4M px × 475 ifgs: 6,189→170 s、36.4× step / 44.4× kernel、VRAM 7.6 GB | **S2** | [results.md](results.md) S2 表 |
| 5 シーン (4 処理系 × 2 波長) で 5.3〜93.8× | **S3** | 同 S3 表 = Table 1 |
| DEM-error 6.2× (同一シーン) | — | 同 `correct_topography` 表 |
| 18 step 完走 (E2E) | — | 同 末尾表 |

### ¶3b Numerical validation

| 主張 | 出典 |
| --- | --- |
| 正規化 RMS gate を最終成果物で 5/5 通過、max ~1e-5 | [results.md](results.md) S3 数値一致節 |
| 絶対差 max ~16 µm (大シーン) | 同 S2 注記 |
| mm 級の変位・大気ノイズ床より桁違いに下 | [numerical_method.md](numerical_method.md) §3 / 姉妹 repo `error_budget.svg` |

### ¶4 Conclusion + Significance

| 主張 | 出典 / 注意 |
| --- | --- |
| 数時間→数分で rapid-response 監視が現実的に | S2/S3 実測 |
| NISAR 時代のアーカイブにスケール | **定性のみ**。定量を足すなら [compute_scale.md](compute_scale.md) の但し書き必須 |
| 台湾の SAR 観測能力の拡大 (FORMOSAT-9) | TASA 公式 (ref [4])。**下記「表現上の注意」5 を厳守** |
| コンシューマ GPU で参入障壁を下げる | RTX 5080 実測そのもの |
| upstream に PR 済 (review 待ち) | **PR #1490 は OPEN — 下記 1 参照** |

## 表現上の注意 (毎回チェック)

1. **PR の状態と時制**: 現ドラフトは "has been submitted for upstream review"
   (= 事実、2026-08-06 時点で OPEN / REVIEW_REQUIRED)。**merged と書いてはいけない**。
   提出日に `gh pr view 1490 --repo insarlab/MintPy --json state` で再確認し、
   merged なら文言更新、closed (unmerged) なら "submitted" では事実とずれるので要再検討。

2. **⚠️ 本文の speedup は全て CPU 比に統一 (2026-08-06 決定)**。
   S1 系列 (同一 GPU の QR → Cholesky、internal **16.5×** / step wall **4.49×**) は
   **本文からも Fig. 1 キャプションからも外した**。

   理由: 修飾語で系列を区別しても、**読者に基準の切り替えを要求する時点で負け**。
   初読の査読者は「36.4× と 16.5× はどっちの話か」で止まる (Syota さん判断)。

   - **統一後の対比の方がむしろ強い**: GPU に載せただけ (batched QR) で
     **CPU 比 1.43×** → 正規方程式 + Cholesky で **CPU 比 36.4× / 44.4×**。
     同一基準のまま「ボトルネックはハードウェアでなく問題の形」を言い切れる。
   - ¶3a 冒頭に "Every speedup reported here is measured against the CPU
     reference path" と明示済み。
   - Fig. 1 は「形の違い」と **kernel launch 数** (3,841,835 → 57) だけを担う。
     launch 数は速度比ではないので基準の混乱を起こさない。

   → **16.5× を本文に戻さないこと**。ポスター/スライドで S1 を使うのは可だが、
   そのときは 3 条件 (比較の両側 = GPU QR vs GPU Cholesky / シーン = Fernandina /
   internal であること、**同じ比較の step wall は 4.49×**) を必ず添える。

3. **1.43× と 16.5× と CPU 比を混ぜない**: 1.43× は「GPU 移植のみ」の CPU 比、
   16.5× は「同一 GPU 上のアルゴリズム置換」、36.4×/44.4×/5.3–93.8× は CPU 比。
   ¶2 (1.43× と 16.5×) と ¶3a (CPU 比) は**段落を分けてある**。

4. **⚠️ 規模依存を主張しない**: 「規模が大きいほど高速化の恩恵が大きい」は
   **S3 の 5 シーンでは成立しない** (speedup とピクセル数の順位相関 −0.20、
   per-pixel 演算密度とは +0.00)。表を載せた上でこう書くと**同じ表に否定される**。
   詳細と反例は [results.md](results.md) §「規模依存は S3 では主張できない」。
   主張してよいのは **external validity (どの条件でも一貫して速い)** のみ。
   大規模シーンでの効きを言いたいときは **S2 の条件統一計測**を使う。

5. **FORMOSAT-9 の扱い**: X-band SAR 2 機 (2028 / 2030 打上、TASA)。
   - **Conclusion 側の地域文脈に留める** (Introduction でデータ増の主因として
     NISAR と並列に置くと、「X-band で SBAS 時系列を回す」前提を置くことになる)
   - **分解能の数字は書かない**。1 m 未満はスポットライトモードの値で、
     InSAR 時系列で常用する stripmap は 3 m 級。鋭い査読者ほどここを突く
   - X-band の時間デコリレーションの但し書きは**不要** (適性を主張していないので
     書かなくても不誠実にならない)。Q&A 用に「都市部・インフラ監視が主戦場」
     の答えだけ用意しておく

6. **外挿と実測の区別**: NISAR の定量を本文に入れる場合は "extrapolated from
   measured throughput" を必ず添える。現ドラフトは定性表現のみで回避している。

7. **著者表記**: フルネーム、肩書きなし、発表者 *。affiliation は
   **「Earthsea Wizard, Japan」で確定** (2026-08-06)。
   個人事業なので法人と誤解されないよう "(Independent Researcher)" を添える案を
   一度入れたが、テンプレの公式文言が "organization or institute and country only"
   であり字面から外れるリスクがあるため**外した**。個人事業であることは
   **聞かれたら答えれば十分**、という判断 (Syota さん)。

8. **謝辞なし**: テンプレに acknowledgment 節の規定なし。

9. **⚠️ CholeskyQR2 [3, 4] の引用は「動機」の支持であって「安全性」の根拠ではない**:
   この 2 件から引けるのは次の 2 点だけ。
   - Gram 行列を作って Cholesky にかけるのは **level-3 BLAS のみ・通信最小**で
     並列/GPU 環境に向く ([3] Abstract の "ideal from the viewpoint of high
     performance computing" がそのまま使える)
   - **条件数二乗 $O(\kappa^2 u)$ は既知の代償**として定量化されている

   **混同禁止**:
   - CholeskyQR2 は **QR 分解を得る**手法。本実装は**正規方程式を直接解く**
     (直交基底 $Q$ は不要で、解だけが要る)
   - CholeskyQR2 は **Cholesky QR を 2 回繰り返して**直交性を回復するのが肝。
     **本実装は反復しない**
   - [3] の安定性条件 $\kappa_2(X) \le O(u^{-1/2})$ は **CholeskyQR2 (2 回) の結果**。
     本実装に直接は適用できない

   → **「CholeskyQR2 と同じだから安全」とは書けない**。本実装の安全性の根拠は
   あくまで「$G$ が良条件 + 要求精度がミリ級 + 実測 RMS」
   ([numerical_method.md](numerical_method.md) §3)。

   > 想定問答「なぜ反復しないのか」→「直交基底が要らず解だけが要るから。
   > 反復は $Q$ の直交性を回復するための手順で、本件の誤差は実測で観測床の
   > 4 桁下に収まっている」

## 判断の記録

| # | 論点 | 結論 | 決めた根拠 |
| --- | --- | --- | --- |
| 1 | トラック | **0201 EO/Remote Sensing で確定** | 手法貢献が主で防災は応用例 |
| 2 | 図の枚数 | **Fig. 1 のみ** | 手法の「形」は言葉だと 3〜4 文かかるので図が勝つ。S3 は**表**に (下記 3) |
| 3 | S3 を図か表か | **表 (Table 1)** | 規模依存が成立しない以上、bar chart だと順序のバラつきが目立って弱く見える。表なら条件と結果を淡々と並べて external validity を示せる |
| 4 | 誤差バジェット図 | **不採用** | 主張は本文 1 文で閉じる。図にすると Kuju/SanFranSen の中間生成物の発散 (マスク領域、1〜7%) まで説明責任が広がり、質疑の隙を自分で作る |
| 5 | 16.5× の置き場 | **本文・キャプションとも不採用 (2026-08-06 再決定)** | 一度は「本文 + キャプション」に置いたが、**基準が 2 つあると初読者が混乱する**ため CPU 比に統一。1.43× → 36.4× の同一基準の対比で「なぜ Cholesky か」は十分言える |
| 6 | NISAR 定量 (frame-year) | **入れず、定性のみ** | 語数と構成の流れで不要と判断。入れるなら外挿注記込みで +30 words |
| 7 | FORMOSAT-9 | **Conclusion の地域文脈として 1 節** | 上記「注意 5」。台湾の聴衆へのフックは**ポスターセッションで口頭**にする方が効く (Syota さん判断) |
| 8 | タイトル | **現案維持** (21 words < 50) | "NISAR-Ready" 案は未実測なので誇大 risk |
| 9 | 発表形態 | **poster で確定** | 台湾の聴衆に顔と名前を売るのはポスターの口頭説明でやる (#7 と対) |
| 10 | upstream PR の置き場 | **References [7] + 本文半文** | テンプレの文書構造に Appendix の規定がない。売り込まず所在の透明性として扱う |
| 11 | affiliation | **Earthsea Wizard, Japan** | "(Independent Researcher)" を一度入れたが、公式文言「組織名 + 国名のみ」から外れるリスクを取らず撤回。個人事業であることは聞かれたら答える |
| 13 | 本文フォント | **newtx (TeX Gyre Termes) のまま** | 規定は Times New Roman だが Times 互換メトリックで実用上十分。厳格運用が判明したら XeLaTeX + fontspec に切替 (`tasti2026.sty` にコメント) |
| 12 | CholeskyQR2 の引用 | **¶2 に [3, 4] を追加** | 「Gram + Cholesky は GPU で有利」が突飛な発想でないことの裏付け。ただし**動機の支持まで** — 上記「注意 9」を厳守 |

## 図の実装メモ

- **Fig. 1** = [figures/fig1_batched_cholesky.svg](../figures/fig1_batched_cholesky.svg)。
  姉妹 repo `vrc-insar-batched-cholesky-LT` の `cholesky_batch.svg` を英語化 +
  $K$/$P$/$n$ の一般記号化 + **kernel launches 3,841,835 → 57 を図自体に載せて情報図化**。
  pdfLaTeX は SVG を読めないので `make` が `rsvg-convert -f pdf` を通す。
- **Fig. 2 相当** = [scripts/plot_speedup.py](../scripts/plot_speedup.py)。
  **抄録では使っていない** (表にしたため) が、ポスター/スライド用に残してある。
  `make figures` で生成。数値は S3 表から。
- 姉妹 repo の他の図 (`error_budget` / `assembly_as_gemm` / `condition_*` /
  `tall_skinny_matrix` / `qr_column_sweep`) は**ポスター向き**。全部日本語テキストが
  `<text>` 要素で入っているので、英語化は機械的にできる。

## References の方針

現行 7 件、本文の出現順 (テンプレ規定):

| # | 文献 | 出現 | 役割 |
| --- | --- | --- | --- |
| 1 | NISAR Science Users' Handbook | ¶1 | データ増の主因 |
| 2 | Yunjun+ 2019 — MintPy | ¶1 | 対象ソフトウェア |
| 3 | Yamamoto+ 2015 (ETNA 44:306–326) — CholeskyQR2 の丸め誤差解析 | ¶2 | **手法選択の妥当性** (注意 9) |
| 4 | Fukaya+ 2014 (METR 2014-37, 東大) — CholeskyQR2 の並列アルゴリズム | ¶2 | 同上 |
| 5 | Paszke+ 2019 — PyTorch | ¶2 | 実装基盤 |
| 6 | TASA FORMOSAT-9 mission page | ¶4 | 地域文脈。accessed 日付つき |
| 7 | insarlab/MintPy PR #1490 | ¶4 | 実装の所在。"under review" 明記 |

- 現物は `docs/` に置いてある (`ROUNDOFF ERROR ANALYSIS OF THE CHOLESKYQR2
  ALGORITHM.pdf` / `METR14-37.pdf`)。`.gitignore` が `*.pdf` を無視するので
  **git 管理外** — 必要なら再取得すること。
- `docs/Trefethen-Bau.pdf` (Numerical Linear Algebra) も置いてあるが**未引用**。
  正規方程式の条件数の一般論が要るときの参照用。抄録の references を増やす
  必要はないと判断した。
- 足すなら: Berardino+ 2002 (SBAS 原典, IEEE TGRS)。
- **sibling repo (mintpy-benchmark) にはリンクを張らない** — 将来 private 化の
  可能性があるため、数値は本文に焼き込む。upstream の insarlab/MintPy は消えないので
  こちらは引いてよい ([results.md](results.md) permalink 方針)。
