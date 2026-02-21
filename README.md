# dev-template

A template repository for PR-driven development with:

## Always-on (no AI dependency)
- Issue templates
- PR template
- CI (auto-detect: PHP / Go / Python)
- Security checks: CodeQL + dependency review (and optional Dependabot)

## Optional AI helpers (DEFAULT OFF)
- PR summary generation (requires OPENAI_API_KEY + AI_ENABLED=true)
- Codex review request comment (label-driven; requires Codex integration + AI_ENABLED=true)

### How to enable optional AI helpers
Repository Settings -> Secrets and variables -> Actions:
- Variables:
  - AI_ENABLED=true
- Secrets (optional):
  - OPENAI_API_KEY=<your key>  (only needed for pr-summary.yml)

> Recommended: Keep AI helpers optional so the workflow remains usable even without any AI plan.
