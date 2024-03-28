import 'package:flutter/material.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/login/admin_login_content.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  static const String routeName = 'admin-login';
  static const String path = 'login';

  @override
  Widget build(BuildContext context) {
    return OflScaffold(content: AdminContent(width: smallContainerWidth, child: const AdminLoginContent()));
  }
}
