ZORDON ?= zordon
MODULES := coredns caddy

.PHONY: lint test

lint:
	@for m in $(MODULES); do \
		test -f "$$m/zordon.mod" || { echo "missing $$m/zordon.mod" >&2; exit 1; }; \
		test -f "$$m/Alphasfile" || { echo "missing $$m/Alphasfile" >&2; exit 1; }; \
	done

test: lint
	@set -e; \
	tmp="$$(mktemp -d)"; \
	trap 'rm -rf "$$tmp"' EXIT; \
	printf 'search "%s" {}\n' "$(CURDIR)" > "$$tmp/zordon.work"; \
	for m in $(MODULES); do \
		echo "==> zordon plan $$m"; \
		cp -R "$$m" "$$tmp/$$m"; \
		(cd "$$tmp/$$m" && $(ZORDON) --home "$$tmp/home" plan > /dev/null); \
	done; \
	mkdir -p "$$tmp/stack"; \
	printf 'module = "github.com/zordon-io/zordon-modules/test"\nrequire "github.com/zordon-io/zordon-modules/coredns" { ref = "coredns/v0.1.0" }\nrequire "github.com/zordon-io/zordon-modules/caddy" { ref = "caddy/v0.1.0" }\n' > "$$tmp/stack/zordon.mod"; \
	printf 'import "github.com/zordon-io/zordon-modules/coredns" {\n  features = ["any", "debug", "health", "local", "log", "loop", "metrics", "minimal", "pprof", "reload", "resolver", "shed", "whoami"]\n}\nimport "github.com/zordon-io/zordon-modules/caddy" {\n  features = ["dns", "tls", "admin", "metrics", "debug", "log", "watch", "encode"]\n  packages = {\n    coredns = {\n      features = ["debug", "health", "log", "metrics", "whoami"]\n    }\n  }\n}\n' > "$$tmp/stack/Alphasfile"; \
	echo "==> zordon plan stack (coredns + caddy)"; \
	(cd "$$tmp/stack" && $(ZORDON) --home "$$tmp/home" plan > /dev/null)
