import 'package:flutter/services.dart' show rootBundle;

/// Service for generating responsive, brand-aligned HTML emails for Ginder.
///
/// Supports email verification and forgot password templates using the Bauhaus
/// Design System aesthetics (#E11D48, #4F46E5, #F59E0B, clean typography).
class EmailTemplateService {
  EmailTemplateService._();

  static const String _verificationTemplatePath =
      'assets/email_templates/email_verification.html';
  static const String _forgotPasswordTemplatePath =
      'assets/email_templates/forgot_password.html';

  /// Generates the HTML body for the Email Verification email.
  ///
  /// Replaces `%EMAIL%` and `%LINK%` with the provided parameters.
  static Future<String> getVerificationEmailHtml({
    required String email,
    required String actionLink,
  }) async {
    String template;
    try {
      template = await rootBundle.loadString(_verificationTemplatePath);
    } catch (_) {
      template = _fallbackVerificationTemplate;
    }

    return _replacePlaceholders(template, {'EMAIL': email, 'LINK': actionLink});
  }

  /// Generates the HTML body for the Password Reset email.
  ///
  /// Replaces `%EMAIL%` and `%LINK%` with the provided parameters.
  static Future<String> getPasswordResetEmailHtml({
    required String email,
    required String actionLink,
  }) async {
    String template;
    try {
      template = await rootBundle.loadString(_forgotPasswordTemplatePath);
    } catch (_) {
      template = _fallbackForgotPasswordTemplate;
    }

    return _replacePlaceholders(template, {'EMAIL': email, 'LINK': actionLink});
  }

  static String _replacePlaceholders(
    String template,
    Map<String, String> replacements,
  ) {
    var result = template;
    replacements.forEach((key, value) {
      result = result
          .replaceAll('%$key%', value)
          .replaceAll('{{$key}}', value)
          .replaceAll('{{${key.toLowerCase()}}}', value);
    });
    return result;
  }

  // Fallback templates in case assets are loaded before bundle is ready or in tests
  static const String _fallbackVerificationTemplate = '''
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><title>Verify Email</title></head>
<body style="font-family: sans-serif; background-color: #F8F9FA; padding: 30px;">
  <div style="max-width: 580px; margin: 0 auto; background: #fff; border: 1px solid #E2E8F0; border-radius: 16px; padding: 32px;">
    <h2 style="color: #1E293B;">Verify Your University Email - Ginder</h2>
    <p style="color: #475569;">Account: <strong>%EMAIL%</strong></p>
    <div style="margin: 24px 0;">
      <a href="%LINK%" style="background-color: #4F46E5; color: #fff; padding: 14px 28px; border-radius: 12px; text-decoration: none; font-weight: bold; display: inline-block;">Verify Email Now</a>
    </div>
    <p style="font-size: 12px; color: #64748B;">If the button does not work: <a href="%LINK%">%LINK%</a></p>
  </div>
</body>
</html>
''';

  static const String _fallbackForgotPasswordTemplate = '''
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><title>Reset Password</title></head>
<body style="font-family: sans-serif; background-color: #F8F9FA; padding: 30px;">
  <div style="max-width: 580px; margin: 0 auto; background: #fff; border: 1px solid #E2E8F0; border-radius: 16px; padding: 32px;">
    <h2 style="color: #1E293B;">Reset Your Ginder Password</h2>
    <p style="color: #475569;">Account: <strong>%EMAIL%</strong></p>
    <div style="margin: 24px 0;">
      <a href="%LINK%" style="background-color: #E11D48; color: #fff; padding: 14px 28px; border-radius: 12px; text-decoration: none; font-weight: bold; display: inline-block;">Reset Password Now</a>
    </div>
    <p style="font-size: 12px; color: #64748B;">If the button does not work: <a href="%LINK%">%LINK%</a></p>
  </div>
</body>
</html>
''';
}
