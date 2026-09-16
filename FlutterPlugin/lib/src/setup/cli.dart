import 'dart:convert';
import 'dart:io';

import 'package:pub_semver/pub_semver.dart';

import 'project.dart';

Future<void> runSetup(List<String> args, {required bool checkOnly}) async {
  if (args.contains('--help') || args.contains('-h')) {
    stdout.writeln(
        'Run dart run daro_flutter:${checkOnly ? 'doctor' : 'configure'} '
        'in your Flutter app root. Reads daro.yaml with '
        'platform app_key and key_file, plus ios.admob_app_id.');
    return;
  }
  if (args.isNotEmpty) {
    stderr.writeln('Unknown arguments. Use --help.');
    exitCode = 64;
    return;
  }
  try {
    final plan = SetupPlan(Directory.current)..prepare();
    if (checkOnly) {
      final problems = await checkToolchain(plan);
      for (final path in plan.changes.keys) {
        problems.add(
          '$path needs configuration. Run dart run daro_flutter:configure.',
        );
      }
      for (final problem in problems) {
        stderr.writeln('FAIL $problem');
      }
      exitCode = problems.isEmpty ? 0 : 1;
      if (problems.isEmpty) {
        stdout.writeln(
            'PASS Daro configuration and checked toolchain requirements. '
            'Run a Flutter build to verify dependency resolution and compilation.');
      }
    } else {
      plan.apply();
      for (final path in plan.changes.keys) {
        stdout.writeln('Updated $path');
      }
      stdout.writeln(
        plan.changes.isEmpty
            ? 'Daro configuration is up to date.'
            : 'Daro configured. Run dart run daro_flutter:doctor, then your Flutter build.',
      );
      if (plan.platforms.contains('ios') && Platform.isMacOS) {
        stdout.writeln('Installing iOS pods and checking key resources...');
        final pods = await Process.run(
          'pod',
          plan.file('ios/Podfile.lock').existsSync()
              ? ['update', 'DaroAds']
              : ['install', '--repo-update'],
          workingDirectory: '${plan.root.path}/ios',
        );
        if (pods.exitCode != 0) {
          throw SetupException(
              'iOS pod update DaroAds failed. Configuration was saved. '
              'Run pod update DaroAds in ios/ to inspect the native dependency error.');
        }
        stdout.writeln('iOS pods installed.');
      } else if (plan.platforms.contains('ios')) {
        stdout.writeln('Run configure again on macOS to install iOS pods.');
      }
    }
  } on SetupException catch (error) {
    stderr.writeln('FAIL ${error.message}');
    exitCode = 1;
  } on Exception {
    stderr.writeln(
        'FAIL Could not read or update the project. Check file permissions '
        'and daro.yaml/Info.plist syntax. Integration keys are not logged.');
    exitCode = 1;
  }
}

Future<ProcessResult?> command(String executable, List<String> args) async {
  try {
    return await Process.run(executable, args, runInShell: Platform.isWindows);
  } on ProcessException {
    return null;
  }
}

Future<List<String>> checkToolchain(
  SetupPlan plan, {
  Future<ProcessResult?> Function(String, List<String>) run = command,
}) async {
  final problems = <String>[];
  final flutter = await run('flutter', ['--version', '--machine']);
  if (flutter == null || flutter.exitCode != 0) {
    problems.add('Flutter is unavailable. Add the Flutter SDK to PATH.');
  } else {
    try {
      final data = jsonDecode(flutter.stdout as String) as Map<String, dynamic>;
      if (Version.parse(data['frameworkVersion'] as String) <
          Version(3, 24, 0)) {
        problems.add('Flutter >=3.24.0 is required. Upgrade Flutter.');
      }
    } on Exception {
      problems
          .add('Could not determine Flutter version. Run flutter doctor -v.');
    }
  }
  if (plan.platforms.contains('android')) {
    final settings = plan.read(plan.gradle('android/settings'));
    final requirements = {
      'com.android.application': Version(8, 6, 0),
      'org.jetbrains.kotlin.android': Version(2, 0, 21),
    };
    for (final entry in requirements.entries) {
      final match = RegExp(
        '''id\\s*\\(?["']${RegExp.escape(entry.key)}["']\\)?\\s+version\\s+["']([^"']+)["']''',
      ).firstMatch(settings);
      if (match == null) {
        problems.add(
            'Cannot resolve ${entry.key} version in android/settings.gradle(.kts). '
            'Use a literal version >=${entry.value}.');
      } else {
        try {
          if (entry.key == 'com.android.application' && Version.parse(match[1]!).major >= 9) {
            problems.add('Flutter 1.x native dependencies require AGP 8.x. Use the verified AGP 8.7.0 / Gradle 8.10.2 toolchain.');
          }
          if (Version.parse(match[1]!) < entry.value) {
            problems.add('${entry.key} >=${entry.value} is required. '
                'Update the compatible Gradle/AGP/Kotlin toolchain together.');
          }
        } on FormatException {
          problems.add(
            'Cannot parse ${entry.key} version. Use a literal semantic version.',
          );
        }
      }
    }
    final wrapper =
        plan.read('android/gradle/wrapper/gradle-wrapper.properties');
    final gradle = RegExp(r'gradle-(\d+\.\d+(?:\.\d+)?)-').firstMatch(wrapper);
    if (gradle == null ||
        Version.parse(
              gradle[1]!.split('.').length == 2 ? '${gradle[1]}.0' : gradle[1]!,
            ) <
            Version(8, 7, 0)) {
      problems.add(
        'Gradle >=8.7 is required; use a version compatible with your AGP.',
      );
    }
    // Flutter may select Android Studio's JDK instead of PATH's java.
    final doctor = await run('flutter', ['doctor', '-v']);
    final output = doctor?.stdout as String? ?? '';
    final java =
        RegExp(r'Java version.*?(?:build |version ")(\d+)').firstMatch(output);
    if (java == null || int.parse(java[1]!) < 17) {
      problems
          .add('Could not verify Flutter uses JDK >=17. Run flutter doctor -v '
              "and configure Flutter's jdk-dir.");
    }
  }
  if (plan.platforms.contains('ios')) {
    if (!Platform.isMacOS) {
      problems.add(
        'iOS build verification requires macOS with Xcode and CocoaPods.',
      );
    } else {
      for (final tool in ['xcodebuild', 'pod']) {
        final result = await run(
          tool,
          [if (tool == 'pod') '--version' else '-version'],
        );
        if (result == null || result.exitCode != 0) {
          problems.add(
            '$tool is unavailable. Install/configure it before building iOS.',
          );
        }
      }
    }
  }
  return problems;
}
