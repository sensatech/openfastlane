import 'package:flutter/material.dart';
import 'package:frontend/ui/apps/admin/AdminApp.dart';
import 'package:frontend/ui/apps/admin/login/AdminLoginPage.dart';
import 'package:frontend/ui/apps/qr_reader/QrReaderApp.dart';
import 'package:frontend/ui/apps/qr_reader/login/QrReaderLoginPage.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router =
    GoRouter(navigatorKey: _rootNavigatorKey, initialLocation: AdminMain.path, routes: [
  GoRoute(
      name: AdminMain.routeName,
      path: AdminMain.path,
      builder: (context, state) {
        return const AdminMain();
      },
      routes: [
        GoRoute(
          name: AdminLoginPage.routeName,
          path: AdminLoginPage.path,
          builder: (context, state) {
            return const AdminLoginPage();
          },
        ),
      ]),
  GoRoute(
      name: QrReaderMain.routeName,
      path: QrReaderMain.path,
      builder: (context, state) {
        return const QrReaderMain();
      },
      routes: [
        GoRoute(
          name: QrReaderLoginPage.routeName,
          path: QrReaderLoginPage.path,
          builder: (context, state) {
            return const QrReaderLoginPage();
          },
        ),
      ]),
]);
