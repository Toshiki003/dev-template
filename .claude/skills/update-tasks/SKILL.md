---
name: update-tasks
description: 最新のレポートに基づいてタスクリストを更新
argument-hint:
allowed-tools: Read, Glob, Write
---

# タスクリスト更新

**重要**: ファイルを更新する際は、必ずファイル全体を出力してください。「...」で省略することは禁止です。

1. `claude-ext/prompts/outputs/` から最新の分析レポートを読み込む
2. `claude-ext/docs/tasklist.md` を以下のルールで更新:
   - 完了タスク: `- [ ]` → `- [x]`
   - 進行中: タスク名の後に `🚧` を追記
   - 新規タスク: レポートで発見された未記載タスクを追加

3. 更新サマリーを報告:
   - 完了にしたタスク数
   - 新規追加したタスク数
   - 次に着手すべきタスク
