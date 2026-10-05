import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/account/account_screen.dart';
import '../features/auth/auth_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/home/home_screen.dart';
import '../features/listings/listing_detail_screen.dart';
import '../features/nearby/nearby_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/offers/offers_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/requests/create_request_screen.dart';
import '../features/requests/request_detail_screen.dart';
import '../features/requests/requests_screen.dart';
import '../features/search/search_screen.dart';
import 'shell_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/home', builder: (context, state) => const HomeScreen())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesScreen())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/requests',
                builder: (context, state) => const RequestsScreen())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/account',
                builder: (context, state) => const AccountScreen())
          ]),
        ],
      ),
      GoRoute(
          path: '/listing/:id',
          builder: (context, state) =>
              ListingDetailScreen(id: state.pathParameters['id']!)),
      GoRoute(
          path: '/nearby', builder: (context, state) => const NearbyScreen()),
      GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen()),
      GoRoute(
          path: '/offers', builder: (context, state) => const OffersScreen()),
      GoRoute(
          path: '/request/new',
          builder: (context, state) => const CreateRequestScreen()),
      GoRoute(
          path: '/request/:id',
          builder: (context, state) =>
              RequestDetailScreen(id: state.pathParameters['id']!)),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
          path: '/chat',
          builder: (context, state) => const ConversationsScreen()),
      GoRoute(
          path: '/chat/:id',
          builder: (context, state) =>
              ChatScreen(conversationId: state.pathParameters['id']!)),
    ],
  );
});
