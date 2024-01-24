import 'package:flutter/material.dart';
import 'package:frontend/ui/apps/admin/login/admin_login_content.dart';
import 'package:frontend/ui/commons/ofl_scaffold.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  static const String routeName = 'admin-login';
  static const String path = 'admin_login';

  @override
  Widget build(BuildContext context) {
    return const OflScaffold(child: AdminLoginContent());
  }
}
