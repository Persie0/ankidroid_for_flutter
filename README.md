# ankidroid_for_flutter

This plugin is a flutter wrapper over the [java AnkiDroid API](https://github.com/ankidroid/Anki-Android/wiki/AnkiDroid-API). 

## Installation

### 1. Add this plugin to your pubspec

`ankidroid_for_flutter: <your version here>`

### 2. Edit your project's `android/app/build.gradle`

Add `repositories { maven { url "https://jitpack.io" } }` to the end of the file. This is because Gradle can't find the AnkiDroid java API files.

### 3. Edit your project's `android/app/src/main/AndroidManifest.xml`

In the opening `<manifest...>` tag: add `xmlns:tools="http://schemas.android.com/tools"` to the end, just after the other `xmlns` thingy. Then in the `<Application...>` tag, add `tools:replace="android:label"` above `android:label="..."`. This is because the AnkiDroid java API has an `AndroidManifest.xml` with a set value for the label, but we want to use our own label, so we do `tools:replace`.

## Usage

First you need to get the permission to use the AnkidroidAPI

```dart
await Ankidroid.askForPermission()
```

Then, create an Ankidroid instance with its own isolate by running this:

```dart
final ankiIsolate = await Ankidroid.createAnkiIsolate();
```

After this the following methods are available:

```dart
anki.addNote(modelId, deckId, fields, tags)
anki.addNotes(modelId, deckId, fieldsList, tagsList)
anki.addMedia(bytes, preferredName, mimeType)
anki.findDuplicateNotesWithKey(mid, key)
anki.findDuplicateNotesWithKeys(mid, keys)
anki.getNoteCount(mid)
anki.updateNoteTags(noteId, tags)
anki.updateNoteFields(noteId, fields)
anki.getNote(noteId)
anki.previewNewNote(mid, flds)
anki.addNewBasicModel(name)
anki.addNewBasic2Model(name)
anki.addNewCustomModel(name, fields, cards, qfmt, afmt, css, did, sortf)
anki.currentModelId()
anki.getFieldList(modelId)
anki.modelList()
anki.getModelList(minNumFields)
anki.getModelName(mid)
anki.addNewDeck(deckName)
anki.selectedDeckName()
anki.deckList()
anki.getDeckName(did)
anki.apiHostSpecVersion()
```

If you know you're not going to use `ankiIsolate` anymore, then you should kill the isolate

```dart
anki.killIsolate();
```
