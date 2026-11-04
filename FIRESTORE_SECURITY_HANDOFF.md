# Firestore Security Handoff: Compromised eMudhra Intermediate CA

_Written Nov 3, 2026, from a Firebase dependency audit of this repo, after Firebase's Nov 3, 2026 notice. Firebase guide: https://firebase.google.com/support/guides/compromised-emudhra-intermediate-ca (dated Oct 22, 2026)._

## Summary
Some eMudhra intermediate CA certificates were compromised. The Apple (iOS) Firestore SDK compiles its TLS root certificate bundle into the app binary, so older builds may trust forged certificates. That opens them to man-in-the-middle attacks on Firestore traffic.

- **Fixed versions:** Apple FirebaseFirestore **13.1.1+** (recommended), or **12.19.3**. CocoaPods tops out at **12.19.3** because Firebase 12 is the last major release on CocoaPods.
- **OS and server updates don't fix installed builds.** The app has to be rebuilt with a patched SDK, republished to the App Store, and users prompted to update.
- **Not affected:** Web, Android, and server SDKs.

## What's affected in this repo
- Firebase project `goodwyn-babynames`, bundle ID `Daniel.Baby-Names`
- `Podfile` (platform :ios, '15.0') includes unpinned `pod 'Firebase/Core'`, `pod 'Firebase/Auth'`, `pod 'Firebase/Firestore'`
- `Podfile.lock`: **FirebaseFirestore 12.18.0** (Firebase 12.18.0), `COCOAPODS: 1.17.0`. **Vulnerable.**
- Firestore is used directly in `Baby Names/DBObject.m`, `Baby Names/DBQuery.m`, and `Baby Names/DBUser.m`.
- Note: `Web-Baby-Names/App_Publishing_Handoff.md` says the iOS app became a WebView, but this code still calls Firestore directly. Assume the shipped app is affected unless you confirm the App Store build is WebView-only.

**Target:** FirebaseFirestore **12.19.3** (the highest version on CocoaPods). Moving to 13.1.1+ would mean migrating to Swift Package Manager.

## Steps
1. `cd` to the repo root and run `pod repo update`.
2. Optional: pin in `Podfile`, e.g. `pod 'Firebase/Firestore', '~> 12.19.3'` (and the same for Core/Auth).
3. Run `pod update Firebase FirebaseFirestore` (or `pod update` for all Firebase pods).
4. Confirm that `Podfile.lock` lists `FirebaseFirestore (12.19.3)`.
5. Open `Baby Names.xcworkspace`, then clean and build. Fix any warnings or errors.
6. Run the tests and do a device test of Firestore reads and writes (DBObject/DBQuery/DBUser flows).
7. Bump the build number, then archive and submit to App Store Connect.
8. After release, prompt users to update (release notes, and a minimum-version prompt if available).

## Verification checklist
- [ ] `Podfile.lock` shows FirebaseFirestore 12.19.3 (or higher)
- [ ] App builds cleanly
- [ ] Firestore reads and writes work on a real device
- [ ] New build submitted and approved on the App Store
- [ ] Users prompted to update

## Links
- Firebase guide: https://firebase.google.com/support/guides/compromised-emudhra-intermediate-ca
- Firebase iOS SDK releases: https://github.com/firebase/firebase-ios-sdk/releases
- Firebase Apple release notes: https://firebase.google.com/support/release-notes/ios
