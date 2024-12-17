import 'package:flutter_test/flutter_test.dart';
import 'package:ankidroid_for_flutter/ankidroid_for_flutter.dart';
import 'package:ankidroid_for_flutter/ankidroid_for_flutter_platform_interface.dart';
import 'package:ankidroid_for_flutter/ankidroid_for_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAnkidroidForFlutterPlatform
    with MockPlatformInterfaceMixin
    implements AnkidroidForFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AnkidroidForFlutterPlatform initialPlatform = AnkidroidForFlutterPlatform.instance;

  test('$MethodChannelAnkidroidForFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAnkidroidForFlutter>());
  });

  test('getPlatformVersion', () async {
    AnkidroidForFlutter ankidroidForFlutterPlugin = AnkidroidForFlutter();
    MockAnkidroidForFlutterPlatform fakePlatform = MockAnkidroidForFlutterPlatform();
    AnkidroidForFlutterPlatform.instance = fakePlatform;

    expect(await ankidroidForFlutterPlugin.getPlatformVersion(), '42');
  });
}
