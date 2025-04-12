import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:async/async.dart';

import 'util/future_result.dart';
export 'util/note_info.dart' show NoteInfo;

/// A Flutter plugin for interacting with AnkiDroid.
///
/// This plugin allows you to add notes, cards, decks, and models to AnkiDroid,
/// as well as query existing content.
class Ankidroid {
  final Isolate _isolate;
  final SendPort _ankiPort;

  const Ankidroid._(this._isolate, this._ankiPort);

  /// Creates a new isolate for AnkiDroid operations.
  ///
  /// If you hot restart your app, the isolate won't be killed, and vscode
  /// will show another isolate in your call stack. not that big of a deal.
  ///
  /// Note: `askForPermission` needs to be called before trying to use any
  /// functions of this isolate.
  static Future<Ankidroid> createAnkiIsolate() async {
    WidgetsFlutterBinding.ensureInitialized();

    final rPort = ReceivePort();
    final isolate = await Isolate.spawn(
      _isolateFunction,
      rPort.sendPort,
      debugName: "AnkiDroid",
    );
    final ankiPort = await rPort.first;
    ankiPort.send({"rootIsolateToken": ServicesBinding.rootIsolateToken});

    return Ankidroid._(isolate, ankiPort);
  }

  /// Ask for permission to communicate with AnkiDroid.
  ///
  /// This opens a dialog that the user needs to agree to.
  ///
  /// Note: this needs to be called before trying to use any functions of an
  /// AnkiDroid isolate.
  ///
  /// Returns a boolean indicating whether permission was granted.
  static Future<bool> askForPermission() async {
    const m = MethodChannel("ankidroid_for_flutter");
    bool ret = await m.invokeMethod("requestPremission");

    return ret;
  }

  /// Kills the isolate used for AnkiDroid operations.
  void killIsolate() => _isolate.kill();

  /// Tests the connection to AnkiDroid.
  ///
  /// Returns 'Test Successful!' if the connection is working properly.
  Future<Result<String>> test() async {
    final rPort = ReceivePort();
    _ankiPort.send({'functionName': 'test', 'sendPort': rPort.sendPort});

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Adds a new note to AnkiDroid.
  ///
  /// Parameters:
  /// - [modelId]: The ID of the model to use (sometimes called mid)
  /// - [deckId]: The ID of the deck to add the note to (sometimes called did)
  /// - [fields]: List of field values for the note. Length should match the number of fields in the model.
  /// - [tags]: List of tags to add to the note.
  ///
  /// Returns the ID of the newly created note.
  ///
  /// Note: Get modelId and deckId using `modelList()` and `deckList()`.
  Future<Result<int>> addNote(
    int modelId,
    int deckId,
    List<String> fields,
    List<String> tags,
  ) async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'addNote',
      'sendPort': rPort.sendPort,
      'modelId': modelId,
      'deckId': deckId,
      'fields': fields,
      'tags': tags,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Adds multiple notes to AnkiDroid in a single operation.
  ///
  /// Parameters:
  /// - [modelId]: The ID of the model to use (sometimes called mid)
  /// - [deckId]: The ID of the deck to add the notes to (sometimes called did)
  /// - [fieldsList]: List of field arrays, one per note. Each array length should match the number of fields in the model.
  /// - [tagsList]: List of tag lists, one per note.
  ///
  /// Returns the number of notes successfully added.
  Future<Result<int>> addNotes(
    int modelId,
    int deckId,
    List<List<String>> fieldsList,
    List<List<String>> tagsList,
  ) async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'addNotes',
      'sendPort': rPort.sendPort,
      'modelId': modelId,
      'deckId': deckId,
      'fieldsList': fieldsList,
      'tagsList': tagsList,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Adds media (image or audio) to AnkiDroid's media collection.
  ///
  /// Parameters:
  /// - [bytes]: The binary data of the media file.
  /// - [preferredName]: The preferred name for the file (will be part of the final filename).
  /// - [mimeType]: The MIME type of the media, either 'audio' or 'image'.
  ///
  /// Returns a string that can be used in a note field to reference the media:
  /// - For images: `<img src="filename" />`
  /// - For audio: `[sound:filename]`
  ///
  /// The actual filename will be `$preferredName_$randomNumber`.
  Future<Result<String>> addMedia(
    Uint8List bytes,
    String preferredName,
    String mimeType,
  ) async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'addMedia',
      'sendPort': rPort.sendPort,
      'bytes': bytes,
      'preferredName': preferredName,
      'mimeType': mimeType,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Finds duplicate notes with a specific key (first field value).
  ///
  /// Parameters:
  /// - [mid]: The model ID to search within.
  /// - [key]: The value of the first field to search for.
  ///
  /// Returns a list of NoteInfo objects for duplicate notes.
  /// Consider using the NoteInfo class from util/note_info.dart.
  Future<Result<List<dynamic>>> findDuplicateNotesWithKey(
    int mid,
    String key,
  ) async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'findDuplicateNotesWithKey',
      'sendPort': rPort.sendPort,
      'mid': mid,
      'key': key,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Finds duplicate notes with multiple keys (first field values).
  ///
  /// Parameters:
  /// - [mid]: The model ID to search within.
  /// - [keys]: List of first field values to search for.
  ///
  /// Returns a list of lists of NoteInfo objects, one list per key.
  /// Consider using the NoteInfo class from util/note_info.dart.
  Future<Result<List<dynamic>>> findDuplicateNotesWithKeys(
    int mid,
    List<String> keys,
  ) async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'findDuplicateNotesWithKeys',
      'sendPort': rPort.sendPort,
      'mid': mid,
      'keys': keys,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Gets the number of notes for a specific model.
  ///
  /// Parameters:
  /// - [mid]: The model ID to count notes for.
  ///
  /// Returns the number of notes with the specified model ID.
  Future<Result<int>> getNoteCount(int mid) async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'getNoteCount',
      'sendPort': rPort.sendPort,
      'mid': mid,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Updates the tags for a specific note.
  ///
  /// Parameters:
  /// - [noteId]: The ID of the note to update.
  /// - [tags]: The new list of tags for the note.
  ///
  /// Returns a boolean indicating whether the update was successful.
  Future<Result<bool>> updateNoteTags(int noteId, List<String> tags) async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'updateNoteTags',
      'sendPort': rPort.sendPort,
      'noteId': noteId,
      'tags': tags,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Updates the fields for a specific note.
  ///
  /// Parameters:
  /// - [noteId]: The ID of the note to update.
  /// - [fields]: The new field values for the note.
  ///
  /// Returns a boolean indicating whether the update was successful.
  Future<Result<bool>> updateNoteFields(int noteId, List<String> fields) async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'updateNoteFields',
      'sendPort': rPort.sendPort,
      'noteId': noteId,
      'fields': fields,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Gets the content of a specific note.
  ///
  /// Parameters:
  /// - [noteId]: The ID of the note to retrieve.
  ///
  /// Returns a map containing the note's ID, fields, and tags.
  /// Consider using the NoteInfo class from util/note_info.dart.
  Future<Result<Map<dynamic, dynamic>>> getNote(int noteId) async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'getNote',
      'sendPort': rPort.sendPort,
      'noteId': noteId,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Previews how a new note would look with the specified fields.
  ///
  /// Parameters:
  /// - [mid]: The model ID to use for the preview.
  /// - [flds]: The field values to preview.
  ///
  /// Returns a map of card names to their HTML content (question and answer).
  Future<Result<Map<dynamic, dynamic>>> previewNewNote(
    int mid,
    List<String> flds,
  ) async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'previewNewNote',
      'sendPort': rPort.sendPort,
      'mid': mid,
      'flds': flds,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Creates a new basic model with two fields (Front and Back) and one card.
  ///
  /// Parameters:
  /// - [name]: The name for the new model.
  ///
  /// Returns the ID of the newly created model.
  Future<Result<int>> addNewBasicModel(String name) async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'addNewBasicModel',
      'sendPort': rPort.sendPort,
      'name': name,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Creates a new basic model with two fields (Front and Back) and two cards.
  ///
  /// The first card goes from front to back, and the second goes from back to front.
  ///
  /// Parameters:
  /// - [name]: The name for the new model.
  ///
  /// Returns the ID of the newly created model.
  Future<Result<int>> addNewBasic2Model(String name) async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'addNewBasic2Model',
      'sendPort': rPort.sendPort,
      'name': name,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Creates a new custom model with specified fields and card templates.
  ///
  /// Parameters:
  /// - [name]: The name for the new model.
  /// - [fields]: List of field names for the model.
  /// - [cards]: List of card template names.
  /// - [qfmt]: List of question format strings for each card template.
  /// - [afmt]: List of answer format strings for each card template.
  /// - [css]: CSS styling for the cards.
  /// - [did]: Default deck ID for cards created with this model (optional).
  /// - [sortf]: Index of the field to use for sorting (optional).
  ///
  /// Returns the ID of the newly created model.
  ///
  /// For more information on templates, see the [Anki Desktop Manual](https://docs.ankiweb.net/templates/intro.html).
  Future<Result<int>> addNewCustomModel(
    String name,
    List<String> fields,
    List<String> cards,
    List<String> qfmt,
    List<String> afmt,
    String css,
    int? did,
    int? sortf,
  ) async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'addNewCustomModel',
      'sendPort': rPort.sendPort,
      'name': name,
      'fields': fields,
      'cards': cards,
      'qfmt': qfmt,
      'afmt': afmt,
      'css': css,
      'did': did,
      'sortf': sortf,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Gets the ID of the currently selected model.
  ///
  /// Returns the model ID of the currently selected model.
  Future<Result<int>> currentModelId() async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'currentModelId',
      'sendPort': rPort.sendPort,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Gets the list of field names for a specific model.
  ///
  /// Parameters:
  /// - [modelId]: The ID of the model to get fields for.
  ///
  /// Returns a list of field names.
  /// If you need a List<String>, consider using List<String>.from(fieldList).
  Future<Result<List<dynamic>>> getFieldList(int modelId) async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'getFieldList',
      'sendPort': rPort.sendPort,
      'modelId': modelId,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Gets a map of all model IDs and names.
  ///
  /// Returns a map where keys are model IDs and values are model names.
  Future<Result<Map<dynamic, dynamic>>> modelList() async {
    final rPort = ReceivePort();
    _ankiPort.send({'functionName': 'modelList', 'sendPort': rPort.sendPort});

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Gets a map of model IDs and names with at least the specified number of fields.
  ///
  /// Parameters:
  /// - [minNumFields]: The minimum number of fields a model must have to be included.
  ///
  /// Returns a map where keys are model IDs and values are model names.
  /// Use 0 for minNumFields to include all models.
  Future<Result<Map<dynamic, dynamic>>> getModelList(int minNumFields) async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'getModelList',
      'sendPort': rPort.sendPort,
      'minNumFields': minNumFields,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Gets the name of a model by its ID.
  ///
  /// Parameters:
  /// - [mid]: The ID of the model.
  ///
  /// Returns the name of the model.
  Future<Result<String>> getModelName(int mid) async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'getModelName',
      'sendPort': rPort.sendPort,
      'mid': mid,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Creates a new deck with the specified name.
  ///
  /// Parameters:
  /// - [deckName]: The name for the new deck.
  ///
  /// Returns the ID of the newly created deck.
  Future<Result<int>> addNewDeck(String deckName) async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'addNewDeck',
      'sendPort': rPort.sendPort,
      'deckName': deckName,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Gets the name of the currently selected deck.
  ///
  /// Returns the name of the currently selected deck.
  Future<Result<String>> selectedDeckName() async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'selectedDeckName',
      'sendPort': rPort.sendPort,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Gets a map of all deck IDs and names.
  ///
  /// Returns a map where keys are deck IDs and values are deck names.
  Future<Result<Map<dynamic, dynamic>>> deckList() async {
    final rPort = ReceivePort();
    _ankiPort.send({'functionName': 'deckList', 'sendPort': rPort.sendPort});

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Gets the name of a deck by its ID.
  ///
  /// Parameters:
  /// - [did]: The ID of the deck.
  ///
  /// Returns the name of the deck.
  Future<Result<String>> getDeckName(int did) async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'getDeckName',
      'sendPort': rPort.sendPort,
      'did': did,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Gets the API specification version of the installed AnkiDroid app.
  ///
  /// This is not the same as the AnkiDroid app version code.
  ///
  /// Returns the API specification version number.
  Future<Result<int>> apiHostSpecVersion() async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'apiHostSpecVersion',
      'sendPort': rPort.sendPort,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  /// Checks if the app has permission to interact with AnkiDroid.
  ///
  /// Returns a boolean indicating whether permission is granted.
  Future<Result<bool>> checkPermission() async {
    final rPort = ReceivePort();
    _ankiPort.send({
      'functionName': 'checkPermission',
      'sendPort': rPort.sendPort,
    });

    final ret = await rPort.first;
    return mapToResult(ret);
  }

  @pragma('vm:entry-point')
  static Future<void> _isolateFunction(SendPort sendPort) async {
    final ankiPort = ReceivePort();
    sendPort.send(ankiPort.sendPort);

    const methodChannel = MethodChannel('ankidroid_for_flutter');

    await for (Map<String, dynamic> msg in ankiPort) {
      if (msg.containsKey("rootIsolateToken")) {
        BackgroundIsolateBinaryMessenger.ensureInitialized(
          msg["rootIsolateToken"],
        );
        continue;
      }

      msg['sendPort'].send(
        await futureToResultMap(
          () async => await methodChannel.invokeMethod(
            msg['functionName'],
            msg
              ..remove('functionName')
              ..remove('sendPort'),
          ),
        ),
      );
    }
  }
}
