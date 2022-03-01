import 'package:collection/collection.dart';
import 'package:github/github.dart';
import 'package:http/http.dart' as http;

class GitHubInfo {
  final Release latestRelease;
  final Repository repo;

  GitHubInfo._({required this.latestRelease, required this.repo});

  /// Retrieves the info for the latest release of this project.
  static Future<GitHubInfo> fetch({
    required String projectId,
    required String repository,
    required String user,
  }) async {
    final github = GitHub();
    final repoSlug = RepositorySlug(user, repository);
    final latestRelease = await github.repositories.getLatestRelease(repoSlug);
    final repo = await github.repositories.getRepository(repoSlug);
    github.dispose();

    // latestRelease.body; release description if we want to update that as well

    final isDraft = latestRelease.isDraft ?? true;
    final isPreRelease = latestRelease.isPrerelease ?? true;

    if (isDraft || isPreRelease) {
      throw Exception('Release is draft or prerelease, expected published.');
    }
    return GitHubInfo._(latestRelease: latestRelease, repo: repo);
  }

  ReleaseAsset? get linuxAssetName => latestRelease.assets?.firstWhereOrNull(
      (element) => element.name!.contains('-Linux-Portable.tar.gz'));

  /// The sha256sum for the Linux portable asset.
  Future<String> linuxAssetHash() async {
    final asset = latestRelease.assets?.firstWhereOrNull(
      (element) => element.name!.contains('-Linux-Portable.sha256sum'),
    );
    if (asset == null) {
      throw Exception('sha256sum not found in release.');
    }
    return await _downloadAssetHash(asset.browserDownloadUrl!);
  }

  /// Download the sha256sum from the GitHub release.
  Future<String> _downloadAssetHash(String assetUrl) async {
    final response = await http.get(Uri.parse(assetUrl));
    // First part is hash, second is file name.
    final hash = response.body.split(' ').first;
    return hash;
  }
}
