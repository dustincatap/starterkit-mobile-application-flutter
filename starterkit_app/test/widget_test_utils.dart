// ignore_for_file: prefer-static-class

import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:platform/platform.dart' as pl;
import 'package:starterkit_app/core/service_registrar.dart';

import 'test_utils.dart';

Future<void> setUpWidgetTest() async {
  ServiceRegistrar.registerDependencies();
  await setupLocale();
  await loadFonts();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
}

Future<void> loadFonts() async {
  final Future<ByteData> robotoLight = rootBundle.load('assets/fonts/Roboto-Light.ttf');
  final Future<ByteData> robotoRegular = rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  final Future<ByteData> robotoMedium = rootBundle.load('assets/fonts/Roboto-Medium.ttf');
  final Future<ByteData> robotoBold = rootBundle.load('assets/fonts/Roboto-Bold.ttf');
  final FontLoader robotoFontLoader = FontLoader('Roboto')
    ..addFont(robotoLight)
    ..addFont(robotoRegular)
    ..addFont(robotoMedium)
    ..addFont(robotoBold);
  await robotoFontLoader.load();

  final Future<ByteData> materialIcon = _loadMaterialIcon();
  final FontLoader materialLoader = FontLoader('MaterialIcons')..addFont(materialIcon);
  await materialLoader.load();
}

Future<ByteData> _loadMaterialIcon() {
  const FileSystem fs = LocalFileSystem();
  const pl.LocalPlatform platform = pl.LocalPlatform();
  final Directory flutterRoot = fs.directory(platform.environment['FLUTTER_ROOT']);

  final File iconFont = flutterRoot.childFile(
    fs.path.join('bin', 'cache', 'artifacts', 'material_fonts', 'MaterialIcons-Regular.otf'),
  );

  final Future<ByteData> bytes = Future<ByteData>.value(iconFont.readAsBytesSync().buffer.asByteData());

  return bytes;
}

class Device {
  static const Device phone = Device(name: 'phone', pixelRatio: 2.0, size: Size(828, 1792));
  static const Device tablet = Device(name: 'tablet', pixelRatio: 2.0, size: Size(1536, 2048));
  static const List<Device> all = <Device>[phone, tablet];

  final String name;
  final double pixelRatio;
  final Size size;

  const Device({required this.name, required this.pixelRatio, required this.size});
}

extension WidgetTesterExtension on WidgetTester {
  Future<void> waitFor(Finder finder, {Duration timeout = const Duration(seconds: 30)}) async {
    bool timerDone = false;
    final Timer timer = Timer(timeout, () => debugPrint('Pump until has timed out'));
    while (!timerDone) {
      await pump();

      final bool found = any(finder);
      if (found) {
        timerDone = true;
      }
    }
    timer.cancel();
  }

  void setupDevice(Device device) {
    view.devicePixelRatio = device.pixelRatio;
    view.physicalSize = device.size;
  }

  Object matchGoldenFile(String name, Device device) {
    // Specify golden files to match depending on platform OS that rendered them
    // See https://github.com/flutter/flutter/issues/56383
    final String platformGolden = join('goldens', Platform.operatingSystem, device.name, '${name}_golden.png');
    return matchesGoldenFile(platformGolden);
  }
}
