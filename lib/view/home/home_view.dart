import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:latlong2/latlong.dart';
import '/core/di/app_provider.dart';
import '../../view_model/home_view_model.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(homeVMProvider);

    return Scaffold(
      body: asyncState.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text("Error: $e")),
        data: (state) {
          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: state.source,
                  initialZoom: 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.example.sadak',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: state.source,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                      if (state.destination != null)
                        Marker(
                          point: state.destination!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Bottom Panel
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black12,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.my_location),
                          hintText:
                              "Your location",
                          border:
                              const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TypeAheadField<String>(
                        suggestionsCallback: (pattern) async {
                          return [
                            "New Delhi",
                            "Mumbai",
                            "Kolkata",
                            "Chennai",
                          ]
                              .where((city) =>
                                  city.toLowerCase().contains(pattern.toLowerCase()))
                              .toList();
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion),
                          );
                        },
                        onSelected: (suggestion) {
                          final dest = LatLng(
                            state.source.latitude + 0.02,
                            state.source.longitude + 0.02,
                          );

                          ref.read(homeVMProvider.notifier)
                              .setDestination(dest);
                        },
                        builder: (context, controller, focusNode) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              hintText: "Enter destination",
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                      ),


                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              state.destination == null
                                  ? null
                                  : () {
                                      ScaffoldMessenger
                                              .of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Fetching routes...")),
                                      );
                                    },
                          child: const Text(
                              "Get All Available Routes"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
