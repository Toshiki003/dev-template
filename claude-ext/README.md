# Claude Extension Kit

Claude Codeとの協働を効率化するためのプロジェクト拡張キットです。

## クイックスタート

```bash
# セットアップ（初回のみ）
bash create-claude-ext.sh

# 要件定義を編集
# claude-ext/docs/requirements.md を開いてプロジェクト情報を記入
```

## 使い方（Claude Codeのスラッシュコマンド）

| コマンド | 説明 |
|---------|------|
| `/analyze` | リポジトリの実装状況を分析してレポート生成 |
| `/update-tasks` | 分析結果に基づいてタスクリストを更新 |
| `/create-requirements` | ソースコードから要件定義書を生成 |

## ディレクトリ構成

```
.claude/
├── CLAUDE.md           # プロジェクトルール（Claude が最初に読む）
├── settings.json       # 権限・環境設定
├── skills/             # カスタムスラッシュコマンド
│   ├── analyze/
│   ├── update-tasks/
│   └── create-requirements/
└── rules/              # モジュール化されたルール
    ├── commit.md
    └── security.md

claude-ext/
├── docs/
│   ├── requirements.md           # 要件定義書（最重要）
│   ├── tasklist.md               # タスク管理
│   ├── decision-log.md           # 意思決定ログ
│   └── analysis-repo-template.md # レポートテンプレート
└── prompts/
    └── outputs/                  # 生成されたレポート（Git除外）
```

## 開発フロー

1. **要件定義の作成**: `/create-requirements` または手動で `requirements.md` を編集
2. **タスク確認**: `/analyze` で現状把握
3. **実装**: Claudeと協力して機能を実装
4. **進捗更新**: `/update-tasks` でタスクリストを最新化

## カスタマイズ

### 環境変数でセットアップ時の設定を変更

```bash
# 英語プロジェクト
PROJECT_LANGUAGE=english bash create-claude-ext.sh

# 初心者向けペルソナを設定
USER_PERSONA="開発初心者" bash create-claude-ext.sh
```

### スキルの追加

`.claude/skills/<name>/SKILL.md` を作成すると、`/<name>` コマンドとして使用可能になります。

