import 'dart:io';
import 'dart:isolate';

import 'package:pub_semver/pub_semver.dart';
import 'package:xml/xml.dart';
import 'package:yaml/yaml.dart';

import 'requirements.dart';

class SetupException implements Exception {
  SetupException(this.message);
  final String message;
  @override
  String toString() => message;
}

class SetupPlan {
  SetupPlan(this.root, {this.iosResourceTool});
  final Uri? iosResourceTool;
  final Directory root;
  final Map<String, String> changes = {};
  final Set<String> platforms = {};

  File file(String path) => File('${root.path}/$path');
  String read(String path) {
    if (!file(path).existsSync()) {
      throw SetupException(
        '$path is missing. Run this command in a Flutter app.',
      );
    }
    return file(path).readAsStringSync();
  }

  void stage(String path, String content) {
    if (!file(path).existsSync() || read(path) != content) {
      changes[path] = content;
    }
  }

  void prepare() {
    read('pubspec.yaml');
    final Object? config;
    try {
      config = loadYaml(read('daro.yaml'));
    } on YamlException {
      throw SetupException('Invalid daro.yaml. Check YAML syntax.');
    }
    if (config is! YamlMap || config.isEmpty) {
      throw SetupException(
        'daro.yaml needs an ios and/or android section.',
      );
    }
    for (final platform in config.keys) {
      if (platform != 'ios' && platform != 'android') {
        throw SetupException(
          'daro.yaml supports only ios and android sections.',
        );
      }
      final section = config[platform];
      final fields = platform == 'ios'
          ? {'app_key', 'key_file', 'admob_app_id'}
          : {'app_key', 'key_file'};
      if (section is! YamlMap || section.keys.any((key) => !fields.contains(key))) {
        throw SetupException('$platform requires ${fields.join(', ')}.');
      }
      for (final field in fields) {
        if (section[field] is! String || (section[field] as String).trim().isEmpty) {
          throw SetupException('$platform.$field must be a nonempty string.');
        }
      }
      final key = section['app_key'] as String;
      if (!RegExp(r'^[A-Za-z0-9_+/=.-]+$').hasMatch(key)) {
        throw SetupException('$platform.app_key must be a single key token.');
      }
      final source = section['key_file'] as String;
      final keyFile = File(source).isAbsolute ? File(source) : file(source);
      if (!keyFile.existsSync() || keyFile.readAsStringSync().trim().isEmpty) {
        throw SetupException('$platform.key_file is missing or empty.');
      }
      platforms.add(platform as String);
      if (platform == 'android') {
        _android(key);
        stage('android/app/android-daro-key.txt', keyFile.readAsStringSync());
      } else {
        final admob = section['admob_app_id'] as String;
        if (!RegExp(r'^ca-app-pub-\d+~\d+$').hasMatch(admob)) {
          throw SetupException('ios.admob_app_id must be an AdMob application ID.');
        }
        _ios(key, admob);
        stage('ios/Runner/ios-daro-key.txt', keyFile.readAsStringSync());
      }
    }
  }

  void apply() {
    for (final entry in changes.entries) {
      file(entry.key).parent.createSync(recursive: true);
      file(entry.key).writeAsStringSync(entry.value);
    }
  }

  String gradle(String base) {
    final paths = ['$base.gradle', '$base.gradle.kts']
        .where((path) => file(path).existsSync())
        .toList();
    if (paths.length != 1) {
      throw SetupException('Expected one $base.gradle or $base.gradle.kts.');
    }
    return paths.single;
  }

  void _android(String key) {
    final rootPath = gradle('android/build');
    final appPath = gradle('android/app/build');
    final settingsPath = gradle('android/settings');
    final settings = read(settingsPath);
    final app = read(appPath);
    if (RegExp(r'productFlavors\s*\{').hasMatch(app)) {
      throw SetupException(
        'Android productFlavors need per-flavor keys; automatic configuration currently supports a single app.',
      );
    }
    if (!app.contains('com.android.application')) {
      throw SetupException('$appPath must apply com.android.application.');
    }
    if (settings.contains('dependencyResolutionManagement')) {
      throw SetupException(
        '$settingsPath uses dependencyResolutionManagement. Automatic configuration currently supports Flutter project-level repositories.',
      );
    }
    var rootGradle = read(rootPath);
    final unmanagedRoot = removeBlock(rootGradle, 'android-build');
    if (unmanagedRoot.contains('so.daro:daro-plugin:')) {
      throw SetupException(
        '$rootPath already configures Daro manually. Remove the old Daro classpath before configure.',
      );
    }
    final repositories = mavenRepositories
        .map((url) => '        maven { url = uri("$url") }')
        .join('\n');
    rootGradle = managedBlock(
      rootGradle,
      'android-build',
      '''
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("$gradlePlugin")
    }
}
allprojects {
    repositories {
        google()
        mavenCentral()
$repositories
    }
}''',
      prepend: true,
    );
    if (RegExp(r'^\s*(import\s|plugins\s*\{)', multiLine: true)
        .hasMatch(unmanagedRoot)) {
      throw SetupException(
        '$rootPath has imports or a plugins block; this root script layout needs manual integration.',
      );
    }
    final unmanagedApp = removeBlock(app, 'android-app');
    if (RegExp(r'''["']so\.daro(?:\.[am])?["']''').hasMatch(unmanagedApp)) {
      throw SetupException(
        '$appPath already applies Daro manually. Remove the old Daro plugin application before configure.',
      );
    }
    if (file('android/app/daro.gradle').existsSync() &&
        !read('android/app/daro.gradle')
            .trimLeft()
            .startsWith('// Generated by daro_flutter:configure.')) {
      throw SetupException(
          'android/app/daro.gradle already exists and is not managed by Daro configure. Move or rename it before configuring.',);
    }
    stage(rootPath, rootGradle);
    stage(
      appPath,
      managedBlock(
        app,
        'android-app',
        appPath.endsWith('.kts')
            ? 'apply(from = "daro.gradle")'
            : "apply from: 'daro.gradle'",
      ),
    );
    stage('android/app/daro.gradle', '''
// Generated by daro_flutter:configure. Re-run after SDK updates.
apply plugin: 'so.daro.a'
android {
    if (ndkVersion == null || org.gradle.util.GradleVersion.version(ndkVersion) < org.gradle.util.GradleVersion.version('$androidNdk')) {
        ndkVersion '$androidNdk'
    }
    compileSdkVersion Math.max(compileSdkVersion.replace('android-', '').toInteger(), $androidCompileSdk)
    defaultConfig {
        minSdkVersion Math.max(minSdkVersion.apiLevel, $androidMinSdk)
    }
    compileOptions {
        coreLibraryDesugaringEnabled true
    }
}
dependencies {
    coreLibraryDesugaring '$desugarLibrary'
}
''');
    var properties = read('android/gradle.properties');
    properties = setProperty(properties, 'daroAppKey', key);
    properties = setProperty(properties, 'android.useAndroidX', 'true');
    properties = setProperty(properties, 'android.enableJetifier', 'true');
    stage('android/gradle.properties', properties);
  }

  void _ios(String key, String admob) {
    final template = flutterPodfileTemplate();
    var podfile =
        file('ios/Podfile').existsSync() ? read('ios/Podfile') : template;
    final templateMinimum =
        RegExp(r"platform :ios, '([0-9]+)\.").firstMatch(template);
    final minimum = templateMinimum == null
        ? iosMinimum
        : int.parse(templateMinimum[1]!) > iosMinimum
            ? int.parse(templateMinimum[1]!)
            : iosMinimum;
    final project = read('ios/Runner.xcodeproj/project.pbxproj');
    final plistPaths = RegExp(r'\bINFOPLIST_FILE = "?([^";]+)"?;')
        .allMatches(project)
        .map((match) => match[1])
        .toSet();
    if (plistPaths.length != 1 || plistPaths.single != 'Runner/Info.plist') {
      throw SetupException(
        'iOS requires a standard Runner target using Runner/Info.plist; custom targets/plists need manual integration.',
      );
    }
    final platform =
        RegExp(r'''^\s*platform :ios, ['"]([0-9.]+)['"]''', multiLine: true);
    if (platform.hasMatch(podfile)) {
      podfile = podfile.replaceFirstMapped(
        platform,
        (match) => parseIosVersion(match[1]!) < Version(minimum, 0, 0)
            ? "platform :ios, '$minimum.0'"
            : match[0]!,
      );
    } else {
      podfile = "platform :ios, '$minimum.0'\n$podfile";
    }
    if (!RegExp(r'^\s*use_frameworks!', multiLine: true).hasMatch(podfile)) {
      final runner =
          RegExp(r'''^target ['"]Runner['"] do[ \t]*$''', multiLine: true);
      if (runner.allMatches(podfile).length != 1) {
        throw SetupException(
          'ios/Podfile needs one Runner target to configure framework linkage.',
        );
      }
      podfile = podfile.replaceFirstMapped(
        runner,
        (match) => '${match[0]}\n  use_frameworks! :linkage => :static',
      );
    }
    final frameworkPath = 'ios/Flutter/AppFrameworkInfo.plist';
    if (!file(frameworkPath).existsSync()) {
      throw SetupException('$frameworkPath is missing. Restore the Flutter framework plist before configuring.');
    }
    final framework = XmlDocument.parse(read(frameworkPath));
    final frameworkDict = framework.getElement('plist')?.getElement('dict');
    if (frameworkDict == null) {
      throw SetupException('AppFrameworkInfo.plist must be an XML plist dictionary.');
    }
    final minimumKey = frameworkDict
        .findElements('key')
        .where((element) => element.innerText == 'MinimumOSVersion')
        .firstOrNull;
    final value = minimumKey?.nextElementSibling;
    if (value == null ||
        parseIosVersion(value.innerText) < Version(minimum, 0, 0)) {
      setPlistString(frameworkDict, 'MinimumOSVersion', '$minimum.0');
      stage(frameworkPath, '${framework.toXmlString().trimRight()}\n');
    }
    final doc = XmlDocument.parse(read('ios/Runner/Info.plist'));
    final dict = doc.getElement('plist')?.getElement('dict');
    if (dict == null) {
      throw SetupException(
        'Runner/Info.plist must be an XML plist dictionary.',
      );
    }
    setPlistString(dict, 'DaroAppKey', key);
    setPlistString(dict, 'GADApplicationIdentifier', admob);
    mergeSkAdNetworks(dict);
    stage('ios/Runner/Info.plist', '${doc.toXmlString().trimRight()}\n');
    stage('ios/Podfile', podfile);
    stage(
      'ios/Runner.xcodeproj/project.pbxproj',
      registerIosKeyResource(project.replaceAllMapped(
        RegExp('IPHONEOS_DEPLOYMENT_TARGET = ([0-9.]+);'),
        (match) => parseIosVersion(match[1]!) < Version(minimum, 0, 0)
            ? 'IPHONEOS_DEPLOYMENT_TARGET = $minimum.0;'
            : match[0]!,
      ), tool: iosResourceTool, minimum: minimum,),
    );
  }
}

Version parseIosVersion(String value) {
  if (!RegExp(r'^\d+(?:\.\d+){0,2}$').hasMatch(value)) {
    throw SetupException('Invalid iOS deployment version. Use major.minor.patch.');
  }
  final parts = value.split('.').map(int.parse).toList();
  return Version(
    parts[0],
    parts.length > 1 ? parts[1] : 0,
    parts.length > 2 ? parts[2] : 0,
  );
}

void setPlistString(XmlElement dict, String name, String value) {
  final keys =
      dict.findElements('key').where((key) => key.innerText == name).toList();
  if (keys.length > 1) throw SetupException('Duplicate $name in Info.plist.');
  if (keys.isNotEmpty) {
    final next = keys.single.nextElementSibling;
    if (next == null || next.name.local != 'string') {
      throw SetupException('$name in Info.plist must be a string.');
    }
    next.innerText = value;
  } else {
    dict.children.addAll([
      XmlText('\n\t'),
      XmlElement(XmlName('key'), [], [XmlText(name)]),
      XmlText('\n\t'),
      XmlElement(XmlName('string'), [], [XmlText(value)]),
      XmlText('\n'),
    ]);
  }
}

String setProperty(String source, String name, String value) {
  final pattern =
      RegExp('^[ \t]*${RegExp.escape(name)}[ \\t]*[=:].*\$', multiLine: true);
  if (pattern.allMatches(source).length > 1) {
    throw SetupException('Duplicate $name in gradle.properties.');
  }
  if (pattern.hasMatch(source)) {
    return source.replaceFirst(pattern, '$name=$value');
  }
  return '${source.trimRight()}\n$name=$value\n';
}

String removeBlock(String source, String name, {String comment = '//'}) {
  final start = '$comment BEGIN daro $name';
  final end = '$comment END daro $name';
  if (!source.contains(start) && !source.contains(end)) return source;
  if (start.allMatches(source).length != 1 ||
      end.allMatches(source).length != 1 ||
      source.indexOf(end) < source.indexOf(start)) {
    throw SetupException(
      'Invalid Daro managed block: $name. Restore its markers.',
    );
  }
  return source.replaceFirst(
    RegExp('${RegExp.escape(start)}[\\s\\S]*?${RegExp.escape(end)}\\n?'),
    '',
  );
}

String managedBlock(
  String source,
  String name,
  String body, {
  bool prepend = false,
}) {
  final block = '// BEGIN daro $name\n$body\n// END daro $name\n';
  final start = '// BEGIN daro $name';
  if (source.contains(start)) {
    removeBlock(source, name); // Validate before replacement.
    return source.replaceFirst(
      RegExp(
        '${RegExp.escape(start)}[\\s\\S]*?// END daro ${RegExp.escape(name)}\\n?',
      ),
      block,
    );
  }
  return prepend ? '$block$source' : '${source.trimRight()}\n$block';
}

String flutterPodfileTemplate() {
  var directory = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 7; i++) {
    for (final name in ['Podfile-ios', 'Podfile-ios-swift']) {
      final template = File('${directory.path}/packages/flutter_tools/templates/cocoapods/$name');
      if (template.existsSync()) return template.readAsStringSync();
    }
    directory = directory.parent;
  }
  throw SetupException(
    "Could not locate Flutter's Podfile template. Run with the dart executable bundled with Flutter.",
  );
}

void mergeSkAdNetworks(XmlElement dict) {
  final keys = dict
      .findElements('key')
      .where((key) => key.innerText == 'SKAdNetworkItems')
      .toList();
  if (keys.length > 1) {
    throw SetupException('Duplicate SKAdNetworkItems in Info.plist.');
  }
  XmlElement array;
  if (keys.isEmpty) {
    array = XmlElement(XmlName('array'));
    dict.children.addAll([
      XmlText('\n\t'),
      XmlElement(XmlName('key'), [], [XmlText('SKAdNetworkItems')]),
      XmlText('\n\t'),
      array,
      XmlText('\n'),
    ]);
  } else {
    final next = keys.single.nextElementSibling;
    if (next == null || next.name.local != 'array') {
      throw SetupException('SKAdNetworkItems must be an array.');
    }
    array = next;
  }
  final existing =
      array.findAllElements('string').map((item) => item.innerText).toSet();
  for (final id in skAdNetworkIds.where((id) => !existing.contains(id))) {
    array.children.add(
      XmlElement(XmlName('dict'), [], [
        XmlElement(XmlName('key'), [], [XmlText('SKAdNetworkIdentifier')]),
        XmlElement(XmlName('string'), [], [XmlText(id)]),
      ]),
    );
  }
}

String registerIosKeyResource(String project, {Uri? tool, int minimum = iosMinimum}) {
  final script = tool ?? Isolate.resolvePackageUriSync(
    Uri.parse('package:daro_flutter/src/setup/ios_resources.rb'),
  );
  if (script == null) throw SetupException('Could not locate iOS resource tool.');
  final temporary = Directory.systemTemp.createTempSync('daro-project-');
  try {
    final path = '${temporary.path}/Runner.xcodeproj';
    final file = File('$path/project.pbxproj');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(project);
    final result = Process.runSync('ruby', [script.toFilePath(), path, '$minimum.0']);
    if (result.exitCode != 0) {
      throw SetupException('Could not configure Runner key resources. Ensure Ruby can load the CocoaPods xcodeproj gem and Runner is the only app target.');
    }
    return file.readAsStringSync();
  } on ProcessException {
    throw SetupException('iOS resource configuration requires Ruby and the CocoaPods xcodeproj gem.');
  } finally {
    temporary.deleteSync(recursive: true);
  }
}
