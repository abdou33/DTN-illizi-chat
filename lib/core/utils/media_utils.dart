import 'dart:io';

import 'package:flutter/material.dart';

bool isLocalMediaPath(String? path) {
  if (path == null || path.isEmpty) return false;
  return path.startsWith('/') || (path.length > 2 && path[1] == ':');
}

ImageProvider? mediaImageProvider(String? url) {
  if (url == null || url.isEmpty) return null;
  if (isLocalMediaPath(url)) return FileImage(File(url));
  return NetworkImage(url);
}
