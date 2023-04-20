import 'dart:io';

import '../logs/logging_manager.dart';

/// An issue was raised where the error indicated the app couldn't
/// launch because the hive database was already locked, so we will
/// kill any existing version of the app before continuing to load.
Future<void> closeExistingSessions() async {
  if (Platform.isLinux) await _closeOnLinux();
}

Future<void> _closeOnLinux() async {
  final result = await Process.run(
    'bash',
    ['-c', 'ps -A | grep feeling_finder'],
  );

  final processLines = (result.stdout as String).trim().split('\n');

  for (var processLine in processLines) {
    final process = _LinuxProcessResult.fromTerminalOutput(processLine);
    if (process.pid == pid) continue;
    if (process.executableName != 'feeling_finder') continue;
    log.i('Closing existing instance with pid ${process.pid}');
    Process.killPid(process.pid);
  }
}

class _LinuxProcessResult {
  final int pid;
  final String executableName;

  const _LinuxProcessResult({
    required this.pid,
    required this.executableName,
  });

  factory _LinuxProcessResult.fromTerminalOutput(String terminalLine) {
    final List<String> pieces = terminalLine.trim().split(' ');
    return _LinuxProcessResult(
      pid: int.parse(pieces.first),
      executableName: pieces.last,
    );
  }
}
