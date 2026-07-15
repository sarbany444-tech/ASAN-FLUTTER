import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';

/// Last path segment without using dart:io or package:path (breaks on web).
String fileBasename(String path, {String fallback = 'video.mp4'}) {
  final trimmed = path.trim();
  if (trimmed.isEmpty) return fallback;

  final normalized = trimmed.replaceAll('\\', '/');
  final slash = normalized.lastIndexOf('/');
  if (slash == -1 || slash == normalized.length - 1) {
    return normalized.isEmpty ? fallback : normalized;
  }
  final name = normalized.substring(slash + 1);
  return name.isEmpty ? fallback : name;
}

/// Web-safe display name for a picked video.
String pickedVideoDisplayName(XFile file, {String? overrideName}) {
  final override = overrideName?.trim();
  if (override != null && override.isNotEmpty) return override;

  final name = file.name.trim();
  if (name.isNotEmpty) return name;

  if (!kIsWeb) {
    final path = file.path.trim();
    if (path.isNotEmpty) return fileBasename(path);
  }

  return 'video.mp4';
}

String displayNameFromPath(String path, {String fallback = 'video.mp4'}) {
  return fileBasename(path, fallback: fallback);
}
