import 'package:flutter/material.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/home/admin_home_content.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  static const String routeName = 'admin-home';
  static const String path = 'home';

  @override
  Widget build(BuildContext context) {
    return OflScaffold(content: AdminContent(width: smallContainerWidth, child: const AdminHomeContent()));
  }
}
