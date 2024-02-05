import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/global_login_service.dart';
import 'package:frontend/ui/commons/buttons.dart';
import 'package:frontend/ui/values/spacer.dart';

class OflScaffold extends StatelessWidget {
  const OflScaffold({super.key, required this.content});

  final Widget content;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Column(
        children: [
          headerRow(context, colorScheme),
          largeVerticalSpacer(),
          content,
          largeVerticalSpacer()
        ],
      ),
    );
  }

  Widget headerRow(BuildContext context, ColorScheme colorScheme) {
    GlobalLoginService loginService = context.read<GlobalLoginService>();

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              largeHorizontalSpacer(),
              Padding(
                padding: EdgeInsets.all(smallSpace),
                child: Image.asset('assets/vhw_logo_not_formatted.png'),
              )
            ],
          ),
          BlocConsumer<GlobalLoginService, GlobalLoginState>(
            listener: (context, state) {
              //TODO: listen to login state, and if logged out, jump to login page
            },
            builder: (context, state) {
              if (state is LoggedIn) {
                return Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, largeSpace, 0),
                    child: oflButton('Logout', () {
                      context.read<GlobalLoginService>().logout();
                    }));
              } else if (state is LoginLoading && loginService.isLoggedIn) {
                return Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, largeSpace, 0),
                    child: const CircularProgressIndicator());
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}
