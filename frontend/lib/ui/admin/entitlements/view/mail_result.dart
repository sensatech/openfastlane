import 'package:frontend/domain/abstract_api.dart';

class MailResult {
  final bool success;
  final String? errorMessage;
  final ApiException? exception;

  MailResult(
    this.success, {
    this.errorMessage,
    this.exception,
  });
}
