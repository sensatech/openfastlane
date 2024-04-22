import 'package:flutter/material.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  static const String routeName = 'admin-not-found';
  static const String path = '404';

  @override
  Widget build(BuildContext context) {
    return OflScaffold(
        content: AdminContent(
      width: smallContainerWidth,
      child: Padding(padding: EdgeInsets.symmetric(vertical: largeSpace), child: const Text('Route nicht gefunden')),
    ));
  }
}
