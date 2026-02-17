import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sadak/view/home/widget/location_autocomplete_fied.dart';
import 'package:sadak/view/home/widget/map_widget.dart';

@Preview(name: 'Simple TextField Preview')
Widget textFieldPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Hello Flutter',
            ),
          ),
        ),
      ),
    ),
  );
}



@Preview(name: 'Source & Destination - Real')
Widget locationFieldsPreview() {
  return const ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LocationAutocompleteField(
                type: LocationFieldType.source,
              ),
              SizedBox(height: 16),
              LocationAutocompleteField(
                type: LocationFieldType.destination,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


@Preview(
  name: 'MapViewWidgetWidget - Real Integration',
)
Widget mapViewFullRealPreview() {
  return const ProviderScope(
    child: MaterialApp(
      home: MapViewWidgetWidget(),
    ),
  );
}

