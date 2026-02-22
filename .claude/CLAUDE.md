# Project Rules

## Start-up Protocol
- **最優先**: 作業開始前に `claude-ext/docs/requirements.md` を読み、3〜7行で要約して提示すること
- **実行ガード**: 上記ファイルが存在しない場合、いかなる変更も行わずユーザーに作成を依頼すること

## 基本方針
- **言語**: japaneseで応対



## 開発ルール
- **コンテキスト管理**: 重要な進捗・決定事項は `claude-ext/docs/` に記録
- **機密情報**: APIキー等を含むファイル作成時は即座に `.gitignore` へ追記
- **意思決定記録**: 仕様変更は `claude-ext/docs/decision-log.md` に追記

## コミット規約
- 1行の日本語で簡潔に（例: `feat: ログイン機能の実装`）
- タイプ: `feat` / `fix` / `docs` / `refactor` / `test` / `chore`

## スキル（スラッシュコマンド）

### `/implement-next` — タスク自動実装
`tasklist.md` から次の未着手タスクを取得し、ブランチ作成→実装→PR作成まで一括実行する。

### `/fix-review` — レビュー指摘修正
現在ブランチのPRレビューコメントを取得し、自動修正してプッシュする。

### その他のスキル
- `/analyze` — リポジトリの実装状況を分析してレポート生成
- `/update-tasks` — 最新レポートに基づいてタスクリスト更新
- `/create-requirements` — ソースコードから要件定義書を生成

## 推奨開発フロー

1. `requirements.md` に要件を記載
2. `tasklist.md` にタスクを定義（または `/analyze` → `/update-tasks` で自動生成）
3. `/implement-next` でタスクを実装・PR作成
4. AIレビュー（Codex）またはチームレビューを受ける
5. `/fix-review` でレビュー指摘を修正
6. マージ → 次のタスクへ

## スクリプト

| スクリプト | 用途 |
|-----------|------|
| `scripts/pr.sh "タイトル"` | フィーチャーブランチ作成 |
| `scripts/pr-finish.sh "タイトル"` | コミット→Push→PR作成 |

`pr-finish.sh` はタイトルプレフィックス（`feat:` / `fix:` 等）からラベルを自動判定し、`ai-review` ラベルも付与する。

## 手動フォールバック
Claude Code / Codex が利用できない場合でも、上記スクリプトとGitHub CI（CodeQL、dependency-review等）は動作する。詳細は `claude-ext/docs/manual-workflow.md` を参照。

## 参照
- @claude-ext/docs/requirements.md - 要件定義
- @claude-ext/docs/tasklist.md - タスクリスト
- @claude-ext/docs/manual-workflow.md - 手動ワークフロー手順書
