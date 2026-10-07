# Bollywood Guess

Guess the Bollywood title. The Android app is on Google Play and serves AdMob
banners, interstitials, and rewarded ads.

Version **1.1.0+5** (`versionName` 1.1.0, Play `versionCode` 5).

## AdMob IDs to create or paste

Search the repo for `TODO(admob)`. Release builds never substitute Google's
sample publisher `ca-app-pub-3940256099942544`. A placeholder is skipped, not
replaced with a sample unit.

| Slot | Already live? | Paste into | Current value |
| --- | --- | --- | --- |
| Android App ID | Yes | `AndroidManifest.xml` and `AppConstants.androidAppId` | `ca-app-pub-8661918790125012~8544493942` |
| Android banner | Yes | `AppConstants.androidBannerId` | `ca-app-pub-8661918790125012/2909023888` |
| Android rewarded | Yes | `AppConstants.androidRewardedId` | `ca-app-pub-8661918790125012/1532740336` |
| Android interstitial | Yes | `AppConstants.androidInterstitialId` | `ca-app-pub-8661918790125012/5959696196` |
| iOS App ID | **Create the iOS app** | `AppConstants.iosAppId` **and** `GAD_APPLICATION_ID` in `ios/Flutter/Release.xcconfig` (same string in both) | `ca-app-pub-8661918790125012~1000000002` |
| iOS banner | **Create this unit** | `AppConstants.iosBannerId` | `ca-app-pub-8661918790125012/TODO_IOS_BANNER` |
| iOS interstitial | **Create this unit** | `AppConstants.iosInterstitialId` | `ca-app-pub-8661918790125012/TODO_IOS_INTERSTITIAL` |
| iOS rewarded | **Create this unit** | `AppConstants.iosRewardedId` | `ca-app-pub-8661918790125012/TODO_IOS_REWARDED` |

Android banner, interstitial, and rewarded units are set. iOS is still TODO
because there is no iOS app yet. Those placeholders are skipped on Android and
do not fail an Android release build. Create an iOS app plus banner,
interstitial, and rewarded units, then paste each ID over the matching
placeholder. Leave `ios/Flutter/Debug.xcconfig` on the sample App ID so debug
runs can still show test ads.

Also publish a GDPR message (and a US state privacy message if you need one)
in AdMob → Privacy & messaging, for each app. The consent form only appears
after that message is published.

## When ads show

- **Banner** — bottom of the board during a round, after consent allows ads.
- **Rewarded** — the extra-life button on the game-over dialog.
- **Interstitial** — only between rounds. After every 4 finished rounds, the
  next "Next Round" tap may show one before the countdown. It is not shown
  during guessing, the countdown, pause, or hints. A second interstitial is
  held for at least 90 seconds. Watching the rewarded extra-life ad skips the
  following interstitial and restarts the 4-round count.

Debug and profile builds (`flutter run`, `flutter run --profile`) use Google
sample units on purpose. Store artifacts from `flutter build appbundle` and
`flutter build ipa` are release builds and use the production IDs.

## Why a release build was still a candidate for test ads

- iOS banner, rewarded, and interstitial IDs, plus `GADApplicationIdentifier`
  in `Info.plist`, were Google's sample IDs in every build mode.
- The Android interstitial ID was null, so release showed no interstitial.
- `isAdTestMode` is `!kReleaseMode`, so only debug and profile request sample
  units. A Play App Bundle is release and already used the real Android banner
  and rewarded IDs.
- `testDeviceIds` was set only outside release. It is now set only in debug
  (`EMULATOR`). Release and profile send an empty list. A phone added under
  AdMob → Settings → Test devices still receives test creatives for real unit
  IDs; remove it there when you want to confirm production fill.

Release startup calls `AppConstants.guardReleaseAdUnits()`. An assert fires in
debug and profile if a production constant contains the sample publisher.
Release builds strip asserts, so the same check throws `StateError` and will
not request the sample unit.

## Verify real ads in a release build

1. Android banner, interstitial, and rewarded IDs are already real. iOS IDs
   stay TODO until an iOS app exists.
2. Build the store artifact:

   ```bash
   flutter build appbundle --release
   ```

3. Install that release build (Play internal testing, or
   `flutter run --release` on a device). A debug install will say "Test Ad"
   even when the code is correct.
4. Use a phone that is not an AdMob test device.
5. Cold start and check logs:

   ```bash
   adb logcat | grep AdMob
   ```

   You want a line like `AdMob release units` whose banner is
   `ca-app-pub-8661918790125012/2909023888`, whose interstitial is
   `ca-app-pub-8661918790125012/5959696196`, and whose rewarded ID is
   `ca-app-pub-8661918790125012/1532740336`. Publisher `3940256099942544` should
   not appear. iOS TODO lines may be logged; they are not requested on Android.
6. Play a round. The bottom banner must not be labeled "Test Ad".
7. Lose and watch the extra-life video. That rewarded ad must not be labeled
   "Test Ad".
8. Finish 4 rounds and tap Next Round. The interstitial appears before the
   next countdown and not on top of an in-progress guess.
9. For iOS, replace the App ID in both places above, then archive the Release
   configuration. The built `GADApplicationIdentifier` must be your App ID, not
   `ca-app-pub-3940256099942544~1458002511`.

Outside the EEA, `canRequestAds` is true and no form is shown. In a regulated
region the form is shown before the Mobile Ads SDK starts, and Settings gains
"Manage ad consent" when Google requires a privacy-options entry point.

To preview that form, change only a debug build: set
`debugGeography: DebugGeography.debugGeographyEea` and add the device hash
printed by the UMP SDK to `testIdentifiers` in `lib/services/ads/consent_manager.dart`.
Release passes `consentDebugSettings: null`. Revert the debug geography before
you ship.
