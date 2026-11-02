.PHONY: lint test

lint:
	@test -f coredns/zordon.mod
	@test -f coredns/Alphasfile
	@test -f caddy/zordon.mod
	@test -f caddy/Alphasfile

test: lint
