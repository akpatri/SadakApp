/// ===============================================================
/// DISTANCE MATRIX
/// ===============================================================

class MapDistanceMatrix {
  final List<List<double>> distances;
  final List<List<double>> durations;

  const MapDistanceMatrix({required this.distances, required this.durations});

    double getDistance(int originIndex, int destinationIndex) {
    return distances[originIndex][destinationIndex];
  }

  double getDuration(int originIndex, int destinationIndex) {
    return durations[originIndex][destinationIndex];
  }
}