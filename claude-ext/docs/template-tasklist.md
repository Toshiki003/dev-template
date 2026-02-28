# テンプレート保守タスクリスト（dev-template）

> 本ファイルは `dev-template` 自体の保守タスクを管理する。

## 凡例
- [ ] 未着手
- [x] 完了
- 🚧 進行中

---

## フェーズ 1: 基盤整備（完了）

- [x] Issueテンプレート（Bug / Feature / Chore）整備
- [x] PRテンプレート整備
- [x] CI（PHP / Go / Python 自動判定）整備
- [x] Dependency Review ワークフロー整備
- [x] Dependabot設定整備
- [x] PR補助スクリプト（`scripts/pr.sh`, `scripts/pr-finish.sh`）整備

## フェーズ 2: PR運用安全化（完了）

- [x] `pr-finish.sh` の保護ブランチ実行拒否
- [x] `pr-finish.sh` のブランチ命名ガード
- [x] `gh pr create` 失敗時の異常終了とURL妥当性確認

## フェーズ 3: Optional AI運用（完了）

- [x] `AI_ENABLED` によるOptional機能の明示有効化
- [x] PRサマリ生成ワークフロー整備
- [x] Codexレビュー依頼コメント自動化
- [x] LLM外部送信ポリシーの README / SECURITY 明記

## フェーズ 4: 仕様統治・文書整合

- [x] テンプレート要件を `template-requirements.md` として独立管理
- [x] 互換ポインタ（`requirements.md` / `tasklist.md`）を整備
- [x] `claude-ext/README.md` の説明を実体ファイルへ同期
- [x] 仕様変更時のドキュメント同時更新チェック（README / SECURITY / decision-log）の運用ルールをCI化

## フェーズ 5: CI・スクリプト改善

- [x] GitHub Actions バージョンを v6 に引き上げ
- [x] `dependency-review.yml` に `continue-on-error` + 初期設定ガイダンス追加
- [x] Claude Code スキル定義（`/analyze`, `/update-tasks`, `/implement-next`, `/fix-review`, `/setup-repo`, `/create-requirements`）
- [ ] `pr.sh` のブランチプレフィックスをタイトルプレフィックスから動的生成（現在 `feat/` 固定）
- [ ] README内のCodeQL例示のactionsバージョン整合（`@v4` → `@v6`）

---

## 次に着手するタスク

- [ ] `pr.sh` のブランチプレフィックスをタイトルプレフィックスから動的生成

---

**最終更新**: 2026-03-01
