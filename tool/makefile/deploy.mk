.PHONY: build-web deploy-web serve-web build-android build-windows

build-web:
	@cd example
	@fvm flutter build web --release --dart-define-from-file=config/production.json --no-source-maps --pwa-strategy offline-first --web-renderer auto --web-resources-cdn --base-href /

deploy-web: build-web
	@cd example
	@firebase deploy

# https://docs.flutter.dev/platform-integration/web/wasm
#build-web-wasm:
#	@fvm spawn main build web --wasm --release --dart-define-from-file=config/development.json --no-source-maps --pwa-strategy offline-first --web-renderer skwasm --web-resources-cdn --base-href /

#deploy-web-wasm: build-web-wasm
#	@firebase hosting:channel:deploy wasm --expires 14d

serve-web: build-web
	@cd example
	@firebase serve --only hosting -p 8080

build-android:
	@cd example
	@fvm flutter build apk --release --dart-define-from-file=config/production.json

build-windows:
	@cd example
	@fvm flutter build windows --release --dart-define-from-file=config/production.json