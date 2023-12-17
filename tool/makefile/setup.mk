.PHONY: splash icon init-firebase

# https://pub.dev/packages/flutter_launcher_icons
icon:
	@cd example
	@fvm flutter pub run flutter_launcher_icons -f flutter_launcher_icons.yaml

# https://pub.dev/packages/flutter_native_splash
splash:
	@cd example
	@fvm flutter pub run flutter_native_splash:create --path=flutter_native_splash.yaml

init-firebase:
	@cd example
	@npm install -g firebase-tools
	@firebase login
	@firebase init
#	@dart pub global activate flutterfire_cli
#	@flutterfire configure \
#		-i com.vexus.app \
#		-m com.vexus.app \
#		-a com.vexus.app \
#		-p vexus \
#		-e plugfox@gmail.com \
#		-o lib/src/common/constant/firebase_options.g.dart

# "assets/images/products\/(\d+)\/(\d+)\.jpg"
#downscale-images:
#	@cd example/assets/data/images
#	@find . -name "*.jpg" -exec mogrify -format webp {} \;
#	@find . -name "*.jpeg" -exec mogrify -format webp {} \;
#	@find . -name "*.png" -exec mogrify -format webp {} \;
#	@find . -name "*.jpg" -exec rm -f {} \;
#	@find . -name "*.jpeg" -exec rm -f {} \;
#	@find . -name "*.png" -exec rm -f {} \;
#	@find . -type f \( -name "0.webp" -o -name "1.webp" -o -name "2.webp" -o -name "3.webp" -o -name "4.webp" -o -name "5.webp" -o -name "6.webp" -o -name "7.webp" -o -name "8.webp" -o -name "9.webp" \) -exec mogrify -resize '512x512>' -quality 80 {} \;
#	@find . -name "thumbnail.webp" -exec mogrify -resize '256x256>' -quality 75 {} \;
