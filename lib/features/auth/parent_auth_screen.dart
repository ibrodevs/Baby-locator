import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_providers.dart';
import '../../core/theme/app_colors.dart';

class ParentAuthScreen extends StatelessWidget {
  const ParentAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.dividerLight),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: AppColors.textPrimaryLight),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: AppColors.primary, size: 40),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                t.iAmParent,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.parentAuthSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 15,
                ),
              ),

              const Spacer(),

              // Sign In button
              _ActionBtn(
                label: t.parentSignIn,
                color: AppColors.primary,
                textColor: Colors.white,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const _AuthForm(isRegister: false))),
              ),
              const SizedBox(height: 14),
              // Create account button
              _ActionBtn(
                label: t.parentCreateAccount,
                color: Colors.white,
                textColor: AppColors.primary,
                bordered: true,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const _AuthForm(isRegister: true))),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.bordered = false,
  });
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: bordered
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                )
              : null,
          child: Text(label,
              style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

class _AuthForm extends ConsumerStatefulWidget {
  const _AuthForm({required this.isRegister});
  final bool isRegister;
  @override
  ConsumerState<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<_AuthForm> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _busy = false;
  String? _err;

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      if (widget.isRegister) {
        await ref.read(sessionProvider.notifier).registerParent(
              username: _username.text.trim(),
              password: _password.text,
              displayName: _name.text.trim(),
            );
      } else {
        await ref.read(sessionProvider.notifier).login(
              username: _username.text.trim(),
              password: _password.text,
            );
      }
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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.isRegister ? t.createAccount : t.signIn),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isRegister)
                _Field(controller: _name, label: t.displayName),
              if (widget.isRegister) const SizedBox(height: 12),
              _Field(controller: _username, label: t.username),
              const SizedBox(height: 12),
              _Field(controller: _password, label: t.password, obscure: true),
              const SizedBox(height: 20),
              if (_err != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_err!,
                      style: const TextStyle(
                          color: AppColors.danger, fontSize: 13)),
                ),
              ElevatedButton(
                onPressed: _busy ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(widget.isRegister ? t.createAccount : t.signIn,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(
      {required this.controller, required this.label, this.obscure = false});
  final TextEditingController controller;
  final String label;
  final bool obscure;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.dividerLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.dividerLight),
        ),
      ),
    );
  }
}
