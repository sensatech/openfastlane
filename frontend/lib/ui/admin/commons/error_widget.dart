import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/abstract_api.dart';
import 'package:frontend/ui/admin/commons/exceptions.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

class ErrorTextWidget extends StatelessWidget {
  const ErrorTextWidget({
    super.key,
    this.exception,
    this.onTryAgain,
    this.errorTitle,
    this.errorMessage,
  });

  final Exception? exception;
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
            smallVerticalSpacer(),
            if (exception != null)
              if (exception is ApiException)
                ...buildApiException(context, exception as ApiException)
              else if (exception is HttpException)
                ...buildHttpException(context, exception as HttpException)
              else if (exception is DioException)
                ...buildDioException(context, exception as DioException)
                else if (exception is UiException)
                ...buildUiException(context, exception as UiException),
            smallVerticalSpacer(),
            if (onTryAgain != null)
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

  List<Widget> buildDioException(BuildContext context, DioException exception) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return [
      Text(exception.type.toString(), style: textTheme.labelLarge),
      Text(exception.toString(), style: textTheme.bodyMedium),
    ];
  }

  List<Widget> buildUiException(BuildContext context, UiException exception) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return [
      Text(exception.type.toLocale(context), style: textTheme.bodyMedium),
    ];
  }

  List<Widget> buildApiException(BuildContext context, ApiException exception) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return [
      Text(exception.statusCode.toString(), style: textTheme.labelMedium),
      Text(exception.errorCode.toString(), style: textTheme.labelMedium),
      Text(exception.errorName.toString(), style: textTheme.bodyMedium),
      Text(exception.errorMessage.toString(), style: textTheme.bodyMedium),
    ];
  }
}
