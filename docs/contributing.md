# 🤝 Contributing Guide

## CrossPlatform DevToolkit

Contributions welcome! Please read this guide before submitting PRs.

---

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow

---

## How to Contribute

### 1. Fork & Clone
```bash
git clone https://github.com/yourusername/cross-platform-toolkit
cd cross-platform-toolkit
git checkout -b feature/your-feature-name
```

### 2. Make Changes

**Bash scripts:**
- Test on Linux AND Termux
- Use `shellcheck` for linting:
  ```bash
  shellcheck scripts/bash/yourscript.sh
  ```
- Follow the color/output style used in existing scripts

**Python scripts:**
- Python 3.6+ compatible
- No external dependencies unless absolutely necessary
- Test on Windows, Linux, and Termux if possible

**Windows batch:**
- Test on CMD and PowerShell
- Handle paths with spaces

### 3. Test Your Changes

```bash
# Bash
bash -n scripts/bash/yourscript.sh   # Syntax check
bash scripts/bash/yourscript.sh      # Run it

# Python
python3 -m py_compile scripts/python/yourscript.py   # Syntax check
python3 scripts/python/yourscript.py                  # Run it
```

### 4. Commit & Push

```bash
git add .
git commit -m "feat: add XYZ tool for Linux/Termux"
git push origin feature/your-feature-name
```

### 5. Open PR

- Title: Clear and concise
- Description: What does it do? Why is it needed?
- Platform tested: Windows / Linux / Termux

---

## Commit Message Format

```
type: short description

Types:
  feat     - New feature
  fix      - Bug fix
  docs     - Documentation
  refactor - Code refactoring
  style    - Formatting only
  test     - Tests
  chore    - Build/CI changes
```

Examples:
```
feat: add backup rotation for older archives
fix: netcheck.sh fails on Termux without ping
docs: update Termux installation steps
```

---

## Adding a New Tool

1. Create the bash version: `scripts/bash/toolname.sh`
2. Create Windows version (if applicable): `scripts/batch/toolname.bat`
3. Add Python version: `scripts/python/toolname.py`
4. Add to `toolkit.py` CLI
5. Document in `docs/api-reference.md`
6. Add to README table

### Template for new bash tool:
```bash
#!/usr/bin/env bash
# ============================================================
# toolname.sh - Brief Description
# Works on: Linux, Termux
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; RESET='\033[0m'

# Your code here

echo -e "${GREEN}Done!${RESET}"
```

---

## Directory Structure

```
cross-platform-toolkit/
├── scripts/bash/        # Linux + Termux scripts
├── scripts/batch/       # Windows batch/cmd
├── scripts/python/      # Cross-platform Python
├── tools/               # Standalone utilities
├── configs/             # Config templates  
├── docs/                # Documentation
├── assets/              # Static resources
├── samples/             # Example data files
├── templates/           # Project templates
└── modules/             # Reusable modules
```

---

## Testing Checklist

Before submitting a PR, verify:

- [ ] Script runs on Linux
- [ ] Script runs on Termux (if bash)
- [ ] Script runs on Windows (if batch)
- [ ] Python version works on Python 3.6+
- [ ] No hardcoded absolute paths
- [ ] Error handling for missing tools
- [ ] Colored output works (and gracefully degrades)
- [ ] Documentation updated

---

*Thank you for contributing! 🙏*
