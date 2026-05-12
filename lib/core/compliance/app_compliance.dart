import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppCompliance {
  static const String appName = 'Family Security';
  static const String companyName = 'Quantum limited';
  static const String supportEmail = 'sattarzhanovdev@gmail.com';
  static const String privacyPolicyUrl =
      'https://baby-locator-web.vercel.app/privacy-policy.html';
  static const String accountDeletionUrl =
      'https://baby-locator-web.vercel.app/delete-account.html';
  static const String websiteUrl = 'https://baby-locator-web.vercel.app';

  static Uri get _supportMailUri => Uri(
        scheme: 'mailto',
        path: supportEmail,
        queryParameters: {
          'subject': '$appName support request',
        },
      );

  static Future<void> openPrivacyPolicy() => _openExternal(privacyPolicyUrl);

  static Future<void> openAccountDeletionPage() =>
      _openExternal(accountDeletionUrl);

  static Future<void> contactSupport() => launchUrl(_supportMailUri);

  static Future<void> openWebsite() => _openExternal(websiteUrl);

  static Future<void> _openExternal(String value) async {
    await launchUrl(
      Uri.parse(value),
      mode: LaunchMode.externalApplication,
    );
  }

  static Future<bool> confirmDeleteAccount(
    BuildContext context, {
    required bool cascadesChildren,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account'),
        content: Text(
          cascadesChildren
              ? 'This will permanently delete your account and all linked child profiles. This action cannot be undone.'
              : 'This will permanently delete your account and associated data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<void> showAboutSheet(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(appName),
        content: const Text(
          'Family Security helps families stay connected with live location, safe zones, alerts, child device status, and parental safety tools.\n\n'
          'Developer: Quantum limited\n'
          'Privacy policy and account deletion options are available in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
