import 'package:flutter/material.dart';
import 'package:frontend/ui/apps/admin/login/admin_login_page.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  static const String routeName = 'admin';
  static const String path = '/admin';

  @override
  Widget build(BuildContext context) {
    // here we will check for the login status in a global cubit
    // for now we will just return the login page
    return const AdminLoginPage();
  }
}
