#!/bin/bash
set -e

# ============================================================
# Claude Extension Kit - セットアップスクリプト
# 既存リポジトリにClaude Code連携機能を追加
# ============================================================

VERSION="2.0.0"

# ============================================================
# 設定: 色定義（POSIX互換）
# ============================================================
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
GRAY='\033[0;90m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# デフォルト設定（環境変数で上書き可能）
PROJECT_LANGUAGE="${PROJECT_LANGUAGE:-japanese}"
USER_PERSONA="${USER_PERSONA:-}"
ENABLE_AWS="${ENABLE_AWS:-false}"
DRY_RUN=false
VERBOSE=false

# ============================================================
# ヘルプメッセージ
# ============================================================
show_help() {
    cat << 'HELP'
Claude Extension Kit - 既存リポジトリにClaude Code連携機能を追加

使い方:
  bash create-claude-ext.sh [オプション]

オプション:
  -h, --help          このヘルプを表示
  -v, --version       バージョンを表示
  -n, --dry-run       実際にはファイルを作成せず、何が行われるかを表示
  --verbose           詳細なログを出力

環境変数:
  PROJECT_LANGUAGE    Claude応答の言語 (default: japanese)
  USER_PERSONA        ユーザーペルソナの説明 (空の場合は汎用設定)
  ENABLE_AWS          AWS関連の設定を含める (default: false)

例:
  # 基本的な使用方法
  bash create-claude-ext.sh

  # ドライランで確認
  bash create-claude-ext.sh --dry-run

  # 英語プロジェクト向け
  PROJECT_LANGUAGE=english bash create-claude-ext.sh

  # 初心者向けペルソナを設定
  USER_PERSONA="開発初心者。専門用語は噛み砕いて説明する" bash create-claude-ext.sh
HELP
}


if [ ! -d ".git" ]; then
    printf "${YELLOW}[WARN] .git ディレクトリが見つかりません。Gitリポジトリルートで実行することを推奨します。${NC}\n"
    # 強制終了
    exit 1
fi

# ============================================================
# 引数パース
# ============================================================
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            echo "Claude Extension Kit v${VERSION}"
            exit 0
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        *)
            echo "不明なオプション: $1"
            echo "ヘルプを表示するには: bash create-claude-ext.sh --help"
            exit 1
            ;;
    esac
done

# ============================================================
# ユーティリティ関数
# ============================================================

log_info() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

log_create() {
    printf "${GREEN}[CREATE]${NC} %s\n" "$1"
}

log_skip() {
    printf "${YELLOW}[SKIP]${NC} %s\n" "$1"
}

log_config() {
    printf "${GREEN}[CONFIG]${NC} %s\n" "$1"
}

log_dryrun() {
    printf "${GRAY}[DRY-RUN]${NC} Would create: %s\n" "$1"
}

# ファイル作成（上書き防止機能付き）
safe_create() {
    local filepath="$1"
    local dirpath
    dirpath=$(dirname "$filepath")

    if [ "$DRY_RUN" = true ]; then
        log_dryrun "$filepath"
        cat > /dev/null
        return
    fi

    if [ ! -d "$dirpath" ]; then
        mkdir -p "$dirpath"
    fi

    if [ -e "$filepath" ]; then
        cat > /dev/null
        log_skip "$filepath (既に存在します)"
    else
        cat > "$filepath"
        log_create "$filepath"
    fi
}

# 空ファイル作成（上書き防止）
safe_touch() {
    local filepath="$1"
    local dirpath
    dirpath=$(dirname "$filepath")

    if [ "$DRY_RUN" = true ]; then
        log_dryrun "$filepath"
        return
    fi

    if [ ! -d "$dirpath" ]; then
        mkdir -p "$dirpath"
    fi

    if [ -e "$filepath" ]; then
        log_skip "$filepath (既に存在します)"
    else
        touch "$filepath"
        log_create "$filepath"
    fi
}

# .gitignore 追記用
safe_append_gitignore() {
    local ignore_file="$1"
    local pattern="$2"

    if [ "$DRY_RUN" = true ]; then
        printf "${GRAY}[DRY-RUN]${NC} Would add '%s' to %s\n" "$pattern" "$ignore_file"
        return
    fi

    if [ ! -f "$ignore_file" ]; then
        touch "$ignore_file"
    fi

    if grep -qF "$pattern" "$ignore_file" 2>/dev/null; then
        log_skip ".gitignore already contains '$pattern'"
    else
        echo "$pattern" >> "$ignore_file"
        log_config "Added '$pattern' to $ignore_file"
    fi
}

# ============================================================
# メイン処理
# ============================================================
printf "${GRAY}=============================================${NC}\n"
printf "   Claude Extension Kit v%s\n" "$VERSION"
printf "${GRAY}=============================================${NC}\n"

if [ "$DRY_RUN" = true ]; then
    printf "${YELLOW}ドライランモード: ファイルは作成されません${NC}\n\n"
fi

# ============================================================
# 1. ディレクトリ構造の作成
# ============================================================
printf "\n${GRAY}--- ディレクトリ構造 ---${NC}\n"

if [ "$DRY_RUN" = false ]; then
    mkdir -p .claude/skills
    mkdir -p .claude/rules
    mkdir -p claude-ext/docs
    mkdir -p claude-ext/prompts/outputs
    log_info "ディレクトリ構造を作成しました"
else
    log_dryrun ".claude/skills/"
    log_dryrun ".claude/rules/"
    log_dryrun "claude-ext/docs/"
    log_dryrun "claude-ext/prompts/outputs/"
fi

# ============================================================
# 2. .gitignore の設定
# ============================================================
printf "\n${GRAY}--- Git Ignore Settings ---${NC}\n"

# outputs ディレクトリの除外設定
safe_create "claude-ext/prompts/outputs/.gitignore" <<'EOF'
# Ignore all markdown files in this directory
*.md
# But keep the gitignore file itself
!.gitignore
EOF

# .claude/settings.local.json の除外（個人設定）
safe_append_gitignore ".gitignore" ".claude/settings.local.json"
safe_append_gitignore ".gitignore" ".env"
safe_append_gitignore ".gitignore" ".env.local"

# ============================================================
# 3. .claude/settings.json - プロジェクト設定
# ============================================================
printf "\n${GRAY}--- Claude Settings ---${NC}\n"

safe_create ".claude/settings.json" << EOF
{
  "language": "${PROJECT_LANGUAGE}",
  "permissions": {
    "allow": [
      "Read(claude-ext/**)",
      "Read(.claude/**)",
      "Bash(npm run:*)",
      "Bash(yarn:*)",
      "Bash(pnpm:*)",
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)"
    ],
    "deny": [
      "Bash(rm -rf /)**"
    ]
  },
  "attribution": {
    "commit": "Co-Authored-By: Claude <noreply@anthropic.com>"
  }
}
EOF

# ============================================================
# 4. CLAUDE.md - メイン設定ファイル
# ============================================================
printf "\n${GRAY}--- CLAUDE.md ---${NC}\n"

# ペルソナ設定の生成
PERSONA_SECTION=""
if [ -n "$USER_PERSONA" ]; then
    PERSONA_SECTION="- **ユーザーペルソナ**: ${USER_PERSONA}"
fi

# AWS設定の生成
AWS_SECTION=""
if [ "$ENABLE_AWS" = "true" ]; then
    AWS_SECTION="- **AWS**: 最新ドキュメントを必ず確認すること（Web Search使用）"
fi

safe_create ".claude/CLAUDE.md" << EOF
# Project Rules

## Start-up Protocol
- **最優先**: 作業開始前に \`claude-ext/docs/requirements.md\` を読み、3〜7行で要約して提示すること
- **実行ガード**: 上記ファイルが存在しない場合、いかなる変更も行わずユーザーに作成を依頼すること

## 基本方針
- **言語**: ${PROJECT_LANGUAGE}で応対
${PERSONA_SECTION}
${AWS_SECTION}

## 開発ルール
- **コンテキスト管理**: 重要な進捗・決定事項は \`claude-ext/docs/\` に記録
- **機密情報**: APIキー等を含むファイル作成時は即座に \`.gitignore\` へ追記
- **意思決定記録**: 仕様変更は \`claude-ext/docs/decision-log.md\` に追記

## コミット規約
- 1行の日本語で簡潔に（例: \`feat: ログイン機能の実装\`）

## 参照
- @claude-ext/docs/requirements.md - 要件定義
- @claude-ext/docs/tasklist.md - タスクリスト
EOF

# ============================================================
# 5. カスタムスキル（スラッシュコマンド）
# ============================================================
printf "\n${GRAY}--- Custom Skills ---${NC}\n"

# /analyze - 現状分析
safe_create ".claude/skills/analyze/SKILL.md" << 'EOF'
---
name: analyze
description: リポジトリの実装状況を分析してレポートを生成
argument-hint:
allowed-tools: Read, Glob, Grep, Write
---

# 現状分析レポートの生成

以下の手順で実装状況を分析してください:

1. **テンプレート読み込み**: `claude-ext/docs/analysis-repo-template.md` を読む
2. **効率的な調査**:
   - `git ls-files` コマンドを使用して、Git管理下のファイルのみ構造を把握する（`node_modules`などを除外するため）
   - または `tree -I 'node_modules|dist|.git'` を使用する
   - 必要な箇所のみ `grep` で詳細確認
3. **レポート出力**:
   - パス: `claude-ext/prompts/outputs/analysis-{{YYYYMMDD-HHmmss}}.md`
   - テンプレートの構造を維持

**注意**: コンテキスト節約のため、無関係なファイルの読み込みは避けてください。
EOF

# /update-tasks - タスクリスト更新
safe_create ".claude/skills/update-tasks/SKILL.md" << 'EOF'
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
EOF

# /create-requirements - 要件定義生成
safe_create ".claude/skills/create-requirements/SKILL.md" << 'EOF'
---
name: create-requirements
description: ソースコードから要件定義書を生成（リバースエンジニアリング）
argument-hint:
allowed-tools: Read, Glob, Grep, Write
---

# 要件定義書の生成

あなたはシステムアナリスト兼テクニカルライターです。
ソースコードを分析し、`claude-ext/docs/requirements.md` に詳細要件定義書を出力してください。

## 出力セクション
1. **システム概要** - 目的と主要機能
2. **データモデル・用語定義** - エンティティと属性
3. **機能要件詳細** - 各機能の入出力・処理ロジック
4. **ビジネスルール・制約** - バリデーション、定数、状態遷移
5. **外部インターフェース** - ライブラリ、API、DB
6. **非機能要件** - セキュリティ、パフォーマンス
7. **不明点・確認事項** - 意図不明箇所、バグ候補

## ルール
- 「適切な処理を行う」のような曖昧表現は禁止
- エラー処理やコーナーケースも省略しない
- 必要に応じてMermaid図を使用
EOF

# ============================================================
# 6. ルールファイル（モジュール化）
# ============================================================
printf "\n${GRAY}--- Rules ---${NC}\n"

safe_create ".claude/rules/commit.md" << 'EOF'
# コミットルール

## メッセージ形式
```
<type>: <summary>
```

## タイプ一覧
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント変更
- `refactor`: リファクタリング
- `test`: テスト追加・修正
- `chore`: ビルド・設定変更
EOF

safe_create ".claude/rules/security.md" << 'EOF'
# セキュリティルール

## 機密情報の取り扱い
- APIキー、パスワード、トークンはコードにハードコードしない
- 環境変数または `.env` ファイルを使用
- `.env` ファイルは必ず `.gitignore` に追加

## 禁止事項
- 本番環境の認証情報をログ出力しない
- ユーザー入力を直接SQLクエリやコマンドに埋め込まない
EOF

# ============================================================
# 7. ドキュメントテンプレート
# ============================================================
printf "\n${GRAY}--- Document Templates ---${NC}\n"

safe_create "claude-ext/docs/decision-log.md" << 'EOF'
# Decision Log

実装中に発生した設計判断を記録するドキュメント。

---

## テンプレート

### YYYY-MM-DD: [トピック]

**決定**: [何を決めたか]

**理由**:
- [理由1]
- [理由2]

**代替案**: [検討した他の選択肢]
- 却下理由: [なぜ選ばなかったか]
EOF

# --- requirements.md ---
safe_create "claude-ext/docs/requirements.md" << 'EOF'
# 要件定義書

> このファイルはプロジェクトの要件を定義する最重要ドキュメントです。
> Claudeは作業開始時にこのファイルを読み込み、内容に従って作業を行います。

---

## 1. プロジェクト概要

**プロジェクト名**: （プロジェクト名を記入）

**目的**: （このプロジェクトが解決する課題・達成したい目標）

**対象ユーザー**: （誰のためのシステムか）

---

## 2. 技術スタック

| カテゴリ | 技術 | バージョン |
|---------|------|-----------|
| 言語 | | |
| フレームワーク | | |
| データベース | | |
| インフラ | | |

---

## 3. 機能要件

### 3.1 必須機能（MVP）

- [ ] **機能1**: （説明）
- [ ] **機能2**: （説明）

### 3.2 追加機能（将来対応）

- [ ] **機能A**: （説明）

---

## 4. 非機能要件

| 項目 | 要件 |
|------|------|
| パフォーマンス | |
| セキュリティ | |
| 可用性 | |

---

**作成日**: YYYY-MM-DD
**最終更新**: YYYY-MM-DD
EOF

# --- tasklist.md ---
safe_create "claude-ext/docs/tasklist.md" << 'EOF'
# タスクリスト

> `/update-tasks` コマンドで自動更新できます。

## 凡例
- [ ] 未着手
- [x] 完了
- 🚧 進行中

---

## フェーズ 1: 環境構築

- [ ] 開発環境のセットアップ
- [ ] 依存関係のインストール
- [ ] 環境変数の設定

## フェーズ 2: 基本実装

- [ ] （タスク1）
- [ ] （タスク2）

## フェーズ 3: テスト・検証

- [ ] ユニットテスト作成
- [ ] 統合テスト実施
- [ ] 動作確認

---

**最終更新**: YYYY-MM-DD
EOF

# --- analysis-repo-template.md ---
safe_create "claude-ext/docs/analysis-repo-template.md" << 'EOF'
# 実装進捗レポート

- **更新日時**: {{YYYY-MM-DD HH:MM:SS}}
- **対象リポジトリ**: {{リポジトリ名}}
- **ブランチ**: {{ブランチ名}}
- **全体進捗**: {{完了数}}/{{総数}} ({{進捗率}}%)

---

## 1. 直近の作業状況

### 1.1 最後に完了した作業
- [x] {{完了した作業}}（{{完了日時}}）

### 1.2 現在進行中の作業
- [ ] **{{進行中の作業}}** ← 現在ここ
  - 進捗: {{詳細}}
  - 残り: {{残り作業}}

### 1.3 ブロッカー・課題
| 課題 | 影響範囲 | 対応方針 |
|------|---------|---------|
| | | |

---

## 2. 実装状況

### 2.1 コンポーネント別ステータス

| コンポーネント | ファイル | 実装 | テスト | 動作確認 | 備考 |
|--------------|---------|:----:|:-----:|:-------:|------|
| | | | | | |

**凡例**: ✅完了 / ⚠️一部完了 / 🚧進行中 / ❌未着手

---

## 3. テスト状況

| テスト種別 | 状態 | 件数 | 最終実行 | 結果 |
|-----------|:----:|------|---------|------|
| Unitテスト | | | | |
| Integrationテスト | | | | |

---

## 4. 次のアクション（優先度順）

1. **{{タスク名}}**
   - [ ] {{サブタスク}}

---

## 5. まとめ

**完了したこと**:
-

**残っていること**:
-

---

**最終更新**: {{YYYY-MM-DD HH:MM:SS}}
EOF

# ============================================================
# 8. README
# ============================================================
printf "\n${GRAY}--- README ---${NC}\n"

safe_create "claude-ext/README.md" << 'EOF'
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

EOF

# ============================================================
# 完了メッセージ
# ============================================================
printf "\n${GRAY}=============================================${NC}\n"
if [ "$DRY_RUN" = true ]; then
    printf "   ${YELLOW}ドライラン完了${NC}\n"
    printf "   実際に作成するには --dry-run を外して再実行\n"
else
    printf "   ${GREEN}セットアップ完了!${NC}\n"
    printf "\n"
    printf "   ${BLUE}次のステップ:${NC}\n"
    printf "   1. Claude Code で /create-requirements を実行\n"
    printf "   2. Claude Code で /analyze を実行\n"
fi
printf "${GRAY}=============================================${NC}\n"
