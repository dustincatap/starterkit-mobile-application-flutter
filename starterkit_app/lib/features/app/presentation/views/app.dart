import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:context_plus/context_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:starterkit_app/common/localization/generated/l10n.dart';
import 'package:starterkit_app/core/presentation/navigation/navigation_router.dart';
import 'package:starterkit_app/core/presentation/navigation/navigation_router_delegate.dart';
import 'package:starterkit_app/core/presentation/views/view_model_builder.dart';
import 'package:starterkit_app/core/service_locator.dart';
import 'package:starterkit_app/features/app/presentation/view_models/app_view_model.dart';

class App extends StatefulWidget {
  final PageRouteInfo? initialRoute;

  const App({super.key, this.initialRoute});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final NavigationRouter _rootStackRouter = ServiceLocator.get<NavigationRouter>();
  final NavigationRouterDelegate _routerDelegate = ServiceLocator.get<NavigationRouterDelegate>();
  final Completer<void> _initialRouteCompleter = Completer<void>();

  @override
  void initState() {
    super.initState();
    unawaited(_setInitialRoute());
  }

  @override
  Widget build(BuildContext context) {
    return ContextPlus.root(
      child: FutureBuilder<void>(
        future: _initialRouteCompleter.future,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox.shrink();
          }

          return AutoViewModelBuilder<AppViewModel>(
            builder: (BuildContext context, AppViewModel viewModel) {
              return MaterialApp.router(
                routeInformationParser: _rootStackRouter.routeInformationParser,
                routerDelegate: _routerDelegate,
                theme: ThemeData(
                  useMaterial3: true,
                  colorSchemeSeed: Colors.blue,
                  fontFamily: 'Roboto',
                ),
                localizationsDelegates: const <LocalizationsDelegate<Object>>[
                  Il8n.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: Il8n.delegate.supportedLocales,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _setInitialRoute() async {
    if (widget.initialRoute != null) {
      final RouteMatch<dynamic>? matchingRoute = _rootStackRouter.match(widget.initialRoute!);

      await _routerDelegate.setInitialRoutePath(
        UrlState.fromSegments(<RouteMatch<dynamic>>[
          ?matchingRoute,
        ]),
      );
    }

    _initialRouteCompleter.complete();
  }
}
