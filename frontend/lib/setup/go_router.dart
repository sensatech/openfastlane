import 'package:flutter/material.dart';
import 'package:frontend/ui/admin/admin_app.dart';
import 'package:frontend/ui/admin/campaign/campaign_selection_page.dart';
import 'package:frontend/ui/admin/entitlements/create_entitlement_page.dart';
import 'package:frontend/ui/admin/login/admin_login_page.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_page.dart';
import 'package:frontend/ui/admin/persons/create_person/create_person_page.dart';
import 'package:frontend/ui/admin/persons/edit_person/edit_person_page.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_page.dart';
import 'package:frontend/ui/qr_reader/camera_test/scanner_camera_test_page.dart';
import 'package:frontend/ui/qr_reader/check_consume/scanner_check_consume_page.dart';
import 'package:frontend/ui/qr_reader/choose_campaign/scanner_choose_campaign_page.dart';
import 'package:frontend/ui/qr_reader/qr_reader_app.dart';
import 'package:go_router/go_router.dart';

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
                Function(bool) result = state.extra as Function(bool);
                return EditPersonPage(personId: personId, result: result);
              }),
            ),
            GoRoute(
              name: CreateEntitlementPage.routeName,
              path: CreateEntitlementPage.path,
              builder: (context, state) {
                final String? personId = state.pathParameters['personId'];
                Function(bool) result = state.extra as Function(bool);
                return CreateEntitlementPage(personId: personId, result: result);
              },
            )
          ],
        ),
        // Attention: QrApp is under /admin/scanner
        GoRoute(
            name: QrReaderApp.routeName,
            path: QrReaderApp.path,
            pageBuilder: defaultPageBuilder((context, state) {
              return const ScannerCampaignPage();
            }),
            routes: [
              GoRoute(
                name: ScannerCheckConsumePage.routeName,
                path: ScannerCheckConsumePage.path,
                pageBuilder: defaultPageBuilder((context, state) {
                  final String? campaignId = state.pathParameters['campaignId'];
                  return ScannerCheckConsumePage(campaignId: campaignId);
                }),
              ),
            ]),
      ]),
  GoRoute(
      name: ScannerCameraTestPage.routeName,
      path: ScannerCameraTestPage.path,
      pageBuilder: defaultPageBuilder((context, state) {
        return const ScannerCameraTestPage();
      })),
]);

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
