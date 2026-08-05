# Abstract 執筆ノート — 主張→出典対応、表現上の注意、判断待ち事項

`abstract.tex` の現ドラフト (465 words) を推敲・更新するときの作業基準。

## 核心メッセージ (1 文)

> InSAR 時系列解析の最重ステップを正規方程式 + batched Cholesky で GPU 化し、
> **コンシューマ GPU 1 枚**で 5〜94× の高速化と数値一致 gate 通過を両立、
> NISAR 時代のデータ量に耐える処理を「クラスタなしで」手が届くものにした。

TASTI の聴衆 (宇宙科学・衛星技術・産業) に合わせて **NISAR / rapid response /
democratization** を前面に、条件数の数理は裏方に
([project_overview.md](project_overview.md) 参照)。

## 段落ごとの主張 → 出典対応表

### ¶1 Objective (背景とボトルネック)

| 主張 | 出典 / 裏付け |
| --- | --- |
| Sentinel-1 / NISAR でデータ量が処理能力を超えて伸びる | 一般論 + [compute_scale.md](compute_scale.md) の $D^3$ スケーリング |
| MintPy は最普及級の OSS SBAS ツール | Yunjun+ 2019 (ref [2]) |
| 網逆解析が smallbaselineApp の支配的ボトルネック | baseline 計測 43.5% ([results.md](results.md) 末尾表) |
| 目標: opt-in / CPU 挙動不変 / クラスタ不要 | PR #1490 設計 ([numerical_method.md](numerical_method.md) §4) |

### ¶2 Methodology

| 主張 | 出典 |
| --- | --- |
| per-pixel WLS → バッチ線形代数への再定式化 | [numerical_method.md](numerical_method.md) §1, §3 |
| normal equations + batched Cholesky, float32, chunk streaming | 同 §3-§4 |
| 単一 cfg key で opt-in、CPU 経路 byte-for-byte 不変 | 同 §4 |
| DEM-error correction への同一設計適用 | [results.md](results.md) correct_topography 節 |
| 数値 gate (正規化 RMS) で CPU 参照との一致を強制 | 同 S1/S3 |

### ¶3 Key results

| 主張 (ドラフトの文言) | 系列 | 値の出典 |
| --- | --- | --- |
| QR→Cholesky 置換で同一 GPU 上 16.5× / kernel launches 3.8M→57 | **S1** | [results.md](results.md) S1 表 |
| Galapagos 3.4M px × 475 ifgs: 6,189→170 s, 36.4× step / 44.4× kernel | **S2** | 同 S2 表 |
| 5 シーン (4 処理系 × 2 波長) で 5.3〜93.8× | **S3** | 同 S3 表 |
| VRAM 7.6 GB 以内 (16 GB カード) | — | 同 S2 注記 |
| DEM-error 6.15× (同一シーン) | — | 同 correct_topography 表 |
| 正規化 RMS ~1e-5 オーダー = float32 round-off | S1/S3 | 同 gate 節 |
| 18 step 完走 (E2E) | — | 同 末尾表 |

**⚠️ 系列混同の禁止**: 16.5× を CPU 比と書かない。44.4× と 16.5× を「規模で
伸びた」と連結しない。詳細は [results.md](results.md) 冒頭の警告。

### ¶4 Significance

| 主張 | 出典 / 注意 |
| --- | --- |
| 数時間→数分で rapid-response 監視が現実的に | S2/S3 実測 + [compute_scale.md](compute_scale.md) 外挿 |
| NISAR 時代のアーカイブにスケール | compute_scale の但し書き付き。定量を足すなら「〜minutes per frame-year (extrapolated)」形 |
| upstream に PR 済 (opt-in feature) | **PR #1490 は OPEN / review 待ち — 下記「表現上の注意」参照** |
| bench harness / report は公開・再現可能 | mintpy-benchmark (ただし本文にリンクは張らない — [results.md](results.md) permalink 方針) |
| コンシューマ GPU で参入障壁を下げる | RTX 5080 実測そのもの |

## 表現上の注意 (毎回チェック)

1. **PR の状態と時制**: 現ドラフトは "has been submitted upstream ... as an
   opt-in feature" (= 事実)。**merged と書いてはいけない**。毎セッション
   `gh pr view 1490 --repo insarlab/MintPy --json state` で確認し、merge されたら
   "has been merged into MintPy vX.Y" に更新。閉じられた場合の表現も要検討。
2. **"kernel-level" vs "step-level"**: internal / step wall の 2 数字を並記する
   ときは必ず修飾語を付ける (44.4× kernel-level / 36.4× step-level)。
3. **外挿と実測の区別**: NISAR の数字を本文に入れる場合は "extrapolated from
   measured throughput" を必ず添える。
4. **著者表記**: フルネーム、肩書きなし、発表者 *。affiliation は
   「Earthsea Wizard, Japan」— **屋号の英字表記は Syota さん確認待ち**。
5. **謝辞なし**: テンプレに acknowledgment 節の規定なし。JAXA 共同研究等への
   言及は不要 (本件は独立の OSS 貢献)。

## 判断待ち事項 (Syota さん)

| # | 論点 | 選択肢 | 華扇の推し |
| --- | --- | --- | --- |
| 1 | トラック | 0201 EO/Remote Sensing vs 0204 Disaster Management | **0201**。手法貢献が主で、防災は応用例。0204 は応用実証 (実イベント解析) が主戦場になりがちで、本件はまだ処理基盤の話 |
| 2 | 図の有無 | なし / S3 の 5 シーン speedup bar chart 1 枚 | **入れる**。800 words 上限に余裕 (現 465) があり、5〜94× のレンジは表より図が伝わる。データは results.md S3 表から生成 |
| 3 | NISAR 定量 | 定性のみ / 「frame-year が数分」を 1 文追加 | **追加**。宇宙学会なので NISAR の具体数字は強い。外挿注記込みで +30 words 程度 |
| 4 | タイトル | 現案 "Accelerating Open-Source InSAR Time-Series Analysis on Consumer GPUs: A PyTorch-Based Network Inversion Solver for MintPy" | 現案維持で可 (21 words < 50)。"NISAR-Ready" を入れる案もあるが未実測なので誇大risk |
| 5 | 発表形態 | oral / poster の希望欄が提出時にあるか不明 | 提出システムで確認 |

## 図を入れる場合の仕様メモ

- 横棒グラフ: 5 シーン × speedup (log スケール推奨、5.3〜93.8 の 1 桁半)。
  ラベルにシーン名 + (processor / band / K / D)。
- キャプションは**図の下** ([submission_requirements.md](submission_requirements.md))。
  "Step-level speedup of the torch solver over the CPU path, measured end-to-end
  on five public Zenodo scenes (four processors, two wavelengths)."
- 埋め込みは PDF (ベクタ) を `\includegraphics`。10 MB 上限は問題にならない。
- 生成スクリプトはこの repo に `scripts/plot_speedup.py` として置く (matplotlib、
  数値は results.md S3 表をハードコードで可 — 出典 commit を docstring に記載)。

## References の方針

- 現行 3 件: NISAR handbook / Yunjun+ 2019 (MintPy) / Paszke+ 2019 (PyTorch)。
- 足すなら: Berardino+ 2002 (SBAS 原典, IEEE TGRS) — ¶1 の SBAS 言及の格上げ用。
- テンプレ規定は「出現順の番号 + 角括弧引用」のみ。現ドラフト準拠済み。
