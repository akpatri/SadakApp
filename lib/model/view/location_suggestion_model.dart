
class LocationSuggestion {
  final String label;
  final double? lat;
  final double? lng;

  const LocationSuggestion({
    required this.label,
    this.lat,
    this.lng,
  });
}