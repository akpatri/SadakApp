// lib/core/model/map/transport_file_enum.dart

enum TransportProfile {
  driving,
  cycling,
  walking,
  bikeSharing,
  bus,
  train,
  ferry;

  static TransportProfile fromString(String value) {
    final normalized = value.trim().toLowerCase();

    // 🔹 Alias handling for AI responses
    switch (normalized) {
      case 'bike':
      case 'bicycle':
        return TransportProfile.cycling;

      case 'car':
        return TransportProfile.driving;

      case 'walk':
        return TransportProfile.walking;
    }

    return TransportProfile.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () =>
          throw ArgumentError('Unknown TransportProfile: $value'),
    );
  }

  /// Safe parser (does not throw)
  static TransportProfile? tryParse(String value) {
    try {
      return fromString(value);
    } catch (_) {
      return null;
    }
  }

  String toShortString() => name;
}
