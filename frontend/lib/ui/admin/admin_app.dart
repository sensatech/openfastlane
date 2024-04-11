import 'package:flutter/material.dart';
import 'package:frontend/ui/admin/admin_loading_page.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  static const String routeName = 'admin';
  static const String path = '/admin';

  @override
  Widget build(BuildContext context) {
    return const AdminLoadingPage();
  }
}
