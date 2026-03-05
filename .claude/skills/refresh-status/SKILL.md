---
name: refresh-status
description: mainを最新化し、実装状況を分析してタスクリストを更新（/sync-main + /analyze + /update-tasks）
argument-hint:
allowed-tools: Read, Glob, Grep, Write, Bash, Edit
---

# mainブランチ同期 → 分析 → タスクリスト更新

`/sync-main` → `/analyze` → `/update-tasks` を連続実行します。

---

## ステップ 1: mainブランチの同期（/sync-main 相当）

1. `git checkout main` でmainブランチに切り替える
2. `git pull` でリモートの最新を取得する
3. 結果を報告する（取得したコミット数、現在の状態）

---

## ステップ 2: 現状分析レポートの生成（/analyze 相当）

1. **テンプレート読み込み**: `claude-ext/docs/analysis-repo-template.md` を読む
2. **効率的な調査**:
   - `git ls-files` コマンドを使用して、Git管理下のファイルのみ構造を把握する（`node_modules`などを除外するため）
   - または `tree -I 'node_modules|dist|.git'` を使用する
   - 必要な箇所のみ `grep` で詳細確認
3. **レポート出力**:
   - パス: `claude-ext/prompts/outputs/analysis-{{YYYYMMDD-HHmmss}}.md`
   - テンプレートの構造を維持

**注意**: コンテキスト節約のため、無関係なファイルの読み込みは避けてください。

---

## ステップ 3: タスクリスト更新（/update-tasks 相当）

**重要**: ファイルを更新する際は、必ずファイル全体を出力してください。「...」で省略することは禁止です。

1. ステップ2で生成したレポートを使用する（再読み込み不要）
2. デフォルトで `docs/app-tasklist.md` を更新する
3. `app-tasklist.md` が存在しない場合は `claude-ext/docs/template-tasklist.md` を更新する
4. 更新ルール:
   - 完了タスク: `- [ ]` → `- [x]`
   - 進行中: タスク名の後に `🚧` を追記
   - 新規タスク: レポートで発見された未記載タスクを追加

5. 更新サマリーを報告:
   - 完了にしたタスク数
   - 新規追加したタスク数
   - 次に着手すべきタスク
