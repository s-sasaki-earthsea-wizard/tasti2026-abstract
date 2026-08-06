# 申し送り — TASTI 2026 アブストラクト作成

最終更新: 2026-08-06 / 華扇 (Claude Code)

> **詳細資料は [docs/](docs/) にある** ([project_overview.md](docs/project_overview.md)
> から辿れる)。数値を触るときは必ず [docs/results.md](docs/results.md)
> (系列混同の禁止事項) を、本文を触るときは
> [docs/abstract_notes.md](docs/abstract_notes.md) (表現上の注意 8 項目) を先に読むこと。

## ⚠️ 最重要: 締切

**Abstract submission deadline: 2026-08-15** — 本日 2026-08-06 時点で**残り 9 日**。
PDF アップロード (≤ 10 MB)、TASTI conference submission system 経由。

## 1. 目的

[insarlab/MintPy#1490](https://github.com/insarlab/MintPy/pull/1490) の成果
(MintPy の PyTorch GPU solver) を TASTI 2026 に extended abstract として投稿する。

- 学会: TASTI 2026 (Taiwan International Assembly of Space Science, Technology, and Industry)
- 会期: 2026-11-08 〜 11-11、International Convention Center, Tainan, Taiwan
- CfP: <https://tasti2026.conf.tw/site/page53.aspx?pid=901&sid=1691&lang=en>
- トラック: **0201 Earth Observation and Remote Sensing** 推し (提出時に選択、未確定)

## 2. 現在の状態 — **本文完成、ビルド通過**

| 項目 | 状態 |
| --- | --- |
| 本文 | **665 words** (規定 300–800、`make wordcount` で再計測) |
| short abstract | **199 words** (規定 ≤ 200、`make shortcount` で再計測)。[short_abstract.md](short_abstract.md) — 提出フォームに直接入力する |
| ページ数 | **2 ページ** |
| 図表 | **Fig. 1** (手法の模式図) + **Table 1** (5 シーン実測) |
| ビルド | `make` で通過。**Overfull / Underfull ボックス 0 件** |
| References | 7 件 (出現順) |
| トラック / 発表形態 | **0201 Earth Observation and Remote Sensing / poster** |
| チームレビュー | カラスノエンドウ・ルスダン両名が通読、**指摘は全て反映済み** |
| 提出前チェックリスト | **2026-08-06 時点で全項目通過** (下記 §4-2 参照) |

### 本文の構成

¶1 Objective / ¶2 Methodology (+Fig. 1) / ¶3a **Speedup.** (+Table 1) /
¶3b **Numerical validation.** / ¶4 Conclusion + Significance

3a・3b はランイン見出し (段落頭の太字) で speedup と validation を並列に見せている。
テンプレPDF 自身が太字見出しを使っており、禁止されているのは "Abstract" 見出しのみ。

### この構成に至った判断 (全部 [docs/abstract_notes.md](docs/abstract_notes.md) §判断の記録 に記載)

チーム tasti2026 (華扇 / カラスノエンドウ / ルスダン) で検討した結果:

- **S3 の 5 シーンは図でなく表**。「規模が大きいほど恩恵が大きい」は**実データで成立しない**
  (speedup とピクセル数の順位相関 **−0.20**、per-pixel 演算密度とは **+0.00**)。
  bar chart にすると順序のバラつきが目立つ。表なら external validity を淡々と示せる。
  → [docs/results.md](docs/results.md) の該当記述は 2026-08-06 に訂正済み。
- **⚠️ 抄録中の speedup は全て CPU 比に統一**。一度は 16.5× (同一 GPU の
  QR → Cholesky) を本文 + キャプションに置いたが、**基準が 2 つあると初読者が
  混乱する**ため撤去した。統一後の対比の方が強い: GPU に載せただけで CPU 比
  **1.43×** → 正規方程式 + Cholesky で CPU 比 **36.4× / 44.4×**。
  同一基準のまま「ボトルネックはハードウェアでなく問題の形」を言い切れる。
  **16.5× を本文に戻さないこと** ([docs/abstract_notes.md](docs/abstract_notes.md) 注意 2)。
- **FORMOSAT-9 は Conclusion の地域文脈のみ**。分解能の数字は書かない
  (1 m 未満はスポットライトの値、InSAR 時系列で使う stripmap は 3 m 級)。
  台湾の聴衆へのフックは**ポスターセッションで口頭**にする方が効く。
- **誤差バジェット図は不採用**。主張は本文 1 文で閉じるのに、図にすると
  中間生成物の発散 (マスク領域) まで説明責任が広がる。
- **CholeskyQR2 の 2 件 [3, 4] を ¶2 に引用**。「Gram 行列 + Cholesky が GPU で
  有利」が突飛な発想でないことの裏付け。ただし**引けるのは動機の支持まで** —
  CholeskyQR2 は QR を得る手法で 2 回反復するが、本実装は正規方程式を直接解いて
  反復しない。「同じだから安全」とは書けない
  ([docs/abstract_notes.md](docs/abstract_notes.md) 注意 9)。

## 3. リポジトリ構成

```text
abstract.tex          本文 (% BODY-START / % BODY-END で wordcount 範囲を画定)
short_abstract.md     提出フォーム用 short abstract (≤ 200 words) + 取捨選択の根拠
tasti2026.sty         公式テンプレの LaTeX 再現
Makefile              make / make figures / make wordcount / make clean
figures/
  fig1_batched_cholesky.svg   Fig. 1 のソース (手書き SVG)
  fig1_batched_cholesky.pdf   ↑ の変換結果 (make が生成、git 管理外)
  fig2_speedup.pdf            ポスター用。抄録では未使用 (make figures で生成)
scripts/plot_speedup.py       Fig. 2 相当の生成スクリプト (S3 表から)
docs/                 詳細資料 6 本
template/             公式テンプレ PDF
```

- **Fig. 1 の出自**: 姉妹 repo `vrc-insar-batched-cholesky-LT` の `cholesky_batch.svg` を
  英語化 + $K$/$P$/$n$ の一般記号化 + kernel launches (3,841,835 → 57) を図に載せて情報図化。
- **pdfLaTeX は SVG を読めない**ので `make` が `rsvg-convert -f pdf` を通す。
  `rsvg-convert` (librsvg) が必要 — `brew install librsvg`。
- `scripts/plot_speedup.py` は matplotlib。抄録では使わないが、
  **ポスター用リポジトリを作るときにここから pull すればよい**。

## 4. 残タスク

1. ~~コミット~~ — **完了** (2026-08-06、`f67531f`〜`7ad3f6b`)。`origin/main` に push 済み。
2. **提出前チェックリスト** ([docs/submission_requirements.md](docs/submission_requirements.md) 末尾)
   — 2026-08-06 に全項目通過を確認済み。本文 670 words / title 15 words /
   keywords 5 / affiliation = 組織名 + 国名 / "Abstract" 見出しなし /
   図キャプション下・表キャプション上 / 引用番号 1–7 が出現順 / bibitem 7 件 /
   Overfull・Underfull 0 件 / PDF 180 KB。
   **本文を編集したら再実行すること**。
3. **⚠️ 抄録の内容は 2026-08-06 時点の情報で凍結** (Syota さん判断)
   - PR #1490 は 2026-08-06 時点で **OPEN / REVIEW_REQUIRED** (最終更新 2026-07-16)。
     本文の "has been submitted for upstream review" はこの状態と一致している。
   - **会期 (2026-11) までに merge 等の動きがあっても抄録は追わない**。抄録は
     「投稿時点のスナップショット」として扱う。
   - 更新分・新しい結果は**ポスター側に書く**。ポスターまでには S1 系列や
     DEM 補正、姉妹 repo の図など、抄録で落としたものを載せる余地がある。
4. **公式テンプレとの比較** — 目視でなく `pdftotext -bbox-layout` で実測して
   合わせ込み済み ([docs/submission_requirements.md](docs/submission_requirements.md)
   §公式サンプル PDF との実測比較)。タイトルブロックは 184 pt → 99.9 pt に圧縮。
   本文行送りは意図的に 12.6 pt (テンプレ実測 15 pt) のまま。
   フォントは newtx (TeX Gyre Termes、Times 互換メトリック) を維持する判断
   (Syota さん)。真の Times New Roman が要るなら XeLaTeX + fontspec に切替
   (sty 内にコメントあり)。
5. **提出** — PDF を submission system にアップロード (≤ 10 MB。現状 ~180 KB で余裕)

## 5. 運用メモ

- コミットは英語・動詞始まり。この repo は MintPy fork の運用ルール (upstream style)
  ではなく通常の Syota さん流でよい。
- `.gitignore` が `*.pdf` を無視するので、`abstract.pdf` と `figures/*.pdf` は
  git 管理外。`make` で再現できる。
- MintPy fork 側の進捗管理は fork の `CLAUDE.md` と memory が正。
- agmsg のチーム **tasti2026** に 3 人 (華扇 / カラスノエンドウ / ルスダン) が参加済み。
  このプロジェクトの配信モードは `monitor`。
