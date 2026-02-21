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

## 参照
- @claude-ext/docs/requirements.md - 要件定義
- @claude-ext/docs/tasklist.md - タスクリスト
