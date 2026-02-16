import 'package:go_router/go_router.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:sadak/view/route/route_list_view.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      redirect: (_, __) => '/home',
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: '/routes',
      name: 'routeList',
      builder: (context, state) {
        final data = state.extra as Map<String, ORSCoordinate>;

        return RouteListView(
          source: data['source']!,
          destination: data['destination']!,
        );
      },
    ),
  ],
);
