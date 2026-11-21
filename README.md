# Grundrisse Study — Android app

An offline Android course for reading Karl Marx’s *Grundrisse* (the 1857–58
notebooks, *Outlines of the Critique of Political Economy*): guided lessons,
knowledge checks, interactive models, flashcards, notes, bookmarks, a
page-by-page reading tracker, and progress tracking. Built with Flutter, as a
sibling of the Capital Study app.

## Download

**[⬇ Download grundrisse-study.apk](https://github.com/MechanicalMindVonMisses/grundrisse-study-android-app/releases/latest/download/grundrisse-study.apk)** (about 49 MB, Android 7.0 or newer)

1. Open the link above on your Android phone and download the file.
2. Tap the downloaded file. If Android asks, allow your browser or file manager to install unknown apps.
3. Tap **Install**, then open **Grundrisse Study**.

The APK is not from the Play Store, so Android shows its standard warning for sideloaded apps. All releases are listed on the [Releases page](https://github.com/MechanicalMindVonMisses/grundrisse-study-android-app/releases).

Companion app: [Capital Study](https://github.com/MechanicalMindVonMisses/capital-study-android-app) for *Das Kapital*.

## What is included

- 18 lessons across six levels: the 1857 Introduction and method, the chapter
  on money, the transition to capital, surplus value, pre-capitalist forms and
  the world market, circulation time, the Fragment on Machines, and the
  manuscript’s reception.
- Two-question knowledge checks for every lesson, with explanations and saved best scores.
- Four interactive labs: the time-chit bank, productivity arithmetic,
  circulation time and turnover, and machines & disposable time.
- A searchable 42-term glossary and flashcard review mode.
- A reading room indexing all 271 sections of the manuscript by Penguin page
  number, in five parts, with an on-device “read” tracker and companion texts.
- Lesson notes, bookmarks, a notebook, and previous/next navigation.

Lesson text is original study material. It distinguishes what the notebooks
say, what *Capital* later says, and what interpreters argue. The labs are
simplified teaching models, not forecasts.

## Offline use and your data

Everything above is bundled in the app and works without a connection. There
is no account and no server: progress, scores, bookmarks, notes and read
passages are stored only on the device.

Reading Marx’s text needs the internet: passage links open the Marxists
Internet Archive (Nicolaus translation, Penguin/New Left Review 1973) in the
browser. The translation is not redistributed in the app.

## Building from source

Requires the Flutter SDK and the Android SDK.

```bash
python tool/build_course.py   # regenerate assets/data/course.json after editing tool/content_*.py
flutter pub get
flutter test
flutter build apk --release
```

The APK lands in `build/app/outputs/flutter-apk/app-release.apk`, signed with
the debug key (fine for sideloading; set up a release keystore before
publishing to Play).

## Layout

- `tool/content_*.py` — lessons, glossary and the reading-room index; `tool/build_course.py` validates and writes the JSON
- `assets/data/course.json` — generated course content
- `assets/fonts/` — Archivo, Newsreader, IBM Plex Mono (SIL OFL)
- `lib/data.dart` — models and loader
- `lib/store.dart` — on-device progress, bookmarks, notes, read passages
- `lib/theme.dart` — palette, type, shared widgets
- `lib/screens/` — home, curriculum, lesson, library, labs, glossary, notebook
