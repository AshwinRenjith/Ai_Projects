11. Finally, let's create the pre-commit configuration:

```yaml
repos:
- repo: https://github.com/pre-commit/pre-commit-hooks
  rev: v4.3.0
  hooks:
    - id: trailing-whitespace
    - id: end-of-file-fixer
    - id: check-yaml
    - id: check-added-large-files

- repo: https://github.com/pre-commit/mirrors-eslint
  rev: v8.21.0
  hooks:
    - id: eslint
      files: \.[jt]sx?$  # *.js, *.jsx, *.ts and *.tsx
      types: [file]
      args: [--fix]

- repo: https://github.com/psf/black
  rev: 22.10.0
  hooks:
    - id: black
      language_version: python3.9
```