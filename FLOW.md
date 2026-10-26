# Screenshot and demo capture

Real screenshots come from running the app with `integration_test`, not from mockups.

1. Boot a simulator:
   ```sh
   xcrun simctl boot "iPhone 17 Pro"
   ```
2. Fetch packages:
   ```sh
   flutter pub get
   ```
3. Run the capture:
   ```sh
   flutter drive --driver test_driver/integration_test.dart \
     --target integration_test/screenshot_test.dart -d "iPhone 17 Pro"
   ```

How it works:
- `integration_test/screenshot_test.dart` starts the app with a fixed clock (Saturday 7:10 PM), walks onboarding, the full daily routine (tap words, read along, storybook), progress, achievements, library, filters, story detail and the parent area, and calls `binding.takeScreenshot('NN-name')` at each key screen.
- It uses fixed `pump(Duration)` steps instead of `pumpAndSettle`, because audio and animations keep running.
- `test_driver/integration_test.dart` receives each PNG via `integrationDriver(onScreenshot:)` and writes it to `screenshots/`.

Demo GIFs: record the simulator (`xcrun simctl io booted recordVideo --codec h264 ios.mp4`) or emulator (`adb shell screenrecord --time-limit 100 /sdcard/ademo.mp4`) while the capture runs, then convert with an ffmpeg palette pass at 12 fps, 300 px wide.
