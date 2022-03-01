import 'dart:io';

import 'package:intl/intl.dart';
import 'package:update_flatpak_recipe/src/src.dart';
import 'package:xml/xml.dart';

Future<void> main(List<String> arguments) async {
  projectId = arguments[0];
  repository = arguments[1];
  user = arguments[2];

  final githubInfo = await GitHubInfo.fetch(
    projectId: projectId,
    repository: repository,
    user: user,
  );

  if (githubInfo.linuxAssetName == null) {
    throw Exception('Asset not found.');
  }

  await updateManifest(projectId, githubInfo);
  updateMetainfo(projectId, githubInfo);
}

/// Update the $projectId.json manifest file with the necessary info from
/// the latest release: tag / version and sha256 of the linux asset.
Future<void> updateManifest(String projectId, GitHubInfo githubInfo) async {
  final manifestFile = File(projectId + '.json');
  String manifestJson = manifestFile.readAsStringSync();

  final manifest = Manifest.fromJson(manifestJson);

  manifest.modules?.first.sources = <Source>[
    Source(
      type: 'file',
      url: githubInfo.linuxAssetName?.browserDownloadUrl,
      sha256: await githubInfo.linuxAssetHash(),
    ),
    Source(
      type: 'git',
      url: githubInfo.repo.cloneUrl,
      tag: githubInfo.latestRelease.tagName,
    ),
    Source(
      type: 'file',
      path: projectId + '.metainfo.xml',
    ),
  ];

  manifestJson = manifest.toJson();
  manifestFile.writeAsStringSync(manifestJson);
}

/// Update the $projectId.metainfo.xml file with the
/// date and version of the new release.
void updateMetainfo(String projectId, GitHubInfo githubInfo) {
  final metainfoFile = File(projectId + '.metainfo.xml');
  final metainfo = XmlDocument.parse(metainfoFile.readAsStringSync());

  final publishDate = githubInfo.latestRelease.publishedAt;
  final date = DateFormat('yyyy-MM-dd').format(publishDate!);

  metainfo.findAllElements('release').first.replace(
        XmlElement(XmlName('release'), [
          XmlAttribute(
            XmlName('version'),
            githubInfo.latestRelease.tagName!.substring(1),
          ),
          XmlAttribute(
            XmlName('date'),
            date,
          ),
        ]),
      );

  metainfoFile.writeAsStringSync(metainfo.toXmlString(pretty: true));
}
