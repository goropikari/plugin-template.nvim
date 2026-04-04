.PHONY: nvim
nvim:
	nvim -u $(CURDIR)/dev/init.lua

.PHONY: fmt
fmt:
	stylua -g '*.lua' -- .

.PHONY: lint
lint:
	typos -w

.PHONY: check
check: lint fmt
