import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sadak/repository/interface/map/i_segment_cache.dart';
import 'package:open_route_service/open_route_service.dart';

/// Implementation of SegmentCache using shared_preferences
/// Caches route segments locally to reduce API calls
class SegmentCacheImpl implements SegmentCache {
  final SharedPreferences _prefs;
  static const String _cachePrefix = 'segment_cache_';
  static const Duration _cacheDuration = Duration(hours: 24);

  SegmentCacheImpl({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Future<DirectionRouteData?> get(String key) async {
    try {
      final cachedData = _prefs.getString('$_cachePrefix$key');
      if (cachedData == null) return null;

      // Deserialize from JSON
      final json = jsonDecode(cachedData) as Map<String, dynamic>;

      // Check if cache is still valid
      final timestamp = DateTime.parse(json['timestamp'] as String);
      if (DateTime.now().difference(timestamp) > _cacheDuration) {
        // Cache expired, delete it
        await _prefs.remove('$_cachePrefix$key');
        return null;
      }

      // TODO: Deserialize DirectionRouteData from JSON
      // This requires implementing fromJson method for DirectionRouteData
      return null;
    } catch (e) {
      // Cache corrupted, delete it
      await _prefs.remove('$_cachePrefix$key');
      return null;
    }
  }

  @override
  Future<void> save(
    String key,
    DirectionRouteData data,
  ) async {
    try {
      final json = {
        'timestamp': DateTime.now().toIso8601String(),
        // TODO: Serialize DirectionRouteData to JSON
        // 'data': data.toJson(),
      };

      await _prefs.setString(
        '$_cachePrefix$key',
        jsonEncode(json),
      );
    } catch (e) {
      // Silently fail cache saving
    }
  }

  /// Clear all cached segments
  Future<void> clearCache() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_cachePrefix)) {
        await _prefs.remove(key);
      }
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final keys = _prefs.getKeys();
    final cacheKeys =
        keys.where((k) => k.startsWith(_cachePrefix)).toList();

    return {
      'totalCached': cacheKeys.length,
      'estimatedSize': cacheKeys.fold<int>(
        0,
        (sum, key) => sum + (_prefs.getString(key)?.length ?? 0),
      ),
    };
  }
}
