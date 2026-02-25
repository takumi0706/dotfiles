# Context Analysis Template

> Use this template to record the analysis results for each bounded context.
> Save as `<project>/docs/ddd/contexts/<context-name>.md`.

---

## メタ情報

| 項目 | 内容 |
|------|------|
| コンテキスト名 | |
| 分析日 | |
| ステータス | Draft / Review / Approved |
| 責任チーム | |

## アクター

| アクター | 役割 | 主要な目的 |
|----------|------|------------|
| | | |

## ユビキタス言語

| 用語 | このコンテキストでの定義 | 他コンテキストとの違い |
|------|--------------------------|------------------------|
| | | |

## ビジネスルール

| ID | ルール | 条件 | 結果 |
|----|--------|------|------|
| BR-001 | | | |

## 主要モデル

### エンティティ

| 名前 | 説明 | 主要な属性 | 主要な振る舞い |
|------|------|------------|----------------|
| | | | |

### 値オブジェクト

| 名前 | 説明 | 属性 | 不変条件 |
|------|------|------|----------|
| | | | |

### ドメインイベント

| 名前 | トリガー | ペイロード | 購読者 |
|------|----------|------------|--------|
| | | | |

## コンテキスト間関係

| 相手コンテキスト | 関係の方向 | 統合パターン | 共有データ |
|------------------|------------|--------------|------------|
| | upstream / downstream | | |

## 言語ゲーム分析メモ

### このコンテキスト特有の用語の使われ方

> Describe how terms are used in the specific "game" of this context.
> If the same term has different meanings in other contexts, document the differences.

```
用語「___」について:
- アクター「___」が「___」の目的で使うとき、この用語は「___」を意味する
- 適用されるルール: ___
- 他のコンテキストでの意味との違い: ___
```

### 境界の根拠

> Document why this scope was carved out as a single context.
> Explain from the perspectives of actor purposes, rule consistency, and term semantic coherence.
