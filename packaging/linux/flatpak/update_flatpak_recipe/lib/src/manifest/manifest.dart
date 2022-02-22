import 'dart:convert';

import 'module.dart';

class Manifest {
  String? appId;
  String? runtime;
  String? runtimeVersion;
  String? sdk;
  String? command;
  bool? separateLocales;
  List<String>? finishArgs;
  List<Module>? modules;

  Manifest({
    this.appId,
    this.runtime,
    this.runtimeVersion,
    this.sdk,
    this.command,
    this.separateLocales,
    this.finishArgs,
    this.modules,
  });

  @override
  String toString() {
    return 'Manifest(appId: $appId, runtime: $runtime, runtimeVersion: $runtimeVersion, sdk: $sdk, command: $command, separateLocales: $separateLocales, finishArgs: $finishArgs, modules: $modules)';
  }

  factory Manifest.fromMap(Map<String, dynamic> data) => Manifest(
        appId: data['app-id'] as String?,
        runtime: data['runtime'] as String?,
        runtimeVersion: data['runtime-version'] as String?,
        sdk: data['sdk'] as String?,
        command: data['command'] as String?,
        separateLocales: data['separate-locales'] as bool?,
        finishArgs: data['finish-args'].cast<String>(),
        modules: (data['modules'] as List<dynamic>?)
            ?.map((e) => Module.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'app-id': appId,
        'runtime': runtime,
        'runtime-version': runtimeVersion,
        'sdk': sdk,
        'command': command,
        'separate-locales': separateLocales,
        'finish-args': finishArgs,
        'modules': modules?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Manifest].
  factory Manifest.fromJson(String data) {
    return Manifest.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Manifest] to a JSON string.
  String toJson() => JsonEncoder.withIndent('  ').convert(toMap());

  Manifest copyWith({
    String? appId,
    String? runtime,
    String? runtimeVersion,
    String? sdk,
    String? command,
    bool? separateLocales,
    List<String>? finishArgs,
    List<Module>? modules,
  }) {
    return Manifest(
      appId: appId ?? this.appId,
      runtime: runtime ?? this.runtime,
      runtimeVersion: runtimeVersion ?? this.runtimeVersion,
      sdk: sdk ?? this.sdk,
      command: command ?? this.command,
      separateLocales: separateLocales ?? this.separateLocales,
      finishArgs: finishArgs ?? this.finishArgs,
      modules: modules ?? this.modules,
    );
  }
}
