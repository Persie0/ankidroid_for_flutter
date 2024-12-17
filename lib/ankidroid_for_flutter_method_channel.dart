import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ankidroid_for_flutter_platform_interface.dart';

/// An implementation of [AnkidroidForFlutterPlatform] that uses method channels.
class MethodChannelAnkidroidForFlutter extends AnkidroidForFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ankidroid_for_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
