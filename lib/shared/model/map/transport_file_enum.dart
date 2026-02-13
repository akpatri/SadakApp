/// ===============================================================
/// TRANSPORT PROFILE
/// ===============================================================

enum TransportProfile {
  driving,
  cycling,
  walking,
  bikeSharing,
  bus,
  train,
  ferry;

  static TransportProfile fromString(String value) {
    return TransportProfile.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Unknown TransportProfile: $value'),
    );
  }

  String toShortString() => name;
}
