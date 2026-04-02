.PHONY: check check-deps fmt bump-major bump-minor bump-patch set-skill-version update-skills tag tokens

check-deps:
	@command -v npx >/dev/null 2>&1 || { echo "Error: npx not found. Install Node.js: https://nodejs.org/" >&2; exit 1; }

fmt: check-deps
	@echo "--- fmt: prettier on markdown ---"
	npx prettier --write '**/*.md'
	npx prettier --write '**/*.json'
	@echo "--- fmt: done ---"

bump-major bump-minor bump-patch: check-deps
	@if [ -n "$$(git status --porcelain)" ]; then echo "Error: uncommitted changes in repo" >&2; exit 1; fi
	@PART=$$(echo $@ | sed 's/bump-//'); \
	OLD=$$(cat VERSION); \
	NEW=$$(sh ./vendor/semver bump $$PART "$$OLD") || { echo "Error: semver bump failed" >&2; exit 1; }; \
	if [ -z "$$NEW" ]; then echo "Error: semver returned empty version" >&2; exit 1; fi; \
	echo "--- $@: $$PART $$OLD -> $$NEW ---"; \
	printf '%s\n' "$$NEW" > VERSION
	@$(MAKE) set-skill-version
	@git add VERSION SKILL.md || { echo "Error: git add failed" >&2; exit 1; }; \
	NEW=$$(cat VERSION); \
	git commit -m "v$$NEW" || { echo "Error: git commit failed" >&2; exit 1; }; \
	echo "--- $@: verify ---"; \
	cat VERSION; \
	git --no-pager log --oneline -1; \
	echo "--- $@: done ---"

set-skill-version:
	@vendor/set-skill-version SKILL.md "$$(cat VERSION)"

update-skills: check-deps
	@echo "--- update-skills ---"
	npx skills update --all -y
	@echo "--- update-skills: done ---"

tag:
	@if [ -n "$$(git status --porcelain)" ]; then echo "Error: uncommitted changes in repo" >&2; exit 1; fi
	@VERSION=$$(cat VERSION); \
	if [ -z "$$VERSION" ]; then echo "Error: VERSION file is empty" >&2; exit 1; fi; \
	TAG="v$$VERSION"; \
	if git rev-parse "$$TAG" >/dev/null 2>&1; then echo "Error: tag $$TAG already exists" >&2; exit 1; fi; \
	echo "--- tag: $$TAG ---"; \
	git tag -m "$$TAG" "$$TAG" || { echo "Error: git tag failed" >&2; exit 1; }; \
	echo "--- tag: verify ---"; \
	git --no-pager tag -l "$$TAG"; \
	git push origin "$$TAG"; \
	echo "--- tag: done ---"

tokens:
	@FILES="SKILL.md $$(sed -n 's|.*](\./\([^)]*\.md\)).*|\1|p' SKILL.md)"; \
	TOTAL=0; \
	for f in $$FILES; do \
		if [ -f "$$f" ]; then \
			CHARS=$$(wc -c < "$$f"); \
			TOKS=$$((CHARS / 4)); \
			TOTAL=$$((TOTAL + TOKS)); \
			printf '  %6d tokens  %s\n' "$$TOKS" "$$f"; \
		else \
			echo "  (missing: $$f)"; \
		fi; \
	done; \
	printf '  %6d tokens  TOTAL (estimated)\n' "$$TOTAL"
