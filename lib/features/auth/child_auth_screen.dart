import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_providers.dart';
import '../../core/theme/app_colors.dart';

/// Kid-friendly sign-in screen — blue palette with playful rounded shapes.
class ChildAuthScreen extends StatelessWidget {
  const ChildAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              // Back button — soft rounded
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Fun stacked circles — kid touch
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primarySoft,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.navy],
                        ),
                      ),
                      child: const Icon(Icons.child_care_rounded,
                          size: 44, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                t.childAuthTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                t.childAuthSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 36),

              // Login form
              const Expanded(child: _ChildLoginForm()),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildLoginForm extends ConsumerStatefulWidget {
  const _ChildLoginForm();

  @override
  ConsumerState<_ChildLoginForm> createState() => _ChildLoginFormState();
}

class _ChildLoginFormState extends ConsumerState<_ChildLoginForm> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _err;

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      await ref.read(sessionProvider.notifier).login(
            username: _username.text.trim(),
            password: _password.text,
          );
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Username field — rounded kid style
          _KidField(
            controller: _username,
            label: t.username,
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 14),
          // Password field
          _KidField(
            controller: _password,
            label: t.password,
            icon: Icons.lock_rounded,
            obscure: true,
          ),
          const SizedBox(height: 20),
          if (_err != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.dangerSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_err!,
                    style: const TextStyle(
                        color: AppColors.danger, fontSize: 13)),
              ),
            ),
          // Sign in button — big rounded playful
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
            elevation: 0,
            child: InkWell(
              onTap: _busy ? null : _submit,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 56,
                alignment: Alignment.center,
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.login_rounded,
                              color: Colors.white, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            t.childSignIn,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KidField extends StatelessWidget {
  const _KidField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textSecondaryLight,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 42, minHeight: 0),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.dividerLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.dividerLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
