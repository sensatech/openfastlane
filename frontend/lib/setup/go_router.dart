import 'package:flutter/material.dart';
import 'package:frontend/ui/admin/admin_app.dart';
import 'package:frontend/ui/admin/campaign/campaign_selection_page.dart';
import 'package:frontend/ui/admin/entitlements/create_entitlement_page.dart';
import 'package:frontend/ui/admin/login/admin_login_page.dart';
import 'package:frontend/ui/admin/login/admin_not_found_page.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_page.dart';
import 'package:frontend/ui/admin/persons/create_person/create_person_page.dart';
import 'package:frontend/ui/admin/persons/edit_person/edit_person_page.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_page.dart';
import 'package:frontend/ui/qr_reader/camera_test/scanner_camera_test_page.dart';
import 'package:frontend/ui/qr_reader/check_entitlment/scanner_check_entitlement_page.dart';
import 'package:frontend/ui/qr_reader/choose_campaign/scanner_choose_campaign_page.dart';
import 'package:go_router/go_router.dart';

import '../ui/qr_reader/camera/scanner_camera_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(navigatorKey: _rootNavigatorKey, initialLocation: AdminApp.path, routes: [
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
        GoRoute(
          name: AdminCampaignSelectionPage.routeName,
          path: AdminCampaignSelectionPage.path,
          builder: (context, state) {
            return const AdminCampaignSelectionPage();
          },
        ),
        GoRoute(
          name: AdminPersonListPage.routeName,
          path: AdminPersonListPage.path,
          pageBuilder: defaultPageBuilder((context, state) {
            return const AdminPersonListPage();
          }),
          routes: [
            GoRoute(
              name: CreatePersonPage.routeName,
              path: CreatePersonPage.path,
              pageBuilder: defaultPageBuilder((context, state) {
                // FIXME: this cannot work on page reload
                Function(bool) result = state.extra as Function(bool);
                return CreatePersonPage(result: result);
              }),
            ),
            GoRoute(
              name: AdminPersonViewPage.routeName,
              path: AdminPersonViewPage.path,
              pageBuilder: defaultPageBuilder((context, state) {
                final String? personId = state.pathParameters['personId'];
                if (personId == null) return const AdminPersonListPage();
                return AdminPersonViewPage(personId: personId);
              }),
            ),
            GoRoute(
              name: EditPersonPage.routeName,
              path: EditPersonPage.path,
              pageBuilder: defaultPageBuilder((context, state) {
                final String? personId = state.pathParameters['personId'];
                // FIXME: this cannot work on page reload
                Function(bool) result = state.extra as Function(bool);
                return EditPersonPage(personId: personId, result: result);
              }),
            ),
            GoRoute(
              name: CreateEntitlementPage.routeName,
              path: CreateEntitlementPage.path,
              builder: (context, state) {
                final String? personId = state.pathParameters['personId'];
                // FIXME: this cannot work on page reload
                Function(bool) result = state.extra as Function(bool);
                return CreateEntitlementPage(personId: personId, result: result);
              },
            )
          ],
        ),
        // Attention: QrApp is under /admin/scanner
        GoRoute(
          name: ScannerRoutes.scanner.name,
          path: ScannerRoutes.scanner.path,
          pageBuilder: defaultPageBuilder((context, state) {
            return const ScannerCampaignPage();
          }),
          routes: [],
          // routes: scannerRoutes(),
        ),
      ]),
  // Attention: This testing stuff is under /scanner-test
  GoRoute(
      name: ScannerRoutes.scannerTest.name,
      path: ScannerRoutes.scannerTest.path,
      pageBuilder: defaultPageBuilder((context, state) {
        return const ScannerCameraTestPage();
      }),
      routes: scannerRoutes()),
]);

class ScannerRoutes {
  static const Route scannerTest = Route('scanner-test', '/scanner-test');
  static const Route scanner = Route('scanner', 'scanner');
  static const Route scannerCampaigns = Route('scanner-campaigns', 'campaign/:campaignId');
  static const Route scannerCamera = Route('scanner-camera', 'campaign/:campaignId/camera/:readOnly');
  static const Route scannerEntitlement = Route('scanner-entitlement', 'entitlements/:entitlementId/:readOnly');
  static const Route scannerQr = Route('scanner-qr', 'qr/:qrCode/:readOnly');
}

List<GoRoute> scannerRoutes() {
  return [
    GoRoute(
      name: ScannerRoutes.scannerCamera.name,
      path: ScannerRoutes.scannerCamera.path,
      builder: (context, state) {
        final String? campaignId = state.pathParameters['campaignId'];
        if (campaignId == null) return const NotFoundPage();
        return ScannerCameraPage(
          campaignId: campaignId,
          readOnly: state.pathParameters['readOnly'] == 'readOnly',
        );
      },
    ),
    GoRoute(
      name: ScannerRoutes.scannerEntitlement.name,
      path: ScannerRoutes.scannerEntitlement.path,
      builder: (context, state) {
        final String? entitlementId = state.pathParameters['entitlementId'];
        if (entitlementId == null) return const NotFoundPage();
        return ScannerCheckEntitlementPage(
          readOnly: state.pathParameters['readOnly'] == 'readOnly',
          entitlementId: entitlementId,
          qrCode: null,
        );
      },
    ),
    GoRoute(
      name: ScannerRoutes.scannerQr.name,
      path: ScannerRoutes.scannerQr.path,
      builder: (context, state) {
        final String? qrCode = state.pathParameters['qrCode'];
        if (qrCode == null) return const NotFoundPage();
        return ScannerCheckEntitlementPage(
          readOnly: state.pathParameters['readOnly'] == 'readOnly',
          entitlementId: null,
          qrCode: qrCode,
        );
      },
    )
  ];
}

class Route {
  final String name;
  final String path;

  const Route(this.name, this.path);
}

Page<dynamic> Function(BuildContext, GoRouterState) defaultPageBuilder<T>(GoRouterWidgetBuilder childFunction) =>
    (BuildContext context, GoRouterState state) {
      return CustomTransitionPage<T>(
        key: state.pageKey,
        child: childFunction(context, state),
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) =>
            FadeTransition(opacity: animation, child: child),
      );
    };

Page<dynamic> Function(BuildContext, GoRouterState) mobilePageBuilder<T>(GoRouterWidgetBuilder childFunction) =>
    (BuildContext context, GoRouterState state) {
      return CustomTransitionPage<T>(
        key: state.pageKey,
        child: childFunction(context, state),
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) =>
            FadeTransition(opacity: animation, child: child),
      );
    };
