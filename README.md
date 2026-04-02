# Copier Agent Skill

![context: 11.5k tokens](https://img.shields.io/badge/context-11.5k_tokens-blue)

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

## Benchmark

Evaluated on 3 tasks (template authoring, update conflict resolution, multi-template setup) against
a baseline of Claude without the skill.

| Metric    | With Skill  | Without Skill | Delta       |
| --------- | ----------- | ------------- | ----------- |
| Pass Rate | 100% ± 0%   | 72% ± 5%      | **+28 pts** |
| Latency   | 45s ± 7s    | 59s ± 8s      | -14s        |
| Tokens    | 2,875 ± 620 | 4,071 ± 668   | -1,196      |

The skill improves accuracy by guiding Claude to copier-idiomatic patterns (e.g.
`_copier_conf.answers_file`, `_copier_answers|to_nice_yaml`) that Claude otherwise misses or
approximates incorrectly.

---

## License Terms

This software is licensed under the [PolyForm Internal Use License 1.0.0](./LICENSE).

Informal license summary:

- **Internal use only**: Use and modify freely within your organization.
- **No distribution**: You cannot redistribute outside your organization, no sublicensing.
- **No warranty**: Provided "as is" with no liability.

Please submit PRs via Github.
