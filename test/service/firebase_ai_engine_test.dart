import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:sadak/core/model/AI/ai_context.dart';
import 'package:sadak/core/model/map/transport_file_enum.dart';
import 'package:sadak/core/service/map/implementation/firebase_ai_engine.dart';

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult extends Mock implements HttpsCallableResult {}

void main() {
  late FirebaseAIEngine engine;
  late MockFirebaseFunctions mockFunctions;
  late MockHttpsCallable mockCallable;

  setUp(() {
    mockFunctions = MockFirebaseFunctions();
    mockCallable = MockHttpsCallable();
    engine = FirebaseAIEngine(mockFunctions);
  });

  test('planRoute parses bikeSharing correctly', () async {
    final context = AIContext(
      source: const LatLng(12.9716, 77.5946),
      destinations: const [LatLng(12.2958, 76.6394)],
    );

    final mockResponseData = {
      "legs": [
        {"f": 0, "t": 1, "m": "bikeSharing"},
      ],
      "opt": true,
      "note": "Scenic preference applied",
      "conf": 0.92,
    };

    final mockResult = MockHttpsCallableResult();

    when(() => mockFunctions.httpsCallable(any())).thenReturn(mockCallable);

    when(() => mockCallable.call(any())).thenAnswer((_) async => mockResult);

    when(() => mockResult.data).thenReturn(mockResponseData);

    final result = await engine.planRoute(
      prompt: "Scenic route with bike sharing",
      context: context,
    );

    expect(result.legs.length, 1);
    expect(result.legs.first.fromIndex, 0);
    expect(result.legs.first.toIndex, 1);
    expect(result.legs.first.profile, TransportProfile.bikeSharing);
    expect(result.optimizeRemaining, true);
    expect(result.explanation, "Scenic preference applied");
    expect(result.confidence, 0.92);
  });
}
