import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ankidroid_for_flutter_method_channel.dart';

abstract class AnkidroidForFlutterPlatform extends PlatformInterface {
  /// Constructs a AnkidroidForFlutterPlatform.
  AnkidroidForFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static AnkidroidForFlutterPlatform _instance = MethodChannelAnkidroidForFlutter();

  /// The default instance of [AnkidroidForFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelAnkidroidForFlutter].
  static AnkidroidForFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AnkidroidForFlutterPlatform] when
  /// they register themselves.
  static set instance(AnkidroidForFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
