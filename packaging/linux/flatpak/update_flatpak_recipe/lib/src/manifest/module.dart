import 'dart:convert';

import 'source.dart';

class Module {
  String? name;
  String? buildsystem;
  List<String>? onlyArches;
  List<String>? buildCommands;
  List<Source>? sources;

  Module({
    this.name,
    this.buildsystem,
    this.onlyArches,
    this.buildCommands,
    this.sources,
  });

  @override
  String toString() {
    return 'Module(name: $name, buildsystem: $buildsystem, onlyArches: $onlyArches, buildCommands: $buildCommands, sources: $sources)';
  }

  factory Module.fromMap(Map<String, dynamic> data) => Module(
        name: data['name'] as String?,
        buildsystem: data['buildsystem'] as String?,
        onlyArches: data['only-arches'].cast<String>(),
        buildCommands: data['build-commands'].cast<String>(),
        sources: (data['sources'] as List<dynamic>?)
            ?.map((e) => Source.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'buildsystem': buildsystem,
        'only-arches': onlyArches,
        'build-commands': buildCommands,
        'sources': sources?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Module].
  factory Module.fromJson(String data) {
    return Module.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Module] to a JSON string.
  String toJson() => json.encode(toMap());

  Module copyWith({
    String? name,
    String? buildsystem,
    List<String>? onlyArches,
    List<String>? buildCommands,
    List<Source>? sources,
  }) {
    return Module(
      name: name ?? this.name,
      buildsystem: buildsystem ?? this.buildsystem,
      onlyArches: onlyArches ?? this.onlyArches,
      buildCommands: buildCommands ?? this.buildCommands,
      sources: sources ?? this.sources,
    );
  }
}
