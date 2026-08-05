# プロジェクト概要

**MintPy の PyTorch GPU solver (insarlab/MintPy#1490) を TASTI 2026 に extended
abstract として投稿する**ためのリポジトリ。

## 何を投稿するか

人工衛星 SAR の干渉解析 (InSAR) で地表変位の時系列を復元する **SBAS 法**は、
その内側でピクセルごとの重み付き最小二乗 (WLS) を数百万回解いている。
標準的な InSAR 解析ツール MintPy の GPU 化フォークで、この per-pixel ソルブを
`scipy.linalg.lstsq` (QR/SVD 系) から**正規方程式 + バッチ Cholesky** (PyTorch,
float32) に書き換えて CUDA 上で一括処理し、コンシューマ GPU 1 枚で
order-of-magnitude の高速化を得た。実装は upstream に PR 済
([insarlab/MintPy#1490](https://github.com/insarlab/MintPy/pull/1490)、OPEN /
review 待ち)。

- 元プロジェクト (MintPy GPU 化フォーク): <https://github.com/s-sasaki-earthsea-wizard/MintPy>
- ベンチ資産 (sibling): <https://github.com/s-sasaki-earthsea-wizard/mintpy-benchmark>
- MintPy upstream: <https://github.com/insarlab/MintPy>

## 投稿先と聴衆 (学会の文脈)

- **TASTI 2026** — Taiwan International Assembly of Space Science, Technology,
  and Industry。2026-11-08〜11、International Convention Center, Tainan, Taiwan。
- CfP: <https://tasti2026.conf.tw/site/page53.aspx?pid=901&sid=1691&lang=en>
- トラック候補: **0201 Earth Observation and Remote Sensing** /
  **0204 Climate Monitoring, Disaster Management, and Sustainability Applications**
- 聴衆は**宇宙科学・衛星技術・産業応用**の国際コミュニティ。数値線形代数の
  専門家ではない。したがって主役は:
  1. **NISAR 時代のデータ量問題** — 処理スループットが取得速度に追いつかない
  2. **コンシューマ GPU 1 枚で 5〜94×** — HPC クラスタ不要、防災実務者にも手が届く
  3. **正しさの担保** — 速いだけでなく数値一致 gate を 5 シーンで通過
- 条件数の議論 (正規方程式の但し書き) は**裏方**に回す。Q&A で聞かれたら答え
  られる程度に [numerical_method.md](numerical_method.md) で押さえておく。

## sibling 資料との関係

同じ題材を**数値線形代数フォーカス**で語る VRChat 数学談話会 LT 用リポジトリが
既にある: [vrc-insar-batched-cholesky-LT](https://github.com/s-sasaki-earthsea-wizard/vrc-insar-batched-cholesky-LT)。
本リポジトリの docs はそこの docs を **TASTI の聴衆向けに再構成**したもの。
数学的な深掘り (条件数二乗の議論の完全版、FLOP 勘定の導出) は向こうが正。
ただし向こうの repo の将来の可視性に依存しないよう、abstract の主張に必要な
数値・論拠は**本リポジトリの docs に自己完結**させてある。

## 結論先取り (abstract の骨子)

- **問題**: MintPy の `invert_network` (網逆解析) が end-to-end 実行時間の
  43.5% を占めるボトルネック。Sentinel-1 / NISAR のデータ増に CPU 処理が
  追いつかない。
- **手法**: per-pixel WLS を正規方程式 $G^\top W G\,x = G^\top W d$ に直し、
  SPD 性を使って **batched Cholesky** (PyTorch, float32) で一括ソルブ。
  opt-in 設計 (`mintpy.networkInversion.solver = torch`)、CPU 経路は不変。
- **結果**: 同一 GPU の QR 比 **16.5×** (アルゴリズム置換の寄与)、Galapagos
  大シーンで CPU 比 internal **44.4×** / step wall **36.4×**、5 シーン
  end-to-end で **5.3〜93.8×**。数値一致 gate 5/5 通過。DEM 残差推定にも
  同じコアを再利用して **6.2×**。
- **意義**: 数時間の逆解析が分オーダーに。火山・地震の rapid response、
  NISAR 時代の国土規模監視を、コンシューマ機材で。

## ドキュメント構成

| doc | 中身 |
| --- | --- |
| [submission_requirements.md](submission_requirements.md) | テンプレ要件・締切・提出手順の完全版 |
| [numerical_method.md](numerical_method.md) | 手法の数理 (WLS / 正規方程式 / Cholesky / 条件数) + 実装の要点 |
| [results.md](results.md) | ベンチ数値の正典。**数字の系列の混同禁止事項**を含む |
| [compute_scale.md](compute_scale.md) | NISAR スケール外挿 — abstract の「意義」段落の裏付け |
| [abstract_notes.md](abstract_notes.md) | 段落ごとの主張→出典対応表、表現上の注意、図の候補 |
