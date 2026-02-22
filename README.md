# dev-template

PR駆動開発を「毎回同じ品質」で回すための **テンプレートリポジトリ**です。  
（10個以上の個人開発・PoCを量産しても、Issue/PR/CI/セキュリティの最低ラインを揃える）

## 目的

- Private リポジトリでも運用できる、再現性の高い開発フローを用意する
- AI（Claude/Codex）を使う場合も、**使わない場合も**同じフローで回るようにする（ロックイン回避）
- 「変更の安全性」「セキュリティ」「レビュー」「サマリ」が残る形で開発する

---

## このテンプレでできること

### Always-on（AIなしでも成立）

- Issue テンプレ（Bug / Feature / Chore）
- PR テンプレ（変更点サマリ・影響範囲・テスト・セキュリティ/運用メモ）
- CI（PHP / Go / Python を自動判定して best-effort 実行）
- Dependency Review（PRに入る依存変更のチェック）
- Dependabot（依存更新の自動PR）
- `scripts/` によるローカル補助（PR作成を自動化）

### Optional（必要な時だけ、DEFAULT OFF）

- PR変更点サマリ生成（Codex Action など）
- Codex レビュー依頼コメント（ラベル駆動：`ai-review`）

> **重要**: Optional機能は、設定しなければ「自動でスキップ」されます。  
> つまり Claude/Codex の契約を終了しても、テンプレのフロー自体は壊れません。

---

## ディレクトリ構成

```text
dev-template/
  .github/
    CODEOWNERS                   # コードオーナー設定
    ISSUE_TEMPLATE/
      bug_report.yml
      feature_request.yml
      chore_task.yml
    PULL_REQUEST_TEMPLATE.md
    dependabot.yml
    workflows/
      ci.yml
      dependency-review.yml
      codeql.yml               # ※privateでは有効化できない場合あり
      pr-summary.yml           # Optional
      codex-review-comment.yml # Optional
  .claude/                     # Claude Code 設定・スキル（Optional）
    CLAUDE.md
    rules/
    skills/
  claude-ext/                  # 要件・タスク管理ドキュメント（Optional）
    docs/
      requirements.md
      tasklist.md
      decision-log.md
      manual-workflow.md
  scripts/
    pr.sh                      # ブランチ作成
    pr-finish.sh               # コミット→Push→PR作成
  create-claude-ext.sh         # Claude拡張セットアップスクリプト
  .gitignore
  README.md
  SECURITY.md
```

---

## 使い方（テンプレ repo → 量産）

### 1) このリポジトリを Template repository にする

GitHubのUI:

- Settings → General → **Template repository** をON

### 2) テンプレから新規リポジトリ作成（gh CLI）

```bash
OWNER="あなたのユーザー名 or 組織名"
TEMPLATE="dev-template"

for n in $(seq -w 1 10); do
  name="proj${n}"
  gh repo create "$OWNER/$name" --private --template "$OWNER/$TEMPLATE"
done
```

---

## 日々の開発フロー（基本・AI不問）

### 1) Issue作成（任意）

Issueテンプレで作成して、タスクを明確化。

### 2) 実装

ローカルで実装し、変更を作る。（Claude Code 等のAIツールとの併用も可）

### 3) PR作成（スクリプトで自動）

- ブランチ作成だけ（作業開始用）

```bash
./scripts/pr.sh "feat: add x"
```

- コミット → Push → PR作成（作業完了用）

```bash
./scripts/pr-finish.sh "feat: add x"
```

`pr-finish.sh` はタイトルプレフィックス（`feat:` / `fix:` / `docs:` 等）からラベルを自動判定し、`ai-review` ラベルも付与します。

### 4) GitHub上でチェック

- CI が通ること
- dependency review がOKであること
- PRテンプレのサマリ/テスト/リスクが書けていること

### 5) OKなら merge

あなたは **PRサマリを確認して merge するだけ**に近づきます。

> Claude Code を使う場合は、上記フローを自動化するスキルが利用できます。
> 詳細は「[Claude Code 連携](#claude-code-連携optional)」セクションを参照してください。

---

## Optional（AI機能）を有効化する

### 1) Repo Variables に `AI_ENABLED=true` を設定

GitHub: Settings → Secrets and variables → Actions → Variables

- `AI_ENABLED=true`

### 2) PRサマリ生成を使いたい場合（任意）

GitHub: Settings → Secrets and variables → Actions → Secrets

- `OPENAI_API_KEY` を追加

> APIキーは **リポジトリにコミットしません**。Secretsに保存します。

### 3) Codexレビュー依頼（ラベル駆動）

PRにラベル `ai-review` を付けると、`@codex review` コメントが自動で付きます。
（Codex GitHub連携が有効な場合、レビューが返ります）

---

## Claude Code 連携（Optional）

Claude Code を使ってローカル開発を加速するための設定・スキルが含まれています。
**設定しなくてもテンプレートの基本フローには影響しません。**

### セットアップ

既存リポジトリに Claude Code 連携機能を追加するには:

```bash
bash create-claude-ext.sh
```

`--dry-run` オプションで事前に確認できます。詳細は `bash create-claude-ext.sh --help` を参照。

### 構成

| ディレクトリ | 役割 |
|-------------|------|
| `.claude/` | Claude Code のプロジェクト設定・ルール・スキル定義 |
| `claude-ext/docs/` | 要件定義 (`requirements.md`)・タスクリスト (`tasklist.md`)・意思決定ログ等 |

### 利用可能なスキル（スラッシュコマンド）

| コマンド | 説明 |
|---------|------|
| `/analyze` | リポジトリの実装状況を分析してレポート生成 |
| `/update-tasks` | 分析結果に基づいてタスクリストを更新 |
| `/implement-next` | タスクリストから次の未着手タスクを実装しPR作成 |
| `/fix-review` | PRのレビュー指摘を取得して自動修正 |
| `/create-requirements` | ソースコードから要件定義書を生成 |

### Claude Code 利用時の開発フロー

詳細は [`.claude/CLAUDE.md`](.claude/CLAUDE.md) の「推奨開発フロー」を参照してください。

基本的な流れ:

1. `requirements.md` に要件を記載
2. `/analyze` → `/update-tasks` でタスクを自動生成
3. `/implement-next` でタスクを実装・PR作成
4. レビュー後、`/fix-review` で指摘を修正
5. マージ → 次のタスクへ

---

## CodeQL について（重要）

- **Private リポジトリでは、プランや設定により Code scanning が有効化できない場合があります。**
- その場合、`codeql.yml` はデフォルトOFFにする / 削除する運用が安全です。
- 代替として、Dependency Review / Dependabot / Secret scanning を優先します。

---

## セキュリティ方針

詳細は `SECURITY.md` を参照してください。

---

## ライセンス

個人用途のテンプレとして自由に利用してください（必要なら後で追記）。
