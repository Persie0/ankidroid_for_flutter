import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ankidroid_for_flutter/ankidroid_for_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAnkidroidForFlutter platform = MethodChannelAnkidroidForFlutter();
  const MethodChannel channel = MethodChannel('ankidroid_for_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
