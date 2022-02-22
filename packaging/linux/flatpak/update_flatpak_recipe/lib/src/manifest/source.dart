import 'dart:convert';

class Source {
  String? type;
  String? url;
  String? sha256;
  String? tag;

  Source({this.type, this.url, this.sha256, this.tag});

  @override
  String toString() {
    return 'Source(type: $type, url: $url, sha256: $sha256, tag: $tag)';
  }

  factory Source.fromMap(Map<String, dynamic> data) => Source(
        type: data['type'] as String?,
        url: data['url'] as String?,
        sha256: data['sha256'] as String?,
        tag: data['tag'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'type': type,
        'url': url,
        'sha256': sha256,
        'tag': tag,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Source].
  factory Source.fromJson(String data) {
    return Source.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Source] to a JSON string.
  String toJson() => json.encode(toMap());

  Source copyWith({
    String? type,
    String? url,
    String? sha256,
    String? tag,
  }) {
    return Source(
      type: type ?? this.type,
      url: url ?? this.url,
      sha256: sha256 ?? this.sha256,
      tag: tag ?? this.tag,
    );
  }
}
