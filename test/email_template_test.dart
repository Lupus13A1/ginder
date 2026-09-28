import 'package:flutter_test/flutter_test.dart';
import 'package:ginder/services/email_template_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmailTemplateService', () {
    test('renders verification email template with replacements', () async {
      const email = 's6401012345678@email.kmutnb.ac.th';
      const actionLink =
          'https://ginder.kmutnb.ac.th/__/auth/action?mode=verifyEmail&oobCode=XYZ123';

      final html = await EmailTemplateService.getVerificationEmailHtml(
        email: email,
        actionLink: actionLink,
      );

      expect(html.contains(email), isTrue);
      expect(html.contains(actionLink), isTrue);
      expect(html.contains('GINDER'), isTrue);
      expect(html.contains('%EMAIL%'), isFalse);
      expect(html.contains('%LINK%'), isFalse);
    });

    test('renders password reset email template with replacements', () async {
      const email = 's6401012345678@email.kmutnb.ac.th';
      const actionLink =
          'https://ginder.kmutnb.ac.th/__/auth/action?mode=resetPassword&oobCode=XYZ456';

      final html = await EmailTemplateService.getPasswordResetEmailHtml(
        email: email,
        actionLink: actionLink,
      );

      expect(html.contains(email), isTrue);
      expect(html.contains(actionLink), isTrue);
      expect(html.contains('GINDER'), isTrue);
      expect(html.contains('%EMAIL%'), isFalse);
      expect(html.contains('%LINK%'), isFalse);
    });
  });
}
