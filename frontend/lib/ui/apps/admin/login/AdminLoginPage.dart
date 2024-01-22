import 'package:flutter/material.dart';
import 'package:frontend/ui/apps/admin/login/AdminLoginContent.dart';
import 'package:frontend/ui/commons/CustomScaffold.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  static const String routeName = 'admin-login';
  static const String path = 'admin_login';

  @override
  Widget build(BuildContext context) {
    return const CustomScaffold(child: AdminLoginContent());
  }
}
