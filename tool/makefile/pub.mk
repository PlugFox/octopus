.PHONY: version doctor clean get fluttergen l10n build_runner codegen upgrade upgrade-major outdated dependencies format analyze check

# Check flutter version
version:
	@flutter --version

# Check flutter doctor
doctor:
	@flutter doctor

# Clean all generated files
clean:
	@rm -rf coverage .dart_tool .packages pubspec.lock
	@(cd example && rm -rf coverage .dart_tool .packages pubspec.lock)

# Get dependencies
get:
	@flutter pub get
	@flutter pub get --directory=example

# Generate assets
fluttergen:
	@dart pub global activate flutter_gen
	@fluttergen -c example/pubspec.yaml

# Generate localization
l10n:
	@dart pub global activate intl_utils
	@(cd example && dart pub global run intl_utils:generate)
	@(cd example && flutter gen-l10n --arb-dir lib/src/common/localization --output-dir lib/src/common/localization/generated --template-arb-file intl_en.arb)

# Build runner
build_runner:
	@cd example && dart run build_runner build --delete-conflicting-outputs --release

# Generate code
codegen: get fluttergen l10n build_runner format

fix: format
	@dart fix --apply lib
	@dart fix --apply example/lib

# Generate all
gen: codegen

# Upgrade dependencies
upgrade:
	@flutter pub upgrade

# Upgrade to major versions
upgrade-major:
	@flutter pub upgrade --major-versions

# Check outdated dependencies
outdated: get
	@flutter pub outdated

# Check outdated dependencies
dependencies: upgrade
	@flutter pub outdated --dependency-overrides \
		--dev-dependencies --prereleases --show-all --transitive

# Format code
format:
	@dart format --fix -l 80 .
	@(cd example && dart format --fix -l 80 .)


# Analyze code
analyze: get format
	@dart analyze --fatal-infos --fatal-warnings

# Check code
check: analyze
	@dart pub publish --dry-run
	@dart pub global activate pana
	@pana --json --no-warning --line-length 80 > log.pana.json

# Publish package
publish:
	@dart pub publish
