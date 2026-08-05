# 提出要件 — TASTI 2026 extended abstract

出典: `template/TASTI2026_Abstract_Template_0410.pdf` (公式テンプレ、
"A Guideline for Contributors to TASTI 2026") + CfP ページ
(<https://tasti2026.conf.tw/site/page53.aspx?pid=901&sid=1691&lang=en>)。

## 締切と提出方法

| 項目 | 値 |
| --- | --- |
| **提出締切** | **2026-08-15** |
| 提出形式 | **PDF** (TASTI conference submission system にアップロード) |
| ファイルサイズ | **≤ 10 MB** |
| 言語 | 英語 |
| 分量 | **本文 300〜800 words** (最小 300 は必須要件) |
| 査読 | TASTI Program Committee が採否とセッション割当を審査 |
| 採択後 | 会議 web サイトで参加者に公開される |
| 会期 | 2026-11-08 〜 11-11、International Convention Center, Tainan, Taiwan |

> 提出システムのアカウント作成・投稿操作は Syota さんの手作業。トラック選択
> (0201 vs 0204) も提出時に必要になる見込み → [abstract_notes.md](abstract_notes.md) §トラック選択。

## 書式要件 (テンプレの "Formatting Requirements")

| 項目 | 要件 | `tasti2026.sty` での実装 |
| --- | --- | --- |
| 用紙 | A4 | `geometry` a4paper |
| 段組 | 1 段組 | article 既定 |
| 余白 上下 | 2.54 cm | `top=2.54cm,bottom=2.54cm` |
| 余白 左右 | 3.17 cm | `left=3.17cm,right=3.17cm` |
| フォント | Times New Roman | `newtxtext`/`newtxmath` (Times 互換)。真の TNR は XeLaTeX + fontspec (sty 内コメント参照) |
| サイズ | 10.5 pt | `\normalsize` を 10.5/12.6 pt に再定義 |
| 行間 | Single | baseline 1.2x (12.6 pt) |
| フッタ | "TASTI-2026" (サンプル PDF より) | `fancyhdr` 左下 |

## 文書構造 (この順で)

1. Paper Title
2. Authors
3. Affiliations
4. Keywords
5. Abstract Text
6. References (該当する場合)

## 各要素の規則

### Title
- **Title case、bold、中央揃え**。50 words 以内。
- サンプル PDF では本文より大きい (目測 ~14 pt)。テンプレ文書は太字・中央のみ
  規定でサイズ未規定 → sty は 14 pt にしてある。docx 入手時に要確認。

### Authors
- **フルネーム** (first + last)、カンマ区切り、中央揃え。
- **発表者にアスタリスク (*)**。Prof./Dr. などの肩書きは**書かない**。
- 推奨は 8 名以内。超えるなら "et al." 可。
- 所属番号は上付き `1)` 形式 (サンプルより)。sty の `\affmark{*,1}`。

### Affiliations
- 著者行の**直後の行、空行なし**。**イタリック、中央揃え**。
- **組織名 + 国名のみ**。詳細住所は不要。
- 発表者のメールアドレスは次の行に**イタリック + 下線**で置いてよい。

### Keywords
- **最大 5 個**。"keywords" は bold (サンプルより)。

### Abstract Text
- キーワード行の後、**空行 1 つ**おいて本文開始。
- **"Abstract" という見出しは書かない**。
- 段落は**空行で区切り、字下げしない**。
- 内容要件: **objective, methodology, key results, significance** を明示的に
  含むこと (テンプレ本文の指示)。

### Figures / Tables / Equations
- 図表は任意。**図は高解像度で文書内に埋め込み**。
- 図キャプションは**図の下**、表キャプションは**表の上**。
- 数式は `(1)` 形式で連番。

### References
- 末尾に、**本文での出現順**に番号付きで列挙。
- 本文中の引用は角括弧 `[1]`。

## 提出前チェックリスト

- [ ] `make wordcount` で本文 300〜800 words
- [ ] タイトル 50 words 以内、title case
- [ ] 発表者 * / 肩書きなし / affiliation は組織名 + 国名のみ
- [ ] keywords ≤ 5
- [ ] "Abstract" 見出しが無いこと
- [ ] objective / methodology / key results / significance が全部読み取れること
- [ ] 数値の系列が正しいこと ([results.md](results.md) の禁止事項に照合)
- [ ] "submitted upstream (under review)" 表現が PR #1490 の**現在の状態**と一致
      (`gh pr view 1490 --repo insarlab/MintPy`)
- [ ] 図を入れた場合: キャプション位置・解像度・PDF ≤ 10 MB
- [ ] pdfLaTeX でエラー・警告 (overfull 含む) を確認
- [ ] 公式 PDF テンプレと並べて目視比較 (タイトルサイズ・ブロック間余白)
