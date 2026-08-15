TOOLS_DIR ?= $(CURDIR)/.tools
TOOLS_BIN_DIR := $(TOOLS_DIR)/bin
TOOL_HOST_ARCH := $(shell uname -m)
TOOL_ARCH := $(if $(filter x86_64,$(TOOL_HOST_ARCH)),x86_64,$(if $(filter aarch64 arm64,$(TOOL_HOST_ARCH)),aarch64,unsupported))

TYPOS_VERSION ?= 1.49.0
TYPOS_ARCHIVE := typos-v$(TYPOS_VERSION)-$(TOOL_ARCH)-unknown-linux-musl.tar.gz
TYPOS_URL := https://github.com/crate-ci/typos/releases/download/v$(TYPOS_VERSION)/$(TYPOS_ARCHIVE)
TYPOS ?= $(shell command -v typos 2>/dev/null || printf '%s' "$(TOOLS_BIN_DIR)/typos")

STYLUA_VERSION ?= 2.5.2
STYLUA_ARCHIVE := stylua-linux-$(TOOL_ARCH).zip
STYLUA_URL := https://github.com/JohnnyMorganz/StyLua/releases/download/v$(STYLUA_VERSION)/$(STYLUA_ARCHIVE)
STYLUA ?= $(shell command -v stylua 2>/dev/null || printf '%s' "$(TOOLS_BIN_DIR)/stylua")

DPRINT_VERSION ?= 0.55.2
DPRINT_ARCHIVE := dprint-$(TOOL_ARCH)-unknown-linux-gnu.zip
DPRINT_URL := https://github.com/dprint/dprint/releases/download/$(DPRINT_VERSION)/$(DPRINT_ARCHIVE)
DPRINT ?= $(shell command -v dprint 2>/dev/null || printf '%s' "$(TOOLS_BIN_DIR)/dprint")

LUA_LANGUAGE_SERVER_VERSION ?= 3.19.1
LUA_LANGUAGE_SERVER_HOST_ARCH := $(shell uname -m)
LUA_LANGUAGE_SERVER_ARCH := $(if $(filter x86_64,$(LUA_LANGUAGE_SERVER_HOST_ARCH)),x64,$(if $(filter aarch64 arm64,$(LUA_LANGUAGE_SERVER_HOST_ARCH)),arm64,unsupported))
LUA_LANGUAGE_SERVER_ARCHIVE := lua-language-server-$(LUA_LANGUAGE_SERVER_VERSION)-linux-$(LUA_LANGUAGE_SERVER_ARCH).tar.gz
LUA_LANGUAGE_SERVER_URL := https://github.com/LuaLS/lua-language-server/releases/download/$(LUA_LANGUAGE_SERVER_VERSION)/$(LUA_LANGUAGE_SERVER_ARCHIVE)
LUA_LANGUAGE_SERVER_DIR := $(TOOLS_DIR)/lua-language-server
LUA_LANGUAGE_SERVER ?= $(shell command -v lua-language-server 2>/dev/null || printf '%s' "$(LUA_LANGUAGE_SERVER_DIR)/bin/lua-language-server")

.PHONY: nvim
nvim:
	nvim -u $(CURDIR)/dev/init.lua

.PHONY: rename
rename:
	./scripts/rename-plugin.sh $(PLUGIN_NAME)

.PHONY: fmt
fmt:
	$(STYLUA) -g '*.lua' -- .
	$(DPRINT) fmt

.PHONY: lint
lint: lint-lua
	$(TYPOS)

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

.PHONY: install-typos
install-typos:
	@command -v curl >/dev/null 2>&1 || (echo 'curl is required to install typos' >&2; exit 1)
	@command -v tar >/dev/null 2>&1 || (echo 'tar is required to install typos' >&2; exit 1)
	@test "$(TOOL_ARCH)" != unsupported || (echo 'unsupported Linux architecture for typos' >&2; exit 1)
	mkdir -p $(TOOLS_BIN_DIR)
	@if [ ! -x "$(TYPOS)" ]; then \
		set -e; \
		archive=$$(mktemp "$(TOOLS_DIR)/typos.XXXXXX.tar.gz"); \
		staging=$$(mktemp -d "$(TOOLS_DIR)/typos.XXXXXX"); \
		trap 'rm -f "$$archive"; rm -rf "$$staging"' EXIT INT TERM; \
		curl --fail --location --show-error --silent --retry 3 --output "$$archive" "$(TYPOS_URL)"; \
		tar -xzf "$$archive" -C "$$staging"; \
		test -f "$$staging/typos" || (echo 'typos archive has an unexpected layout' >&2; exit 1); \
		mv "$$staging/typos" "$(TOOLS_BIN_DIR)/typos"; \
		chmod +x "$(TOOLS_BIN_DIR)/typos"; \
		rm -f "$$archive"; \
		trap - EXIT INT TERM; \
	fi
	@test -x "$(TYPOS)" || (echo 'failed to install typos release archive' >&2; exit 1)

.PHONY: install-stylua
install-stylua:
	@command -v curl >/dev/null 2>&1 || (echo 'curl is required to install stylua' >&2; exit 1)
	@command -v unzip >/dev/null 2>&1 || (echo 'unzip is required to install stylua' >&2; exit 1)
	@test "$(TOOL_ARCH)" != unsupported || (echo 'unsupported Linux architecture for stylua' >&2; exit 1)
	mkdir -p $(TOOLS_BIN_DIR)
	@if [ ! -x "$(STYLUA)" ]; then \
		set -e; \
		archive=$$(mktemp "$(TOOLS_DIR)/stylua.XXXXXX.zip"); \
		staging=$$(mktemp -d "$(TOOLS_DIR)/stylua.XXXXXX"); \
		trap 'rm -f "$$archive"; rm -rf "$$staging"' EXIT INT TERM; \
		curl --fail --location --show-error --silent --retry 3 --output "$$archive" "$(STYLUA_URL)"; \
		unzip -q "$$archive" stylua -d "$$staging"; \
		test -f "$$staging/stylua" || (echo 'stylua archive has an unexpected layout' >&2; exit 1); \
		mv "$$staging/stylua" "$(TOOLS_BIN_DIR)/stylua"; \
		chmod +x "$(TOOLS_BIN_DIR)/stylua"; \
		rm -f "$$archive"; \
		trap - EXIT INT TERM; \
	fi
	@test -x "$(STYLUA)" || (echo 'failed to install stylua release archive' >&2; exit 1)

.PHONY: install-dprint
install-dprint:
	@command -v curl >/dev/null 2>&1 || (echo 'curl is required to install dprint' >&2; exit 1)
	@command -v unzip >/dev/null 2>&1 || (echo 'unzip is required to install dprint' >&2; exit 1)
	@test "$(TOOL_ARCH)" != unsupported || (echo 'unsupported Linux architecture for dprint' >&2; exit 1)
	mkdir -p $(TOOLS_BIN_DIR)
	@if [ ! -x "$(DPRINT)" ]; then \
		set -e; \
		archive=$$(mktemp "$(TOOLS_DIR)/dprint.XXXXXX.zip"); \
		staging=$$(mktemp -d "$(TOOLS_DIR)/dprint.XXXXXX"); \
		trap 'rm -f "$$archive"; rm -rf "$$staging"' EXIT INT TERM; \
		curl --fail --location --show-error --silent --retry 3 --output "$$archive" "$(DPRINT_URL)"; \
		unzip -q "$$archive" dprint -d "$$staging"; \
		test -f "$$staging/dprint" || (echo 'dprint archive has an unexpected layout' >&2; exit 1); \
		mv "$$staging/dprint" "$(TOOLS_BIN_DIR)/dprint"; \
		chmod +x "$(TOOLS_BIN_DIR)/dprint"; \
		rm -f "$$archive"; \
		trap - EXIT INT TERM; \
	fi
	@test -x "$(DPRINT)" || (echo 'failed to install dprint release archive' >&2; exit 1)

.PHONY: install-tools
install-tools: install-typos install-stylua install-dprint install-lua-language-server
	@echo 'Development tools are ready'

.PHONY: check
check: lint fmt
