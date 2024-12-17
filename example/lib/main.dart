import 'package:flutter/material.dart';

import 'package:ankidroid_for_flutter/ankidroid_for_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Ankidroid? anki;
  String ankiText = '';

  @override
  void initState() {
    super.initState();
    Ankidroid.createAnkiIsolate().then((value) => setState(() => anki = value));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Ankidroid'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await Ankidroid.askForPermission();
                },
                child: const Text("Ask for permission")
              ),
              ElevatedButton(
                onPressed: anki == null ? null : () async {
                  final result = await anki!.deckList();

                  setState(() => ankiText = result.asValue?.value.toString() ?? result.asError!.error.toString());
                },
                child: anki == null ? const CircularProgressIndicator() :  const Text('Get Anki Data', style: TextStyle(fontSize: 42))
              ),
              SizedBox(
                height: 400,
                child: SingleChildScrollView(
                  child: Text(
                    ankiText,
                    style: const TextStyle(fontSize: 42),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
