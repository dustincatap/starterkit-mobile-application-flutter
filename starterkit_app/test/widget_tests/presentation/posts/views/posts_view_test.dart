import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:starterkit_app/common/localization/generated/l10n.dart';
import 'package:starterkit_app/core/data/database/app_database.dart';
import 'package:starterkit_app/core/domain/models/result.dart';
import 'package:starterkit_app/core/infrastructure/platform/connectivity_service.dart';
import 'package:starterkit_app/core/presentation/navigation/navigation_router.gr.dart';
import 'package:starterkit_app/core/service_registrar.dart';
import 'package:starterkit_app/features/app/presentation/views/app.dart';
import 'package:starterkit_app/features/post/data/remote/post_api.dart';
import 'package:starterkit_app/features/post/domain/models/post_entity.dart';
import 'package:starterkit_app/features/post/presentation/views/post_details_view.dart';
import 'package:starterkit_app/features/post/presentation/views/posts_view.dart';

import '../../../../database/in_memory_app_database.dart';
import '../../../../test_utils.dart';
import '../../../../widget_test_utils.dart';
import 'posts_view_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<ConnectivityService>(),
  MockSpec<Dio>(),
])
void main() {
  group(PostsView, () {
    late Il8n il8n;
    late MockConnectivityService mockConnectivityService;
    late MockDio mockDio;

    setUp(() async {
      await setUpWidgetTest();
      mockConnectivityService = MockConnectivityService();
      mockDio = MockDio();
      il8n = await setupLocale();

      ServiceRegistrar.registerLazySingleton<AppDatabase>(InMemoryAppDatabase.new);
      ServiceRegistrar.registerLazySingleton<PostApi>(() => PostApi(mockDio));
      ServiceRegistrar.registerLazySingleton<ConnectivityService>(() => mockConnectivityService);
      provideDummy<Result<Iterable<PostEntity>>>(Failure<Iterable<PostEntity>>(Exception()));
      provideDummy<Result<PostEntity>>(Failure<PostEntity>(Exception()));
    });

    void setUpApi<TResponse>({
      required Matcher expectedPath,
      required Matcher expectedMethod,
      required String expectedResponseFile,
      VoidCallback? onAnswer,
    }) {
      final String expectedPostsJsonString = readFileAsString(expectedResponseFile);
      // these values are not used for testing, but are required by Dio
      when(mockDio.options).thenReturn(BaseOptions(method: 'GET', baseUrl: 'https://www.example.com'));
      when(
        mockDio.fetch<TResponse>(
          argThat(
            isA<RequestOptions>()
                .having((RequestOptions r) => r.path, 'path', expectedPath)
                .having((RequestOptions r) => r.method, 'method', expectedMethod),
          ),
        ),
      ).thenAnswer((_) async {
        onAnswer?.call();

        return Response<TResponse>(
          data: jsonDecode(expectedPostsJsonString) as TResponse,
          requestOptions: RequestOptions(),
        );
      });
    }

    void setUpApiToFail<TResponse>({
      required Matcher expectedPath,
      required Matcher expectedMethod,
      VoidCallback? onAnswer,
    }) {
      // these values are not used for testing, but are required by Dio
      when(mockDio.options).thenReturn(BaseOptions(method: 'GET', baseUrl: 'https://www.example.com'));
      // False positive
      when(
        mockDio.fetch<TResponse>(
          argThat(
            isA<RequestOptions>()
                .having((RequestOptions r) => r.path, 'path', expectedPath)
                .having((RequestOptions r) => r.method, 'method', expectedMethod),
          ),
        ),
      ).thenAnswer((_) async {
        onAnswer?.call();

        return Response<TResponse>(
          data: null,
          requestOptions: RequestOptions(),
        );
      });
    }

    group('AppBar should show correct title when shown', () {
      for (final Device device in Device.all) {
        testWidgets('for ${device.name}', (WidgetTester tester) async {
          tester.setupDevice(device);

          setUpApi<List<dynamic>>(
            expectedPath: endsWith('/posts'),
            expectedMethod: matches('GET'),
            expectedResponseFile: 'posts.json',
          );
          when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);

          await tester.pumpWidget(const App(initialRoute: PostsViewRoute()));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(PostsView),
            tester.matchGoldenFile('posts_view_app_bar_title', device),
          );
          expect(find.text(il8n.posts), findsOneWidget);
        });
      }
    });

    group('ListView should show posts when loaded', () {
      for (final Device device in Device.all) {
        testWidgets('for ${device.name}', (WidgetTester tester) async {
          tester.setupDevice(device);

          setUpApi<List<dynamic>>(
            expectedPath: endsWith('/posts'),
            expectedMethod: matches('GET'),
            expectedResponseFile: 'posts.json',
          );
          when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);

          await tester.pumpWidget(const App(initialRoute: PostsViewRoute()));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(PostsView),
            tester.matchGoldenFile('posts_view_loaded', device),
          );
          expect(find.byType(ListView), findsOneWidget);
          expect(find.byType(ListTile), findsAtLeastNWidgets(1));
        });
      }
    });

    group('ListView should show error message when posts failed to load', () {
      for (final Device device in Device.all) {
        testWidgets('for ${device.name}', (WidgetTester tester) async {
          tester.setupDevice(device);

          setUpApiToFail<List<dynamic>>(
            expectedPath: endsWith('/posts'),
            expectedMethod: matches('GET'),
          );
          when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);

          await tester.pumpWidget(const App(initialRoute: PostsViewRoute()));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(PostsView),
            tester.matchGoldenFile('posts_view_error', device),
          );
          expect(find.byType(ListView), findsNothing);
          expect(find.text(il8n.failedToGetPosts), findsOneWidget);
        });
      }
    });

    group('ListTile should navigate to post details when post tapped', () {
      for (final Device device in Device.all) {
        testWidgets('for ${device.name}', (WidgetTester tester) async {
          tester.setupDevice(device);

          setUpApi<List<dynamic>>(
            expectedPath: endsWith('/posts'),
            expectedMethod: matches('GET'),
            expectedResponseFile: 'posts.json',
            onAnswer: () {
              reset(mockDio);
              setUpApi<Map<String, dynamic>>(
                expectedPath: contains('/posts/'),
                expectedMethod: matches('GET'),
                expectedResponseFile: 'post.json',
              );
            },
          );
          when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);

          await tester.pumpWidget(const App(initialRoute: PostsViewRoute()));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(ListTile));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(PostDetailsView),
            tester.matchGoldenFile('posts_view_navigate_to_post_details_view', device),
          );
          expect(find.byType(PostsView), findsNothing);
          expect(find.byType(PostDetailsView), findsOneWidget);
        });
      }
    });
  });
}
