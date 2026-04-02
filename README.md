# Copier Agent Skill

![context: 0.0k tokens](https://img.shields.io/badge/context-0.0k_tokens-blue)

A skill for creating, updating, and rendering project templates via
[`copier`](https://copier.readthedocs.io/) CLI.

---

## Installation

This skill requires Python 3.10+, Git 2.27+, and `copier` CLI:

```sh
# on MacOS:
brew install copier
# if `uv` is installed
uv tool install copier
# if `pipx` is installed
pipx install copier
# if `pip` is install
pip install copier
```

### Vercel Skills CLI

```sh
npx skills add thesmart/repo-copier
```

### Manual

Clone into your Claude Code skills directory:

```sh
git clone https://github.com/thesmart/repo-copier.git ~/.claude/skills/repo-copier
```

---

## Development Dependencies

- [Node.js / npx](https://nodejs.org/) — used for prettier formatting, skills management
- [yq](https://github.com/mikefarah/yq#install) — used for YAML frontmatter updates in SKILL.md
- [skill-creator](https://github.com/anthropics/skills) — skill creation, evaluation, and
  optimization

---

## License Terms

This software is licensed under the [PolyForm Internal Use License 1.0.0](./LICENSE).

Informal license summary:

- **Internal use only**: Use and modify freely within your organization.
- **No distribution**: You cannot redistribute outside your organization, no sublicensing.
- **No warranty**: Provided "as is" with no liability.

Please submit PRs via Github.
