# 申し送り — TASTI 2026 アブストラクト作成

作成日: 2026-08-06 / 作成: 華扇 (Claude Code session @ MintPy fork repo)

## ⚠️ 最重要: 締切

**Abstract submission deadline: 2026-08-15** — この repo 作成時点で**残り 9 日**。
PDF アップロード (≤ 10 MB)、TASTI conference submission system 経由。

## 1. 目的

[insarlab/MintPy#1490](https://github.com/insarlab/MintPy/pull/1490) の成果
(MintPy の PyTorch GPU solver) を TASTI 2026 に extended abstract として投稿する。

- 学会: TASTI 2026 (Taiwan International Assembly of Space Science, Technology, and Industry)
- 会期: 2026-11-08 〜 11-11、International Convention Center, Tainan, Taiwan
- CfP: <https://tasti2026.conf.tw/site/page53.aspx?pid=901&sid=1691&lang=en>
- トラック候補: **0201 Earth Observation and Remote Sensing** または
  **0204 Climate Monitoring, Disaster Management, and Sustainability Applications**
  (どちらに出すかは Syota さんの判断待ち)

## 2. PR #1490 の現況と主要数値 (abstract の素材)

- **PR**: [insarlab/MintPy#1490](https://github.com/insarlab/MintPy/pull/1490)
  "Add opt-in torch GPU solver for invert_network" — **OPEN / maintainer review 待ち**
  (最終更新 2026-07-16、reviewDecision: REVIEW_REQUIRED)。RFC は
  [#1489](https://github.com/insarlab/MintPy/issues/1489)。
- **手法**: per-pixel lstsq → normal equations + batched Cholesky (float32, PyTorch)、
  VRAM に合わせた chunk streaming。opt-in cfg key `mintpy.networkInversion.solver = torch`、
  CPU 経路は byte-for-byte 不変。`src/mintpy/gpu/` subpackage に分離。
- **ハードウェア**: NVIDIA RTX 5080 (16 GB, Blackwell sm_120)、PyTorch cu128。
- **数値 (すべて bench report で裏取り済み)**:
  - Fernandina (Sentinel-1 tutorial): internal **16.5×** / step wall 4.49×、
    normalized RMS max 1.19e-5 (gate < 1e-4 通過)
  - Galapagos large scene (3.4 M pixels × 475 ifgs): step wall **36.4×** /
    internal **44.4×** (6,189 s → 170.06 s)、VRAM peak 7.6 GiB
  - 5-scene sweep: **5.24–93.77×** (invert_network 単独、report commit `0fbf71b`)
  - correct_topography (DEM error): Galapagos **6.15×** (163.83 s → 26.66 s)
  - E2E: smallbaselineApp 全 18 step を solver=torch で完走確認済み
- **Bench 出典**: [mintpy-benchmark](https://github.com/s-sasaki-earthsea-wizard/mintpy-benchmark)
  `reports/` 配下 (report_torch.md / report_large_scene.md ほか)。abstract に数値を足すときは
  必ずここから引く。

## 3. この repo の状態 (v0.1 skeleton)

- `abstract.tex` — ドラフト一式 (題目 / 著者 / keywords / 本文 4 段落 / references 3 件)。
  **本文 465 words** (規定 300–800、`make wordcount` で再計測可)。
- `tasti2026.sty` — 公式テンプレの LaTeX 再現。実装済み: A4 / margins 上下 2.54 cm・
  左右 3.17 cm / 10.5 pt / single spacing / parskip 段落 / footer "TASTI-2026" /
  title-block 用マクロ (`\abstracttitle` `\abstractauthors` `\abstractaffil`
  `\abstractemail` `\abstractkeywords` `\affmark`)。
- `template/TASTI2026_Abstract_Template_0410.pdf` — 公式テンプレの参照コピー。
  **元の docx はこの repo には無い** (MintPy fork 側にも PDF しか無かった)。
  docx を入手したら `template/` に追加してスタイルの目視比較をすること。

## 4. 残タスク (向こうの repo での作業)

1. **コンパイル確認** — 開発機 (Ubuntu) に TeX が未導入だったため **一度もビルドしていない**。
   `sudo apt-get install texlive-latex-extra texlive-fonts-extra latexmk && make`。
   コンパイルエラーが出たらまず sty の `\abstracttitle` 系マクロを疑うこと。
2. **スタイル微調整** — 公式 PDF と並べて目視比較。既知の近似:
   - フォントは newtx (Times 互換メトリック)。真の Times New Roman が要るなら
     XeLaTeX + fontspec に切替 (sty 内にコメントあり)
   - タイトル 14 pt はサンプル PDF からの目測。docx で要確認
   - title-block 間の余白 (`\vspace{-\parskip}` で詰めてある) の調整
3. **本文の推敲** — 数値・主張のトーン確認。特に "submitted upstream" の表現は
   PR が **merge 前** であることと整合させておくこと (merge されたら書き換え)。
4. **著者情報の確定** — 現状 `Syota Sasaki*, 1) Earthsea Wizard, Japan` としてある。
   affiliation の英字表記 (屋号をどう出すか) は Syota さんの確認が必要。
5. **references の体裁確認** — テンプレは番号付き `[1]` 形式のみ規定。現状
   `thebibliography` で 3 件 (NISAR handbook / Yunjun 2019 / PyTorch NeurIPS)。
6. **図の要否判断** — テンプレ上は任意。speedup bar chart (5-scene sweep) を 1 枚
   入れると説得力が出るが、words とページ体裁次第。データは mintpy-benchmark の
   report から再生成可能。
7. **提出** — PDF 化して submission system にアップロード (≤ 10 MB)。

## 5. 運用メモ

- コミットは英語・動詞始まり。この repo は MintPy fork の運用ルール
  (upstream style) ではなく通常の Syota さん流でよい。
- MintPy fork 側の進捗管理は fork の `CLAUDE.md` と memory が正。この repo からは
  PR #1490 の状態を毎セッション `gh pr view 1490 --repo insarlab/MintPy` で確認してから
  作業に入ること (merge されたら本文表現の更新が必要になるため)。
