import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/abstract_api.dart';

class ErrorTextWidget extends StatelessWidget {
  const ErrorTextWidget({
    super.key,
    this.exception,
    this.onTryAgain,
    this.errorTitle,
    this.errorMessage,
  });

  final HttpException? exception;
  final String? errorTitle;
  final String? errorMessage;
  final VoidCallback? onTryAgain;

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(errorTitle ?? lang.error_load_again, style: textTheme.titleMedium),
            if (errorMessage != null) Text(errorMessage!, style: textTheme.bodyMedium),
            if (exception != null)
              if (exception is ApiException)
                ...buildApiException(context, exception as ApiException)
              else if (exception is HttpException)
                ...buildHttpException(context, exception as HttpException),
            Text(errorTitle ?? lang.error_load_again, style: textTheme.bodyMedium),
            ElevatedButton(
              onPressed: () {
                onTryAgain?.call();
              },
              child: Text(lang.try_again, style: textTheme.bodyMedium),
            ),
          ],
        ));
  }

  List<Widget> buildHttpException(BuildContext context, HttpException exception) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return [
      Text(exception.statusCode.toString(), style: textTheme.bodyMedium),
    ];
  }

  List<Widget> buildApiException(BuildContext context, ApiException exception) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return [
      Text(exception.statusCode.toString(), style: textTheme.bodyMedium),
      Text(exception.errorCode.toString(), style: textTheme.bodyMedium),
      Text(exception.errorName.toString(), style: textTheme.bodyMedium),
      Text(exception.errorMessage.toString(), style: textTheme.bodyMedium),
    ];
  }
}
