# Security Policy

## Reporting a Vulnerability
If you discover a security issue, please open a private report if possible or create an issue with minimal details and mark it as security-related.

## LLM External Transmission Policy

- Optional AI workflows are disabled by default and run only when `AI_ENABLED=true`.
- This template does not send code to external LLM APIs. PR summary and review are handled by GitHub Codex, which processes PR changes within the GitHub platform.
- When the `ai-review` label is applied, the `codex-review-comment.yml` workflow posts a `@codex review` comment requesting summary and review. Codex processes the PR content under GitHub's data handling policies.
- Repository maintainers are responsible for reviewing GitHub Codex's terms and ensuring compliance with their data handling requirements.
