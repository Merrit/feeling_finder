#!/bin/bash

# No spaces in project name.
projectName=FeelingFinder
projectId=codes.merritt.FeelingFinder
executableName=feeling_finder

# This script is triggered by the json manifest.
# It can also be run manually: flatpak-builder build-dir $projectId.json

# Exit if any command fails
set -e

# Echo all commands for debug purposes
set -x

# Grab Flatpak build files.
cp -r packaging/linux/$projectId.desktop .
cp -r assets/icon/icon.svg .

# Extract portable Flutter build.
mkdir -p $projectName
tar -xf $projectName-Linux-Portable.tar.gz -C $projectName
rm $projectName/PORTABLE

# Copy the portable app to the Flatpak-based location.
cp -r $projectName /app/
chmod +x /app/$projectName/$executableName
mkdir -p /app/bin
ln -s /app/$projectName/$executableName /app/bin/$executableName

# Install the icon.
iconDir=/app/share/icons/hicolor/scalable/apps
mkdir -p $iconDir
cp -r icon.svg $iconDir/$projectId.svg

# Install the desktop file.
desktopFileDir=/app/share/applications
mkdir -p $desktopFileDir
cp -r $projectId.desktop $desktopFileDir/

# Install the AppStream metadata file.
metadataDir=/app/share/metainfo
mkdir -p $metadataDir
cp -r $projectId.metainfo.xml $metadataDir/
