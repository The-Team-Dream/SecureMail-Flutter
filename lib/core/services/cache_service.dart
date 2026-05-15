import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CacheService {
  Future<double> getCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      int totalSize = await _getDirSize(tempDir);
      // Convert to MB
      return totalSize / (1024 * 1024);
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getDirSize(Directory dir) async {
    int totalSize = 0;
    try {
      if (await dir.exists()) {
        await for (var entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
    } catch (e) {
      // Ignore errors for individual files
    }
    return totalSize;
  }

  Future<void> clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (var entity in tempDir.list()) {
          try {
            if (entity is File) {
              await entity.delete();
            } else if (entity is Directory) {
              await entity.delete(recursive: true);
            }
          } catch (e) {
            // Ignore individual file deletion errors
          }
        }
      }
    } catch (e) {
      // Handle general errors
    }
  }
}

final cacheServiceProvider = Provider((ref) => CacheService());

final cacheSizeProvider = StateNotifierProvider<CacheSizeNotifier, double>((ref) {
  return CacheSizeNotifier(ref.read(cacheServiceProvider));
});

class CacheSizeNotifier extends StateNotifier<double> {
  final CacheService _service;
  CacheSizeNotifier(this._service) : super(0) {
    updateSize();
  }

  Future<void> updateSize() async {
    state = await _service.getCacheSize();
  }

  Future<void> clear() async {
    await _service.clearCache();
    await updateSize();
  }
}
