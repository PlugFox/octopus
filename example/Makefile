SHELL :=/bin/bash -e -o pipefail
PWD   := $(shell pwd)

.DEFAULT_GOAL := all
.PHONY: all
all: ## build pipeline
all: setup codegen format analyze test build

.PHONY: precommit
precommit: ## validate the branch before commit
precommit: all

.PHONY: ci
ci: ## CI build pipeline
ci: analyze test

.PHONY: git-hooks
git-hooks: ## install git hooks
	@git config --local core.hooksPath .githooks/

.PHONY: help
help:
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: setup
setup: ## setup environment
	$(call print-target)
	@fvm dart --disable-analytics
	@fvm flutter config --no-analytics --enable-android --enable-web
	@yes | fvm flutter doctor --android-licenses
	@fvm flutter precache --universal --android --web
	$(call get)

.PHONY: version
version: ## show current flutter version
	$(call print-target)
	@fvm flutter --version

.PHONY: get
get: ## get dependencies
	$(call print-target)
	@fvm flutter pub get

.PHONY: upgrade
upgrade: get ## upgrade dependencies
	$(call print-target)
	@fvm flutter pub upgrade

.PHONY: outdated
outdated: ## check for outdated dependencies
	$(call print-target)
	@fvm flutter pub outdated

.PHONY: codegen
codegen: get ## run codegenerators
	$(call print-target)
	@fvm dart run build_runner build --delete-conflicting-outputs
	$(call fix)

.PHONY: gen
gen: codegen

.PHONY: fix
fix: get ## format and fix code
	$(call print-target)
	@fvm dart format --fix -l 110 lib/ test/
	@fvm dart fix --apply lib/
	@fvm dart fix --apply test/

.PHONY: format
format: fix

.PHONY: fmt
fmt: fix

.PHONY: clean
clean: ## remove files created during build pipeline
	$(call print-target)
	@fvm flutter clean
	@rm -rf .dart_tool build coverage .flutter-plugins .flutter-plugins-dependencies
	$(call get)

.PHONY: analyze
analyze: get ## check source code for errors and warnings
	$(call print-target)
	@fvm dart format --set-exit-if-changed -l 110 -o none lib/ test/
	@fvm flutter analyze --fatal-infos --fatal-warnings lib/ test/

.PHONY: check
check: analyze

.PHONY: lint
lint: analyze

.PHONY: test
test: ## run tests
	$(call print-target)
	@fvm flutter test --color --coverage --concurrency=50 --platform=tester --reporter=compact --timeout=30s

.PHONY: coverage
coverage: test ## generate coverage report
	$(call print-target)
	@lcov --list coverage/lcov.info

.PHONY: build
build: get ## build the application
	$(call print-target)
	@fvm flutter build web --web-renderer canvaskit --release --source-maps --base-href / --dart-define VERSION=0.0.0 --dart-define-from-file=.env.dev

.PHONY: diff
diff: ## git diff
	$(call print-target)
	@git diff --exit-code
	@RES=$$(git status --porcelain) ; if [ -n "$$RES" ]; then echo $$RES && exit 1 ; fi

define print-target
    @printf "Executing target: \033[36m$@\033[0m\n"
endef
