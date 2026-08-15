TOOLS_DIR ?= $(CURDIR)/.tools
LUA_LANGUAGE_SERVER_VERSION ?= 3.19.1
LUA_LANGUAGE_SERVER_HOST_ARCH := $(shell uname -m)
LUA_LANGUAGE_SERVER_ARCH := $(if $(filter x86_64,$(LUA_LANGUAGE_SERVER_HOST_ARCH)),x64,$(if $(filter aarch64 arm64,$(LUA_LANGUAGE_SERVER_HOST_ARCH)),arm64,unsupported))
LUA_LANGUAGE_SERVER_ARCHIVE := lua-language-server-$(LUA_LANGUAGE_SERVER_VERSION)-linux-$(LUA_LANGUAGE_SERVER_ARCH).tar.gz
LUA_LANGUAGE_SERVER_URL := https://github.com/LuaLS/lua-language-server/releases/download/$(LUA_LANGUAGE_SERVER_VERSION)/$(LUA_LANGUAGE_SERVER_ARCHIVE)
LUA_LANGUAGE_SERVER_DIR := $(TOOLS_DIR)/lua-language-server
LUA_LANGUAGE_SERVER := $(LUA_LANGUAGE_SERVER_DIR)/bin/lua-language-server

.PHONY: nvim
nvim:
	nvim -u $(CURDIR)/dev/init.lua

.PHONY: rename
rename:
	./scripts/rename-plugin.sh $(PLUGIN_NAME)

.PHONY: fmt
fmt:
	stylua -g '*.lua' -- .
	dprint fmt

.PHONY: lint
lint: lint-lua
	typos

.PHONY: lint-lua
lint-lua:
	$(LUA_LANGUAGE_SERVER) --check . --checklevel=Warning --configpath=$(CURDIR)/.luarc.json

.PHONY: install-lua-language-server
install-lua-language-server:
	@command -v curl >/dev/null 2>&1 || (echo 'curl is required to install lua-language-server' >&2; exit 1)
	@command -v tar >/dev/null 2>&1 || (echo 'tar is required to install lua-language-server' >&2; exit 1)
	@test "$(LUA_LANGUAGE_SERVER_ARCH)" != unsupported || (echo 'unsupported Linux architecture for lua-language-server' >&2; exit 1)
	mkdir -p $(TOOLS_DIR)
	@if [ ! -x "$(LUA_LANGUAGE_SERVER)" ]; then \
		set -e; \
		archive=$$(mktemp "$(TOOLS_DIR)/lua-language-server.XXXXXX.tar.gz"); \
		staging=$$(mktemp -d "$(TOOLS_DIR)/lua-language-server.XXXXXX"); \
		trap 'rm -f "$$archive"; rm -rf "$$staging"' EXIT INT TERM; \
		curl --fail --location --show-error --silent --retry 3 --output "$$archive" "$(LUA_LANGUAGE_SERVER_URL)"; \
		tar -xzf "$$archive" -C "$$staging"; \
		test -x "$$staging/bin/lua-language-server" || (echo 'lua-language-server archive has an unexpected layout' >&2; exit 1); \
		if [ -e "$(LUA_LANGUAGE_SERVER_DIR)" ]; then \
			backup=$$(mktemp -d "$(TOOLS_DIR)/lua-language-server-source.XXXXXX"); \
			rmdir "$$backup"; \
			mv "$(LUA_LANGUAGE_SERVER_DIR)" "$$backup"; \
		fi; \
		mv "$$staging" "$(LUA_LANGUAGE_SERVER_DIR)"; \
		rm -f "$$archive"; \
		trap - EXIT INT TERM; \
	fi
	@test -x "$(LUA_LANGUAGE_SERVER)" || (echo 'failed to install lua-language-server release archive' >&2; exit 1)

.PHONY: check
check: lint fmt
