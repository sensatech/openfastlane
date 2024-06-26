import 'package:flutter/material.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/admin_app.dart';
import 'package:frontend/ui/admin/campaign/campaign_selection_page.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/create_entitlement_page.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/edit_entitlement_page.dart';
import 'package:frontend/ui/admin/entitlements/view/entitlement_view_page.dart';
import 'package:frontend/ui/admin/login/admin_login_page.dart';
import 'package:frontend/ui/admin/login/admin_not_found_page.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_page.dart';
import 'package:frontend/ui/admin/persons/create_person/create_person_page.dart';
import 'package:frontend/ui/admin/persons/edit_person/edit_person_page.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_page.dart';
import 'package:frontend/ui/admin/reports/admin_reports_page.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/scanner/camera/scanner_camera_page.dart';
import 'package:frontend/ui/scanner/check_entitlement/scanner_entitlement_page.dart';
import 'package:frontend/ui/scanner/choose_campaign/scanner_choose_campaign_page.dart';
import 'package:frontend/ui/scanner/person_list/scanner_person_list_page.dart';
import 'package:frontend/ui/scanner/person_view/scanner_person_view_page.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class CampaignIdObserver extends NavigatorObserver {
  NavigationService navigationService;

  CampaignIdObserver(this.navigationService);

  @override
  void didPush(route, previousRoute) {
    if (route is PageRoute && route.settings.arguments != null) {
      if (route.settings.arguments is Map<String, String>) {
        final params = route.settings.arguments as Map<String, String>;
        if (params.containsKey('campaignId') && params['campaignId'] != null) {
          navigationService.updateCampaignId(params['campaignId']!);
        }
      }
    }
  }
}

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AdminApp.path,
  errorBuilder: (context, state) {
    logger.e('Error: ${state.error}');
    return const NotFoundPage();
  },
  observers: [
    CampaignIdObserver(sl<NavigationService>()),
  ],
  routes: [
    GoRoute(
        name: AdminApp.routeName,
        path: AdminApp.path,
        builder: (context, state) {
          return const AdminCampaignSelectionPage();
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
            name: AdminReportsPage.routeName,
            path: AdminReportsPage.path,
            builder: (context, state) {
              return const AdminReportsPage();
            },
          ),
          GoRoute(
            name: AdminPersonListPage.routeName,
            path: AdminPersonListPage.path,
            pageBuilder: defaultPageBuilder((context, state) {
              final String? campaignId = nullableCampaignId(state);
                return AdminPersonListPage(campaignId: campaignId);
            }),
            routes: [
              GoRoute(
                name: CreatePersonPage.routeName,
                path: CreatePersonPage.path,
                pageBuilder: defaultPageBuilder((context, state) {
                  return const CreatePersonPage();
                }),
              ),
              GoRoute(
                name: AdminPersonViewPage.routeName,
                path: AdminPersonViewPage.path,
                pageBuilder: defaultPageBuilder((context, state) {
                  final String? personId = nullablePersonId(state);
                  final String? campaignId = nullableCampaignId(state);
                  if (personId == null) return const NotFoundPage();

                  return AdminPersonViewPage(personId: personId, campaignId: campaignId);
                }),
              ),
              GoRoute(
                name: EditPersonPage.routeName,
                path: EditPersonPage.path,
                pageBuilder: defaultPageBuilder((context, state) {
                  final String? personId = nullablePersonId(state);
                  if (personId == null) return const NotFoundPage();

                  return EditPersonPage(personId: personId);
                }),
              ),
              GoRoute(
                name: EntitlementViewPage.routeName,
                path: EntitlementViewPage.path,
                builder: (context, state) {
                  final String? personId = nullablePersonId(state);
                  final String? entitlementId = nullableEntitlementId(state);
                  if (personId == null || entitlementId == null) return const NotFoundPage();

                  return EntitlementViewPage(personId: personId, entitlementId: entitlementId);
                },
              ),
              GoRoute(
                name: CreateEntitlementPage.routeName,
                path: CreateEntitlementPage.path,
                builder: (context, state) {
                  final String? personId = nullablePersonId(state);
                  final String? campaignId = nullableCampaignId(state);
                  if (personId == null || campaignId == null) return const NotFoundPage();

                  return CreateEntitlementPage(personId: personId, campaignId: campaignId);
                },
              ),
              GoRoute(
                name: EditEntitlementPage.routeName,
                path: EditEntitlementPage.path,
                builder: (context, state) {
                  final String? personId = nullablePersonId(state);
                  final String? entitlementId = nullableEntitlementId(state);
                  if (personId == null || entitlementId == null) return const NotFoundPage();

                  return EditEntitlementPage(
                    personId: personId,
                    entitlementId: entitlementId,
                  );
                },
              )
            ],
          ),
          // Attention: QrApp is under /admin/scanner
        ]),
    GoRoute(
      name: ScannerRoutes.scanner.name,
      path: ScannerRoutes.scanner.path,
      pageBuilder: defaultPageBuilder((context, state) {
        final String? campaignId = nullableCampaignId(state);
        if (campaignId == null) return const ScannerCampaignPage();
        return const ScannerCampaignPage();
      }),
      // routes: [],
      routes: scannerRoutes(),
    ),
  ],
);

class ScannerRoutes {
  static const Route scannerTest = Route('scanner-test', '/scanner-test');
  static const Route scanner = Route('scanner', '/scanner');
  static const Route scannerCampaigns = Route('scanner-campaigns', 'campaigns/:campaignId');
  static const Route scannerCamera = Route('scanner-camera', 'camera');
  static const Route scannerEntitlement = Route('scanner-entitlement', 'entitlements/:entitlementId');
  static const Route scannerQr = Route('scanner-qr', 'qr/:qrCode');
  static const Route scannerPerson = Route('scanner-person', 'persons/:personId');
  static const Route scannerPersonList = Route('scanner-person-list', 'persons');
}

List<GoRoute> scannerRoutes() {
  return [
    GoRoute(
      name: ScannerRoutes.scannerCamera.name,
      path: ScannerRoutes.scannerCamera.path,
      builder: (context, state) {
        final String? campaignId = nullableCampaignId(state);
        if (campaignId == null) return const NotFoundPage(message: 'campaignId is missing in as query parameter');
        final bool checkOnly = nullableCheckOnly(state);
        return ScannerCameraPage(
          campaignId: campaignId,
          checkOnly: checkOnly,
        );
      },
    ),
    GoRoute(
      name: ScannerRoutes.scannerEntitlement.name,
      path: ScannerRoutes.scannerEntitlement.path,
      builder: (context, state) {
        final String? entitlementId = nullableEntitlementId(state);
        if (entitlementId == null) {
          return const NotFoundPage(
            message: 'entitlementId is missing as path parameter',
          );
        }
        final bool checkOnly = nullableCheckOnly(state);
        return ScannerEntitlementPage(
          entitlementId: entitlementId,
          checkOnly: checkOnly,
          qrCode: null,
        );
      },
    ),
    GoRoute(
        name: ScannerRoutes.scannerPerson.name,
        path: ScannerRoutes.scannerPerson.path,
        builder: (context, state) {
          final String? personId = nullablePersonId(state);
          final String? campaignId = nullableCampaignId(state);
          if (personId == null || campaignId == null) {
            String message = (personId == null)
                ? 'personId is missing as path parameter'
                : 'campaignId is missing as query parameter';
            return NotFoundPage(message: message);
          }
          return ScannerPersonViewPage(personId: personId, campaignId: campaignId);
        }),
    GoRoute(
        name: ScannerRoutes.scannerQr.name,
        path: ScannerRoutes.scannerQr.path,
        builder: (context, state) {
          final String? qrCode = nullableQrCode(state);
          if (qrCode == null) return const NotFoundPage(message: 'qrCode is missing as path parameter');
          return ScannerEntitlementPage(
            qrCode: qrCode,
            checkOnly: nullableCheckOnly(state),
            entitlementId: null,
          );
        }),
    GoRoute(
        name: ScannerRoutes.scannerPersonList.name,
        path: ScannerRoutes.scannerPersonList.path,
        builder: (context, state) {
          final String? campaignId = nullableCampaignId(state);
          if (campaignId == null) return const NotFoundPage(message: 'campaignId is missing as query parameter');
          final bool checkOnly = nullableCheckOnly(state);
          return ScannerPersonListPage(
            campaignId: campaignId,
            checkOnly: checkOnly,
          );
        }),
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

String? nullableEntitlementId(GoRouterState state) {
  return state.pathParameters['entitlementId'];
}

String? nullablePersonId(GoRouterState state) {
  return state.pathParameters['personId'];
}

String? nullableCampaignId(GoRouterState state) {
  return state.uri.queryParameters['campaignId'];
}

String? nullableQrCode(GoRouterState state) {
  return state.pathParameters['qrCode'];
}

bool nullableCheckOnly(GoRouterState state) {
  String? value = state.uri.queryParameters['checkOnly'];
  bool checkOnly = value == 'true' || value == null;
  return checkOnly;
}
