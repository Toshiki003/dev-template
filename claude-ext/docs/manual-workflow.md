# 手動ワークフロー手順書

> Claude Code / Codex が利用できない場合に、同等の開発フローを手動で実行する手順です。

---

## 前提条件

- Git CLI がインストール済み
- GitHub CLI (`gh`) がインストール・認証済み

---

## 0. 作業対象ドキュメントの選択

- アプリ実装を進める場合: `claude-ext/docs/app-requirements.md` / `claude-ext/docs/app-tasklist.md`
- テンプレート保守を進める場合: `claude-ext/docs/template-requirements.md` / `claude-ext/docs/template-tasklist.md`

---

## 1. ブランチ作成

```bash
./scripts/pr.sh "feat: タスクの説明"
```

これにより:
- mainブランチを最新化
- `feat/タスクの説明-タイムスタンプ` ブランチが作成される

---

## 2. 実装

通常通りコードを編集します。

---

## 3. PR作成

```bash
./scripts/pr-finish.sh "feat: タスクの説明"
```

これにより:
- 全変更をコミット（Co-Authored-By付き）
- リモートにプッシュ
- PRを作成（`.github/PULL_REQUEST_TEMPLATE.md` をボディに使用）
- タイトルプレフィックスに応じたラベルを自動付与
- `ai-review` ラベルを付与

---

## 4. レビュー確認

```bash
# PRの状態確認
gh pr view

# レビューコメント確認
gh pr view --json reviews,comments

# インラインコメント確認
gh api repos/{owner}/{repo}/pulls/{number}/comments
```

---

## 5. レビュー修正

指摘に基づいてコードを修正し、プッシュします:

```bash
git add -A
git commit -m "fix: レビュー指摘の修正"
git push
```

---

## 6. マージ

GitHub上でPRをマージするか、CLIで実行します:

```bash
gh pr merge --squash
```

---

## ラベル自動判定ルール

| タイトルプレフィックス | 付与されるラベル |
|---------------------|----------------|
| `feat:` | `feat` |
| `fix:` | `fix` |
| `docs:` | `docs` |
| `refactor:` | `refactor` |
| `test:` | `test` |
| `chore:` | `chore` |

全てのPRに `ai-review` ラベルが自動付与されます。

---

## シナリオ別影響

| シナリオ | 影響 | 代替手段 |
|---------|------|---------|
| Claude Code解約 | `/implement-next`、`/fix-review` 使用不可 | 本手順書のスクリプトで手動PR作成 |
| Codex解約 | PRサマリー・AIレビューなし | CI/dependency-reviewは継続動作。PRテンプレートで手動サマリー |
| 両方解約 | AI機能すべて停止 | Issueテンプレート、PRテンプレート、CI、dependency-reviewは動作 |

> CodeQL は任意導入です。導入済みの場合のみ継続動作します。
