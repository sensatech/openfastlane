import 'package:flutter/material.dart';
import 'package:frontend/ui/apps/admin/admin_app.dart';
import 'package:frontend/ui/apps/admin/login/admin_login_page.dart';
import 'package:frontend/ui/apps/qr_reader/login/QrReaderLoginPage.dart';
import 'package:frontend/ui/apps/qr_reader/qr_reader_app.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router =
    GoRouter(navigatorKey: _rootNavigatorKey, initialLocation: AdminApp.path, routes: [
  GoRoute(
      name: AdminApp.routeName,
      path: AdminApp.path,
      builder: (context, state) {
        return const AdminApp();
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
      name: QrReaderApp.routeName,
      path: QrReaderApp.path,
      builder: (context, state) {
        return const QrReaderApp();
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
