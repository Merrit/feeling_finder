#!/bin/bash

projectId=codes.merritt.FeelingFinder
repository=feeling_finder
githubUsername=merrit

# Update manifest and AppStream metadata files.
dart run update_flatpak_recipe/bin/update.dart $projectId $repository $githubUsername

# Verify AppStream metadata file.
appstream-util validate $projectId.metainfo.xml
